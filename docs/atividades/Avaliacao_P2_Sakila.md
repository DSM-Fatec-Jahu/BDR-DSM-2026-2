# Avaliação P2 — Inserções, Consultas e Exclusões no `sakila_pt` (Tópicos 04 a 07)

**Disciplina:** Banco de Dados — Relacional (IBD015)
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br
**Fatec Jahu — 2º Semestre/2026**
**Valor:** 4,0 pontos
**Modalidade:** em dupla, em um único computador do laboratório, durante o horário da disciplina

---

## 📋 Regras da avaliação

- **Em dupla, em um único computador.** A dupla trabalha junta na mesma máquina e recebe
  a mesma nota.
- **Somente nos computadores do laboratório** onde a prova acontece — não vale
  resolver em notebook pessoal ou em casa.
- **Consulta permitida:**
    - a **folha de anotações escrita à mão** que cada aluno foi autorizado a trazer;
    - o **portal da disciplina**, **somente nas páginas de conteúdo dos tópicos**.
- **Consulta proibida:** exercícios, checkpoints, gabaritos, práticas, simulados,
  avaliações e qualquer outra atividade publicada no portal, além de anotações digitais
  ou qualquer outro material no computador.
- **Banco de dados:** todas as atividades usam o banco `sakila_pt`. Selecione-o antes de
  começar.
- **Conteúdo cobrado:** Tópicos 04 a 07 (`INSERT`, `UPDATE`, `DELETE`, `SELECT` com
  filtros, ordenação, funções de agregação, `GROUP BY` e `INNER JOIN`).
- **Todas as duplas fazem as três atividades.**

---

## 🧮 Composição da nota

| Atividade | O que a dupla faz | Valor |
|---|---|---|
| **Atividade 1** — Contratação de funcionário | O fluxo completo de cadastro e atualização | 1,5 pt |
| **Atividade 2** — Consultas com `SELECT` | **1** consulta da Parte 1 + **1** consulta da Parte 2, à escolha da dupla (0,75 pt cada) | 1,5 pt |
| **Atividade 3** — Exclusão segura | **2** exclusões (0,5 pt cada): a do funcionário criado na Atividade 1 + **1** das outras 2 à escolha — ou, se a Atividade 1 não foi concluída, as **outras 2** exclusões | 1,0 pt |
| | **Total** | **4,0 pts** |

---

## 📦 O que entregar

Um único arquivo **`.sql`**, com **todos os comandos** da avaliação, preenchido nas
seções já delimitadas.

📥 Baixe o modelo e preencha-o:
[Avaliacao_P2_Sakila.sql](Avaliacao_P2_Sakila.sql){: download }

No início do arquivo, preencha em comentário o **nome dos dois integrantes** e o
**número do computador**. Na Atividade 2 e na Atividade 3, marque no próprio arquivo
quais itens a dupla escolheu.

**Entrega:** **os dois integrantes** devem enviar o mesmo arquivo `.sql` na **atividade
específica desta avaliação no Google Classroom da turma**. Como a dupla usa um único
computador, cada aluno entra no **seu próprio** Classroom em um navegador diferente
(por exemplo, um no Edge e outro no Chrome) — assim as duas contas ficam logadas ao mesmo
tempo, sem precisar sair de uma para entrar na outra.

### Orientações gerais

- Antes de iniciar qualquer atividade, selecione o banco de dados `sakila_pt`.
- **Use sempre o último id gerado.** Depois de cada inserção em tabela com chave primária
  autoincrementável, a etapa seguinte deve usar o id que acabou de ser gerado.
- Ao final da Atividade 1, atualize o registro criado filtrando sempre pela chave
  primária dele e confira o resultado.
- **Comandos recomendados, mas não obrigatórios:** os passos marcados com
  *(recomendado)* — inspecionar a estrutura da tabela (`DESCRIBE`) e verificar se um
  registro já existe — ajudam a acertar o resto, mas **não precisam estar no arquivo** e
  **não valem nota**.
- **A execução pode ser parcial.** Deixe **comentado** qualquer trecho incompleto ou com
  erro, para que ele não impeça a execução do restante do arquivo.

---

## Atividade 1 — Fluxo de Contratação de Funcionário · 1,5 pt

