<!--
GABARITO — não faz parte do fluxo principal do tópico e fica fora do `nav` do
mkdocs.yml de propósito. É acessível só pelo link no final de
Topico_11_Functions_Transacoes.md.
-->

# Gabarito — Tópico 11 — Functions (UDF) e Transações

**Disciplina:** Banco de Dados — Relacional (IBD015)
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br
**Fatec Jahu — 2º Semestre/2026**

> ⚠️ Este gabarito é para conferência **depois** de você tentar resolver os checkpoints
> e os Exercícios de Fixação por conta própria no [Tópico 11](Topico_11_Functions_Transacoes.md).
> Resolver antes de tentar reduz o benefício de treinar a recuperação ativa do
> conteúdo.

---

## Checkpoint 1 — Função escalar com validação: entrega por drone {: #checkpoint-1 }

**Resposta:**

```sql
DROP FUNCTION IF EXISTS fn_frete_drone;

DELIMITER $$
CREATE FUNCTION fn_frete_drone(
    p_peso_kg       DECIMAL(5, 2),
    p_distancia_km  DECIMAL(6, 2)
)
RETURNS DECIMAL(8, 2)
DETERMINISTIC
BEGIN
    IF p_peso_kg <= 0 OR p_distancia_km <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Peso e distância devem ser positivos';
    END IF;

    IF p_peso_kg > 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Peso acima do limite de 5 kg do drone';
    END IF;

    RETURN ROUND(8.00 + 2.50 * p_distancia_km + 4.00 * p_peso_kg, 2);
END$$
DELIMITER ;

SELECT fn_frete_drone(1.5, 4) AS frete;      -- 8,00 + 2,50 × 4 + 4,00 × 1,5 = 24.00
```

**Característica:** `DETERMINISTIC`. A função é um cálculo puro: depende apenas dos
argumentos, não lê tabelas e não usa data/hora. Para os mesmos peso e distância, devolve
sempre o mesmo frete. (Se as tarifas ficassem em uma tabela consultada pela função, ela
passaria a ser `READS SQL DATA`, e não mais `DETERMINISTIC`.) O `SIGNAL` é permitido dentro
de funções, ao contrário de `COMMIT`/`ROLLBACK`.

---

## Checkpoint 2 — Função que consulta tabelas: programa de fidelidade {: #checkpoint-2 }

**Resposta:**

```sql
DROP FUNCTION IF EXISTS fn_pontos_fidelidade;

DELIMITER $$
CREATE FUNCTION fn_pontos_fidelidade(p_usuario_id BIGINT UNSIGNED)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(12, 2);

    SELECT COALESCE(SUM(valor), 0)
    INTO   v_total
    FROM   compras_app
    WHERE  usuario_id = p_usuario_id
      AND  status = 'paga';

    RETURN FLOOR(v_total / 10);
END$$
DELIMITER ;

SELECT u.usuario_id,
       fn_pontos_fidelidade(u.usuario_id) AS pontos
FROM  (SELECT DISTINCT usuario_id FROM compras_app) AS u;
```

**Característica:** `READS SQL DATA`, porque a função faz `SELECT` em uma tabela (não é
`DETERMINISTIC`: o mesmo `p_usuario_id` pode dar resultados diferentes depois que novas
compras forem inseridas). O `COALESCE(SUM(...), 0)` garante `0` pontos para quem não tem
compras pagas — sem ele, o `SUM` devolveria `NULL`. `FLOOR` arredonda para baixo (R$ 95 →
9 pontos; R$ 9 → 0). Com compras de R$ 95 e R$ 30 pagas e R$ 500 estornada, o usuário 1
tem `FLOOR(125 / 10) = 12` pontos.

---

## Checkpoint 3 — Transação ACID: transferência entre carteiras {: #checkpoint-3 }

**Resposta (a):**

```sql
START TRANSACTION;

UPDATE carteiras SET saldo = saldo - 200 WHERE id_carteira = 1;     -- debita a origem
UPDATE carteiras SET saldo = saldo + 200 WHERE id_carteira = 2;     -- credita o destino
INSERT INTO transferencias (origem_id, destino_id, valor) VALUES (1, 2, 200.00);

COMMIT;
```

**Resposta (b) — o que protege cada propriedade:**

