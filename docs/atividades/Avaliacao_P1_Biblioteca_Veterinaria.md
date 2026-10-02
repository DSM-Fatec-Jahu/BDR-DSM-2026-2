# Avaliação P1 — Biblioteca ou Clínica Veterinária (Aulas 01 a 03)

**Disciplina:** Banco de Dados — Relacional (IBD015)
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br
**Fatec Jahu — 2º Semestre/2026**
**Valor:** 4,0 pontos
**Modalidade:** em dupla, em um único computador do laboratório, durante a aula

---

## 📋 Regras da avaliação

- **Em dupla, em um único computador.** A dupla trabalha junta na mesma máquina e recebe
  a mesma nota.
- **Somente nos computadores do laboratório** onde a aula acontece — não vale
  resolver em notebook pessoal ou em casa.
- **Consulta:** somente a **folha de rascunho escrita à mão** que cada aluno foi
  autorizado a trazer. Não é permitido abrir aulas, práticas, gabaritos, simulados,
  anotações digitais ou qualquer outro material no computador.
- **Qual cenário a dupla faz depende do número do computador** (o número da etiqueta na
  máquina em que a dupla está trabalhando):

    | Número do computador | Cenário que a dupla resolve |
    |---|---|
    | **Ímpar** (1, 3, 5, 7...) | 📚 **Biblioteca Comunitária** — banco `leiabairro` |
    | **Par** (2, 4, 6, 8...) | 🐾 **Clínica Veterinária** — banco `clinica_amigo_fiel` |

  É como a fila do posto de saúde que chama por senha par e ímpar: o número decide
  o guichê, e não adianta tentar trocar.
- **Conteúdo cobrado:** Aulas 01, 02 e 03 (modelagem de entidades e relacionamentos,
  cardinalidade, normalização e SQL DDL).
- **Só criação do banco.** A parte prática é feita **somente em SQL de criação**:
  `CREATE DATABASE` e `CREATE TABLE`. Não há inserção, consulta, atualização nem
  exclusão de dados, e não é preciso usar `ALTER TABLE`.

---

## 📦 O que entregar

Um único arquivo **`.sql`**, contendo duas partes, nesta ordem:

1. **As respostas das 4 perguntas** da seção abaixo, cada uma escrita como **comentário**
   (`/* ... */`) no próprio arquivo.
2. **O script SQL completo** que cria o banco de dados do cenário da sua dupla.

📥 Baixe o modelo e preencha-o:
[Avaliacao_P1_Biblioteca_Veterinaria.sql](Avaliacao_P1_Biblioteca_Veterinaria.sql){: download }

No início do arquivo, escreva em comentário o **nome dos dois integrantes** e o **cenário**
resolvido (Biblioteca ou Veterinária).

**Entrega:** **os dois integrantes** devem enviar o mesmo arquivo `.sql` na **atividade
específica desta avaliação no Google Classroom da turma**. Como a dupla usa um único
computador, cada aluno entra no **seu próprio** Classroom em um navegador diferente
(por exemplo, um no Edge e outro no Chrome) — assim as duas contas ficam logadas ao mesmo
tempo, sem precisar sair de uma para entrar na outra.

### Regras do script

- **O script deve poder ser executado várias vezes seguidas, sem gerar erro.** Garanta a
  remoção prévia dos objetos que serão criados e proteja tanto a remoção quanto a criação
  contra a existência ou a inexistência deles.
- **A execução pode ser parcial.** Deixe **comentado** qualquer trecho incompleto ou com
  erro, para que ele não impeça a execução do restante do arquivo.
- Aplique **todas as convenções de nomenclatura, tipos e padrões estruturais** vistos em
  aula — as **9 regras de nomenclatura da disciplina** (Aula 03 — SQL DDL, Seção 1).
- **Cada tabela deve ter a sua própria chave primária (PK)**, sem chaves compostas e sem
  restrições de unicidade que envolvam mais de uma coluna.

---

## ❓ Perguntas — respondidas como comentário no arquivo

Escreva a resposta de cada pergunta em um bloco de comentário, **antes** do script SQL.
As respostas devem se referir ao **banco que a sua dupla montou**, não a exemplos de
outros cenários.