**Cadeia de tabelas:** `paises` → `cidades` → `enderecos` → `funcionarios` *(com consulta em `lojas`)*

1. Consulte a tabela `paises` e localize o registro do país `'Argentina'` (ou `'Brasil'`).
2. *(recomendado)* Verifique na tabela `cidades` se já existe uma cidade chamada
   `'Mendoza'` (caso tenha escolhido `'Argentina'`) ou `'Jaú'` (caso tenha escolhido
   `'Brasil'`).
3. *(recomendado: inspecione a estrutura da tabela `cidades`)* Cadastre a nova cidade
   vinculada ao `id_pais` do país escolhido (por subconsulta) e confira o registro
   inserido consultando-o pelo último id gerado (`id_cidade`).
4. *(recomendado: inspecione a estrutura da tabela `enderecos`)* Cadastre um novo
   endereço completo vinculado ao `id_cidade` recém-criado (informando logradouro,
   complemento opcional, bairro, código postal e telefone) e confira o registro inserido
   consultando-o pelo último id gerado (`id_endereco`).
5. Consulte a tabela `lojas` para verificar quais `id_loja` existem cadastrados.
6. *(recomendado)* Inspecione a estrutura da tabela `funcionarios` para identificar todos
   os campos obrigatórios (como nome, sobrenome, endereço, loja, status ativo e nome de
   usuário).
7. Cadastre um novo funcionário na tabela `funcionarios` vinculado ao `id_endereco`
   recém-criado e à loja `1` (deixando os campos opcionais como `foto` e `senha` como
   nulos, se preferir).
8. Consulte o registro inserido na tabela `funcionarios` pelo último id gerado
   (`id_funcionario`) para confirmar o cadastro.
9. Atualize o registro do funcionário recém-criado na tabela `funcionarios` (filtrando
   pelo seu `id_funcionario`), alterando o `email`, o `nome_usuario` e transferindo-o para
   a loja `2` (`loja_id`). Em seguida, consulte o registro novamente para validar as
   alterações.

---

## Atividade 2 — Consultas Analíticas com `SELECT` · 1,5 pt

**A dupla escolhe livremente 1 item da Parte 1 e 1 item da Parte 2** — 2 consultas no
total, 0,75 pt cada. Itens além dos 2 escolhidos não valem nota extra.

**Regras desta atividade:**

- Utilize apenas as cláusulas: `SELECT`, `FROM`, `WHERE`, `INNER JOIN`, `GROUP BY`,
  `ORDER BY` e `LIMIT`.
- Use **exatamente** a função indicada em cada item, **no campo indicado** — nem outra
  função, nem outro campo. Item que não indica função deve ser resolvido **sem nenhuma
  função e sem `GROUP BY`**.
- Os itens **1 a 5** devem ser resolvidos **sem `INNER JOIN`** (apenas uma tabela).
- Os itens **6 a 10** devem ser resolvidos **com `INNER JOIN`** (relacionando duas ou
  três tabelas).

### Parte 1 — Consultas em tabela única (sem `INNER JOIN`) — escolha 1

1. Liste o `titulo`, a `taxa_aluguel` e a `duracao` dos filmes da tabela `filmes` que
   possuem classificação `'PG-13'`, ordenados pelo `titulo` em ordem alfabética.
2. Apresente os **10 filmes com maior custo de reposição** (`custo_reposicao`) da tabela
   `filmes`, exibindo o `titulo`, a `classificacao` e o `custo_reposicao`, ordenados do
   maior para o menor valor (`LIMIT 10`).
3. **Função: `AVG` no campo `taxa_aluguel`.** Calcule a média da `taxa_aluguel` dos
   filmes da tabela `filmes` cuja `classificacao` seja `'G'`.
4. **Função: `MAX` no campo `duracao`.** Na tabela `filmes`, apresente a `classificacao`
   e a maior duração de cada classificação, agrupando (`GROUP BY`) pelo campo
   `classificacao`, e ordene o resultado da maior para a menor duração.
5. **Função: `SUM` no campo `valor`.** Considerando apenas os registros com `valor` maior
   que `0` na tabela `pagamentos`, apresente o `cliente_id` e o valor total pago dos
   **5 clientes que mais gastaram**, agrupando (`GROUP BY`) pelo campo `cliente_id` e
   ordenando do maior para o menor total (`LIMIT 5`).

