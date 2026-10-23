<!--
GABARITO — não faz parte do fluxo principal do tópico e fica fora do `nav` do
mkdocs.yml de propósito. É acessível só pelo link no final de
Topico_07_Joins_Subconsultas_Visoes.md.
-->

# Gabarito — Tópico 07 — Junções (JOINs), Subconsultas e Visões

**Disciplina:** Banco de Dados — Relacional (IBD015)
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br
**Fatec Jahu — 2º Semestre/2026**

> ⚠️ Este gabarito é para conferência **depois** de você tentar resolver os checkpoints
> e os Exercícios de Fixação por conta própria no [Tópico 07](Topico_07_Joins_Subconsultas_Visoes.md).
> Resolver antes de tentar reduz o benefício de treinar a recuperação ativa do
> conteúdo.

---

## Checkpoint 1 — INNER JOIN com 3 tabelas: micromobilidade elétrica {: #checkpoint-1 }

**Resposta:**

```sql
SELECT u.nome         AS usuario,
       p.modelo       AS modelo,
       v.distancia_km,
       v.valor
FROM   viagens v
INNER JOIN usuarios  u ON u.id_usuario  = v.usuario_id
INNER JOIN patinetes p ON p.id_patinete = v.patinete_id
WHERE  v.distancia_km > 5
ORDER BY v.valor DESC;
```

A tabela `viagens` é o centro: ela guarda as duas FKs (`usuario_id`, `patinete_id`, Regra 6),
e cada `INNER JOIN` liga uma delas à PK correspondente (`id_usuario`, `id_patinete`,
Regra 5). O filtro de distância é uma condição sobre a linha da viagem e fica no
`WHERE`. Viagens de um usuário ou patinete que não existissem (impossível com FK
válida) seriam descartadas pelo `INNER JOIN`.

---

## Checkpoint 2 — LEFT JOIN e anti-join: plataforma de criadores {: #checkpoint-2 }

**Resposta (a):**

```sql
SELECT c.nome_canal,
       COUNT(v.id_video)                AS total_videos,
       COALESCE(SUM(v.visualizacoes), 0) AS total_visualizacoes
FROM   criadores c
LEFT JOIN videos v ON v.criador_id = c.id_criador
GROUP BY c.id_criador, c.nome_canal
ORDER BY total_visualizacoes DESC;
```

`criadores` fica à esquerda porque **todos** os canais precisam aparecer. O `COUNT(v.id_video)`
(e não `COUNT(*)`) dá 0 para o canal sem vídeos, e o `COALESCE` converte o `NULL` que o
`SUM` devolve nesse caso em 0.

**Resposta (b):**

```sql
SELECT c.nome_canal
FROM   criadores c
LEFT JOIN videos v ON v.criador_id = c.id_criador
WHERE  v.id_video IS NULL;
```

O `LEFT JOIN` deixa `NULL` em todas as colunas de `videos` para canais sem vídeo; testar a
PK `v.id_video IS NULL` isola exatamente esses canais. A versão equivalente com
`NOT EXISTS (SELECT 1 FROM videos v WHERE v.criador_id = c.id_criador)` também é correta.

---

## Checkpoint 3 — Self join: gig economy {: #checkpoint-3 }

**Resposta (a):**

```sql
SELECT e.nome                                  AS entregador,
       COALESCE(s.nome, '(sem supervisor)')    AS supervisor
FROM   entregadores e
LEFT JOIN entregadores s ON s.id_entregador = e.supervisor_id
ORDER BY e.nome;
```

A mesma tabela aparece duas vezes: `e` é o entregador e `s` é o supervisor, ligados por
`s.id_entregador = e.supervisor_id`. O `LEFT JOIN` é essencial — quem não tem supervisor
(`supervisor_id` nulo) sumiria com um `INNER JOIN`.

**Resposta (b):**

```sql
SELECT s.nome                       AS supervisor,
       COUNT(e.id_entregador)       AS equipe
FROM   entregadores s
LEFT JOIN entregadores e ON e.supervisor_id = s.id_entregador
GROUP BY s.id_entregador, s.nome
ORDER BY equipe DESC;
```

Agora os papéis se invertem: `s` (à esquerda) é quem pode supervisionar e `e` são os
subordinados diretos. Quem não supervisiona ninguém fica com `COUNT(e.id_entregador) = 0`
graças ao `LEFT JOIN`.

---

## Checkpoint 4 — Subconsultas: cloud gaming {: #checkpoint-4 }

**Resposta (a):**

```sql
SELECT j.titulo
FROM   jogos j
WHERE  NOT EXISTS (SELECT 1
                   FROM   sessoes_jogo s
                   WHERE  s.jogo_id = j.id_jogo);
```

