<!--
GABARITO — não faz parte do fluxo principal do tópico e fica fora do `nav` do
mkdocs.yml de propósito. É acessível só pelo link no final de
Topico_13_Otimizacao_Indices.md.
-->

# Gabarito — Tópico 13 — Otimização de Consultas e Índices

**Disciplina:** Banco de Dados — Relacional (IBD015)
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br
**Fatec Jahu — 2º Semestre/2026**

> ⚠️ Este gabarito é para conferência **depois** de você tentar resolver os checkpoints
> e os Exercícios de Fixação por conta própria no [Tópico 13](Topico_13_Otimizacao_Indices.md).
> Resolver antes de tentar reduz o benefício de treinar a recuperação ativa do
> conteúdo.
>
> Os números de `rows` e os tempos citados foram medidos em MariaDB 10.4 com tabelas de 200 mil
> linhas; no seu computador variarão um pouco — compare a **mudança de plano**, não o valor exato.

---

## Checkpoint 1 — Escolhendo a estrutura: plataforma de cloud gaming {: #checkpoint-1 }

| | Necessidade | Escolha | Por quê |
|---|---|---|---|
| **(a)** | Sessão ativa por `token_sessao`, igualdade exata, tabela pequena e volátil em memória | **Hash** (tabela `MEMORY`) | Só igualdade, sem ordem ou faixa: é o caso ideal do hash. Em InnoDB seria uma B-Tree (que também funcionaria bem) |
| **(b)** | `pontos` entre 1.000 e 2.000, ordenados | **B-Tree** | Faixa e ordenação: as folhas ordenadas e encadeadas servem aos dois |
| **(c)** | Autocompletar `LIKE 'dra%'` | **B-Tree** | O prefixo é conhecido, então a árvore pula direto à região (`range`). O hash não serve a `LIKE` |
| **(d)** | Descrição contendo "aventura espacial" | **`FULLTEXT`** | Busca por palavras em texto longo; B-Tree não ajuda quando a palavra está no meio |
| **(e)** | `online = 1`, só 2% online | **B-Tree** (talvez parcial, conforme a consulta) | A *seletividade* depende do **valor** buscado: `online = 1` retorna 2% das linhas — o índice compensa; já `online = 0` (98%) leria quase tudo e o otimizador ignoraria o índice. Em colunas de poucos valores, o índice só vale para o valor raro |
| **(f)** | `LIKE '%mer%'` (contém, no meio) | **Nenhum índice B-Tree resolve** | O começo do texto é desconhecido; o índice varre-se por inteiro. Alternativas: `FULLTEXT` por palavra (não casa pedaços de palavra) ou mudar o requisito/modelagem |

---

## Checkpoint 2 — Lendo planos: plataforma de streaming {: #checkpoint-2 }

**O que os planos revelam:** as três consultas fazem `type: ALL` — leem as 199.392 linhas.
Q1 lê tudo para devolver ~25 linhas de um usuário; Q2 faz o mesmo e ainda **ordena** o resultado
(`Using filesort`); Q3 lê tudo para agrupar em uma tabela temporária.

**O índice que resolve Q1 e Q2:**

```sql
CREATE INDEX idx_reproducoes_usuario_iniciada ON reproducoes (usuario_id, iniciada_em);
```

Planos depois:

| Consulta | `type` | `key` | `rows` | `Extra` |
|---|---|---|---|---|
| Q1 | **ref** | idx_reproducoes_usuario_iniciada | 25 | |
| Q2 | **ref** | idx_reproducoes_usuario_iniciada | 25 | Using where — **sem `filesort`** |

O índice composto cobre os dois: `usuario_id` (igualdade, primeira coluna) resolve a Q1; como
dentro de cada usuário as entradas já estão ordenadas por `iniciada_em`, a Q2 recebe as linhas
na ordem pedida (percorrendo o índice de trás para frente, por causa do `DESC`) e para ao
atingir o `LIMIT 20`.

**Por que a Q3 não precisa de índice:** o `Using temporary; Using filesort` ali é o custo de
agrupar 200 mil linhas em **3 grupos** (`tv`, `celular`, `web`). A consulta precisa **ler todas as
linhas de qualquer jeito** (o `AVG` envolve todas) — um índice em `dispositivo` não reduziria a
leitura e, com apenas 3 valores distintos, não seria usado. A tabela temporária tem 3 linhas e é
barata. Se essa agregação fosse executada o tempo todo em tela, a solução seria **pré-calcular**
(uma tabela-resumo atualizada periodicamente), não indexar.

---

## Checkpoint 3 — Reescrevendo para o índice: fintech {: #checkpoint-3 }

