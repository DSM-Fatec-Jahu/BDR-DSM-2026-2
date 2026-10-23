<!--
GABARITO — não faz parte do fluxo principal do tópico e fica fora do `nav` do
mkdocs.yml de propósito. É acessível só pelo link no final de
Topico_08_Integridade_Restricoes.md.
-->

# Gabarito — Tópico 08 — Integridade Referencial e Restrições

**Disciplina:** Banco de Dados — Relacional (IBD015)
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br
**Fatec Jahu — 2º Semestre/2026**

> ⚠️ Este gabarito é para conferência **depois** de você tentar resolver os checkpoints
> e os Exercícios de Fixação por conta própria no [Tópico 08](Topico_08_Integridade_Restricoes.md).
> Resolver antes de tentar reduz o benefício de treinar a recuperação ativa do
> conteúdo.

---

## Checkpoint 1 — Classificando violações: rede de eletropostos {: #checkpoint-1 }

| Situação | Tipo de integridade | Restrição que deveria barrar |
|---|---|---|
| **(a)** duas recargas com o mesmo `id_recarga` | **Entidade** | `PRIMARY KEY (id_recarga)` — erro `1062` |
| **(b)** recarga com `kwh_consumidos = -12` | **Domínio** | `CHECK (kwh_consumidos >= 0)` (ou coluna `UNSIGNED`) — erro `4025`/`1264` |
| **(c)** recarga ligada a um `carregador_id` inexistente | **Referencial** | `FOREIGN KEY (carregador_id) REFERENCES carregadores (id_carregador)` — erro `1452` |
| **(d)** carregador sem `potencia_kw` | **Domínio** | `NOT NULL` na coluna — erro `1048`/`1364` |
| **(e)** duas recargas em andamento no mesmo carregador | **De negócio** | Nenhuma restrição declarativa resolve: o `CHECK` só enxerga a linha atual, e o MariaDB não tem índice único parcial. Exige um *trigger* ou *stored procedure* que consulte as recargas ativas do carregador antes de gravar (Tópicos 09 e 10), idealmente dentro de uma transação (Tópico 11) |
| **(f)** dois eletropostos com o mesmo `codigo_registro` | **Entidade** | `UNIQUE (codigo_registro)` — erro `1062` |

O ponto central do exercício é perceber que **(e)** é diferente das demais: nem toda regra
cabe numa constraint declarativa. Quando a regra depende de **outras linhas** ou do
**momento da operação**, ela é uma regra de negócio e vive em código dentro do banco.

---

## Checkpoint 2 — Domínio com CHECK: assinaturas de um app de fitness {: #checkpoint-2 }

**Resposta:**

```sql
CREATE TABLE assinaturas (
    id_assinatura        BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    usuario_id           BIGINT UNSIGNED  NOT NULL,
    plano                VARCHAR(20)      NOT NULL,
    valor_mensal         DECIMAL(8, 2)    NOT NULL,
    desconto_percentual  DECIMAL(5, 2)    NOT NULL DEFAULT 0.00,
    inicio               DATE             NOT NULL,
    fim                  DATE                 NULL,
    criado_em            DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em          DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                   ON UPDATE CURRENT_TIMESTAMP,
    deletado_em          DATETIME             NULL,

    CONSTRAINT pk_assinatura         PRIMARY KEY (id_assinatura),
    CONSTRAINT fk_assinatura_usuario FOREIGN KEY (usuario_id)
                                     REFERENCES usuarios (id_usuario)
                                     ON DELETE RESTRICT
                                     ON UPDATE CASCADE,
    CONSTRAINT ck_assinatura_plano   CHECK (plano IN ('basico', 'padrao', 'premium')),
    CONSTRAINT ck_assinatura_valor   CHECK (valor_mensal > 0),
    CONSTRAINT ck_assinatura_desc    CHECK (desconto_percentual BETWEEN 0 AND 100),
    CONSTRAINT ck_assinatura_fim     CHECK (fim IS NULL OR fim >= inicio)
);
```

**Pontos de atenção:** a PK segue a Regra 5 (`id_assinatura`) e a FK, a Regra 6
(`usuario_id`); o dinheiro é `DECIMAL` (Regra 8); os campos de log vêm da Regra 9; e o
`CHECK` de `fim` trata explicitamente o `NULL` (assinatura ativa) — sem o `fim IS NULL OR`,
a regra seria satisfeita por `NULL` apenas por acaso, e a intenção não estaria
documentada.

**Os cinco `INSERT` inválidos** (supondo que o `usuario_id = 1` existe):