| Propriedade | O que a protege neste exemplo |
|---|---|
| **A**tomicidade | Os três comandos formam uma unidade: se algum falhar e a transação sofrer `ROLLBACK`, o undo log devolve tudo ao estado inicial — nunca fica dinheiro "debitado e não creditado" |
| **C**onsistência | O `CHECK (saldo >= 0)` e as FKs de `transferencias` impedem estados inválidos (saldo negativo, carteira inexistente); a soma total do dinheiro permanece igual porque o débito e o crédito têm o mesmo valor |
| **I**solamento | Enquanto a transação não termina, outras sessões não enxergam a carteira 1 já debitada e a 2 ainda não creditada (o que daria "dinheiro sumido" momentaneamente); as travas de linha impedem duas transferências de mexerem no mesmo saldo ao mesmo tempo |
| **D**urabilidade | Depois do `COMMIT`, o redo log garante que a transferência sobrevive a uma queda de energia do servidor |

**Resposta (c):** se o débito violar o `CHECK` (saldo insuficiente), o comando
`UPDATE` falha com o erro `4025` e **só ele** é desfeito — a transação continua **aberta**
(`@@in_transaction = 1`). Se a aplicação seguisse em frente e desse `COMMIT`, nada teria
sido debitado, mas ela poderia (por falha de lógica) creditar o destino e registrar a
transferência. A aplicação precisa **capturar o erro e executar `ROLLBACK`**. É exatamente
o que uma *stored procedure* com `EXIT HANDLER FOR SQLEXCEPTION ... ROLLBACK; RESIGNAL`
faz automaticamente (veja a versão completa no Checkpoint 6).

---

## Checkpoint 4 — Prevendo o que cada sessão enxerga: estoque de vacinas {: #checkpoint-4 }

**Resposta (a) — o que A lê em t3:**

| Nível | A lê em t1 | A lê em t3 | Anomalia |
|---|:-:|:-:|---|
| `READ COMMITTED` | 300 | **200** | **Leitura não repetível**: a mesma linha mudou dentro da transação de A |
| `REPEATABLE READ` | 300 | **300** | Nenhuma — o snapshot de A foi congelado em t1 |

**Resposta (b):** o valor final é **190 nos dois níveis**. O `UPDATE ... SET doses_disponiveis
= doses_disponiveis - 10` de t4 não usa o snapshot: ele lê o valor **confirmado mais
recente** (200, depois do `COMMIT` de B) e subtrai 10. Isso confirma a regra do InnoDB: no
`REPEATABLE READ`, a visão congelada vale só para leituras comuns; **escritas operam sobre
os dados atuais**.

**Resposta (c):** se a aplicação lê 300 em t1 (ou em t3, no `REPEATABLE READ`), calcula
`300 - 10 = 290` e envia `UPDATE ... SET doses_disponiveis = 290`, o valor 290 **sobrescreve**
o resultado do `UPDATE` de B (que deixou 200). Final: 290 em vez de 190 — as 100 doses
retiradas por B reaparecem no estoque: é a **atualização perdida**. A correção é deixar o
banco calcular (`= doses_disponiveis - 10`) ou travar a linha na leitura
(`SELECT ... FOR UPDATE`), como na Seção 5.2.

---

## Checkpoint 5 — Controle otimista: leilão de itens de jogo {: #checkpoint-5 }

**Resposta:**

```sql
UPDATE leiloes
SET    lance_atual = 150.00,
       lider_id    = 2
WHERE  id_leilao   = 1
  AND  lance_atual < 150.00          -- (i) o lance precisa superar o atual
  AND  encerra_em  > NOW();          -- (ii) o leilão ainda está aberto

SELECT ROW_COUNT() AS lance_aceito;  -- 1 = aceito · 0 = recusado
```

**Como a aplicação descobre:** pelo número de linhas afetadas (`ROW_COUNT()` no SQL, ou o
"affected rows" retornado pelo driver). Se for **0**, o lance perdeu a corrida (alguém
cobriu antes) ou o leilão terminou; a aplicação avisa o jogador e mostra o novo lance
atual.