| # | Problema | Reescrita |
|---|---|---|
| **(1)** | `YEAR()` e `MONTH()` aplicadas à coluna `criada_em` impedem o uso do índice (plano: `index`/`ALL`) | `WHERE criada_em >= '2026-03-01' AND criada_em < '2026-04-01'` → `type: range` em `idx_transacoes_criada` |
| **(2)** | `codigo_conta` é `VARCHAR`; comparado ao número `00000042` (que vira 42) o banco converte a coluna inteira: plano `ALL`, `key NULL` apesar de `possible_keys` listar o índice. (Também mudaria o valor: `'00000042'` ≠ `'42'` como texto) | `WHERE codigo_conta = '00000042'` → `type: ref`, 10 linhas |
| **(3)** | `UPPER()` na coluna: plano `ALL` | Retire a função: `WHERE codigo_conta = '00000042'`. A *collation* padrão (`utf8mb4_unicode_ci`) já é **insensível a maiúsculas/minúsculas**, então o `UPPER` era desnecessário |
| **(4)** | `valor + 10 > 100` é uma expressão na coluna `valor` (não sargável). **Mas** a outra condição (`criada_em` dentro de um dia) é sargável, e foi ela que o otimizador usou: o plano é `range` em `idx_transacoes_criada` (≈ 1.4 mil linhas) nos dois casos | Mesmo assim, escreva `valor > 90`: se esse fosse o único filtro, só a forma "limpa" poderia usar um índice em `valor`. Moral: a condição ruim às vezes é inofensiva por acompanhar uma boa — **o `EXPLAIN` diz** |
| **(5)** | `LIKE '%ref 1999'` tem `%` no começo: nenhum índice B-Tree ajuda (plano `ALL`) | **Não há reescrita** que use índice B-Tree. O sintoma aponta para a **modelagem**: o número de referência está *embutido* na descrição (dado não atômico — viola a 1ª Forma Normal, Tópico 02). A correção é separar uma coluna `referencia` e indexá-la |

---

## Checkpoint 4 — Projetando índices compostos: micromobilidade elétrica {: #checkpoint-4 }

**Respostas:**

```sql
-- Q1: igualdade em usuario_id e status, depois ORDER BY iniciada_em
CREATE INDEX idx_viagens_usuario_status_iniciada ON viagens (usuario_id, status, iniciada_em);

-- Q2: faixa em iniciada_em; patinete_id e valor "pegos de carona" para cobrir a consulta
CREATE INDEX idx_viagens_iniciada_patinete_valor ON viagens (iniciada_em, patinete_id, valor);

-- Q3: igualdade em status, depois faixa em iniciada_em
CREATE INDEX idx_viagens_status_iniciada ON viagens (status, iniciada_em);
```

**O que esperar no `EXPLAIN` (e o que foi medido):**

| Consulta | Plano depois do índice |
|---|---|
| **Q1** | `type: ref`, `key_len: 9` (as **duas** primeiras colunas — 8 do `BIGINT` + 1 do `ENUM` — usadas na igualdade), ~5 linhas, **sem `Using filesort`**: a 3ª coluna do índice já entrega as linhas ordenadas por data |
| **Q2** | `type: range`, `Using index` (índice de **cobertura**: não toca na tabela). Ainda aparece `Using temporary; Using filesort` porque o `GROUP BY patinete_id` não está na ordem do índice (a faixa é em `iniciada_em`); para a janela de uma semana (~31 mil linhas) isso é aceitável |
| **Q3** | `type: range`, ~116 linhas, `Using index condition`: o índice vai direto às viagens `'em_andamento'` (rara, <1% das linhas) e, dentro delas, corta pela data |

**Justificativa da ordem:** a regra é **igualdade primeiro, faixa/ordenação depois**. Em Q1, `usuario_id` e `status` (igualdades) vêm antes de `iniciada_em` (ordenação). Em Q3, `status` (igualdade) precede `iniciada_em` (faixa). Em Q2 não há igualdade: a faixa em `iniciada_em` abre o índice, e as outras colunas só servem para cobertura. Um índice `(iniciada_em, usuario_id)` para a Q1 seria um erro: a faixa em primeiro lugar impediria o uso eficiente de `usuario_id` e a ordenação.

---

## Checkpoint 5 — Diagnosticando um JOIN lento: saúde digital {: #checkpoint-5 }

**Leitura do plano:** como `consultas.paciente_id` não tem índice, o banco não consegue "ir direto" às consultas de um paciente. Ele escolheu **percorrer `consultas` inteira** (`ALL`, ~200 mil linhas) e, para cada uma, procurar o paciente pela PK (`eq_ref`) e só então testar `p.nome = 'Paciente 777'` — ou seja, **200 mil buscas** para devolver um punhado de linhas (≈ 140 ms).