```sql
-- 1) plano fora da lista                       → ERROR 4025: ck_assinatura_plano
INSERT INTO assinaturas (usuario_id, plano, valor_mensal, inicio)
VALUES (1, 'gold', 39.90, '2026-01-01');

-- 2) valor zero                                → ERROR 4025: ck_assinatura_valor
INSERT INTO assinaturas (usuario_id, plano, valor_mensal, inicio)
VALUES (1, 'basico', 0, '2026-01-01');

-- 3) desconto acima de 100                     → ERROR 4025: ck_assinatura_desc
INSERT INTO assinaturas (usuario_id, plano, valor_mensal, desconto_percentual, inicio)
VALUES (1, 'basico', 10, 120, '2026-01-01');

-- 4) fim anterior ao início                    → ERROR 4025: ck_assinatura_fim
INSERT INTO assinaturas (usuario_id, plano, valor_mensal, inicio, fim)
VALUES (1, 'basico', 10, '2026-02-01', '2026-01-01');

-- 5) usuário inexistente                       → ERROR 1452: fk_assinatura_usuario
INSERT INTO assinaturas (usuario_id, plano, valor_mensal, inicio)
VALUES (999, 'premium', 39.90, '2026-01-01');
```

---

## Checkpoint 3 — Escolhendo ações referenciais: coworking {: #checkpoint-3 }

**Resposta:**

```sql
-- salas → unidades
CONSTRAINT fk_sala_unidade FOREIGN KEY (unidade_id)
    REFERENCES unidades (id_unidade)
    ON DELETE RESTRICT ON UPDATE CASCADE,

-- reservas → salas, membros e aprovador
CONSTRAINT fk_reserva_sala FOREIGN KEY (sala_id)
    REFERENCES salas (id_sala)
    ON DELETE RESTRICT ON UPDATE CASCADE,
CONSTRAINT fk_reserva_membro FOREIGN KEY (membro_id)
    REFERENCES membros (id_membro)
    ON DELETE RESTRICT ON UPDATE CASCADE,
CONSTRAINT fk_reserva_aprovador FOREIGN KEY (aprovador_id)
    REFERENCES membros (id_membro)
    ON DELETE SET NULL ON UPDATE CASCADE,
CONSTRAINT ck_reserva_periodo CHECK (fim > inicio),

-- convidados_reserva → reservas
CONSTRAINT fk_convidado_reserva FOREIGN KEY (reserva_id)
    REFERENCES reservas (id_reserva)
    ON DELETE CASCADE ON UPDATE CASCADE
```

**Justificativas (a pergunta "o filho faz sentido sem o pai?"):**

- `salas → unidades` (**RESTRICT**): uma sala não existe sem a unidade onde fica, mas apagar uma unidade
  inteira não deve levar as salas (e todo o histórico de reservas) junto por acidente — o
  banco exige que a pessoa desative/transfira as salas antes.
- `reservas → salas` e `reservas → membros` (**RESTRICT**): a reserva é **histórico**
  (financeiro e operacional); não pode perder a sala ou o membro a que se refere.
- `reservas → aprovador` (**SET NULL**): o aprovador é opcional e uma reserva continua
  válida se quem a aprovou deixar de existir. Note o nome `aprovador_id`, pelo papel (Regra 7):
  são duas FKs para `membros` com papéis diferentes (`membro_id` e `aprovador_id`).
  `fk_reserva_aprovador` exige que `aprovador_id` seja `NULL`-able.
- `convidados_reserva → reservas` (**CASCADE**): a lista de convidados é parte da
  reserva; sem ela não tem significado, e apagar a reserva deve apagar seus convidados.

O `ON UPDATE CASCADE` em todas é inofensivo (PKs `AUTO_INCREMENT` raramente mudam) e evita
um erro caso uma PK precise ser corrigida.

---

## Checkpoint 4 — Limpando dados antes de criar restrições: marketplace de freelancers {: #checkpoint-4 }

**Resposta (a) — contratos órfãos:**

```sql
SELECT c.id_contrato, c.freelancer_id
FROM   contratos c
LEFT JOIN freelancers f ON f.id_freelancer = c.freelancer_id
WHERE  f.id_freelancer IS NULL;
```

**Resposta (b) — e-mails duplicados:**

```sql
SELECT email,
       COUNT(*)                 AS ocorrencias,
       GROUP_CONCAT(id_freelancer) AS ids
FROM   freelancers
GROUP BY email
HAVING COUNT(*) > 1;
```