1. **Chave estrangeira no relacionamento 1:N.** No relacionamento 1:N do seu
   banco, em qual das duas tabelas vocês colocaram a **chave estrangeira (FK)** e
   por que essa foi a escolha? O que mudaria — ou quebraria — se a FK ficasse na outra
   tabela, do lado oposto? (Lembrete: a FK é a coluna que "aponta" para a chave primária
   de outra tabela, como o número da comanda anotado em cada item consumido, que leva de
   volta à comanda da mesa.)

2. **Escolha do tipo dos campos.** Três campos do seu banco permitem mais de um tipo
   de dado:
    - **`quantidade`** — poderia ser `INT` ou `DECIMAL`;
    - **`cpf`** — poderia ser `VARCHAR`, `CHAR` ou `INT`;
    - **`cep`** — poderia ser `CHAR` ou `INT`.

    Para **cada um dos três**, digam qual tipo vocês escolheram e **como decidiram** que
    ele é o mais adequado para o banco: que perguntas vocês se fizeram sobre o dado
    para chegar a essa escolha? O que poderia dar errado com cada um dos outros tipos?
    (Lembrete: o tipo define o que a coluna aceita guardar — como a caixa de ovos que só
    comporta ovos. Um bom caminho de raciocínio: um número de telefone parece número,
    mas ninguém faz conta com telefone — então será que o tipo numérico é o mais
    adequado?)

3. **Especialização na modelagem.** Como a **especialização** poderia ser incluída na
   modelagem do cenário da sua dupla? Indiquem qual tabela do seu banco seria a
   **tabela geral**, quais seriam as **tabelas especializadas**, qual **campo exclusivo**
   cada tabela especializada teria e **como as chaves (PK e FK) ligariam as tabelas
   especializadas à tabela geral**. Não é necessário incluir a especialização no
   script — a pergunta é sobre como ela entraria na modelagem. (Lembrete: é como a
   padaria que vende "produtos": todo pão de queijo e todo bolo são produtos, mas o bolo
   tem o campo "sabor da cobertura" que o pão de queijo não tem.)

4. **Normalização.** Depois de concluir o script, analisem o banco de dados que vocês
   criaram sob a ótica da normalização. **Foram encontrados problemas de
   normalização?**
    - **Em caso afirmativo**, indiquem quais são (tabela, coluna e forma normal violada)
      e se foram resolvidos no seu script.
    - **Em caso negativo**, justifiquem por que o banco atende às formas normais.

---

## 📚 Cenário A — Biblioteca Comunitária (computador **ímpar**)

O **LeiaBairro** é o sistema de uma pequena biblioteca comunitária, dessas mantidas pela
associação do bairro ou por uma escola da cidade. Hoje o controle é feito num caderno
e na memória da bibliotecária — e já aconteceu de dois leitores saírem com o mesmo
livro e de ninguém lembrar quem está com o quê.

A partir da especificação abaixo, faça a modelagem e escreva o SQL que cria o banco de
dados **`leiabairro`**, com uma configuração adequada a um sistema em português.

**Requisitos Funcionais**

- **RF01** — O sistema deve organizar os livros por **categoria** (ex.: "Romance",
  "Didático", "Infantil"). Cada categoria tem nome e uma descrição opcional.
- **RF02** — Cada **livro** pertence a **uma única** categoria, e uma categoria pode ter
  muitos livros. O livro tem título, autor, **ISBN** (o código de 13 dígitos impresso no
  verso, que identifica a edição), ano de publicação, o estado de conservação (texto
  curto, como "ótimo", "bom" ou "desgastado") e a **quantidade** de exemplares que a
  biblioteca possui daquele livro.
- **RF03** — Cada **leitor** tem nome, **CPF**, e-mail, telefone, **CEP** do endereço e
  data de nascimento.
- **RF04** — Um leitor pode pegar emprestados vários livros ao longo do tempo, e um mesmo
  livro pode ser emprestado a vários leitores (em momentos diferentes).
- **RF05** — Cada **empréstimo** é um registro próprio: **o mesmo leitor pode pegar o
  mesmo livro mais de uma vez**, em datas diferentes.
- **RF06** — O empréstimo guarda a data em que o livro saiu, a data prevista de devolução
  e a data em que o livro de fato voltou, que fica vazia enquanto o livro não for
  devolvido.

**Requisitos Não Funcionais**

- **RNF01** — Todo o SQL deve seguir as convenções de nomenclatura da disciplina.
- **RNF02** — Não pode haver duas categorias com o mesmo nome, dois livros com o mesmo
  ISBN, nem dois leitores com o mesmo CPF.
