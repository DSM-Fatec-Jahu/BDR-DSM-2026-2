<!--
GABARITO — não faz parte do fluxo principal do tópico e fica fora do `nav` do
mkdocs.yml de propósito. É acessível só pelo link no final de
Topico_06_SQL_DQL_Agregacao.md.
-->

# Gabarito — Tópico 06 — SQL DQL: Consultas e Agregação

**Disciplina:** Banco de Dados — Relacional (IBD015)
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br
**Fatec Jahu — 2º Semestre/2026**

> ⚠️ Este gabarito é para conferência **depois** de você tentar resolver os checkpoints
> e os Exercícios de Fixação por conta própria no [Tópico 06](Topico_06_SQL_DQL_Agregacao.md).
> Resolver antes de tentar reduz o benefício de treinar a recuperação ativa do
> conteúdo.

---

## Checkpoint 1 — Filtros combinados: plataforma de streaming {: #checkpoint-1 }

**Resposta:**

```sql
SELECT nome,
       tipo,
       CASE
           WHEN nota_media >= 4.5 THEN 'Imperdível'
           ELSE                        'Bom'
       END AS destaque
FROM   titulos
WHERE  (tipo = 'filme' OR tipo = 'serie')
  AND  nota_media >= 4.0
  AND  classificacao NOT IN ('16', '18')
ORDER BY nota_media DESC;
```

O `(tipo = 'filme' OR tipo = 'serie')` poderia ser escrito também como
`tipo IN ('filme', 'serie')`, que dispensa os parênteses e é mais legível. O `CASE` cria
a coluna `destaque` apenas no resultado.

**E sem os parênteses?** Como o `AND` tem precedência sobre o `OR`, a condição
`tipo = 'filme' OR tipo = 'serie' AND nota_media >= 4.0 AND classificacao NOT IN ('16','18')`
seria lida como `tipo = 'filme' OR (tipo = 'serie' AND nota >= 4.0 AND classificação
liberada)`. Resultado: **todos** os filmes entrariam — inclusive os de nota baixa e os
de classificação 16 ou 18 —, quebrando justamente o filtro de perfil infantojuvenil.

---

## Checkpoint 2 — Agregação: energia solar residencial {: #checkpoint-2 }

**Resposta:**

```sql
SELECT COUNT(*)                 AS leituras,
       SUM(kwh_gerado)          AS total_gerado_kwh,
       ROUND(AVG(kwh_gerado), 2) AS media_gerada_kwh,
       MAX(kwh_gerado)          AS pico_kwh,
       COUNT(kwh_consumido)     AS leituras_com_consumo
FROM   geracao_diaria
WHERE  data_leitura BETWEEN '2026-09-01' AND '2026-09-30';
```

O `WHERE` define a população (somente setembro) **antes** da agregação. `COUNT(*)` conta
todas as leituras do mês; `COUNT(kwh_consumido)` conta só as que têm consumo informado —
as demais, com o medidor offline, são `NULL` e ficam de fora. Se a coluna `data_leitura`
fosse `DATETIME` (com hora), `BETWEEN ... '2026-09-30'` deixaria de fora o dia 30 depois
da meia-noite; nesse caso o filtro robusto é
`data_leitura >= '2026-09-01' AND data_leitura < '2026-10-01'`.

---

## Checkpoint 3 — GROUP BY: e-sports competitivo {: #checkpoint-3 }

**Resposta (a) — por mapa:**

```sql
SELECT mapa,
       COUNT(*)                  AS partidas,
       SUM(resultado = 'vitoria') AS vitorias,
       ROUND(AVG(abates), 1)     AS media_abates
FROM   partidas
GROUP BY mapa
ORDER BY vitorias DESC, mapa;
```

A expressão `resultado = 'vitoria'` vale 1 ou 0, então o `SUM` dela conta as vitórias.
Em um SGBD que não aceite isso, use `SUM(CASE WHEN resultado = 'vitoria' THEN 1 ELSE 0 END)`.
O `mapa` entra no `ORDER BY` como critério de desempate para a ordem ficar estável.

**Resposta (b) — por jogador e mapa:**

```sql
SELECT jogador_id,
       mapa,
       COUNT(*) AS partidas
FROM   partidas
GROUP BY jogador_id, mapa
ORDER BY jogador_id, mapa;
```

Com duas colunas no `GROUP BY`, cada **combinação** (jogador, mapa) forma um grupo. O
`ORDER BY jogador_id, mapa` mostra, para cada jogador, os mapas em ordem alfabética.

---

## Checkpoint 4 — HAVING: antifraude em fintech {: #checkpoint-4 }

**Resposta:**

```sql
SELECT conta_id,
       COUNT(*)   AS qtd_envios,
       SUM(valor) AS total_enviado
FROM   transacoes_pix
WHERE  tipo   = 'envio'                             -- WHERE: filtros sobre a LINHA
  AND  status = 'concluida'                         --        (cada transação, individualmente)
  AND  realizada_em >= NOW() - INTERVAL 30 DAY
GROUP BY conta_id
HAVING COUNT(*)   > 5                               -- HAVING: filtros sobre o GRUPO
   AND SUM(valor) > 10000                           --         (o resultado da agregação por conta)
ORDER BY total_enviado DESC;
```

