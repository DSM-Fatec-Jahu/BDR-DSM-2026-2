<!--
GABARITO — não faz parte do fluxo principal do tópico e fica fora do `nav` do
mkdocs.yml de propósito. É acessível só pelo link no final de
Topico_10_Triggers.md.
-->

# Gabarito — Tópico 10 — Triggers (Gatilhos)

**Disciplina:** Banco de Dados — Relacional (IBD015)
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br
**Fatec Jahu — 2º Semestre/2026**

> ⚠️ Este gabarito é para conferência **depois** de você tentar resolver os checkpoints
> e os Exercícios de Fixação por conta própria no [Tópico 10](Topico_10_Triggers.md).
> Resolver antes de tentar reduz o benefício de treinar a recuperação ativa do
> conteúdo.

---

## Checkpoint 1 — Auditoria: carteira digital {: #checkpoint-1 }

**Resposta:**

```sql
CREATE TABLE historico_saldos (
    id_historico    BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    conta_id        BIGINT UNSIGNED  NOT NULL,
    saldo_anterior  DECIMAL(12, 2)   NOT NULL,
    saldo_novo      DECIMAL(12, 2)   NOT NULL,
    diferenca       DECIMAL(12, 2)   NOT NULL,
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_historico_saldo  PRIMARY KEY (id_historico),
    CONSTRAINT fk_historico_conta  FOREIGN KEY (conta_id)
                                   REFERENCES contas (id_conta)
                                   ON DELETE RESTRICT
                                   ON UPDATE CASCADE
);

DELIMITER $$
CREATE TRIGGER trg_contas_registrar_saldo
AFTER UPDATE ON contas
FOR EACH ROW
BEGIN
    IF NOT (OLD.saldo <=> NEW.saldo) THEN
        INSERT INTO historico_saldos (conta_id, saldo_anterior, saldo_novo, diferenca)
        VALUES (OLD.id_conta, OLD.saldo, NEW.saldo, NEW.saldo - OLD.saldo);
    END IF;
END$$
DELIMITER ;

-- Teste
UPDATE contas SET saldo = saldo + 50 WHERE id_conta = 1;          -- gera 1 linha (diferença +50)
UPDATE contas SET titular = 'Ana Lima' WHERE id_conta = 1;        -- não gera: o saldo não mudou
```

O gatilho é `AFTER UPDATE` porque o histórico deve registrar apenas mudanças que de fato
foram gravadas. O `IF` filtra os `UPDATE`s que mexem em outras colunas; o operador
`<=>` torna a comparação segura mesmo se o saldo pudesse ser `NULL`. Usar `OLD` e `NEW` ao
mesmo tempo é possível somente em `UPDATE`.

---

## Checkpoint 2 — BEFORE INSERT: monitoramento de energia solar {: #checkpoint-2 }

**Resposta:**

```sql
DELIMITER $$
CREATE TRIGGER trg_leituras_inversores_antes_inserir
BEFORE INSERT ON leituras_inversores
FOR EACH ROW
BEGIN
    IF NEW.kwh_gerado < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Geração (kWh) não pode ser negativa';
    END IF;

    IF NEW.registrado_em IS NULL THEN
        SET NEW.registrado_em = NOW();
    END IF;
END$$
DELIMITER ;

-- Testes
INSERT INTO leituras_inversores (inversor_id, kwh_gerado) VALUES (1, 12.5);                              -- data preenchida pelo gatilho
INSERT INTO leituras_inversores (inversor_id, kwh_gerado, registrado_em) VALUES (1, 9, '2026-10-01 10:00:00');  -- mantém a data informada
INSERT INTO leituras_inversores (inversor_id, kwh_gerado) VALUES (1, -3);                                -- ERROR 1644: Geração (kWh) não pode ser negativa
```

