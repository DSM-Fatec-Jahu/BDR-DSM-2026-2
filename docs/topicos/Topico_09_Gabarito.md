<!--
GABARITO — não faz parte do fluxo principal do tópico e fica fora do `nav` do
mkdocs.yml de propósito. É acessível só pelo link no final de
Topico_09_Stored_Procedures.md.
-->

# Gabarito — Tópico 09 — Stored Procedures

**Disciplina:** Banco de Dados — Relacional (IBD015)
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br
**Fatec Jahu — 2º Semestre/2026**

> ⚠️ Este gabarito é para conferência **depois** de você tentar resolver os checkpoints
> e os Exercícios de Fixação por conta própria no [Tópico 09](Topico_09_Stored_Procedures.md).
> Resolver antes de tentar reduz o benefício de treinar a recuperação ativa do
> conteúdo.

---

## Checkpoint 1 — Procedure simples: clínica veterinária digital {: #checkpoint-1 }

**Resposta:**

```sql
DROP PROCEDURE IF EXISTS sp_agenda_do_veterinario;

DELIMITER $$
CREATE PROCEDURE sp_agenda_do_veterinario(
    IN p_veterinario_id  BIGINT UNSIGNED,
    IN p_data            DATE
)
BEGIN
    SELECT id_consulta,
           pet_id,
           TIME(data_hora)  AS horario,
           status
    FROM   consultas_vet
    WHERE  veterinario_id = p_veterinario_id
      AND  DATE(data_hora) = p_data
      AND  status <> 'cancelada'
    ORDER BY data_hora;
END$$
DELIMITER ;

CALL sp_agenda_do_veterinario(5, '2026-11-03');
```

O `DELIMITER` evita que o cliente corte o `CREATE PROCEDURE` no primeiro `;`. Os nomes dos
parâmetros levam o prefixo `p_` para não colidir com as colunas `veterinario_id` e
`data_hora`. `DATE(data_hora) = p_data` compara só a parte da data (a coluna é
`DATETIME`); o `ORDER BY data_hora` mantém a ordem do dia. (Em tabelas grandes, o filtro
`DATE(data_hora) = ...` impede o uso de índice em `data_hora` — a alternativa é
`data_hora >= p_data AND data_hora < p_data + INTERVAL 1 DAY`, como na Seção 5 do Tópico 08.)

---

## Checkpoint 2 — Parâmetro OUT: carteira digital {: #checkpoint-2 }

**Resposta:**

```sql
DROP PROCEDURE IF EXISTS sp_saldo_conta;

DELIMITER $$
CREATE PROCEDURE sp_saldo_conta(
    IN  p_conta_id  BIGINT UNSIGNED,
    OUT p_saldo     DECIMAL(12, 2)
)
BEGIN
    SELECT COALESCE(SUM(CASE WHEN tipo = 'credito' THEN valor ELSE -valor END), 0)
    INTO   p_saldo
    FROM   movimentacoes
    WHERE  conta_id = p_conta_id;
END$$
DELIMITER ;

CALL sp_saldo_conta(1, @saldo);
SELECT @saldo AS saldo_da_conta;
```

O `CASE` dentro do `SUM` transforma débitos em valores negativos, e o `COALESCE(..., 0)`
cobre a conta sem lançamentos — nesse caso o `SUM` devolveria `NULL` (Tópico 06). O
`SELECT ... INTO p_saldo` grava o resultado no parâmetro `OUT`, que o chamador lê pela
variável de sessão `@saldo`. Uma conta com créditos de 1.000,00 e 100,00 e um débito de
250,50 devolve 849,50.

---

## Checkpoint 3 — IF/CASE com validação: ranking de e-sports {: #checkpoint-3 }

**Resposta:**