**Correção que resolve a lentidão e melhora a integridade:** criar a `FOREIGN KEY`, que cria o índice automaticamente (Tópico 08) e passa a garantir que toda consulta tenha paciente:

```sql
-- 1) antes: achar consultas órfãs (senão o ALTER falha com 1452)
SELECT c.id_consulta FROM consultas c
LEFT JOIN pacientes p ON p.id_paciente = c.paciente_id
WHERE p.id_paciente IS NULL;

-- 2) criar a FK (e, com ela, o índice em paciente_id)
ALTER TABLE consultas
    ADD CONSTRAINT fk_consulta_paciente FOREIGN KEY (paciente_id)
        REFERENCES pacientes (id_paciente)
        ON DELETE RESTRICT ON UPDATE CASCADE;

-- 3) atualizar as estatísticas
ANALYZE TABLE consultas, pacientes;
```

Plano resultante: `p` (`pacientes`) → `ALL` (20 mil linhas, porque não há índice em `nome`) e `c` → **`ref`** pelo índice da FK (~5 linhas por paciente). Tempo ≈ **4,5 ms** (de ~140 ms).

**Segundo índice (busca por nome):**

```sql
CREATE INDEX idx_pacientes_nome ON pacientes (nome);
```

Plano final: `p` → **`ref`** em `idx_pacientes_nome` (1 linha) e `c` → `ref` pelo índice da FK (5 linhas); tempo ≈ **0,05 ms** — cerca de **2.500 vezes** mais rápido que o original.

**Detalhe importante:** logo depois de criar a FK, o `EXPLAIN` mostrou `rows: 14` para `consultas` — estatística defasada. Só depois de `ANALYZE TABLE` o plano passou a refletir a realidade (Seção 6.2).

---

## Checkpoint 6 — Paginação por chave: feed de criadores {: #checkpoint-6 }

**(a)** Com `OFFSET 150000`, o banco precisa **ler e descartar** 150.000 linhas para só então devolver as 20 da página 7.501: no plano, `type: index` com `rows: 150020`. O trabalho cresce linearmente com a profundidade — a página 1 é instantânea e cada página seguinte é mais lenta que a anterior.

**(b)** Paginação por chave (por `id_publicacao`, que é a PK e o critério de ordem):

```sql
-- Primeira página
SELECT id_publicacao, titulo
FROM   publicacoes
ORDER BY id_publicacao DESC
LIMIT  20;

-- Páginas seguintes (:ultimo_id = menor id_publicacao da página anterior)
SELECT id_publicacao, titulo
FROM   publicacoes
WHERE  id_publicacao < :ultimo_id
ORDER BY id_publicacao DESC
LIMIT  20;
```

A segunda forma usa o índice da PK para ir direto à posição: lê **20 linhas** (`r_rows: 20`, ≈ 0,02 ms) em qualquer profundidade, contra ~150 mil e ~26 ms do `OFFSET`.

**(c)** A aplicação deve guardar (ou receber de volta do cliente, no token de "próxima página") o **valor da chave da última linha exibida** — aqui, o menor `id_publicacao` da página atual. Se a ordem fosse por uma coluna não única (como `publicada_em`), guardaria o par `(publicada_em, id_publicacao)` e usaria a condição expandida com `OR` do tópico, apoiada em um índice composto `(publicada_em, id_publicacao)`. O custo: só se pode ir "para a frente/para trás", não saltar direto para uma página numerada.

---

## Exercícios de Fixação (Seção 9)

### Exercício 1 — Antes e depois do índice

```sql
ANALYZE FORMAT=JSON SELECT * FROM acessos_site WHERE visitante_id = 1234;
--   "access_type": "ALL", "r_rows": 200000, "r_filtered": 0.02 · ≈ 53 ms

CREATE INDEX idx_acessos_site_visitante ON acessos_site (visitante_id);

ANALYZE FORMAT=JSON SELECT * FROM acessos_site WHERE visitante_id = 1234;
--   "access_type": "ref",  "r_rows": 40,     "r_filtered": 100  · ≈ 0,17 ms
```

Resumo: de 200 mil linhas lidas (das quais só 0,02% serviam) para 40 linhas lidas, todas úteis — o
tempo caiu de dezenas de milissegundos para décimos de milissegundo.

### Exercício 2 — Reescrevendo para `ocorrido_em`