**Resposta (c) — as restrições (só depois de corrigir/remover os registros acima):**

```sql
ALTER TABLE contratos
    ADD CONSTRAINT fk_contrato_freelancer FOREIGN KEY (freelancer_id)
        REFERENCES freelancers (id_freelancer)
        ON DELETE RESTRICT
        ON UPDATE CASCADE;

ALTER TABLE freelancers
    ADD CONSTRAINT uq_freelancer_email UNIQUE (email);
```

Se os `ALTER` fossem executados antes da limpeza, o primeiro falharia com `1452` e o
segundo com `1062` — sem indicar quais linhas são o problema; daí a importância das
consultas (a) e (b). **O que fazer com os registros encontrados é decisão de negócio:**
contratos órfãos podem ser corrigidos (alguém digitou o id errado), arquivados em uma
tabela de quarentena ou apagados; e-mails duplicados podem ser pessoas repetidas (a
unificar) ou erros de digitação.

---

## Checkpoint 5 — Decidindo índices: carona compartilhada {: #checkpoint-5 }

**Resposta:**

```sql
-- (1) histórico do passageiro, mais recentes primeiro
CREATE INDEX idx_corridas_passageiro_solicitada
    ON corridas (passageiro_id, solicitada_em);

-- (2) corridas do motorista em um período
CREATE INDEX idx_corridas_motorista_solicitada
    ON corridas (motorista_id, solicitada_em);
```

- **(1)** O índice composto `(passageiro_id, solicitada_em)` resolve o filtro por passageiro
  **e** já entrega as linhas na ordem de `solicitada_em`, eliminando a etapa extra de
  ordenação (`Using filesort` no `EXPLAIN`). Um índice apenas em `passageiro_id` filtraria,
  mas ainda exigiria ordenar o resultado. Como o `passageiro_id` é FK e o índice composto
  começa por ele, esse mesmo índice já atende a FK — não é preciso manter um índice só
  de `passageiro_id`.
- **(2)** `(motorista_id, solicitada_em)`: igualdade em `motorista_id` primeiro, depois a
  faixa (`>=`) em `solicitada_em` — a ordem do índice segue "igualdade antes de intervalo".
- **(3) Sem índice.** `status` tem só 4 valores com distribuição parecida: cada valor
  representa cerca de 25% da tabela. O índice não filtra o suficiente, o otimizador o
  ignoraria e leria a tabela toda de qualquer forma — o custo nas escritas não compensa.
- **(4) Sem índice `B-Tree` comum.** Busca livre de texto em `observacao` (`LIKE '%palavra%'`)
  não usa um índice comum, porque o padrão começa com `%`. O recurso certo é um índice
  `FULLTEXT` (e uma coluna `TEXT` pesada), assunto de otimização avançada — fora do
  escopo deste tópico.

---

## Exercícios de Fixação (Seção 6)

### Exercício 1 — Dois erros, dois tipos de integridade

```sql
INSERT INTO pedidos (cliente_id) VALUES (999);
-- ERROR 1452: Cannot add or update a child row ... CONSTRAINT `fk_pedido_cliente`
-- Integridade REFERENCIAL (lado do filho): o cliente 999 não existe em pessoas.

DELETE FROM pessoas WHERE id_pessoa = 1;
-- ERROR 1451: Cannot delete or update a parent row ... CONSTRAINT `fk_pedido_cliente`
-- Integridade REFERENCIAL (lado do pai): a Ana tem pedidos e a FK é ON DELETE RESTRICT.
```

(A Ana também tem endereços, que usariam `CASCADE`; é o `RESTRICT` de `pedidos.cliente_id`
que impede a exclusão.)

### Exercício 2 — `avaliacoes_produtos`

