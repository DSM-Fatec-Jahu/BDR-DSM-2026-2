<!--
GABARITO — não faz parte do fluxo principal da aula e fica fora do `nav` do
mkdocs.yml de propósito. É acessível só pelo link no final de
Aula_06_SQL_Consultas_Basicas.md.
-->

# Gabarito — Aula 06 — SQL: Consultas Básicas

**Disciplina:** Banco de Dados — Relacional (IBD015)
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br
**Fatec Jahu — 2º Semestre/2026**

> ⚠️ Este gabarito é para conferência **depois** de você tentar resolver os checkpoints
> e os Exercícios de Fixação por conta própria na [Aula 06](Aula_06_SQL_Consultas_Basicas.md).
> Resolver antes de tentar reduz o benefício de treinar a recuperação ativa do
> conteúdo.

---

## Checkpoint 1 — SELECT e DISTINCT: agricultura de precisão {: #checkpoint-1 }

**Resposta:**

```sql
SELECT DISTINCT talhao AS talhao_monitorado
FROM   leituras_sensores
ORDER BY talhao_monitorado;
```

`DISTINCT` elimina talhões repetidos (cada sensor gera muitas leituras ao longo do
tempo, então o mesmo talhão aparece várias vezes na tabela bruta), e o alias
`talhao_monitorado` renomeia a coluna apenas no resultado exibido, sem alterar o nome
real da coluna na tabela.

---

## Checkpoint 2 — WHERE: app de adoção de pets {: #checkpoint-2 }

**Resposta:**

```sql
SELECT nome, especie, idade_meses
FROM   pets
WHERE  disponivel_adocao = 1
  AND  idade_meses BETWEEN 2 AND 24
  AND  especie IN ('cachorro', 'gato')
  AND  nome LIKE 'B%';
```

Cada condição do enunciado vira uma cláusula combinada com `AND`: `BETWEEN` para o
intervalo de idade (inclusivo nos dois extremos), `IN` para a lista de espécies
aceitas, e `LIKE 'B%'` para nomes que começam com "B".

---

## Checkpoint 3 — ORDER BY: plataforma de ingressos para shows {: #checkpoint-3 }

**Resposta:**

```sql
SELECT nome, cidade, preco_ingresso
FROM   eventos
ORDER BY cidade ASC, preco_ingresso DESC;
```

O primeiro critério de `ORDER BY` (`cidade ASC`) agrupa as cidades em ordem
alfabética; o segundo critério (`preco_ingresso DESC`) só é aplicado **dentro** de
cada grupo de mesma cidade, ordenando do ingresso mais caro para o mais barato.

---

## Checkpoint 4 — LIMIT/OFFSET: estacionamento inteligente {: #checkpoint-4 }

**Resposta:**

```sql
SELECT id_vaga, setor
FROM   vagas
WHERE  ocupada = 0
ORDER BY id_vaga
LIMIT 5 OFFSET 5;
```

Para a segunda página com 5 itens por página, `OFFSET = (página - 1) × itens_por_página
= (2-1)×5 = 5` — ou seja, pula as 5 primeiras vagas livres e traz as 5 seguintes.

---

## Checkpoint 5 — Funções de String/Data: app de aulas de idiomas online {: #checkpoint-5 }

**Resposta:**

```sql
SELECT UPPER(nome_completo)                              AS nome_maiusculo,
       SUBSTRING(email, 1, 3)                             AS inicio_email,
       TIMESTAMPDIFF(YEAR, data_matricula, NOW())         AS anos_matriculado
FROM   alunos_idiomas
ORDER BY data_matricula ASC;
```

`UPPER` converte o nome para maiúsculas, `SUBSTRING(email, 1, 3)` extrai os 3
primeiros caracteres, e `TIMESTAMPDIFF(YEAR, data_matricula, NOW())` calcula quantos
anos completos se passaram desde a matrícula. Ordenar por `data_matricula ASC` (sem
usar o alias, que também funcionaria) coloca os alunos mais antigos primeiro.

---

## Exercícios de Fixação (Seção 6)

### Exercício 1 — Produtos entre R$ 100 e R$ 500

```sql
SELECT nome, preco
FROM   produtos
WHERE  preco BETWEEN 100.00 AND 500.00
ORDER BY preco DESC;
```

### Exercício 2 — Clientes com nome começando em 'A' ou terminando em 'Lima'

```sql
SELECT nome
FROM   pessoas
WHERE  nome LIKE 'A%' OR nome LIKE '%Lima';
```

### Exercício 3 — 3 produtos mais baratos, ativos e com estoque

```sql
SELECT nome, preco
FROM   produtos
WHERE  ativo = 1 AND estoque > 0
ORDER BY preco ASC
LIMIT 3;
```

### Exercício 4 — Pedidos não cancelados, com data formatada

```sql
SELECT id_pedido,
       DATE_FORMAT(data_pedido, '%d/%m/%Y') AS data_formatada,
       valor_total
FROM   pedidos
WHERE  status <> 'cancelado'
ORDER BY valor_total DESC;
```

### Exercício 5 — Produtos sem descrição

```sql
SELECT nome
FROM   produtos
WHERE  descricao IS NULL;
```

---

⬅️ [Voltar à Aula 06 — SQL: Consultas Básicas](./Aula_06_SQL_Consultas_Basicas.md)

---

*Fatec Jahu · IBD015 · Prof. Ronan Adriel Zenatti · 2026*