**Resposta (b):**

```sql
SELECT j.titulo,
       ROUND(AVG(s.duracao_min), 1) AS duracao_media
FROM   jogos j
INNER JOIN sessoes_jogo s ON s.jogo_id = j.id_jogo
GROUP BY j.id_jogo, j.titulo
HAVING AVG(s.duracao_min) > (SELECT AVG(duracao_min) FROM sessoes_jogo);
```

Em (a), a subconsulta é correlacionada (`s.jogo_id = j.id_jogo`) e o `NOT EXISTS` mantém só
os jogos para os quais ela não encontra nenhuma sessão. Em (b), a média por jogo é
comparada, no `HAVING`, com a média geral — calculada pela subconsulta escalar.

---

## Checkpoint 5 — Tabela derivada / WITH: entrega por drone {: #checkpoint-5 }

**Resposta:**

```sql
WITH por_regiao AS (
    SELECT regiao,
           COUNT(*)         AS entregas,
           AVG(duracao_min) AS duracao_media
    FROM   entregas_drone
    GROUP BY regiao
)
SELECT regiao,
       entregas,
       ROUND(duracao_media, 1) AS duracao_media
FROM   por_regiao
WHERE  duracao_media > (SELECT AVG(duracao_min) FROM entregas_drone)
ORDER BY duracao_media DESC;
```

Comentário pedido: a duração média **por região** só existe depois do `GROUP BY`; por isso
o filtro "maior que a média geral" não pode ficar no `WHERE` da própria agregação (ele
roda antes do agrupamento e não enxerga o `AVG` do grupo). Ao nomear a agregação num
`WITH`, ela vira uma "tabela" e o filtro passa a ser um `WHERE` comum sobre a coluna
`duracao_media`. A alternativa equivalente é um `HAVING AVG(duracao_min) > (SELECT ...)`
na própria agregação, ou uma tabela derivada no `FROM`.

---

## Checkpoint 6 — VIEW: carteira digital {: #checkpoint-6 }

**Resposta (a):**

```sql
CREATE VIEW vw_contas_suporte AS
SELECT c.id_conta,
       t.nome  AS titular,
       c.saldo
FROM   contas c
INNER JOIN titulares t ON t.id_titular = c.titular_id
WHERE  c.ativa = 1
  AND  c.deletado_em IS NULL;
```

A visão projeta apenas as três colunas autorizadas — `cpf` e `limite_credito` simplesmente
não existem para quem consulta `vw_contas_suporte` — e aplica o filtro de contas ativas e
não excluídas (soft delete, Regra 9). Dando ao time de suporte apenas `SELECT` na visão
(Tópico 12) e nenhum acesso às tabelas, os dados sensíveis ficam protegidos.

**Resposta (b):** o `UPDATE` **funciona** no MariaDB, porque a visão é simples (um `JOIN`,
sem agregação, e o `saldo` pertence a uma única tabela-base, `contas`). Mas isso **não é
desejável**: ela daria ao suporte poder de alterar saldos. Visões de acesso restrito
devem ser somente leitura — o que se garante não concedendo `UPDATE`/`INSERT`/`DELETE` ao
usuário sobre a visão. Alterações de saldo devem passar por rotinas controladas
(transações e *stored procedures*, Tópicos 09 e 11).

---

## Exercícios de Fixação (Seção 6)

### Exercício 1 — Pedidos entregues com cliente e cidade

```sql
SELECT ped.id_pedido,
       pes.nome        AS cliente,
       e.cidade,
       ped.valor_total
FROM   pedidos ped
INNER JOIN pessoas   pes ON pes.id_pessoa   = ped.cliente_id
INNER JOIN enderecos e   ON e.id_endereco   = ped.endereco_id
WHERE  ped.status = 'entregue'
ORDER BY ped.id_pedido;
-- 8 linhas
```

### Exercício 2 — Produtos nunca vendidos (anti-join)

```sql
SELECT p.id_produto, p.nome
FROM   produtos p
LEFT JOIN itens_pedidos i ON i.produto_id = p.id_produto
WHERE  i.pedido_id IS NULL;
-- 7 (Headset HyperX Cloud) e 10 (Introdução a Sistemas de Bancos de Dados — Date)
```

### Exercício 3 — Todas as categorias, com quantidade e preço médio

```sql
SELECT c.nome                                  AS categoria,
       COUNT(p.id_produto)                     AS qtd_produtos,
       COALESCE(ROUND(AVG(p.preco), 2), 0)     AS preco_medio
FROM   categorias c
LEFT JOIN produtos p ON p.categoria_id = c.id_categoria
GROUP BY c.id_categoria, c.nome
ORDER BY c.nome;
-- Games aparece com 0 produtos e preço médio 0
```