### Parte 2 — Consultas relacionais (com `INNER JOIN`) — escolha 1

6. Liste o `primeiro_nome`, `ultimo_nome` e `email` de todos os clientes ativos
   (`ativo = 1`), juntamente com o `logradouro` e o `telefone` de seus respectivos
   endereços (relacionando `clientes` e `enderecos`), ordenados por `primeiro_nome` em
   ordem alfabética.
7. Liste o `filmes.titulo`, a `filmes.classificacao` e o `categorias.nome` dos filmes com
   classificação `'G'` (relacionando `filmes`, `filmes_categorias` e `categorias`),
   ordenados por `categorias.nome` e, dentro de cada categoria, por `filmes.titulo` em
   ordem alfabética.
8. **Função: `SUM` no campo `pagamentos.valor`.** Apresente os **5 melhores clientes
   ativos** (`ativo = 1`) da locadora, exibindo `primeiro_nome`, `ultimo_nome`, `email` e
   o valor total gasto, relacionando `clientes` e `pagamentos`, agrupando (`GROUP BY`)
   pelos campos `clientes.id_cliente`, `clientes.primeiro_nome`, `clientes.ultimo_nome` e
   `clientes.email`, e ordenando do maior para o menor valor gasto (`LIMIT 5`).
9. **Função: `SUM` no campo `pagamentos.valor`.** Apresente o **funcionário com maior
   valor total em vendas**, exibindo `primeiro_nome`, `ultimo_nome` e o total vendido,
   relacionando `funcionarios` e `pagamentos`, agrupando (`GROUP BY`) pelos campos
   `funcionarios.id_funcionario`, `funcionarios.primeiro_nome` e
   `funcionarios.ultimo_nome`, ordenando do maior para o menor total (`LIMIT 1`).
10. **Função: `AVG` no campo `filmes.taxa_aluguel`.** Apresente o `categorias.nome` e a
    taxa média de aluguel de cada categoria, relacionando `filmes`, `filmes_categorias` e
    `categorias`, agrupando (`GROUP BY`) pelos campos `categorias.id_categoria` e
    `categorias.nome`, e ordenando da maior para a menor taxa média.

---

## Atividade 3 — Exclusão Segura de Registros (`DELETE`) · 1,0 pt

A dupla faz **2 exclusões** — 0,5 pt cada. Quais exclusões fazer depende do resultado da
Atividade 1:

- **Se a dupla concluiu com sucesso a Atividade 1** (o funcionário foi cadastrado): faz
  **obrigatoriamente a exclusão 1** e **escolhe 1 entre as exclusões 2 e 3**.
- **Se a dupla não concluiu a Atividade 1** (não há funcionário cadastrado para excluir):
  **não faz a exclusão 1** e faz **as exclusões 2 e 3**.

**Orientações:** os ids **não são informados**. Para cada exclusão, a dupla deve:

1. **Buscar o id** do registro com um `SELECT` a partir das características descritas.
   Se o `SELECT` trouxer **mais de uma linha**, escolha **uma** delas.
2. **Excluir** com `DELETE`, filtrando **pela chave primária** (e não pelo nome ou por
   outra característica).
3. **Confirmar** a exclusão com um `SELECT` filtrando pela mesma chave primária, que
   agora não deve retornar nada.

Todos os registros descritos abaixo não possuem dependências bloqueadoras
(`ON DELETE RESTRICT`) no banco `sakila_pt`.

1. **Tabela `funcionarios` (obrigatória somente se a Atividade 1 foi concluída):** exclua o
   funcionário cadastrado pela dupla na Atividade 1.
2. **Tabela `idiomas`:** exclua o idioma `'Alemão'`, que não está vinculado a nenhum filme
   na tabela `filmes`.
3. **Tabela `pagamentos`:** exclua um pagamento de valor `1.99` que não está vinculado a
   nenhum aluguel (`aluguel_id` nulo).

---

!!! warning "Antes de entregar"
    Execute o arquivo inteiro do começo ao fim no `sakila_pt` e confira se não há erro
    interrompendo a execução. Trechos incompletos devem ficar **comentados**.