**Por que evita a atualização perdida sem `FOR UPDATE`:** a verificação ("o lance é maior
que o atual?") e a gravação acontecem **no mesmo comando**, e o InnoDB pega uma trava
exclusiva na linha do leilão para executá-lo. Se dois lances chegam juntos, um `UPDATE`
espera o outro; o segundo reavalia a condição `lance_atual < ...` com o valor **já
atualizado** pelo primeiro e, se não superar, não altera nada. Não há intervalo entre
"ler" e "gravar" em que outra transação possa se infiltrar — é o mesmo princípio de
`estoque = estoque - 1`.

---

## Checkpoint 6 — Deadlock em transferências cruzadas {: #checkpoint-6 }

**Resposta (a) — linha do tempo:**

| Tempo | Transação A (1 → 2) | Transação B (2 → 1) |
|---|---|---|
| t1 | `UPDATE ... id = 1` — **trava a carteira 1** | `UPDATE ... id = 2` — **trava a carteira 2** |
| t2 | `UPDATE ... id = 2` — **espera B** | |
| t3 | | `UPDATE ... id = 1` — **espera A** → ciclo: *deadlock* |

O InnoDB detecta o ciclo, escolhe uma das duas como vítima (desfaz e devolve o erro `1213`) e
a outra termina.

**Resposta (b) — transferir sempre travando as carteiras em ordem crescente de id:**

```sql
DROP PROCEDURE IF EXISTS sp_transferir;

DELIMITER $$
CREATE PROCEDURE sp_transferir(
    IN p_origem   BIGINT UNSIGNED,
    IN p_destino  BIGINT UNSIGNED,
    IN p_valor    DECIMAL(12, 2)
)
BEGIN
    DECLARE v_menor  BIGINT UNSIGNED DEFAULT LEAST(p_origem, p_destino);
    DECLARE v_maior  BIGINT UNSIGNED DEFAULT GREATEST(p_origem, p_destino);
    DECLARE v_saldo  DECIMAL(12, 2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_origem = p_destino THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Origem e destino devem ser diferentes';
    END IF;
    IF p_valor <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O valor deve ser positivo';
    END IF;

    START TRANSACTION;

    -- Sempre trava primeiro a carteira de MENOR id, depois a de maior id
    SELECT saldo INTO v_saldo FROM carteiras WHERE id_carteira = v_menor FOR UPDATE;
    SELECT saldo INTO v_saldo FROM carteiras WHERE id_carteira = v_maior FOR UPDATE;

    UPDATE carteiras SET saldo = saldo - p_valor WHERE id_carteira = p_origem;
    UPDATE carteiras SET saldo = saldo + p_valor WHERE id_carteira = p_destino;
    INSERT INTO transferencias (origem_id, destino_id, valor) VALUES (p_origem, p_destino, p_valor);

    COMMIT;
END$$
DELIMITER ;
```

Com a ordem fixa, A (1 → 2) e B (2 → 1) tentam travar **primeiro a carteira 1**: quem chegar
depois simplesmente espera, sem ciclo possível. Se o débito violar o `CHECK`, o handler faz
`ROLLBACK` e repassa o erro.

**Resposta (c):** como o `1213` pode ocorrer mesmo com boas práticas (outros caminhos de
acesso, índices, gatilhos), a aplicação deve tratá-lo como um erro **recuperável**: o
InnoDB já desfez a transação-vítima, então basta **repeti-la inteira** (normalmente com um
número máximo de tentativas e uma pequena espera aleatória) e só então devolver erro ao
usuário.

---

## Exercícios de Fixação (Seção 6)

### Exercício 1 — `fn_preco_com_desconto`

```sql
DROP FUNCTION IF EXISTS fn_preco_com_desconto;

DELIMITER $$
CREATE FUNCTION fn_preco_com_desconto(
    p_preco       DECIMAL(10, 2),
    p_percentual  DECIMAL(5, 2)
)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    IF p_percentual < 0 OR p_percentual > 100 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Percentual de desconto deve estar entre 0 e 100';
    END IF;

    RETURN ROUND(p_preco * (1 - p_percentual / 100), 2);
END$$
DELIMITER ;

SELECT nome, preco, fn_preco_com_desconto(preco, 15) AS preco_promocional
FROM   produtos
WHERE  categoria_id = 1 AND ativo = 1;
-- Notebook Lenovo IdeaPad 3499.90 → 2974.92 · Smartphone Samsung A55 1899.00 → 1614.15 · Monitor LG UltraWide 29" 1299.00 → 1104.15
```

### Exercício 2 — `fn_dias_desde_pedido`

```sql
DROP FUNCTION IF EXISTS fn_dias_desde_pedido;

DELIMITER $$
CREATE FUNCTION fn_dias_desde_pedido(p_pedido_id BIGINT UNSIGNED)
RETURNS INT
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_data DATETIME;

    SELECT data_pedido INTO v_data FROM pedidos WHERE id_pedido = p_pedido_id;

    RETURN DATEDIFF(CURDATE(), DATE(v_data));      -- NULL se o pedido não existir
END$$
DELIMITER ;

SELECT id_pedido, status, fn_dias_desde_pedido(id_pedido) AS dias
FROM   pedidos
WHERE  status IN ('pendente', 'confirmado')
  AND  fn_dias_desde_pedido(id_pedido) > 30;
```

Características: `NOT DETERMINISTIC` (depende de `CURDATE()`, o resultado muda de um dia para
o outro com a mesma entrada) **e** `READS SQL DATA` (consulta `pedidos`). Declará-la
`DETERMINISTIC` seria incorreto. Se o pedido não existe, o `SELECT INTO` não encontra
linha, `v_data` continua `NULL` e `DATEDIFF` devolve `NULL`.

(O resultado depende da data de execução — em 23/10/2026: pedidos 1, 11 e 12.)

### Exercício 3 — Reproduzindo a atualização perdida

Passo a passo com duas janelas (A e B), com o estoque do produto 3 em 50:

```sql
-- Janela A                                           -- Janela B
START TRANSACTION;
SELECT estoque INTO @e FROM produtos WHERE id_produto = 3;     -- A lê 50
                                                      START TRANSACTION;
                                                      SELECT estoque INTO @e FROM produtos WHERE id_produto = 3;   -- B lê 50
                                                      UPDATE produtos SET estoque = @e - 2 WHERE id_produto = 3;   -- 48
                                                      COMMIT;
UPDATE produtos SET estoque = @e - 1 WHERE id_produto = 3;     -- grava 49, sobrescrevendo a baixa de B
COMMIT;
SELECT estoque FROM produtos WHERE id_produto = 3;             -- 49 ❌ (o correto seria 47)
```

Repetindo com `SELECT estoque INTO @e FROM produtos WHERE id_produto = 3 FOR UPDATE;` nas duas
janelas: a janela B **fica esperando** na leitura (porque A já travou a linha) até A dar
`COMMIT`; só então lê o estoque atualizado (49) e grava 47. O resultado final é **47**. O custo
é a espera de B — esse é o ponto de troca entre consistência e concorrência.

### Exercício 4 — `SAVEPOINT` em movimentação de estoque

```sql
START TRANSACTION;

UPDATE produtos SET estoque = estoque - 5 WHERE id_produto = 3;     -- débito na origem
SAVEPOINT apos_debito;

UPDATE produtos SET estoque = estoque + 5 WHERE id_produto = 4;     -- crédito no destino

-- Se algo der errado com o crédito:
ROLLBACK TO SAVEPOINT apos_debito;      -- desfaz só o crédito; o débito continua pendente

-- Aqui a transação ainda está aberta. Decida:
COMMIT;      -- confirma só o débito  →  ERRO DE NEGÓCIO
-- ou
ROLLBACK;    -- desfaz tudo (correto)
```

O `ROLLBACK TO SAVEPOINT apos_debito` desfaz apenas o que veio depois dele (o crédito),
mantendo o débito. Mas, **neste caso**, ficar só com o débito significaria 5 unidades que
**sumiram** do estoque (saíram do produto 3 e não entraram no 4): estado inconsistente.
Como as duas operações só fazem sentido juntas, a decisão correta é `ROLLBACK` total. O
savepoint é útil quando existe uma parte **opcional** na transação (por exemplo, tentar
aplicar um cupom e seguir sem ele se falhar), não quando as partes são interdependentes.

### Exercício 5 — Escolha do nível de isolamento

- **(a) Relatório gerencial do mês:** `READ COMMITTED` ou `REPEATABLE READ`. Como o relatório
  roda várias consultas, o `REPEATABLE READ` dá uma visão única e coerente do instante em que
  começou (todas as consultas somam sobre os mesmos dados); o `READ COMMITTED` serviria se
  a coerência entre as consultas não fosse crítica e se quisesse evitar manter snapshots longos.
- **(b) Conciliação bancária:** `SERIALIZABLE` (ou `REPEATABLE READ` com `SELECT ... FOR UPDATE`
  nas linhas conciliadas). O saldo não pode ser calculado sobre dados que mudam durante o
  cálculo, e a correção vale mais que a concorrência.
- **(c) Contador de visualizações ao vivo:** `READ UNCOMMITTED` ou `READ COMMITTED` —
  é um valor aproximado e descartável; uma pequena defasagem não importa e a leitura nunca
  deve atrapalhar as escritas. (Na prática, `READ COMMITTED` é a escolha segura, pois leitura
  suja raramente compensa.)

---

⬅️ [Voltar ao Tópico 11 — Functions (UDF) e Transações](./Topico_11_Functions_Transacoes.md)

---

*Fatec Jahu · IBD015 · Prof. Ronan Adriel Zenatti · 2026*