```sql
CREATE INDEX idx_acessos_site_ocorrido ON acessos_site (ocorrido_em);

-- (a) MONTH() na coluna → intervalo
SELECT ... WHERE ocorrido_em >= '2026-09-01' AND ocorrido_em < '2026-10-01';

-- (b) expressão na coluna → mova o cálculo para a constante
SELECT ... WHERE ocorrido_em > '2026-10-17' - INTERVAL 1 DAY;

-- (c) DATE() na coluna → intervalo semiaberto (o último dia inclui todo o dia 12)
SELECT ... WHERE ocorrido_em >= '2026-09-10' AND ocorrido_em < '2026-09-13';
```

Planos: a forma original das três é `ALL`. As reescritas de **(b)** e **(c)** passam a `range` (≈ 6.200 e ≈ 7.000 linhas). A de **(a)**, apesar de correta e sargável, **continua em `ALL`**: setembro inteiro representa cerca de 35% da tabela, e o otimizador (corretamente) estima que ler 35% da tabela diretamente é mais barato que fazer dezenas de milhares de idas ao índice e à tabela. Restringindo o intervalo à primeira semana de setembro (`>= '2026-09-01' AND < '2026-09-08'`), a seletividade melhora (~16%) e o plano vira `range` (≈ 31 mil linhas). Lição: **uma condição sargável é necessária para usar o índice, mas não é suficiente** — o índice só compensa quando filtra uma fração pequena da tabela. (E `MONTH(...) = 9` também ignora o ano; a reescrita explicita o ano.)

### Exercício 3 — Índice composto para "últimas 20 páginas do visitante"

```sql
EXPLAIN SELECT pagina, ocorrido_em FROM acessos_site
WHERE visitante_id = 1234 ORDER BY ocorrido_em DESC LIMIT 20;
--   key: idx_acessos_site_visitante · Extra: Using where; Using filesort   (só com o índice simples)

CREATE INDEX idx_acessos_site_visitante_ocorrido ON acessos_site (visitante_id, ocorrido_em);

EXPLAIN SELECT pagina, ocorrido_em FROM acessos_site
WHERE visitante_id = 1234 ORDER BY ocorrido_em DESC LIMIT 20;
--   key: idx_acessos_site_visitante_ocorrido · Extra: Using where   (sem filesort)
```

O índice composto `(visitante_id, ocorrido_em)` tem `visitante_id` como **prefixo à esquerda**, então
tudo que o índice simples só em `visitante_id` fazia, o composto também faz — o simples fica
**redundante** (ocupa espaço e atrasa escritas sem benefício) e pode ser removido com
`DROP INDEX idx_acessos_site_visitante ON acessos_site;`.

### Exercício 4 — Navegação "ver mais"

```sql
-- Primeira página
SELECT id_acesso, pagina FROM acessos_site ORDER BY id_acesso DESC LIMIT 15;
--   (o menor id devolvido é 199986)

-- Próximas páginas (:ultimo_id = menor id da página anterior)
SELECT id_acesso, pagina FROM acessos_site WHERE id_acesso < :ultimo_id ORDER BY id_acesso DESC LIMIT 15;
```

`ANALYZE FORMAT=JSON` das duas formas: por chave (`WHERE id_acesso < 199986 ... LIMIT 15`) →
`range`, `r_rows: 15`, ≈ 0,02 ms; com `LIMIT 15 OFFSET 180000` → `index`, `r_rows: 180015`,
≈ 33 ms. A diferença cresce com a profundidade.

### Exercício 5 — *Slow query log*

```sql
SET GLOBAL slow_query_log = 1;
SET GLOBAL long_query_time = 0.03;
SHOW VARIABLES LIKE 'slow_query_log_file';           -- caminho do arquivo

SELECT COUNT(*) FROM acessos_site WHERE duracao_ms = 5000;
```

Entrada no log (valores aproximados):

```
# Query_time: 0.060330  Lock_time: 0.000044  Rows_sent: 1  Rows_examined: 200000
SELECT COUNT(*) FROM acessos_site WHERE duracao_ms = 5000;
```

`Rows_examined: 200000` contra `Rows_sent: 1` mostra que a consulta leu a tabela inteira para
devolver uma contagem: é uma varredura completa. O candidato é um índice em `duracao_ms`, **mas antes é
preciso perguntar** quanto essa consulta é frequente, quantos valores distintos a coluna tem (9 mil —
boa seletividade para igualdade) e quanto custaria nas escritas. Se a consulta roda uma vez por dia em
um relatório, o índice não compensa. Lembre de desligar a captura depois do exercício
(`SET GLOBAL slow_query_log = 0; SET GLOBAL long_query_time = 10;`).

---

⬅️ [Voltar ao Tópico 13 — Otimização de Consultas e Índices](./Topico_13_Otimizacao_Indices.md)

---

*Fatec Jahu · IBD015 · Prof. Ronan Adriel Zenatti · 2026*