### Exercício 4 — Clientes acima da média de gastos

```sql
SELECT pes.nome,
       SUM(ped.valor_total) AS total_gasto
FROM   pedidos ped
INNER JOIN pessoas pes ON pes.id_pessoa = ped.cliente_id
WHERE  ped.status <> 'cancelado'
GROUP BY pes.id_pessoa, pes.nome
HAVING SUM(ped.valor_total) > (
           SELECT AVG(t.total)
           FROM  (SELECT SUM(valor_total) AS total
                  FROM   pedidos
                  WHERE  status <> 'cancelado'
                  GROUP BY cliente_id) AS t
       )
ORDER BY total_gasto DESC;
```

A média precisa ser a média **dos totais por cliente**, não a média de `valor_total` dos
pedidos — por isso a subconsulta interna agrupa por cliente e a externa tira a média
desses totais (uma tabela derivada no `FROM`). A versão com `WITH`, mostrada na Seção 4.5
do tópico, é equivalente e mais fácil de ler.

### Exercício 5 — Clientes que compraram 'Livros'

```sql
-- Com JOIN + DISTINCT
SELECT DISTINCT pes.nome
FROM   pessoas pes
INNER JOIN pedidos       ped ON ped.cliente_id = pes.id_pessoa
INNER JOIN itens_pedidos i   ON i.pedido_id    = ped.id_pedido
INNER JOIN produtos      pr  ON pr.id_produto  = i.produto_id
INNER JOIN categorias    c   ON c.id_categoria = pr.categoria_id
WHERE  c.nome = 'Livros'
ORDER BY pes.nome;

-- Com EXISTS
SELECT pes.nome
FROM   pessoas pes
WHERE  EXISTS (SELECT 1
               FROM   pedidos ped
               INNER JOIN itens_pedidos i  ON i.pedido_id   = ped.id_pedido
               INNER JOIN produtos      pr ON pr.id_produto = i.produto_id
               WHERE  ped.cliente_id = pes.id_pessoa
                 AND  pr.categoria_id = (SELECT id_categoria FROM categorias WHERE nome = 'Livros'))
ORDER BY pes.nome;
-- Ana Lima, Beatriz Costa, Helena Souza
```

**Comparação:** o `JOIN` multiplica linhas (um cliente que comprou três livros gera três
linhas), por isso precisa do `DISTINCT` para eliminar a repetição. O `EXISTS` testa
apenas "existe pelo menos um?" e já devolve cada pessoa uma única vez, sem precisar de
`DISTINCT` — mais direto quando nenhuma coluna das tabelas de dentro é necessária.

### Exercício 6 — Visão de vendas por produto

```sql
CREATE OR REPLACE VIEW vw_vendas_por_produto AS
SELECT pr.id_produto,
       pr.nome                       AS produto,
       SUM(i.quantidade)             AS unidades_vendidas,
       ROUND(SUM(i.quantidade * i.preco_unitario * (1 - i.desconto / 100)), 2) AS receita
FROM   produtos pr
INNER JOIN itens_pedidos i   ON i.produto_id = pr.id_produto
INNER JOIN pedidos       ped ON ped.id_pedido = i.pedido_id
WHERE  ped.status <> 'cancelado'
GROUP BY pr.id_produto, pr.nome;

SELECT * FROM vw_vendas_por_produto ORDER BY receita DESC LIMIT 3;
-- Notebook Lenovo IdeaPad (10324.71) · Smartphone Samsung A55 (7596.00) · Monitor LG UltraWide 29" (2598.00)
```

### Exercício 7 — Pedidos por atendente

```sql
SELECT fun.nome            AS atendente,
       COUNT(*)            AS pedidos_atendidos,
       SUM(ped.valor_total) AS valor_total
FROM   pedidos ped
INNER JOIN pessoas fun ON fun.id_pessoa = ped.funcionario_id
GROUP BY fun.id_pessoa, fun.nome
ORDER BY pedidos_atendidos DESC, atendente;
-- Diego Rocha (3), Prof. Ronan (3), Marina Duarte (2)
```

O `INNER JOIN` aqui é intencional: ele já descarta os pedidos de autoatendimento
(`funcionario_id` nulo), que era justamente o pedido do enunciado.

---

⬅️ [Voltar ao Tópico 07 — JOINs, Subconsultas e Visões](./Topico_07_Joins_Subconsultas_Visoes.md)

---

*Fatec Jahu · IBD015 · Prof. Ronan Adriel Zenatti · 2026*
