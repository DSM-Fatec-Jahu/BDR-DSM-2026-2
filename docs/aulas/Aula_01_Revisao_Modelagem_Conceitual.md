# Aula 01 — Revisão de Modelagem de Dados (Conceitual)

**Disciplina:** Banco de Dados — Relacional (IBD015)
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br
**Fatec Jahu — 2º Semestre/2026**

---

## 🎯 Objetivos da Aula

Ao final desta aula você deverá ser capaz de:

- Diferenciar dado, informação e conhecimento, situando o papel da modelagem de dados nesse processo;
- Identificar e diferenciar os elementos fundamentais de um Modelo Entidade-Relacionamento (MER): entidades, atributos e relacionamentos;
- Aplicar corretamente os conceitos de cardinalidade e participação para representar as regras de negócio de um sistema real em um diagrama conceitual;
- Reconhecer casos especiais de relacionamento — auto-relacionamento e relacionamento ternário;
- Aplicar um método prático (as "quatro perguntas-chave") para decidir, sem dúvida, se uma informação deve virar entidade ou atributo;
- Compreender os mecanismos de **generalização e especialização** para modelar hierarquias entre entidades.

---

## 🗺️ Mapa Mental da Aula

```mermaid
flowchart LR
    ROOT(("Modelo Entidade-<br/>Relacionamento (MER)"))

    ROOT --> DIC
    subgraph DIC["🔢 Dado → Informação<br/>→ Conhecimento"]
        direction TB
        DIC1["Dado = fato bruto"]
        DIC2["Informação = dado<br/>com contexto"]
        DIC3["Conhecimento = padrão<br/>acumulado"]
    end

    ROOT --> ENT
    subgraph ENT["🧱 Entidades"]
        direction TB
        ENT1["Forte"]
        ENT2["Fraca"]
    end

    ROOT --> ATR
    subgraph ATR["🏷️ Atributos"]
        direction TB
        ATR1["Simples"]
        ATR2["Composto"]
        ATR3["Multivalorado"]
        ATR4["Derivado"]
        ATR5["Chave"]
    end

    ROOT --> REL
    subgraph REL["🔗 Relacionamentos"]
        direction TB
        REL1["Cardinalidade<br/>1:1 · 1:N · N:M"]
        REL2["Participação<br/>Total · Parcial"]
        REL3["Casos especiais<br/>Auto-relac. · Ternário"]
    end

    ROOT --> NOT
    subgraph NOT["📐 Notações"]
        direction TB
        NOT1["Peter Chen"]
        NOT2["Crow's Foot"]
    end

    ROOT --> GE
    subgraph GE["🧬 Generalização /<br/>Especialização"]
        direction TB
        GE1["Superclasse → Subclasse<br/>(herança)"]
        GE2["Total/Parcial ×<br/>Exclusiva/Sobreposta"]
    end
```

---

## 🔢 Dado, Informação e Conhecimento

Antes de desenhar qualquer diagrama, vale revisar uma distinção que sustenta tudo o que vem a seguir: o que exatamente um banco de dados armazena?

Um **dado** é um fato bruto, isolado, sem contexto — por exemplo, o número `2026001`. Sozinho, ele não diz nada. Quando esse número ganha contexto — *"matrícula 2026001 pertence ao aluno João Silva"* — temos uma **informação**: algo interpretável, que já orienta uma decisão. O **conhecimento** surge quando acumulamos e cruzamos informações ao longo do tempo, revelando padrões — por exemplo, perceber que alunos matriculados no primeiro semestre letivo têm uma taxa de evasão maior que os do segundo.

```mermaid
flowchart LR
    A["🔢 Dado
(fato bruto, sem contexto)
Ex: 2026001"] --> B["📊 Informação
(dado + contexto)
Ex: matrícula do aluno João Silva"]
    B --> C["🧠 Conhecimento
(informação + experiência acumulada)
Ex: padrão de evasão por semestre"]
```

Essa distinção importa porque é exatamente isso que um banco de dados existe para gerenciar: ele armazena **dados**, estruturados de forma que a aplicação consiga transformá-los em **informação** útil para quem consulta — e, com o tempo e a análise adequada, em **conhecimento** para quem decide. A modelagem — o assunto do restante desta aula — é o processo de decidir *como* estruturar esses dados para que essa transformação seja possível, consistente e eficiente.

✅ **Verificação Rápida — Dado, Informação e Conhecimento.** Bloco puramente conceitual — sem exercício prático ainda, então confira seu entendimento com os dois quizzes abaixo. A resposta é revelada na hora.

<quiz>
Um sensor de qualidade do ar instalado em um cruzamento de uma cidade inteligente registra, a cada minuto, o valor bruto "38 µg/m³" para a concentração de material particulado (PM2.5). Sozinho, sem nenhum outro contexto associado, esse valor é um exemplo de:
- [ ] Informação, porque já vem com unidade de medida
- [x] Dado, porque é um fato isolado sem contexto que permita uma decisão
- [ ] Conhecimento, porque foi gerado por um sensor automatizado
- [ ] Nenhuma das opções — sensores geram sinais elétricos, não dados

O valor "38 µg/m³" sozinho é um fato bruto: não diz se está acima do limite seguro, em qual cruzamento, nem se é normal para aquele horário. Só vira informação quando ganha esse contexto.
</quiz>

<quiz>
A prefeitura cruza os registros de PM2.5 de 200 sensores espalhados pela cidade ao longo de dois anos e percebe que a poluição do ar sobe consistentemente entre 17h e 19h em dias úteis, coincidindo com o horário de pico de tráfego. Esse padrão identificado é um exemplo de:
- [ ] Dado
- [ ] Informação
- [x] Conhecimento
- [ ] Metadado

Conhecimento surge do acúmulo e cruzamento de informações ao longo do tempo, revelando um padrão — o pico de poluição associado ao tráfego — que nenhuma leitura isolada de sensor revelaria sozinha.
</quiz>

---

## 🧭 Por que começamos pela Modelagem Conceitual?

Imagine que você foi contratado para construir um sistema de gerenciamento de uma biblioteca. Antes de escrever uma única linha de código SQL, você precisa responder: *Quais informações o sistema precisa armazenar? Como essas informações se relacionam entre si?* É exatamente para responder a essas perguntas que existe a **modelagem de dados**.

A modelagem passa por três grandes etapas, e é importante entender como elas se conectam:

![Fases da modelagem](../imgs/Aula_01_IMG_01.png)


A **Modelagem Conceitual** é a primeira etapa — ela é independente de qualquer tecnologia ou banco de dados específico. Aqui, o objetivo é representar o mundo real de forma abstrata, compreensível tanto pelo desenvolvedor quanto pelo cliente. Pense nela como uma planta arquitetônica: antes de construir, você desenha.

A **Modelagem Lógica** transforma esse diagrama conceitual em estruturas de tabelas, colunas e relacionamentos — ainda independente do SGBD escolhido, mas já com a linguagem do modelo relacional.

A **Modelagem Física** é a implementação final em SQL, considerando o SGBD específico (MySQL, PostgreSQL, SQL Server etc.) com seus tipos de dados, índices e particularidades.

Nesta aula, nosso foco é a **etapa conceitual**, usando a abordagem mais consagrada para isso: o **Modelo Entidade-Relacionamento**.

---

## 1. O Modelo Entidade-Relacionamento (MER)

O MER foi proposto por **Peter Chen em 1976** e até hoje é a forma mais utilizada para modelagem conceitual de bancos de dados. Ele é composto por três elementos principais: **Entidades**, **Atributos** e **Relacionamentos**. Vamos explorar cada um deles com profundidade.

---

## 2. Entidades

Uma **entidade** representa algo do mundo real sobre o qual queremos armazenar informações. Pode ser um objeto concreto (como um livro ou um produto), uma pessoa (como um aluno ou um funcionário), ou até um evento (como uma venda ou uma matrícula).

> 💡 **Regra prática:** se você consegue contar unidades daquilo e elas têm características próprias que vale a pena guardar, provavelmente é uma entidade.

Por exemplo, em um sistema de uma faculdade, as entidades naturais seriam **Aluno**, **Disciplina**, **Professor** e **Curso**. Cada aluno individual — como "João Silva, matrícula 2026001" — é chamado de **instância** ou **ocorrência** da entidade Aluno.

### 2.1 Tipos de Entidades

Existem dois tipos de entidades que você encontrará com frequência:

A **Entidade Forte** existe por si mesma, sem depender de outra entidade. Por exemplo, **Aluno** existe independentemente de qualquer outra coisa no sistema.