```sql
DROP PROCEDURE IF EXISTS sp_definir_tier;

DELIMITER $$
CREATE PROCEDURE sp_definir_tier(
    IN  p_pontos  INT,
    OUT p_tier    VARCHAR(20)
)
BEGIN
    IF p_pontos < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pontuação não pode ser negativa';
    END IF;

    SET p_tier = CASE
        WHEN p_pontos < 1000 THEN 'Bronze'
        WHEN p_pontos < 2000 THEN 'Prata'
        WHEN p_pontos < 3000 THEN 'Ouro'
        ELSE                      'Diamante'
    END;
END$$
DELIMITER ;

CALL sp_definir_tier(2999, @tier);  SELECT @tier;     -- Ouro
CALL sp_definir_tier(3000, @tier);  SELECT @tier;     -- Diamante
CALL sp_definir_tier(-5,   @tier);                    -- ERROR 1644 (45000): Pontuação não pode ser negativa
```

A mesma ideia poderia ser escrita com `IF/ELSEIF`. O `CASE` de expressão (em vez da
instrução `CASE ... END CASE`) tem a vantagem de caber numa única atribuição `SET`. As
condições são testadas de cima para baixo, então basta o limite superior de cada faixa. O
`SIGNAL` vem **antes** do `CASE` para que uma pontuação inválida nunca receba uma
classificação.

---

## Checkpoint 4 — Cursor e alternativa em conjunto: manutenção de drones {: #checkpoint-4 }

**Resposta (com cursor):**

```sql
DROP PROCEDURE IF EXISTS sp_abrir_manutencoes;

DELIMITER $$
CREATE PROCEDURE sp_abrir_manutencoes(
    IN  p_limite_horas  INT UNSIGNED,
    OUT p_abertas       INT
)
BEGIN
    DECLARE v_drone_id  BIGINT UNSIGNED;
    DECLARE v_fim       TINYINT DEFAULT 0;

    DECLARE cur_drones CURSOR FOR
        SELECT id_drone
        FROM   drones
        WHERE  horas_voo >= p_limite_horas
          AND  em_manutencao = 0;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_fim = 1;

    SET p_abertas = 0;
    OPEN cur_drones;

    laco: LOOP
        FETCH cur_drones INTO v_drone_id;
        IF v_fim = 1 THEN
            LEAVE laco;
        END IF;

        INSERT INTO manutencoes (drone_id, motivo)
        VALUES (v_drone_id, 'Revisão preventiva por horas de voo');

        UPDATE drones SET em_manutencao = 1 WHERE id_drone = v_drone_id;

        SET p_abertas = p_abertas + 1;
    END LOOP laco;

    CLOSE cur_drones;
END$$
DELIMITER ;
```

**Resposta (em conjunto, sem cursor):**

```sql
DROP PROCEDURE IF EXISTS sp_abrir_manutencoes_em_conjunto;

DELIMITER $$
CREATE PROCEDURE sp_abrir_manutencoes_em_conjunto(
    IN  p_limite_horas  INT UNSIGNED,
    OUT p_abertas       INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    INSERT INTO manutencoes (drone_id, motivo)
    SELECT id_drone, 'Revisão preventiva por horas de voo'
    FROM   drones
    WHERE  horas_voo >= p_limite_horas
      AND  em_manutencao = 0;

    SET p_abertas = ROW_COUNT();        -- linhas inseridas no INSERT ... SELECT

    UPDATE drones
    SET    em_manutencao = 1
    WHERE  horas_voo >= p_limite_horas
      AND  em_manutencao = 0;

    COMMIT;
END$$
DELIMITER ;
```

**Em produção, a versão em conjunto.** São dois comandos que processam todas as linhas de
uma vez, em vez de milhares de idas e vindas do laço. Além disso, a versão com cursor deste
enunciado nem é atômica (se falhar no meio, parte dos drones já foi marcada) — a em conjunto
já nasce dentro de uma transação. O cursor só se justificaria se cada drone exigisse uma
lógica que não coubesse em SQL de conjunto (por exemplo, chamar outra procedure por drone).