**Por quê:** tipo, status e período dizem respeito a **cada transação** — dá para decidir
olhando só a linha, então vão no `WHERE`, antes do agrupamento (e ainda reduzem o
trabalho do `GROUP BY`). Já "mais de 5 envios" e "soma acima de R$ 10.000" só existem
depois que as transações de uma conta foram reunidas — são propriedades do **grupo**, e
por isso só podem ficar no `HAVING`.

---

## Checkpoint 5 — Agregação condicional: telemedicina {: #checkpoint-5 }

**Resposta:**

```sql
SELECT COALESCE(especialidade, 'TODAS')                              AS especialidade,
       COUNT(*)                                                      AS agendadas,
       SUM(status = 'realizada')                                     AS realizadas,
       ROUND(100 * SUM(status = 'nao_compareceu') / COUNT(*), 1)     AS pct_no_show,
       SUM(CASE WHEN status = 'realizada' THEN valor ELSE 0 END)     AS receita
FROM   consultas_telemedicina
GROUP BY especialidade WITH ROLLUP;
```

Cada indicador é uma agregação com condição embutida: `SUM(status = 'realizada')` conta
as realizadas; a divisão dos não comparecimentos pelo total de agendadas dá o percentual;
e o `SUM(CASE ...)` soma o valor **somente** das consultas realizadas (cancelamentos e
faltas não geram receita). O `WITH ROLLUP` acrescenta a linha de totais, que vem com
`NULL` em `especialidade` — o `COALESCE` troca esse `NULL` pelo rótulo `'TODAS'`.

---

## Exercícios de Fixação (Seção 7)

### Exercício 1 — Produtos ativos e valor do estoque

```sql
SELECT COUNT(*)              AS produtos_ativos,
       SUM(preco * estoque)  AS valor_estoque
FROM   produtos
WHERE  ativo = 1;
-- 11 produtos ativos · R$ 178.531,50
```

### Exercício 2 — Quantidade e valor médio por status (sem cancelados)

```sql
SELECT status,
       COUNT(*)                 AS qtd,
       ROUND(AVG(valor_total), 2) AS valor_medio
FROM   pedidos
WHERE  status <> 'cancelado'
GROUP BY status
ORDER BY valor_medio DESC;
```

### Exercício 3 — Clientes com 2+ pedidos não cancelados

```sql
SELECT cliente_id,
       COUNT(*)         AS qtd_pedidos,
       SUM(valor_total) AS total_gasto
FROM   pedidos
WHERE  status <> 'cancelado'
GROUP BY cliente_id
HAVING COUNT(*) >= 2
ORDER BY total_gasto DESC;
-- O cliente 6 tem 2 pedidos, mas um foi cancelado: o WHERE o descarta ANTES de contar,
-- então ele fica de fora. Se o filtro de status fosse omitido, ele apareceria.
```

### Exercício 4 — Faturamento mensal de 2026 (sem cancelados)

```sql
SELECT DATE_FORMAT(data_pedido, '%m/%Y') AS mes,
       SUM(valor_total)                   AS faturamento
FROM   pedidos
WHERE  status <> 'cancelado'
  AND  YEAR(data_pedido) = 2026
GROUP BY YEAR(data_pedido), MONTH(data_pedido), DATE_FORMAT(data_pedido, '%m/%Y')
ORDER BY YEAR(data_pedido), MONTH(data_pedido);
```

O texto `MM/AAAA` não ordena cronologicamente (`'10/2026'` viria antes de `'02/2026'`), então a
ordenação e o agrupamento usam ano e mês numéricos; o `DATE_FORMAT` serve só para exibir.

### Exercício 5 — Os 3 produtos mais vendidos

```sql
SELECT produto_id,
       SUM(quantidade) AS unidades_vendidas
FROM   itens_pedidos
GROUP BY produto_id
ORDER BY unidades_vendidas DESC, produto_id
LIMIT 3;
-- produto 3 (5 un.), produto 2 (4 un.), produto 4 (4 un.)
```

Os produtos 2, 4, 5 e 9 empatam em 4 unidades; o segundo critério do `ORDER BY`
(`produto_id`) decide o desempate de forma determinística. Para exibir o **nome** do
produto em vez do id, seria necessário um `JOIN` — assunto do próximo tópico.

### Exercício 6 — Quantidade de produtos por faixa de preço

```sql
SELECT CASE
           WHEN preco <  200 THEN 'Econômico'
           WHEN preco < 1000 THEN 'Intermediário'
           ELSE                   'Premium'
       END AS faixa_preco,
       COUNT(*) AS qtd_produtos
FROM   produtos
GROUP BY faixa_preco
ORDER BY MIN(preco);
-- Econômico 4 · Intermediário 4 · Premium 4
```

O `CASE` produz um texto por linha, e o `GROUP BY` agrupa por esse texto. O
`ORDER BY MIN(preco)` ordena as faixas da mais barata para a mais cara (ordenar pelo texto
colocaria "Econômico" e "Intermediário" em ordem alfabética, não de preço).

---

⬅️ [Voltar ao Tópico 06 — SQL DQL: Consultas e Agregação](./Topico_06_SQL_DQL_Agregacao.md)

---

*Fatec Jahu · IBD015 · Prof. Ronan Adriel Zenatti · 2026*