A **Entidade Fraca** não tem existência independente — ela só faz sentido em relação a outra entidade. O exemplo clássico é **Dependente** em relação a **Funcionário**: um dependente só existe no sistema porque está vinculado a um funcionário. Se o funcionário for removido, o dependente perde sentido.

> 🔍 **Checkpoint 1 — Entidades: app de patinetes elétricos.** Uma startup está modelando o banco de dados do seu aplicativo de aluguel de patinetes elétricos compartilhados. No sistema existem `Usuários` (que alugam os patinetes), `Patinetes` (cada um com número de série, nível de bateria e localização), `Estações de Recarga` (pontos físicos onde os patinetes ficam disponíveis para retirada) e `Manutenções` (registros de reparo que só existem porque estão vinculados a um patinete específico — se o patinete for removido do sistema, o registro de manutenção perde sentido). Para cada uma dessas quatro entidades, classifique-a como **forte** ou **fraca**, justificando em uma frase.
>
> 🔑 Resolução no [Gabarito da Aula 01](Aula_01_Gabarito.md#checkpoint-1) — tente resolver antes de conferir.

---

## 3. Atributos

**Atributos** são as propriedades ou características de uma entidade. Se a entidade é **Produto**, seus atributos seriam `nome`, `preco`, `descricao` e `quantidade_em_estoque`.

### 3.1 Tipos de Atributos

Entender os tipos de atributos é fundamental para fazer uma modelagem precisa. Veja os principais:

**Atributo Simples (ou Atômico):** não pode ser subdividido. Exemplo: `cpf`, `data_nascimento`, `preco`.

**Atributo Composto:** pode ser dividido em partes menores com significado próprio. O clássico exemplo é `endereco`, que pode ser dividido em `rua`, `numero`, `bairro`, `cidade` e `cep`. A decisão de decompô-lo ou não depende de se o sistema precisará consultar ou filtrar por partes do endereço separadamente.

**Atributo Multivalorado:** pode ter mais de um valor para uma mesma instância. Exemplo: `telefone` de um cliente — uma pessoa pode ter vários números. Na notação do MER, representa-se com **dupla elipse**.

**Atributo Derivado:** seu valor pode ser calculado a partir de outro atributo. Exemplo: `idade` pode ser derivada de `data_nascimento`. Na notação, usa-se **elipse tracejada**.

**Atributo Chave (ou Identificador):** é o atributo cujo valor identifica unicamente cada instância da entidade. Exemplo: `cpf` para Pessoa, `matricula` para Aluno. Na notação do MER, é sublinhado.

> 🔑 **Nível conceitual vs. chave real de banco de dados:** aqui, no MER, identificar `cpf` ou `matricula` como atributo chave é só reconhecer o que identifica cada instância no mundo real — é assim que a literatura acadêmica costuma nomear. Quando esse modelo virar tabela de verdade (Aula 02 em diante), a chave primária efetivamente usada **não** vai ser o `cpf` nem a `matricula`, e sim um identificador substituto `id_` criado pelo banco — você vai entender exatamente o porquê na Aula 02.

![Atributos](../imgs/Aula_01_IMG_02.png)

> 🔍 **Checkpoint 2 — Atributos: reserva de sala em coworking.** Uma rede de coworkings está modelando a entidade `Reservas` para permitir que membros reservem salas de reunião pelo aplicativo. Os dados coletados no formulário de reserva são: `codigo_reserva` (identificador único gerado no ato da reserva), `endereco_unidade` (rua, número, bairro, cidade e CEP da unidade escolhida), `data_hora_inicio`, `data_hora_fim`, `duracao_minutos` (calculada a partir do início e do fim) e `recursos_solicitados` (o membro pode marcar quantos quiser, entre projetor, quadro branco, cafeteira e webcam para videoconferência). Classifique cada um desses cinco atributos quanto ao tipo — simples, composto, multivalorado, derivado ou chave — justificando cada classificação.
>
> 🔑 Resolução no [Gabarito da Aula 01](Aula_01_Gabarito.md#checkpoint-2) — tente resolver antes de conferir.

---

## 4. Relacionamentos

Um **relacionamento** representa uma associação ou ligação entre duas ou mais entidades. No exemplo da faculdade, existe um relacionamento entre **Aluno** e **Disciplina**, pois alunos *cursam* disciplinas.

O nome dado ao relacionamento — chamado de **verbo do relacionamento** — deve descrever a natureza dessa associação do ponto de vista do negócio: *cursa*, *leciona*, *pertence a*, *realiza*.

### 4.1 Cardinalidade

A **cardinalidade** é o conceito mais importante de um relacionamento. Ela define **quantas instâncias** de uma entidade podem se associar a instâncias da outra entidade. Existem três tipos básicos:

**Um para Um (1:1):** uma instância de A se relaciona com no máximo uma instância de B, e vice-versa. Exemplo: um **Funcionário** possui um **Crachá**, e um crachá pertence a apenas um funcionário.

**Um para Muitos (1:N):** uma instância de A se relaciona com várias instâncias de B, mas cada instância de B se relaciona com apenas uma de A. Este é o mais comum! Exemplo: um **Departamento** possui muitos **Funcionários**, mas cada funcionário pertence a apenas um departamento.

**Muitos para Muitos (N:M):** uma instância de A se relaciona com várias de B, e uma instância de B se relaciona com várias de A. Exemplo: um **Aluno** cursa várias **Disciplinas**, e uma disciplina é cursada por vários alunos.

> 🔑 **Ponto de atenção:** relacionamentos N:M na modelagem conceitual são perfeitamente válidos, mas na passagem para o modelo lógico sempre serão resolvidos com a criação de uma **tabela intermediária** (também chamada de tabela associativa ou tabela de junção). Veremos isso na Aula 02.

### 4.2 Participação (ou Modalidade)

Além da cardinalidade, os relacionamentos possuem **participação**, que define se a presença em um relacionamento é obrigatória ou opcional.

A **participação total** (obrigatória) indica que toda instância da entidade *deve* participar do relacionamento. Representa-se com **linha dupla** no diagrama. Exemplo: todo **Pedido** deve estar associado a pelo menos um **Cliente** — não existe pedido sem cliente.

A **participação parcial** (opcional) indica que a entidade *pode* participar do relacionamento, mas não é obrigada. Exemplo: um **Cliente** pode ter feito zero pedidos (é um cliente cadastrado que ainda não comprou nada).

💡[Material completo sobre Cardinalidade](Cardinalidade_MER_Completo.md)

### 4.3 Casos Especiais: Auto-Relacionamento e Relacionamento Ternário

Além dos relacionamentos "normais" entre duas entidades diferentes, existem dois casos especiais que aparecem com frequência suficiente para merecer atenção própria.

**Auto-relacionamento:** ocorre quando uma entidade se relaciona **com ela mesma**. O exemplo clássico é uma hierarquia de supervisão: um **Funcionário** pode supervisionar outros funcionários, e cada funcionário tem (ou não) um supervisor — que também é um funcionário.

```mermaid
erDiagram
    FUNCIONARIOS {
        BIGINT id_funcionario PK
        VARCHAR nome
        BIGINT supervisor_id FK
    }
    FUNCIONARIOS ||--o{ FUNCIONARIOS : "supervisiona"
```

> 🔑 **Repare no nome da chave estrangeira:** ela não se chama `funcionario_id` — se chamasse, seria impossível saber, só pelo nome da coluna, se ela representa "o funcionário" ou "o supervisor dele" (afinal, ambos são registros da mesma tabela). Por isso, quando a FK referencia uma tabela cuja entidade pode exercer **papéis diferentes** dentro do relacionamento, o nome usa o **papel** em vez do nome da tabela: `supervisor_id`. Você vai ver essa e outras convenções de nomenclatura formalizadas na Aula 03.

**Relacionamento ternário:** ocorre quando **três entidades** participam de um único relacionamento, e a combinação das três é que define a ocorrência — não faz sentido analisar duas delas isoladamente. Exemplo: um **Médico** prescreve um **Medicamento** para um **Paciente**. Registrar apenas "médico prescreve medicamento" sem saber para qual paciente perde informação essencial da regra de negócio.

```mermaid
erDiagram
    MEDICOS }o--o{ MEDICAMENTOS : "prescreve"
    MEDICAMENTOS }o--o{ PACIENTES : "prescrito a"
    MEDICOS }o--o{ PACIENTES : "atende"
```

> 💡 Relacionamentos ternários são mais raros e mais complexos de mapear para o modelo lógico — use-os apenas quando o negócio realmente exigir que as três entidades sejam analisadas em conjunto. Na dúvida, verifique se o relacionamento não pode ser decomposto em dois relacionamentos binários mais simples.

> 🔍 **Checkpoint 3 — Relacionamentos: plataforma de créditos de carbono.** Uma plataforma de créditos de carbono conecta `Empresas` (que precisam compensar suas emissões) a `Projetos Ambientais` (reflorestamento, energia solar, captura de metano). Toda vez que uma empresa compra créditos de um projeto, é gerado um registro de `Compensação` com a quantidade de toneladas de CO2 e a data da transação — e esse registro também precisa indicar qual `Auditor Certificador` validou aquela transação específica (o mesmo projeto pode ter compensações validadas por auditores diferentes, em datas diferentes). Além disso, uma empresa pode indicar outra empresa parceira para entrar na plataforma, ganhando desconto na taxa — e essa parceira, no futuro, também pode indicar outras.
>
> a) Que tipo de relacionamento (binário ou ternário) conecta Empresa, Projeto Ambiental e Auditor Certificador em Compensação? Justifique.
> b) Qual é a cardinalidade e a participação (total ou parcial) entre Empresas e Compensações? Toda empresa cadastrada precisa ter feito ao menos uma compensação?
> c) O relacionamento de indicação entre empresas parceiras é um exemplo de qual caso especial visto nesta aula? Explique por que a FK que ele gera não pode se chamar simplesmente `empresa_id`.
>
> 🔑 Resolução no [Gabarito da Aula 01](Aula_01_Gabarito.md#checkpoint-3) — tente resolver antes de conferir.

---

## 5. Notações do MER

Existem diferentes notações visuais para representar um MER. As mais comuns são:

A **Notação de Peter Chen** (a original) usa retângulos para entidades, elipses para atributos e losangos para relacionamentos. É muito utilizada em contextos acadêmicos por ser visualmente explicativa.

A **Notação Pé-de-Galinha** (*Crow's Foot*) é mais compacta e amplamente usada em ferramentas CASE e no mercado de trabalho. Representa a cardinalidade com símbolos na ponta das linhas de relacionamento que lembram garras ou pés de galinha.

Nesta disciplina, utilizaremos a **notação Crow's Foot** nos diagramas, pois é a padrão em ferramentas como MySQL Workbench, dbdiagram.io e outras que vocês usarão profissionalmente.

---

## 6. Diagrama Completo — Exemplo de Sistema Acadêmico

Vamos construir juntos um MER para um sistema acadêmico simplificado, com as seguintes regras de negócio:

- Um **Curso** possui muitas **Disciplinas**, mas cada disciplina pertence a apenas um curso.
- Um **Professor** pode lecionar várias **Disciplinas**, e uma disciplina pode ser lecionada por vários professores (em semestres diferentes, por exemplo).
- Um **Aluno** está matriculado em apenas um **Curso**, e um curso possui muitos alunos.
- Um **Aluno** pode se matricular em várias **Disciplinas**, e cada disciplina pode ter muitos alunos matriculados. Essa matrícula possui uma **nota** associada.

O diagrama abaixo representa esse modelo usando a notação Crow's Foot com Mermaid:

```mermaid
erDiagram
    CURSOS {
        BIGINT id_curso PK
        VARCHAR nome
        INT duracao_semestres
    }

    DISCIPLINAS {
        BIGINT id_disciplina PK
        VARCHAR nome
        VARCHAR sigla
        INT carga_horaria
        BIGINT curso_id FK
    }

    PROFESSORES {
        BIGINT id_professor PK
        VARCHAR nome
        VARCHAR email
        VARCHAR titulacao
    }

    ALUNOS {
        BIGINT id_aluno PK
        VARCHAR nome
        VARCHAR cpf
        DATE data_nascimento
        BIGINT curso_id FK
    }

    MATRICULAS {
        BIGINT id_matricula PK
        BIGINT aluno_id FK
        BIGINT disciplina_id FK
        DECIMAL nota
        VARCHAR situacao
    }

    LECIONAM {
        BIGINT professor_id FK
        BIGINT disciplina_id FK
        VARCHAR semestre
    }

    CURSOS ||--o{ DISCIPLINAS : "possui"
    CURSOS ||--o{ ALUNOS : "possui"
    ALUNOS ||--o{ MATRICULAS : "realiza"
    DISCIPLINAS ||--o{ MATRICULAS : "recebe"
    PROFESSORES }o--o{ DISCIPLINAS : "leciona"
```

> 📌 **Leitura do diagrama:** a notação `||--o{` significa "um e apenas um para zero ou muitos". Lemos a linha entre CURSO e DISCIPLINA como: *"um Curso possui zero ou muitas Disciplinas, e cada Disciplina pertence a exatamente um Curso"*.

---

## 7. Lendo as Regras de Negócio do Diagrama

Um exercício muito importante — e que cai em avaliações — é a capacidade de **ler um diagrama e extrair as regras de negócio** que ele representa, ou o inverso: receber as regras e construir o diagrama.

Treine com o diagrama acima:

Olhando a linha entre **ALUNOS** e **MATRICULAS**: o `||` do lado do Aluno indica participação de "um e apenas um" — cada matrícula pertence a exatamente um aluno. O `o{` do lado da Matrícula indica "zero ou muitos" — um aluno pode ter zero ou muitas matrículas. Traduzindo: *um aluno pode se matricular em zero ou muitas disciplinas, e cada matrícula pertence a exatamente um aluno*.

---

## 8. Generalização e Especialização

Até aqui modelamos entidades de forma independente. Mas e quando percebemos que duas ou mais entidades compartilham um conjunto de atributos em comum, diferindo apenas em alguns atributos específicos? É para esse cenário que existe o mecanismo de **generalização e especialização**.

**O problema que motiva o conceito.** Imagine que você está modelando o sistema de uma locadora de veículos que trabalha com **carros**, **motos** e **caminhões**. Todos eles têm `placa`, `ano_fabricacao`, `cor` e `quilometragem` — mas cada tipo também tem atributos que só fazem sentido para ele: carros têm `numero_portas`, motos têm `cilindrada`, caminhões têm `capacidade_carga`. Como representar isso no modelo? Há duas saídas ingênuas e uma correta:

- ❌ **Abordagem 1 — uma entidade só:** criar uma única entidade `Veículo` com *todos* os atributos de todos os tipos. Resultado: cada carro fica com `cilindrada` vazia, cada moto fica com `capacidade_carga` vazia — muitos campos nulos e a impossibilidade de exigir corretamente o que é obrigatório para cada tipo.
- ❌ **Abordagem 2 — três entidades totalmente separadas:** criar `Carro`, `Moto` e `Caminhão` independentes, repetindo `placa`, `ano_fabricacao`, `cor` e `quilometragem` em cada uma. Resultado: redundância e risco de inconsistência (a mesma ideia de "veículo" definida em três lugares diferentes).
- ✅ **Abordagem correta — generalizar/especializar:** criar uma entidade genérica `Veículo` com os atributos **comuns**, e entidades especializadas `Carro`, `Moto` e `Caminhão` só com os atributos **exclusivos** de cada uma, herdando o resto de `Veículo`.

Visualmente, essa terceira abordagem forma uma **hierarquia** — uma superclasse no topo e as subclasses abaixo, cada uma acrescentando o que lhe é próprio:

```mermaid
flowchart TB
    VEIC["🚗 VEÍCULO (superclasse)<br/>placa · ano_fabricacao<br/>cor · quilometragem"]
    CAR["🚘 CARRO<br/>numero_portas · tipo_cambio"]
    MOT["🏍️ MOTO<br/>cilindrada · tem_sidecar"]
    CAM["🚛 CAMINHÃO<br/>capacidade_carga · numero_eixos"]

    VEIC -->|"é um"| CAR
    VEIC -->|"é um"| MOT
    VEIC -->|"é um"| CAM
```

Guarde essa imagem mental — todo o restante desta seção é sobre como ler, restringir e implementar esse tipo de hierarquia. Vamos aos conceitos formais.

### 8.1 O que é Generalização?

A **generalização** é um processo **bottom-up** (de baixo para cima): você parte de entidades específicas já identificadas e abstrai o que elas têm em comum para criar uma entidade mais genérica — chamada de **superclasse** ou **entidade genérica**.

Pense no raciocínio: *"Aluno e Professor têm nome, CPF, e-mail e data de nascimento. O que eles têm em comum pode ser abstraído em uma entidade Pessoa."* Você estava olhando para as partes e generalizou para o todo.

### 8.2 O que é Especialização?

A **especialização** é o processo inverso — **top-down** (de cima para baixo): você parte de uma entidade genérica e a divide em subtipos mais específicos — chamados de **subclasses** ou **entidades especializadas** — que possuem atributos ou relacionamentos próprios, além dos herdados da superclasse.

Pense no raciocínio: *"Uma Pessoa pode ser Cliente ou Funcionário. Clientes têm histórico de compras; Funcionários têm cargo e salário. Vou especializar Pessoa nessas duas subclasses."* Você estava olhando para o todo e especializou nas partes.

> 💡 **Na prática, generalização e especialização são dois lados da mesma moeda.** O resultado no diagrama é idêntico — uma hierarquia com superclasse e subclasses. A diferença é apenas no raciocínio que levou até lá: você subiu das partes para o todo (generalização) ou desceu do todo para as partes (especialização).

### 8.3 Herança de Atributos

A principal vantagem desse mecanismo é a **herança**: toda subclasse automaticamente herda todos os atributos e relacionamentos da superclasse, além de possuir os seus próprios.

```
PESSOAS (superclasse)
│   ├── id_pessoa
│   ├── nome
│   ├── cpf
│   └── email
│
├── CLIENTES (subclasse — herda tudo de PESSOAS, acrescenta:)
│       ├── data_primeiro_pedido
│       └── limite_credito
│
└── FUNCIONARIOS (subclasse — herda tudo de PESSOAS, acrescenta:)
        ├── cargo
        ├── salario
        └── data_admissao
```

Uma instância de CLIENTES **é uma** PESSOA — ela tem nome, CPF e e-mail (herdados), mais os atributos específicos de cliente. Esse é o princípio central da herança: a relação entre subclasse e superclasse é sempre do tipo **"é um"** (*is-a*).

### 8.4 Restrições de Generalização/Especialização

Existem duas dimensões de restrição que você deve indicar no diagrama:

#### Quanto à obrigatoriedade (participação):

**Total:** toda instância da superclasse *obrigatoriamente* pertence a pelo menos uma subclasse. Não existe uma "Pessoa genérica" — ela é sempre ou Cliente ou Funcionário (ou ambos). Representa-se com linha dupla ou a palavra `{total}` no diagrama.

**Parcial:** uma instância da superclasse *pode* não pertencer a nenhuma subclasse. Existe a possibilidade de uma "Pessoa genérica" no sistema, sem ser cliente nem funcionário. Representa-se com linha simples ou a palavra `{parcial}`.

#### Quanto à exclusividade:

**Exclusiva (disjunta):** uma instância da superclasse pertence a **no máximo uma** subclasse. Uma pessoa é ou Cliente ou Funcionário — nunca os dois ao mesmo tempo. Representa-se com a letra **d** (*disjoint*) ou o símbolo **⊕** no diagrama.

**Sobreposta (overlapping):** uma instância da superclasse pode pertencer a **mais de uma** subclasse simultaneamente. Uma pessoa pode ser Cliente e Funcionário ao mesmo tempo (ex.: um funcionário que também compra na loja onde trabalha). Representa-se com a letra **o** (*overlapping*) ou o símbolo **○**.

A combinação dessas duas dimensões gera quatro tipos possíveis:

| Tipo | Obrigatoriedade | Exclusividade | Significado |
|---|---|---|---|
| Total Exclusiva | Todo indivíduo da superclasse está em uma subclasse | Em no máximo uma | Nenhum "genérico"; subclasses não se sobrepõem |
| Total Sobreposta | Todo indivíduo está em pelo menos uma subclasse | Pode estar em mais de uma | Nenhum "genérico"; subclasses podem se sobrepor |
| Parcial Exclusiva | Pode existir "genérico" | Em no máximo uma | Subclasses não se sobrepõem |
| Parcial Sobreposta | Pode existir "genérico" | Pode estar em mais de uma | Caso mais flexível |

**Visualizando a exclusividade.** A diferença entre *exclusiva* e *sobreposta* é a que mais confunde — e um desenho resolve. Compare os dois casos abaixo: no primeiro, cada instância cai em **no máximo uma** subclasse; no segundo, uma mesma instância pode estar em **mais de uma** ao mesmo tempo.

```mermaid
flowchart TB
    V["🚗 VEÍCULO"]
    C["🚘 CARRO"]
    M["🏍️ MOTO"]
    V -->|"d — no máximo uma"| C
    V -->|"d"| M
```

*Exclusiva (disjunta, **d**): um veículo é carro **ou** moto — nunca os dois.*

```mermaid
flowchart TB
    P["👤 PESSOA"]
    CLI["🛒 CLIENTE"]
    FUN["💼 FUNCIONÁRIO"]
    P -->|"o — pode mais de uma"| CLI
    P -->|"o"| FUN
```

*Sobreposta (**o**): uma pessoa pode ser cliente **e** funcionário ao mesmo tempo.*

#### Quando (e quando não) usar generalização/especialização

Nem toda diferença entre instâncias justifica uma hierarquia. Use esta tabela como checklist ao ler um enunciado — se um dos sinais da esquerda aparecer, a hierarquia provavelmente se justifica:

| Sinal no enunciado | O que costuma indicar |
|---|---|
| *"Existem dois (ou mais) tipos de X…"* | Provável especialização de `X` |
| *"Todo Y é também um X, mas com características a mais…"* | Hierarquia de herança (`Y` é subclasse de `X`) |
| *"X pode ser A, B ou C"* (sempre um só) | Especialização **exclusiva (disjunta)** |
| *"X pode ser A e B ao mesmo tempo"* | Especialização **sobreposta** |
| *"Alguns campos só se aplicam a certos tipos de X"* | Atributos exclusivos de subclasse |

> ⚠️ **Não force a hierarquia.** Se as subclasses candidatas não têm nenhum atributo ou relacionamento próprio além dos herdados, a hierarquia é desnecessária — resolva com uma coluna `tipo` na própria entidade e evite complexidade sem ganho. Voltaremos a esse ponto nos Erros Comuns (Seção 10).

### 8.5 Exemplos de Generalização

**Exemplo 1 — Generalização de Veículos:**

Ao modelar um sistema de locadora, você identificou separadamente as entidades **Carros**, **Motos** e **Caminhãos**. Percebeu que todas têm placa, ano de fabricação, cor e quilometragem. Ao generalizar, você cria **Veículos** como superclasse.

```mermaid
erDiagram
    VEICULOS {
        BIGINT id_veiculo PK
        VARCHAR placa
        INT ano_fabricacao
        VARCHAR cor
        INT quilometragem
    }

    CARROS {
        BIGINT id_veiculo PK, FK
        INT numero_portas
        VARCHAR tipo_cambio
    }

    MOTOS {
        BIGINT id_veiculo PK, FK
        VARCHAR cilindrada
        TINYINT tem_sidecar
    }

    CAMINHAOS {
        BIGINT id_veiculo PK, FK
        DECIMAL capacidade_carga_ton
        INT numero_eixos
    }

    VEICULOS ||--o| CARROS     : "é um"
    VEICULOS ||--o| MOTOS      : "é um"
    VEICULOS ||--o| CAMINHAOS  : "é um"
```

Restrição: **Total Exclusiva** — todo veículo cadastrado é obrigatoriamente um carro, uma moto ou um caminhão; e não pode ser dois ao mesmo tempo.

---

**Exemplo 2 — Generalização de Contas Bancárias:**

Em um sistema bancário, você identificou **Contas Correntes** e **Contas Poupanças**. Ambas têm número de conta, saldo e data de abertura. Ao generalizar: **Contas** é a superclasse.

```mermaid
erDiagram
    CONTAS {
        BIGINT id_conta PK
        VARCHAR numero_conta
        DECIMAL saldo
        DATE data_abertura
        BIGINT cliente_id FK
    }

    CONTAS_CORRENTES {
        BIGINT id_conta PK, FK
        DECIMAL limite_cheque_especial
        DECIMAL taxa_manutencao
    }

    CONTAS_POUPANCAS {
        BIGINT id_conta PK, FK
        DECIMAL taxa_rendimento
        DATE data_aniversario
    }

    CONTAS ||--o| CONTAS_CORRENTES : "é uma"
    CONTAS ||--o| CONTAS_POUPANCAS : "é uma"
```

Restrição: **Total Exclusiva** — toda conta é corrente ou poupança, nunca as duas.

---

**Exemplo 3 — Generalização de Pessoas em um Hospital:**

Ao modelar um sistema hospitalar, você identificou **Médicos**, **Enfermeiros** e **Pacientes** como entidades separadas. Todas têm nome, CPF, data de nascimento e telefone. Ao generalizar: **Pessoa** é a superclasse.

```mermaid
erDiagram
    PESSOAS {
        BIGINT id_pessoa PK
        VARCHAR nome
        CHAR cpf
        DATE data_nascimento
        CHAR telefone
    }

    MEDICOS {
        BIGINT id_pessoa PK, FK
        VARCHAR crm
        VARCHAR especialidade
    }

    ENFERMEIROS {
        BIGINT id_pessoa PK, FK
        VARCHAR coren
        VARCHAR turno
    }

    PACIENTES {
        BIGINT id_pessoa PK, FK
        VARCHAR convenio
        VARCHAR tipo_sanguineo
    }

    PESSOAS ||--o| MEDICOS      : "é uma"
    PESSOAS ||--o| ENFERMEIROS  : "é uma"
    PESSOAS ||--o| PACIENTES    : "é uma"
```

Restrição: **Parcial Sobreposta** — uma pessoa pode ser médico e paciente ao mesmo tempo (um médico que se interna no hospital onde trabalha), e também pode existir uma pessoa cadastrada que ainda não se enquadrou em nenhuma subclasse.

### 8.6 Exemplos de Especialização

**Exemplo 1 — Especialização de Funcionário:**

Ao modelar um sistema de RH, você tem a entidade **Funcionários** com nome, CPF, salário e data de admissão. Percebe que alguns funcionários são **Gerentes** (com bônus e equipe sob responsabilidade) e outros são **Técnicos** (com certificações). Você especializa Funcionário nessas subclasses.

```mermaid
erDiagram
    FUNCIONARIOS {
        BIGINT id_funcionario PK
        VARCHAR nome
        CHAR cpf
        DECIMAL salario
        DATE data_admissao
    }

    GERENTES {
        BIGINT id_funcionario PK, FK
        DECIMAL bonus_anual
        INT tamanho_equipe
    }

    TECNICOS {
        BIGINT id_funcionario PK, FK
        VARCHAR area_tecnica
        VARCHAR nivel_certificacao
    }

    FUNCIONARIOS ||--o| GERENTES  : "é um"
    FUNCIONARIOS ||--o| TECNICOS  : "é um"
```

Restrição: **Parcial Sobreposta** — nem todo funcionário é gerente ou técnico (pode ser outro tipo); e um funcionário pode acumular as duas funções.

---

**Exemplo 2 — Especialização de Produto em E-commerce:**

Em uma loja virtual, a entidade **Produto** tem nome, preço, estoque e descrição. Ao analisar o catálogo, você identifica que produtos físicos precisam de peso e dimensões para frete, enquanto produtos digitais precisam de URL de download e tamanho em MB. Você especializa Produto.

```mermaid
erDiagram
    PRODUTOS {
        BIGINT id_produto PK
        VARCHAR nome
        DECIMAL preco
        INT estoque
        TEXT descricao
    }

    PRODUTOS_FISICOS {
        BIGINT id_produto PK, FK
        DECIMAL peso_kg
        DECIMAL altura_cm
        DECIMAL largura_cm
        DECIMAL profundidade_cm
    }

    PRODUTOS_DIGITAIS {
        BIGINT id_produto PK, FK
        VARCHAR url_download
        DECIMAL tamanho_mb
        INT validade_dias
    }

    PRODUTOS ||--o| PRODUTOS_FISICOS   : "é um"
    PRODUTOS ||--o| PRODUTOS_DIGITAIS  : "é um"
```

Restrição: **Total Exclusiva** — todo produto é obrigatoriamente físico ou digital; nunca os dois.

---

**Exemplo 3 — Especialização de Conteúdo em Streaming:**

Em uma plataforma de streaming, a entidade **Conteudos** agrupa tudo que pode ser reproduzido: tem título, duração e data de lançamento. Ao especializar, você identifica **Musicas** (com letra e álbum) e **Filmes** (com sinopse e classificação etária) como subclasses com atributos e relacionamentos distintos.

```mermaid
erDiagram
    CONTEUDOS {
        BIGINT id_conteudo PK
        VARCHAR titulo
        INT duracao_segundos
        DATE data_lancamento
    }

    MUSICAS {
        BIGINT id_conteudo PK, FK
        TEXT letra
        BIGINT album_id FK
    }

    FILMES {
        BIGINT id_conteudo PK, FK
        TEXT sinopse
        VARCHAR classificacao_etaria
    }

    ALBUNS {
        BIGINT id_album PK
        VARCHAR titulo
        VARCHAR url_capa
    }

    CONTEUDOS ||--o| MUSICAS  : "é um"
    CONTEUDOS ||--o| FILMES   : "é um"
    ALBUNS    ||--o{ MUSICAS  : "contém"
```

Restrição: **Total Exclusiva** — todo conteúdo cadastrado é música ou filme; e um conteúdo não pode ser os dois ao mesmo tempo. Este é exatamente o padrão que resolve o problema do **item de playlist** mencionado na Atividade T1.

### 8.7 Passagem para o Modelo Lógico

A hierarquia de generalização/especialização não tem representação direta no modelo relacional — ela precisa ser mapeada para tabelas. Existem três estratégias, cada uma com vantagens e desvantagens. Nesta aula descrevemos as três apenas **conceitualmente**; a sintaxe SQL para de fato criar essas tabelas fica para a Aula 03 (DDL).

> 📐 **Duas convenções de nomenclatura que você vai ver o tempo todo a partir daqui:** toda **PK** (chave primária) segue o padrão `id_` + nome da tabela no singular (ex.: `id_produto`). Toda **FK** (chave estrangeira) segue o padrão inverso: nome da tabela referenciada no singular + `_id` (ex.: `produto_id`). Repare que a ordem das palavras se inverte entre PK e FK — não é acidente, é assim que se distingue visualmente "quem é dono da linha" de "quem está apontando para outra tabela". Essas regras serão detalhadas com nomes formais (Regra 5 e Regra 6) na Aula 03.

**Estratégia 1 — Uma tabela por hierarquia inteira:** cria-se uma única tabela com todas as colunas da superclasse e de todas as subclasses, mais uma coluna discriminadora indicando o tipo de cada linha (ex.: uma coluna `tipo` com valores `fisico`/`digital`). Colunas que não se aplicam a uma subclasse ficam vazias para aquela linha. Simples de implementar, mas gera muitas colunas vazias e mistura dados de naturezas diferentes na mesma tabela.

```
produtos (tabela única)
    id_produto      — PK
    nome
    preco
    tipo            — discriminador: 'fisico' ou 'digital'
    peso_kg         — só preenchido quando tipo = 'fisico'
    url_download    — só preenchido quando tipo = 'digital'
    tamanho_mb       — só preenchido quando tipo = 'digital'
```

**Estratégia 2 — Uma tabela por subclasse (com JOIN):** cria-se uma tabela para a superclasse e uma tabela para cada subclasse. Cada subclasse tem PK própria e referencia a superclasse por FK única (garantindo o 1:1). É o padrão adotado nesta disciplina.

```
produtos (superclasse)
    id_produto          — PK

produtos_fisicos (subclasse)
    id_produto_fisico   — PK própria
    produto_id          — FK para produtos (única, garante o 1:1)
    peso_kg
```

**Estratégia 3 — Uma tabela por subclasse (sem superclasse):** cada subclasse tem sua própria tabela com todos os atributos, inclusive os herdados da superclasse. Evita a necessidade de juntar tabelas nas consultas, mas duplica a definição dos atributos comuns em cada subclasse.

> 📌 **Nesta disciplina, adotaremos sempre a Estratégia 2** — uma tabela para a superclasse e uma tabela para cada subclasse. Cada subclasse mantém sua própria PK e referencia a superclasse por FK única, preservando o 1:1 da especialização sem duplicar atributos comuns.

> 🔍 **Checkpoint 4 — Generalização/Especialização: entrega por drone e robô.** Uma empresa de logística de última milha despacha entregas usando três tipos de veículos autônomos: `Drones` (com autonomia de voo em minutos e altitude máxima), `Robôs Terrestres` (com velocidade máxima em calçadas e capacidade de subir meio-fio) e `Vans Elétricas` (com capacidade de carga em kg e autonomia em km). Os três compartilham `identificador`, `status_operacional` (disponível, em rota, em manutenção) e `localização_atual` (latitude/longitude). Toda entrega despachada usa exatamente um desses veículos, e nenhum veículo pode ser, ao mesmo tempo, de dois tipos diferentes.
>
> a) Proponha a superclasse e as três subclasses, indicando os atributos comuns (na superclasse) e os exclusivos (em cada subclasse).
> b) Qual é o tipo de restrição dessa hierarquia — quanto à obrigatoriedade e quanto à exclusividade? Justifique com base no enunciado.
> c) Seguindo a Estratégia 2 (Seção 8.7), como ficariam as tabelas do modelo lógico — nomes, PKs e FKs — para a superclasse e para a subclasse `Robôs Terrestres`?
>
> 🔑 Resolução no [Gabarito da Aula 01](Aula_01_Gabarito.md#checkpoint-4) — tente resolver antes de conferir.

---

## 9. Exemplo Prático — Sistema de Streaming (prévia do T1)

Como a **Atividade T1** desta disciplina envolve modelar um sistema de streaming integrado, vamos já começar a pensar nas entidades envolvidas. Tente identificar, a partir da descrição abaixo, quais seriam as entidades, seus atributos e relacionamentos — e onde caberia uma generalização ou especialização:

> *"Uma plataforma de streaming oferece músicas e filmes para seus usuários. As músicas fazem parte de álbuns de artistas; os filmes têm diretores e elenco. Os usuários podem criar playlists que misturem músicas e filmes na ordem que quiserem."*

Reflita: o que músicas e filmes têm em comum? Faz sentido criar uma superclasse? Qual seria a restrição (total/parcial, exclusiva/sobreposta)? Como o item de playlist referenciaria os dois tipos de conteúdo? Na **Aula 05** você desenvolverá o modelo completo desse sistema.

---

## 10. Erros Comuns na Modelagem Conceitual

Conhecer os erros mais frequentes ajuda a evitá-los. Fique atento a:

**Criar atributo quando deveria ser entidade:** se você percebe que aquele atributo tem atributos próprios e se relaciona com outras coisas, ele provavelmente deveria ser uma entidade. Exemplo: `cidade` pode ser só um atributo de texto em Cliente, mas se o sistema precisar de dados sobre cada cidade (como estado, CEP base, etc.), `Cidade` vira uma entidade.

❌ **Enquanto for só um rótulo, atributo basta:**

```mermaid
erDiagram
    CLIENTES {
        BIGINT id_cliente PK
        VARCHAR nome
        VARCHAR cidade
    }
```

✅ **Quando a cidade precisa ter dados próprios, promova-a a entidade:**

```mermaid
erDiagram
    CIDADES {
        BIGINT id_cidade PK
        VARCHAR nome
        CHAR uf
        VARCHAR cep_base
    }
    CLIENTES {
        BIGINT id_cliente PK
        VARCHAR nome
        BIGINT cidade_id FK
    }
    CIDADES ||--o{ CLIENTES : "localiza"
```

**Esquecer de nomear o relacionamento:** o nome do relacionamento deve expressar claramente a associação entre as entidades — evite nomes genéricos como "tem" ou "possui" quando algo mais preciso como "leciona" ou "pertence_a" descreve melhor o negócio.

**Confundir cardinalidade com quantidade de dados:** cardinalidade 1:N não significa que sempre haverá "muitos" — significa que *pode* haver muitos. Um departamento com um único funcionário ainda é uma relação 1:N.

**Modelar como N:M quando é 1:N:** isso acontece quando não se analisa com cuidado a regra de negócio. Sempre pergunte nos dois sentidos: *"Um A pode ter muitos B?"* e *"Um B pode ter muitos A?"*

**Usar generalização quando não há atributos específicos:** se as subclasses candidatas não têm nenhum atributo ou relacionamento próprio além dos herdados, a hierarquia provavelmente é desnecessária. Use uma coluna `tipo` com `CHECK` na própria entidade e evite complexidade sem benefício.

**Confundir generalização com relacionamento comum:** a relação "é um" (herança) é fundamentalmente diferente de "tem um" (associação). Gerente **é um** Funcionário — isso é herança. Funcionário **tem um** Departamento — isso é relacionamento. Aplique generalização somente quando a relação semântica for realmente de subtipagem.

✅ **"é um" → herança (generalização/especialização):**

```mermaid
erDiagram
    FUNCIONARIOS {
        BIGINT id_funcionario PK
        VARCHAR nome
    }
    GERENTES {
        BIGINT id_funcionario PK, FK
        DECIMAL bonus_anual
    }
    FUNCIONARIOS ||--o| GERENTES : "é um"
```

✅ **"tem um" → relacionamento comum (associação), nunca herança:**

```mermaid
erDiagram
    DEPARTAMENTOS {
        BIGINT id_departamento PK
        VARCHAR nome
    }
    FUNCIONARIOS {
        BIGINT id_funcionario PK
        BIGINT departamento_id FK
    }
    DEPARTAMENTOS ||--o{ FUNCIONARIOS : "lotado em"
```

### Resumo dos Erros Comuns

Use esta tabela como revisão rápida antes de dar um modelo por pronto:

| Erro | Sintoma | Como evitar |
|---|---|---|
| Atributo que deveria ser entidade | Um "atributo" que tem dados próprios e se relaciona com outras coisas | Pergunte: *"isso tem vida própria ou só descreve outra coisa?"* |
| Relacionamento sem nome (ou genérico) | Verbo "tem"/"possui" que não descreve o negócio | Nomeie com o verbo real: *"leciona"*, *"pertence_a"*, *"realiza"* |
| Cardinalidade confundida com quantidade | Ler "1:N" como "sempre haverá muitos" | 1:N significa que *pode* haver muitos, não que sempre haverá |
| N:M onde é 1:N (ou o contrário) | Cardinalidade escolhida sem checar os dois sentidos | Pergunte: *"um A tem muitos B?"* **e** *"um B tem muitos A?"* |
| Generalização sem atributo próprio | Subclasses sem nada exclusivo além do herdado | Resolva com uma coluna `tipo`; só especialize se houver atributo/relacionamento próprio |
| "é um" confundido com "tem um" | Herança usada onde havia só uma associação | *"é um"* = herança (Gerente é Funcionário); *"tem um"* = relacionamento (Funcionário tem Departamento) |

### 10.1 Método Prático: Entidade ou Atributo?

O erro mais frequente da lista acima — confundir atributo com entidade — tem um método simples para resolver a dúvida: faça estas quatro perguntas, nesta ordem, para cada informação que você identificar em um enunciado ou documento real.

1. **"Essa informação se repete várias vezes dentro do mesmo registro, com valores diferentes a cada repetição?"** Se sim, é forte sinal de **entidade** (ou entidade associativa) — um atributo simples não se repete dentro do mesmo registro.
2. **"Essa informação continuaria fazendo sentido e poderia ser consultada mesmo sem este registro específico existir?"** Se sim, é sinal de **entidade independente**. Se a informação só existe *dentro* deste documento e morre com ele, é mais provável que seja **atributo**.
3. **"Essa informação está apenas descrevendo/qualificando outra coisa específica?"** Se sim, é **atributo** daquilo que ela descreve.
4. **"Essa informação é o resultado do encontro entre duas outras entidades?"** Se sim, é atributo de uma **entidade associativa** — não de nenhuma das duas entidades originais isoladamente.

A melhor forma de fixar esse método é aplicá-lo, passo a passo, a um documento real. Vamos fazer isso duas vezes, com documentos de domínios diferentes — o raciocínio é sempre o mesmo.

#### Exemplo guiado 1 — Ficha de Empréstimo da Biblioteca

Voltando ao sistema de biblioteca que abriu esta aula, imagine a ficha de empréstimo abaixo, preenchida no balcão:

```text
BIBLIOTECA CENTRAL FATEC JAHU
Ficha de Empréstimo Nº 4821

Aluno: João Silva          Matrícula: 2026001
Livro: Sistemas de Banco de Dados     ISBN: 978-85-352-0000-0
Data do empréstimo: 10/08/2026
Data prevista de devolução: 24/08/2026
Status: Em andamento
```

**Passo 1 — Liste tudo que aparece, sem julgar ainda.** Antes de decidir o que é entidade e o que é atributo, faça um brainstorm cru: nome do aluno, matrícula, título do livro, ISBN, número da ficha, data do empréstimo, data prevista de devolução, status.

**Passo 2 — Aplique as quatro perguntas** (as mesmas quatro listadas acima), item por item.

**Passo 3 — Registre as conclusões numa tabela:**

| Elemento da ficha | Pergunta que decide | Conclusão |
|---|---|---|
| Nome, matrícula do aluno | Descreve o aluno (P3); continua valendo em outra ficha (P2) | Atributos da entidade `ALUNO` |
| Título, ISBN do livro | Descrevem o livro (P3); continuam existindo mesmo que esta ficha seja cancelada (P2) | Atributos da entidade `LIVRO` |
| Nº da ficha | Identifica este empréstimo específico | Atributo (chave) da entidade `EMPRESTIMO` |
| Data do empréstimo, data prevista de devolução, status | Só fazem sentido no encontro entre *este* aluno e *este* livro (P4) | Atributos da entidade associativa `EMPRESTIMO` |

Resumindo o raciocínio: **nome e matrícula** descrevem o aluno e continuariam fazendo sentido em outra ficha → atributos de `ALUNO`. **Título e ISBN** descrevem o livro → atributos de `LIVRO`. Já **data do empréstimo, data prevista de devolução e status** só existem no encontro específico entre este aluno e este livro → são atributos da entidade associativa `EMPRESTIMO`, não do Aluno nem do Livro isoladamente.

**Passo 4 — Monte o modelo:**

```mermaid
erDiagram
    ALUNOS {
        BIGINT id_aluno PK
        VARCHAR nome
        VARCHAR matricula
    }
    LIVROS {
        BIGINT id_livro PK
        VARCHAR titulo
        VARCHAR isbn
    }
    EMPRESTIMOS {
        BIGINT aluno_id FK
        BIGINT livro_id FK
        DATE data_emprestimo
        DATE data_devolucao_prevista
        VARCHAR status
    }
    ALUNOS ||--o{ EMPRESTIMOS : "realiza"
    LIVROS ||--o{ EMPRESTIMOS : "é objeto de"
```

#### Exemplo guiado 2 — Nota Fiscal de Venda

Agora um documento de outro domínio, com uma diferença importante: ele tem **linhas que se repetem** (os itens). Observe como a pergunta 1 (repetição dentro do mesmo registro) passa a fazer diferença aqui.

```text
FATEC LIVRARIA E PAPELARIA LTDA
CNPJ: 12.345.678/0001-90          Nota Fiscal Nº 5573
Data: 12/08/2026

CLIENTE: João Silva              CPF: 123.456.789-00

ITEM  DESCRIÇÃO                 QTD   VL.UNIT   VL.TOTAL
001   Caneta Azul                5      2,50      12,50
002   Caderno 96 folhas          2     18,90      37,80
003   Marca-texto Amarelo        3      6,00      18,00

VALOR TOTAL R$: 68,30
FORMA DE PAGAMENTO: PIX
```

**Passo 1 — Liste tudo:** nome/CNPJ da loja, número da nota, data, nome/CPF do cliente, descrição/quantidade/valor unitário/valor total de cada item, valor total da nota, forma de pagamento.

**Passo 2 — Aplique as quatro perguntas.** Repare que a **linha de item** (descrição, qtd, valores) aparece *três vezes* na mesma nota, com valores diferentes → pela pergunta 1, isso é forte sinal de que ali há uma entidade (ou associativa), não um atributo simples.

**Passo 3 — Tabela de conclusões:**

| Elemento da nota | Pergunta que decide | Conclusão |
|---|---|---|
| Nome do cliente, CPF | Descrevem o cliente (P3); continuam valendo em outra nota (P2) | Atributos da entidade `CLIENTE` |
| Nº da nota, data, valor total, forma de pagamento | Descrevem a nota em si; não se repetem dentro dela (P3) | Atributos da entidade `NOTA_FISCAL` |
| Descrição e valor unitário do produto | Continuam existindo em outra nota, outro dia (P2) | Atributos da entidade `PRODUTO`, independente da nota |
| Quantidade e valor total daquele item | Resultado do encontro entre *esta* nota e *este* produto (P4) | Atributos da entidade associativa `ITEM_NOTA` |

**Passo 4 — Monte o modelo:**

```mermaid
erDiagram
    CLIENTES {
        BIGINT id_cliente PK
        VARCHAR nome
        VARCHAR cpf
    }
    NOTAS_FISCAIS {
        BIGINT id_nota_fiscal PK
        DATE data_emissao
        DECIMAL valor_total
        VARCHAR forma_pagamento
        BIGINT cliente_id FK
    }
    PRODUTOS {
        BIGINT id_produto PK
        VARCHAR descricao
        DECIMAL valor_unitario
    }
    ITENS_NOTA {
        BIGINT nota_fiscal_id FK
        BIGINT produto_id FK
        INT quantidade
        DECIMAL valor_total_item
    }
    CLIENTES ||--o{ NOTAS_FISCAIS : "recebe"
    NOTAS_FISCAIS ||--o{ ITENS_NOTA : "contém"
    PRODUTOS ||--o{ ITENS_NOTA : "aparece em"
```

> 🔑 **O mesmo produto pode aparecer em várias notas, com quantidades diferentes a cada venda.** Por isso `quantidade` e `valor_total_item` não pertencem à entidade `PRODUTO` (que é fixa), e sim à entidade associativa `ITEM_NOTA`, que representa o encontro entre uma nota e um produto. Este é exatamente o padrão que resolve todo relacionamento N:M com atributos próprios — você o reverá na Aula 02, ao normalizar o modelo. Repare de passagem que os nomes de chave já seguem a convenção da disciplina: PK no padrão `id_` + tabela no singular (`id_nota_fiscal`) e FK no padrão inverso, tabela referenciada no singular + `_id` (`nota_fiscal_id`, `produto_id`) — as regras formais de nomenclatura virão na Aula 03.

> 💡 **Pratique em casa:** pegue qualquer outro documento real (um boleto, uma nota fiscal de serviço, um formulário de matrícula) e refaça os quatro passos, item por item. É o mesmo raciocínio sempre — só muda o domínio.

> 🔍 **Checkpoint 5 — Método das quatro perguntas: comprovante de corrida elétrica.** Desta vez sem passo a passo guiado — aplique você mesmo o método das quatro perguntas (Seção 10.1) ao comprovante abaixo, gerado por um aplicativo de corrida com carros 100% elétricos:
>
> ```text
> APP GIRACITY — CORRIDA ELÉTRICA
> Comprovante da Corrida Nº 88342
>
> Passageiro: Marina Costa           CPF: 987.654.321-00
> Motorista: Diego Andrade           Placa do veículo: ELÉTRICO-2E45
> Modelo do veículo: BYD Dolphin     Autonomia: 340 km
>
> Origem: Av. Paulista, 1000         Destino: Rua Augusta, 500
> Início: 12/08/2026 08:15           Término: 12/08/2026 08:38
> Distância percorrida: 6,4 km
> Valor da corrida: R$ 18,90
> Avaliação dada pelo passageiro: 5 estrelas
> ```
>
> Liste os elementos do comprovante, aplique as quatro perguntas a cada um e monte a tabela de conclusões (como nos dois exemplos guiados desta seção), indicando a qual entidade cada elemento pertence — incluindo se algum elemento pertence a uma entidade associativa. Ao final, desenhe o diagrama `erDiagram` correspondente.
>
> 🔑 Resolução no [Gabarito da Aula 01](Aula_01_Gabarito.md#checkpoint-5) — tente resolver antes de conferir.

---

## 📝 Exercícios de Fixação

**Exercício 1 — Identificação de Entidades:** leia o trecho abaixo e liste todas as entidades, atributos e relacionamentos que você consegue identificar, indicando a cardinalidade de cada relacionamento.

> *"Uma clínica médica cadastra seus pacientes e médicos. Um médico pode ter várias especialidades. Os pacientes podem agendar consultas com os médicos. Cada consulta ocorre em uma data e horário específicos e gera um prontuário com o diagnóstico e a prescrição."*

**Exercício 2 — Leitura de Diagrama:** analise o diagrama da Seção 6 e responda: é possível que um Aluno exista no banco sem estar associado a nenhum Curso? Justifique sua resposta com base na notação do diagrama.

**Exercício 3 — Modelagem Livre:** escolha um sistema do cotidiano (uma locadora, um pet shop, um restaurante) e crie um MER conceitual com pelo menos 4 entidades, identificando atributos e relacionamentos com suas cardinalidades.

**Exercício 4 — Generalização:** leia as entidades abaixo e identifique quais poderiam ser reunidas em uma superclasse. Proponha o nome da superclasse, liste os atributos que seriam herdados e os que permaneceriam em cada subclasse. Indique também o tipo de restrição (total/parcial, exclusiva/sobreposta) e justifique.

> Entidades: **Aluno**, **Professor**, **Funcionário Administrativo** — todos de uma faculdade.

**Exercício 5 — Especialização:** dada a entidade **Pagamento** com atributos `id_pagamento`, `valor`, `data` e `status`, especialize-a em pelo menos três subclasses que representem formas de pagamento diferentes. Para cada subclasse, liste os atributos específicos e indique o tipo de restrição da hierarquia.

---

## 📚 Referências desta Aula

- ELMASRI, R.; NAVATHE, S. B. *Sistemas de Banco de Dados*. 7 ed. Cap. 3 — Modelagem de Dados usando o Modelo Entidade-Relacionamento; Cap. 4 — Modelo ER Estendido. São Paulo: Pearson, 2018.
- SILBERSCHATZ, A.; KORTH, H. F.; SUNDARSHAN, S. *Sistema de banco de dados*. 6 ed. Cap. 6 — Projeto de Banco de Dados usando o Modelo ER. Rio de Janeiro: Elsevier, 2016.
- DATE, C. J. *Introdução a sistemas de bancos de dados*. 8 ed. Rio de Janeiro: Elsevier/Campus, 2004.

---

## 🃏 Flashcards de Revisão

??? question "Qual a diferença entre dado e informação? Dê um exemplo."
    Dado é um fato bruto, sem contexto — como o número `2026001` isolado. Informação é
    o dado interpretado dentro de um contexto que permite tomar decisões — como saber
    que `2026001` é a matrícula do aluno João Silva.

??? question "Qual a diferença entre entidade forte e entidade fraca?"
    Uma entidade forte existe por si mesma (ex.: Aluno). Uma entidade fraca só existe em
    relação a outra entidade — se a entidade da qual depende for removida, ela perde
    sentido (ex.: Dependente em relação a Funcionário).

??? question "O que é um atributo derivado? Dê um exemplo."
    É um atributo cujo valor pode ser calculado a partir de outro atributo, em vez de
    ser armazenado diretamente. Exemplo: `idade`, derivada de `data_nascimento`. Na
    notação do MER, representa-se com elipse tracejada.

??? question "O que significa a notação `||--o{` em um diagrama Crow's Foot?"
    Lê-se "um e apenas um para zero ou muitos". O lado com `||` indica participação
    total (exatamente um), e o lado com `o{` indica participação parcial (zero ou
    muitos).

??? question "Qual a diferença entre generalização e especialização?"
    São o mesmo resultado no diagrama (superclasse + subclasses), mas com raciocínios
    opostos: generalização é bottom-up (parte de entidades específicas e abstrai o que
    têm em comum); especialização é top-down (parte de uma entidade genérica e a divide
    em subtipos).

??? question "O que significa uma restrição de especialização 'Total Exclusiva'?"
    Total = toda instância da superclasse obrigatoriamente pertence a alguma subclasse
    (não existe instância "genérica"). Exclusiva = cada instância pertence a **no
    máximo uma** subclasse (as subclasses não se sobrepõem).

??? question "Pegadinha comum: cardinalidade 1:N sempre significa que vai existir 'muitos' registros na prática?"
    Não. Cardinalidade 1:N significa que **pode** haver muitos — não que sempre haverá.
    Um Departamento com um único Funcionário ainda é, estruturalmente, uma relação 1:N.

??? question "O que é um auto-relacionamento? Dê um exemplo."
    É quando uma entidade se relaciona com ela mesma. Exemplo: FUNCIONARIOS supervisiona
    FUNCIONARIOS (hierarquia de supervisão) — nesse caso a FK usa o papel semântico no
    nome (`supervisor_id`), não o nome da tabela, para evitar ambiguidade.

??? question "Quando um relacionamento é considerado ternário?"
    Quando três entidades participam de um único relacionamento e a combinação das três
    — não de duas isoladamente — é que define a ocorrência. Exemplo: Médico prescreve
    Medicamento para Paciente.

---

## ✅ Quiz de Fixação

<quiz>
Quais são os três elementos principais do Modelo Entidade-Relacionamento proposto por Peter Chen?
- [ ] Tabelas, Colunas e Chaves
- [x] Entidades, Atributos e Relacionamentos
- [ ] Classes, Objetos e Métodos
- [ ] Índices, Views e Triggers

O MER de Peter Chen (1976) é composto por Entidades, Atributos e Relacionamentos — a base de toda modelagem conceitual.
</quiz>

<quiz>
Qual notação é adotada nesta disciplina para os diagramas de modelagem?
- [ ] Notação de Peter Chen (losangos e elipses)
- [x] Notação Crow's Foot (Pé-de-Galinha)
- [ ] Notação UML de classes
- [ ] Não há notação padronizada

A notação Crow's Foot foi escolhida por ser o padrão em ferramentas de mercado como MySQL Workbench e dbdiagram.io, que vocês usarão profissionalmente.
</quiz>

<quiz>
Marque todas as alternativas que são exemplos válidos de ATRIBUTO DERIVADO.
- [x] `idade`, calculada a partir de `data_nascimento`
- [ ] `cpf` de uma Pessoa
- [x] `tempo_de_casa`, calculado a partir de `data_admissao`
- [ ] `nome` de um Produto

Atributos derivados nunca são armazenados diretamente — seu valor sempre pode ser recalculado a partir de outro atributo já existente na entidade.
</quiz>

<quiz>
Na generalização de Veículos em Carros, Motos e Caminhões (Total Exclusiva), o que isso implica?
- [ ] Um veículo pode ser carro e moto ao mesmo tempo
- [ ] Pode existir um veículo cadastrado sem ser carro, moto ou caminhão
- [x] Todo veículo é obrigatoriamente um carro, uma moto ou um caminhão, e nunca mais de um tipo
- [ ] A hierarquia é opcional e pode ser ignorada na modelagem lógica

"Total" garante que não existe veículo "genérico" (toda instância cai em alguma subclasse); "Exclusiva" garante que nenhuma instância pertence a mais de uma subclasse simultaneamente.
</quiz>

<quiz>
Um Cliente pode ter feito zero pedidos, mas todo Pedido precisa estar associado a um Cliente. Como se chama, respectivamente, a participação de Cliente e de Pedido nesse relacionamento?
- [ ] Total e Total
- [x] Parcial (Cliente) e Total (Pedido)
- [ ] Total (Cliente) e Parcial (Pedido)
- [ ] Parcial e Parcial

Cliente participa de forma parcial (pode não ter nenhum pedido) enquanto Pedido participa de forma total (não existe pedido sem cliente associado).
</quiz>

<quiz>
Em uma entidade FUNCIONARIOS que se relaciona consigo mesma (supervisão), por que a chave estrangeira se chama `supervisor_id` e não `funcionario_id`?
- [ ] Porque `funcionario_id` já é usado como nome da chave primária
- [x] Porque, em um auto-relacionamento, nomear a FK só com o nome da tabela seria ambíguo — o papel no relacionamento precisa aparecer no nome
- [ ] Não há diferença, os dois nomes são equivalentes
- [ ] Porque toda FK deve terminar em "_id" exatamente uma vez

Como a FK referencia a própria tabela FUNCIONARIOS, chamá-la de `funcionario_id` não diria se ela representa "o funcionário" ou "o supervisor dele". Usar o papel semântico (`supervisor_id`) resolve a ambiguidade.
</quiz>

---

## 📝 Resumo

Nesta aula revisamos a distinção entre dado, informação e conhecimento, situando a
modelagem de dados como a etapa que estrutura os dados para que virem informação
confiável. Revisamos também os três elementos centrais do Modelo Entidade-Relacionamento —
entidades, atributos e relacionamentos — e como cardinalidade e participação
descrevem as regras de negócio entre eles, incluindo os casos especiais de
auto-relacionamento e relacionamento ternário. Vimos a notação Crow's Foot, adotada
nesta disciplina, um método prático de quatro perguntas para nunca mais confundir
entidade com atributo, e o mecanismo de generalização/especialização para modelar
hierarquias com herança, incluindo suas quatro combinações de restrição (total/parcial
× exclusiva/sobreposta). Também já demos uma prévia do sistema de streaming que será a
base da Atividade T1. Na próxima aula, esse modelo conceitual vira modelo lógico
relacional, através da Normalização.

---

## 🏆 Conquista da Aula

!!! success "Selo desbloqueado: 🧭 Explorador(a) de Dados"
    Você completou a Aula 01 e já domina a leitura e construção de diagramas MER. A
    próxima parada da Trilha do(a) Modelador(a) de Dados é transformar esse modelo
    conceitual em um modelo lógico consistente, livre de redundâncias.

---

## 🔑 Gabarito desta Aula

As respostas dos 5 checkpoints espalhados pela aula estão em um arquivo separado, para
não estragar a tentativa de quem ainda não chegou até aqui: [Gabarito — Aula
01](Aula_01_Gabarito.md).

---

## 🔗 Navegação

⬅️ Você está na primeira aula · ➡️ [Aula 02 — Normalização](./Aula_02_Normalizacao.md)

---

*Fatec Jahu · IBD015 · Prof. Ronan Adriel Zenatti · 2026*