Atenção à ordem na versão em conjunto: o `INSERT` precisa vir **antes** do `UPDATE`, porque
o filtro `em_manutencao = 0` de ambos usa o estado anterior.

---

## Checkpoint 5 — Procedure transacional: aluguel de bicicletas elétricas {: #checkpoint-5 }

**Resposta:**

```sql
DROP PROCEDURE IF EXISTS sp_iniciar_aluguel;

DELIMITER $$
CREATE PROCEDURE sp_iniciar_aluguel(
    IN  p_usuario_id    BIGINT UNSIGNED,
    IN  p_bicicleta_id  BIGINT UNSIGNED,
    OUT p_aluguel_id    BIGINT UNSIGNED
)
BEGIN
    DECLARE v_bateria     TINYINT UNSIGNED;
    DECLARE v_disponivel  TINYINT(1);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT nivel_bateria, disponivel
    INTO   v_bateria, v_disponivel
    FROM   bicicletas
    WHERE  id_bicicleta = p_bicicleta_id
    FOR UPDATE;

    IF v_disponivel IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bicicleta inexistente';
    ELSEIF v_disponivel = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bicicleta indisponível';
    ELSEIF v_bateria < 20 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bateria abaixo do mínimo para aluguel (20%)';
    END IF;

    INSERT INTO alugueis (usuario_id, bicicleta_id)
    VALUES (p_usuario_id, p_bicicleta_id);

    SET p_aluguel_id = LAST_INSERT_ID();

    UPDATE bicicletas SET disponivel = 0 WHERE id_bicicleta = p_bicicleta_id;

    COMMIT;
END$$
DELIMITER ;

CALL sp_iniciar_aluguel(1, 1, @aluguel);     -- ok
CALL sp_iniciar_aluguel(1, 1, @aluguel);     -- ERROR 1644: Bicicleta indisponível (acabou de ser alugada)
```

Pontos centrais: o `SELECT ... FOR UPDATE` **trava a linha da bicicleta** até o fim da
transação, de modo que duas pessoas tentando alugar a mesma bicicleta ao mesmo tempo não
passem ambas pela verificação (assunto do Tópico 11). Quando `v_disponivel` é `NULL`, a
bicicleta não existe (o `SELECT INTO` não encontrou linha e deixou as variáveis nulas). O
`EXIT HANDLER FOR SQLEXCEPTION` captura tanto os `SIGNAL`s de validação quanto erros de
banco (como FK de usuário inexistente), desfaz tudo e relança o erro original.

---

## Exercícios de Fixação (Seção 6)

### Exercício 1 — `sp_listar_produtos_categoria`

```sql
DROP PROCEDURE IF EXISTS sp_listar_produtos_categoria;

DELIMITER $$
CREATE PROCEDURE sp_listar_produtos_categoria(IN p_categoria_id BIGINT UNSIGNED)
BEGIN
    SELECT id_produto, nome, preco, estoque
    FROM   produtos
    WHERE  categoria_id = p_categoria_id
      AND  ativo = 1
    ORDER BY preco DESC;
END$$
DELIMITER ;

CALL sp_listar_produtos_categoria(2);
```

### Exercício 2 — `sp_total_vendido_periodo`

```sql
DROP PROCEDURE IF EXISTS sp_total_vendido_periodo;

DELIMITER $$
CREATE PROCEDURE sp_total_vendido_periodo(
    IN  p_inicio  DATE,
    IN  p_fim     DATE,
    OUT p_total   DECIMAL(12, 2)
)
BEGIN
    SELECT COALESCE(SUM(valor_total), 0)
    INTO   p_total
    FROM   pedidos
    WHERE  status <> 'cancelado'
      AND  data_pedido >= p_inicio
      AND  data_pedido <  DATE_ADD(p_fim, INTERVAL 1 DAY);
END$$
DELIMITER ;

CALL sp_total_vendido_periodo('2026-04-01', '2026-06-30', @total);
SELECT @total;      -- 10500.92
```