Os dois requisitos exigem `BEFORE`: o primeiro **recusa** antes de gravar e o segundo
**altera `NEW`**, o que o `AFTER` não permite. Observação: para a coluna `registrado_em`
ser omitida no `INSERT` e ainda chegar ao gatilho como `NULL`, ela precisa aceitar `NULL`
(sem `NOT NULL` e sem `DEFAULT` próprio). Se a única necessidade fosse "preencher a data
quando faltar", `DEFAULT CURRENT_TIMESTAMP` na coluna seria mais simples — o gatilho se
justifica aqui por combinar as duas regras.

---

## Checkpoint 3 — Contadores derivados: plataforma de criadores {: #checkpoint-3 }

**Resposta:**

```sql
DELIMITER $$
CREATE TRIGGER trg_curtidas_apos_inserir
AFTER INSERT ON curtidas
FOR EACH ROW
BEGIN
    UPDATE videos
    SET    total_curtidas = total_curtidas + 1
    WHERE  id_video = NEW.video_id;
END$$

CREATE TRIGGER trg_curtidas_apos_excluir
AFTER DELETE ON curtidas
FOR EACH ROW
BEGIN
    UPDATE videos
    SET    total_curtidas = total_curtidas - 1
    WHERE  id_video = OLD.video_id
      AND  total_curtidas > 0;           -- nunca deixa o contador ficar negativo
END$$
DELIMITER ;
```

O gatilho altera `videos`, **outra** tabela (diferente de `curtidas`, que disparou o
gatilho) — por isso é permitido. Se o contador fosse `UNSIGNED` e chegasse a 0, o `-1`
geraria erro; o `AND total_curtidas > 0` evita isso.

**E com `ON DELETE CASCADE`?** Quando um vídeo é excluído, as curtidas dele são apagadas
em cascata pelo InnoDB, e as ações em cascata **não disparam gatilhos** — então
`trg_curtidas_apos_excluir` não roda para elas. Neste caso específico não há dano, porque o
contador que ficaria desatualizado está na própria linha do vídeo, que também está
sendo apagada. O problema surgiria se o contador vivesse em **outra** tabela que
continuasse existindo (por exemplo, `criadores.total_curtidas_recebidas`): ele permaneceria
com o valor antigo, e a inconsistência só seria percebida depois. É exatamente o tipo de
cuidado a ter com dados derivados mantidos por gatilho.

---

## Checkpoint 4 — BEFORE UPDATE como trava: campeonato de e-sports {: #checkpoint-4 }

**Resposta:**

```sql
DELIMITER $$
CREATE TRIGGER trg_partidas_campeonato_antes_atualizar
BEFORE UPDATE ON partidas_campeonato
FOR EACH ROW
BEGIN
    IF OLD.status = 'finalizada' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Partida finalizada não pode ser alterada';
    END IF;

    IF OLD.status = 'em_andamento' AND NEW.status = 'agendada' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Partida em andamento não pode voltar para agendada';
    END IF;
END$$
DELIMITER ;

-- Quatro testes
UPDATE partidas_campeonato SET status = 'em_andamento' WHERE id_partida = 1;                     -- passa (agendada → em_andamento)
UPDATE partidas_campeonato SET status = 'agendada'     WHERE id_partida = 1;                     -- bloqueado: não pode voltar
UPDATE partidas_campeonato SET status = 'finalizada', placar_a = 2, placar_b = 1 WHERE id_partida = 1;   -- passa
UPDATE partidas_campeonato SET placar_a = 9            WHERE id_partida = 1;                     -- bloqueado: partida finalizada
```

A regra (a) usa só `OLD` (o estado atual) — qualquer coluna da partida finalizada fica
congelada. A regra (b) compara `OLD.status` com `NEW.status`, o padrão para
representar **transições de estado** permitidas ou proibidas.

---

## Checkpoint 5 — BEFORE + AFTER juntos: venda de ingressos {: #checkpoint-5 }

**Resposta:**