```sql
CREATE TABLE avaliacoes_produtos (
    id_avaliacao  BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    produto_id    BIGINT UNSIGNED   NOT NULL,
    pessoa_id     BIGINT UNSIGNED   NOT NULL,
    nota          TINYINT UNSIGNED  NOT NULL,
    comentario    TEXT                  NULL,
    criado_em     DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP
                                             ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME              NULL,

    CONSTRAINT pk_avaliacao                  PRIMARY KEY (id_avaliacao),
    CONSTRAINT uq_avaliacao_produto_pessoa   UNIQUE (produto_id, pessoa_id),
    CONSTRAINT fk_avaliacao_produto          FOREIGN KEY (produto_id)
                                             REFERENCES produtos (id_produto)
                                             ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_avaliacao_pessoa           FOREIGN KEY (pessoa_id)
                                             REFERENCES pessoas (id_pessoa)
                                             ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_avaliacao_nota             CHECK (nota BETWEEN 1 AND 5)
);

-- Testes (um de cada tipo de violação):
INSERT INTO avaliacoes_produtos (produto_id, pessoa_id, nota) VALUES (1, 1, 5);   -- ok
INSERT INTO avaliacoes_produtos (produto_id, pessoa_id, nota) VALUES (1, 1, 3);   -- 1062 (entidade: já avaliou)
INSERT INTO avaliacoes_produtos (produto_id, pessoa_id, nota) VALUES (1, 3, 6);   -- 4025 (domínio: nota > 5)
INSERT INTO avaliacoes_produtos (produto_id, pessoa_id, nota) VALUES (99, 3, 3);  -- 1452 (referencial: produto inexistente)
DELETE FROM pessoas WHERE id_pessoa = 1;                                          -- 1451 (referencial: quem avaliou)
```

Observação: o `UNIQUE (produto_id, pessoa_id)` tem `produto_id` como primeira coluna, então
o InnoDB o reaproveita como índice da FK `fk_avaliacao_produto` — só `pessoa_id` precisa de
um índice automático separado (confira com `SHOW INDEX FROM avaliacoes_produtos`).

### Exercício 3 — Prevendo o efeito das ações referenciais

```sql
BEGIN;  DELETE FROM pedidos  WHERE id_pedido  = 8;  ROLLBACK;
-- (a) OK: itens do pedido 8 são apagados junto (fk_item_pedido = CASCADE).

BEGIN;  DELETE FROM produtos WHERE id_produto = 1;  ROLLBACK;
-- (b) ERROR 1451: o produto 1 já foi vendido (fk_item_produto = RESTRICT).

BEGIN;  DELETE FROM produtos WHERE id_produto = 7;  ROLLBACK;
-- (c) OK: o produto 7 (Headset) nunca foi vendido, então nenhum filho o referencia.

BEGIN;  DELETE FROM enderecos WHERE id_endereco = 1;
        SELECT id_pedido, endereco_id FROM pedidos WHERE id_pedido IN (1, 12);
ROLLBACK;
-- (d) OK: os pedidos 1 e 12 continuam existindo, com endereco_id = NULL (fk_pedido_endereco = SET NULL).
```

### Exercício 4 — Categorias sem produtos

```sql
-- 1) Descobrir (anti-join)
SELECT c.id_categoria, c.nome
FROM   categorias c
LEFT JOIN produtos p ON p.categoria_id = c.id_categoria
WHERE  p.id_produto IS NULL;
-- → 5 · Games

-- 2) Apagar somente essa
DELETE FROM categorias WHERE id_categoria = 5;      -- OK

-- 3) Tentar apagar 'Eletrônicos'
DELETE FROM categorias WHERE nome = 'Eletrônicos';
-- ERROR 1451: tem produtos e a FK é RESTRICT.
```

### Exercício 5 — Índice composto para "pedidos do cliente, mais recentes primeiro"

```sql
CREATE INDEX idx_pedidos_cliente_data ON pedidos (cliente_id, data_pedido);
SHOW INDEX FROM pedidos;
DROP INDEX idx_pedidos_cliente_data ON pedidos;
```

A FK `fk_pedido_cliente` já indexa `cliente_id`, então a **filtragem** já é rápida. Mas o
índice dela guarda só `cliente_id`: depois de achar os pedidos do cliente, o banco ainda
precisa **ordenar** por `data_pedido`. O índice composto `(cliente_id, data_pedido)` entrega
os pedidos do cliente já na ordem de data — e, por começar por `cliente_id`, passa a servir
também de índice para a FK.

### Exercício 6 — Por que 1264 e não 4025?

A coluna `estoque` é `INT UNSIGNED`. O MariaDB valida o **tipo** antes de avaliar a
`CHECK`: o valor `-1` está fora da faixa do tipo (0 a 4.294.967.295), então a escrita é
recusada com `1264 Out of range value`. A `ck_estoque` nem chega a ser avaliada. As duas
camadas protegem a mesma regra — o tipo é a mais barata, e o `CHECK` fica como
documentação explícita (e como proteção caso a coluna deixe de ser `UNSIGNED`).

---

⬅️ [Voltar ao Tópico 08 — Integridade Referencial e Restrições](./Topico_08_Integridade_Restricoes.md)

---

*Fatec Jahu · IBD015 · Prof. Ronan Adriel Zenatti · 2026*