Como `data_pedido` é `DATETIME`, um `BETWEEN p_inicio AND p_fim` pararia à meia-noite do
último dia (`2026-06-30 00:00:00`) e perderia os pedidos feitos naquele dia. A forma
robusta é "maior ou igual ao início" **e** "menor que o dia seguinte ao fim".

### Exercício 3 — `sp_reajustar_estoque_minimo`

```sql
DROP PROCEDURE IF EXISTS sp_reajustar_estoque_minimo;

DELIMITER $$
CREATE PROCEDURE sp_reajustar_estoque_minimo(
    IN p_categoria_id  BIGINT UNSIGNED,
    IN p_quantidade    INT
)
BEGIN
    IF p_quantidade < 1 OR p_quantidade > 1000 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quantidade deve estar entre 1 e 1000';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM categorias WHERE id_categoria = p_categoria_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Categoria inexistente';
    END IF;

    UPDATE produtos
    SET    estoque = estoque + p_quantidade
    WHERE  categoria_id = p_categoria_id
      AND  ativo = 1;

    SELECT ROW_COUNT() AS produtos_afetados;
END$$
DELIMITER ;
```

`p_quantidade` é `INT` (e não `INT UNSIGNED`) de propósito: assim um valor negativo chega
à procedure e é recusado pela **nossa** validação, com mensagem clara, em vez de estourar
um erro genérico de conversão de tipo.

### Exercício 4 — `sp_classificar_produto`

```sql
DROP PROCEDURE IF EXISTS sp_classificar_produto;

DELIMITER $$
CREATE PROCEDURE sp_classificar_produto(
    IN  p_produto_id  BIGINT UNSIGNED,
    OUT p_faixa       VARCHAR(20)
)
BEGIN
    DECLARE v_preco DECIMAL(10, 2);

    SELECT preco INTO v_preco FROM produtos WHERE id_produto = p_produto_id;

    IF v_preco IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Produto inexistente';
    ELSEIF v_preco < 200 THEN
        SET p_faixa = 'econômico';
    ELSEIF v_preco < 1000 THEN
        SET p_faixa = 'intermediário';
    ELSE
        SET p_faixa = 'premium';
    END IF;
END$$
DELIMITER ;
```

Como `produtos.preco` é `NOT NULL`, um `v_preco` nulo só pode significar que o `SELECT INTO`
não encontrou linha — ou seja, o produto não existe. A ordem das condições (`NULL`
primeiro) é importante: comparar `NULL < 200` seria desconhecido e cairia no `ELSE`.

### Exercício 5 — Sem o handler

Sem o `EXIT HANDLER ... ROLLBACK; RESIGNAL;`, o erro no `INSERT` em `itens_pedidos`
interromperia a procedure **antes do `COMMIT`, mas sem desfazer nada**. Nesse momento a
transação ainda estaria aberta, com uma alteração pendente feita antes do erro: o registro
novo em `pedidos` (um pedido "fantasma", sem itens; o `UPDATE` do estoque vem depois do
`INSERT` de itens e nem chegaria a executar). Essa alteração seria visível para a conexão
que chamou, manteria travas (inclusive a do `FOR UPDATE` no produto, que bloquearia outros
compradores) e só desapareceria se o chamador lembrasse de dar `ROLLBACK` (ou se a
conexão fosse encerrada, o que também faz o InnoDB desfazer a transação aberta). Se, em
vez disso, a aplicação desse `COMMIT` achando que "deu tudo certo", persistiria um pedido
sem itens — exatamente o estado inconsistente que a atomicidade deve impedir.

---

⬅️ [Voltar ao Tópico 09 — Stored Procedures](./Topico_09_Stored_Procedures.md)

---

*Fatec Jahu · IBD015 · Prof. Ronan Adriel Zenatti · 2026*