```sql
DELIMITER $$
CREATE TRIGGER trg_vendas_ingressos_antes_inserir
BEFORE INSERT ON vendas_ingressos
FOR EACH ROW
BEGIN
    DECLARE v_disponiveis INT;

    SELECT ingressos_disponiveis
    INTO   v_disponiveis
    FROM   eventos
    WHERE  id_evento = NEW.evento_id;

    IF v_disponiveis IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Evento inexistente';
    ELSEIF NEW.quantidade > v_disponiveis THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ingressos insuficientes para a quantidade pedida';
    END IF;
END$$

CREATE TRIGGER trg_vendas_ingressos_apos_inserir
AFTER INSERT ON vendas_ingressos
FOR EACH ROW
BEGIN
    UPDATE eventos
    SET    ingressos_disponiveis = ingressos_disponiveis - NEW.quantidade
    WHERE  id_evento = NEW.evento_id;
END$$
DELIMITER ;
```

O `BEFORE` valida e produz uma **mensagem clara** antes de qualquer gravação; o `AFTER`
executa o efeito colateral (baixar o saldo de ingressos) somente quando a venda foi aceita.

**Se o `BEFORE` não existisse:** a venda continuaria sendo barrada pela rede de segurança
do próprio schema. O `AFTER INSERT` tentaria deixar `ingressos_disponiveis` abaixo de zero e
o `CHECK (ingressos_disponiveis >= 0)` de `eventos` rejeitaria o `UPDATE`; como o `UPDATE`
faz parte da instrução que disparou o gatilho, o InnoDB desfaz também o `INSERT` da venda.
Na prática (num teste com tipos `INT` e `INT UNSIGNED` misturados) o erro vem como
`1690 BIGINT UNSIGNED value is out of range`, por causa da subtração com um operando
`UNSIGNED` — mas o efeito é o mesmo: nenhuma venda registrada e o estoque intacto.
Mensagem pior, proteção igual. Isso ilustra o princípio do Tópico 08: validações
declarativas (`CHECK`) são a **última linha de defesa**; o gatilho `BEFORE` melhora a
experiência de quem recebe o erro. (A corrida entre dois compradores simultâneos é
tratada com transações e travas — Tópico 11.)

---

## Exercícios de Fixação (Seção 7)

### Exercício 1 — `log_status_pedidos`

```sql
CREATE TABLE log_status_pedidos (
    id_log           BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    pedido_id        BIGINT UNSIGNED  NOT NULL,
    status_anterior  VARCHAR(20)      NOT NULL,
    status_novo      VARCHAR(20)      NOT NULL,
    criado_em        DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                               ON UPDATE CURRENT_TIMESTAMP,
    deletado_em      DATETIME             NULL,

    CONSTRAINT pk_log_status_pedido  PRIMARY KEY (id_log),
    CONSTRAINT fk_log_status_pedido  FOREIGN KEY (pedido_id)
                                     REFERENCES pedidos (id_pedido)
                                     ON DELETE CASCADE
                                     ON UPDATE CASCADE
);

DELIMITER $$
CREATE TRIGGER trg_pedidos_logar_status
AFTER UPDATE ON pedidos
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO log_status_pedidos (pedido_id, status_anterior, status_novo)
        VALUES (OLD.id_pedido, OLD.status, NEW.status);
    END IF;
END$$
DELIMITER ;

UPDATE pedidos SET status = 'confirmado' WHERE id_pedido = 12;
UPDATE pedidos SET status = 'enviado'    WHERE id_pedido = 12;
-- log: 12 pendente → confirmado · 12 confirmado → enviado
```

O `ON DELETE CASCADE` na FK do log é uma escolha: o histórico acompanha o pedido. Seria
igualmente defensável usar `RESTRICT` se o histórico deve sobreviver a qualquer custo.

### Exercício 2 — Trava de status

```sql
DELIMITER $$
CREATE TRIGGER trg_pedidos_validar_status
BEFORE UPDATE ON pedidos
FOR EACH ROW
BEGIN
    IF OLD.status IN ('entregue', 'cancelado') AND NEW.status <> OLD.status THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Pedido entregue ou cancelado não pode mudar de status';
    END IF;
END$$
DELIMITER ;

UPDATE pedidos SET status = 'pendente' WHERE id_pedido = 2;   -- ERROR 1644 (pedido 2 está entregue)
UPDATE pedidos SET status = 'pendente' WHERE id_pedido = 3;   -- ERROR 1644 (pedido 3 também está entregue)
UPDATE pedidos SET observacoes = 'frágil' WHERE id_pedido = 12;   -- ok: o status não muda
```