- **RNF03** — A quantidade de exemplares de um livro não pode ser negativa.
- **RNF04** — A data prevista de devolução não pode ser anterior à data do empréstimo,
  e a data de devolução, quando preenchida, também não.
- **RNF05** — Não pode ser possível excluir uma categoria que ainda possua livros, nem
  um livro ou um leitor que já possua empréstimos: o histórico não pode ser apagado
  silenciosamente.
- **RNF06** — O banco deve registrar, em todas as tabelas, quando cada registro foi
  criado, quando foi alterado pela última vez e quando foi excluído (exclusão lógica).
- **RNF07** — O script deve poder ser executado várias vezes seguidas, sem gerar erro.

---

## 🐾 Cenário B — Clínica Veterinária (computador **par**)

A **Clínica Amigo Fiel** é uma clínica veterinária de bairro que quer deixar a ficha de
papel de lado. Hoje, para saber quando o Thor tomou a última vacina ou quanto foi cobrado
no banho do mês passado, a recepcionista precisa revirar o fichário.

A partir da especificação abaixo, faça a modelagem e escreva o SQL que cria o banco de
dados **`clinica_amigo_fiel`**, com uma configuração adequada a um sistema em português.

**Requisitos Funcionais**

- **RF01** — Cada **tutor** (o dono do bicho) tem nome, **CPF**, telefone, e-mail e
  **CEP** do endereço.
- **RF02** — Um tutor pode ter vários **pets**, mas cada pet pertence a **um único**
  tutor. O pet tem nome, espécie (texto curto, como "cão" ou "gato"), raça (opcional,
  pois nem todo pet tem raça definida) e data de nascimento (opcional).
- **RF03** — A clínica mantém um **catálogo de procedimentos** (ex.: "Vacina
  antirrábica", "Banho e tosa", "Consulta clínica"), cada um com nome, descrição opcional
  e o **valor de tabela** em reais.
- **RF04** — Um pet pode receber vários procedimentos ao longo da vida, e um mesmo
  procedimento pode ser feito em vários pets.
- **RF05** — Cada **atendimento** é um registro próprio: **o mesmo pet pode receber o
  mesmo procedimento mais de uma vez**, em datas diferentes (a vacina é anual, por
  exemplo).
- **RF06** — O atendimento guarda a data e hora em que aconteceu, a **quantidade**
  aplicada do procedimento (por exemplo, número de doses ou de sessões), o **valor
  realmente cobrado** (que pode ser diferente do valor de tabela, por causa de desconto)
  e observações opcionais.

**Requisitos Não Funcionais**

- **RNF01** — Todo o SQL deve seguir as convenções de nomenclatura da disciplina.
- **RNF02** — Não pode haver dois tutores com o mesmo CPF, nem dois procedimentos com o
  mesmo nome.
- **RNF03** — O valor de tabela de um procedimento e o valor cobrado em um atendimento
  não podem ser negativos.
- **RNF04** — A quantidade aplicada em um atendimento deve ser de pelo menos 1.
- **RNF05** — Não pode ser possível excluir um tutor que ainda possua pets, nem um pet ou
  um procedimento que já possua atendimentos: o histórico não pode ser apagado
  silenciosamente.
- **RNF06** — O banco deve registrar, em todas as tabelas, quando cada registro foi
  criado, quando foi alterado pela última vez e quando foi excluído (exclusão lógica).
- **RNF07** — O script deve poder ser executado várias vezes seguidas, sem gerar erro.

---

## 🎯 Como será a correção (4,0 pontos)

| Item | Pontos |
|---|---|
| Pergunta 1 — FK no 1:N | 0,5 |
| Pergunta 2 — escolha dos tipos (`quantidade`, `cpf`, `cep`) | 0,5 |
| Pergunta 3 — especialização na modelagem | 0,5 |
| Pergunta 4 — normalização | 0,5 |
| Script SQL (banco e 4 tabelas, 1:N, N:M com tabela intermediária, nomenclatura, tipos, restrições, reexecução) | 2,0 |

---

🔑 O gabarito será postado pelo professor **depois da avaliação**.

---

⬅️ [Voltar para Atividades e Avaliações](index.md)

---

*Fatec Jahu · IBD015 · Prof. Ronan Adriel Zenatti · 2026*