A condição `NEW.status <> OLD.status` permite alterar **outras colunas** de um pedido
finalizado (como `observacoes`), bloqueando apenas a mudança de status. Este gatilho
(`BEFORE UPDATE`) convive sem problema com o do Exercício 1 (`AFTER UPDATE`) na mesma
tabela: um valida antes da gravação e o outro registra depois; e, se a validação falhar, o
log nem chega a ser escrito.

### Exercício 3 — Auditoria de reajuste

```sql
TRUNCATE TABLE auditoria_precos;

UPDATE produtos SET preco = ROUND(preco * 1.10, 2) WHERE categoria_id = 2 AND ativo = 1;

SELECT COUNT(*) FROM auditoria_precos;      -- 4 (os 4 produtos ativos da categoria 2)

SELECT p.nome, a.preco_antigo, a.preco_novo
FROM   auditoria_precos a
INNER JOIN produtos p ON p.id_produto = a.produto_id
ORDER BY a.id_auditoria;
```

Foram **4** linhas, uma por produto reajustado — o gatilho roda por linha. O mesmo
resultado vem de chamar a procedure `sp_reajustar_precos_categoria(2, 10)`: o gatilho não
liga para *quem* altera o preço (procedure, `UPDATE` manual ou aplicação), e é isso que o
torna uma boa ferramenta de auditoria. (`TRUNCATE` aqui é só para limpar o histórico do
exercício; lembre que ele não dispara nenhum gatilho de `DELETE`.)

### Exercício 4 — `SHOW TRIGGERS`, `DROP` e `TRUNCATE`

```sql
SHOW TRIGGERS;

SELECT trigger_name, event_manipulation, action_timing, event_object_table
FROM   information_schema.triggers
WHERE  trigger_schema = 'loja_virtual';

DROP TRIGGER IF EXISTS trg_pedidos_bloquear_exclusao;
```

O `TRUNCATE TABLE` não dispara o gatilho `AFTER DELETE` porque, no MariaDB/InnoDB, ele não
remove linha a linha: descarta e recria a tabela (por isso também reinicia o
`AUTO_INCREMENT` e não é revertido por `ROLLBACK`, como visto no Tópico 04). Como nenhuma
linha é "excluída" individualmente, não há evento `DELETE` para disparar o gatilho. Quem
precisa que a auditoria registre a limpeza total deve usar `DELETE FROM tabela` — ou
proibir o `TRUNCATE` por permissão (Tópico 12).

### Exercício 5 — Baixa de estoque: gatilho ou procedure?

Como **gatilho**, "ao inserir um item, baixar o estoque" garante que **nenhum** caminho de
escrita (procedure, `INSERT` manual, outro sistema) esqueça de baixar — a regra vale
sempre. Como **procedure**, a regra fica explícita, testável e ordenada junto com as
demais etapas do pedido (validar estoque, criar pedido, criar itens, baixar estoque,
numa transação com tratamento de erro), mas só vale para quem a chama.

Para o `loja_virtual`, a defesa mais coerente com o que foi construído é a **procedure**
(`sp_registrar_pedido`), porque ela precisa **validar** o estoque *antes* de gravar e
devolver mensagens claras, orquestrar a transação inteira e já baixa o estoque. Acrescentar
um gatilho que também baixa o estoque faria a regra existir em **dois** lugares e o estoque
seria baixado em dobro. Se a escolha fosse o gatilho, a procedure precisaria **deixar de**
baixar o estoque. Qualquer que seja a opção, o princípio é o mesmo: **um dono por regra**.

---

⬅️ [Voltar ao Tópico 10 — Triggers](./Topico_10_Triggers.md)

---

*Fatec Jahu · IBD015 · Prof. Ronan Adriel Zenatti · 2026*
