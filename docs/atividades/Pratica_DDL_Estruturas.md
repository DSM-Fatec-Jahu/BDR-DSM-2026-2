# Prática — SQL DDL: Criando as Estruturas (Aula 03)

**Disciplina:** Banco de Dados — Relacional (IBD015)
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br
**Fatec Jahu — 2º Semestre/2026**

!!! info "🧪 Atividade de treino — não vale nota"
    Esta atividade **não tem peso na média**. Ela existe para você praticar, errar à
    vontade e tirar dúvidas em aula antes das avaliações que valem nota (T1, P1...).
    Traga sua tentativa — mesmo incompleta — para a aula: é matéria-prima para
    discussão, não algo para entregar "pronto".

---

## 🧭 Contexto — dos requisitos de negócio ao banco de dados de verdade

Na [Prática — Modelagem com dbdiagram.io](Pratica_Modelagem_dbdiagram.md) você
transformou cenários de negócio em modelos lógicos e diagramas DBML. Um diagrama,
porém, não roda em lugar nenhum — é só uma representação visual. Esta atividade fecha o
ciclo: parte dos **mesmos 7 cenários de negócio**, mas agora o alvo final é o
`CREATE TABLE` de verdade, em SQL, seguindo exatamente as convenções ensinadas na
[Aula 03 — SQL DDL](../aulas/Aula_03_SQL_DDL.md).

!!! tip "Boa prática: produza o modelo lógico antes de escrever o SQL"
    O caminho recomendado — e o que se espera que você já tenha feito na prática de
    modelagem — é: **requisitos de negócio → modelo lógico (entidades, PK, FK,
    cardinalidade) → SQL**. Pular direto dos requisitos para o `CREATE TABLE` é como
    escrever código sem rascunhar a lógica antes: funciona às vezes, mas quebra fácil em
    qualquer cenário com um pouco mais de complexidade. Por isso cada exercício abaixo
    parte novamente da descrição do negócio (a mesma da outra atividade, ou a
    especificação formal quando indicado) — **não do modelo lógico pronto**. Se você já
    modelou este cenário antes, ótimo, é só reaproveitar seu próprio modelo lógico e ir
    direto para o SQL; se não modelou, essa é justamente a etapa que você deve fazer
    primeiro, por conta própria, antes de abrir o editor SQL. O Exemplo Completo desta
    atividade demonstra as duas etapas juntas, uma depois da outra.

### O que muda de verdade: DBML (dbdiagram.io) → SQL real (MariaDB)

| No DBML (atividade anterior) | Em SQL real (esta atividade) |
|---|---|
| `id_x "BIGINT UNSIGNED" [PK, INCREMENT]` — tipo composto **entre aspas duplas**, é uma particularidade só do parser do dbdiagram.io | `id_x BIGINT UNSIGNED NOT NULL AUTO_INCREMENT` — sem aspas, `INCREMENT` vira `AUTO_INCREMENT` |
| `[PK]` dentro dos colchetes da coluna | `PRIMARY KEY (id_x)` como cláusula própria, no fim do `CREATE TABLE` (Aula 03, Seção 6.2) |
| Sem sintaxe para `ON DELETE`/`ON UPDATE` | `CONSTRAINT fk_... FOREIGN KEY (...) REFERENCES ... ON DELETE ... ON UPDATE ...` — **obrigatório decidir e justificar** em cada FK (Aula 03, Seção 7.2) |
| `[UNIQUE]` dentro dos colchetes | `CONSTRAINT uq_... UNIQUE (coluna)` como cláusula própria (Aula 03, Seção 7.4) |
| Nenhum plugin valida domínio de valor | `CONSTRAINT ck_... CHECK (expressão)` para validar domínio (preço ≥ 0, nota entre limites etc.) |
| Nenhum comando cria o banco em si | `CREATE DATABASE` com charset e collation corretos vem **antes** de qualquer `CREATE TABLE` (Aula 03, Seção 4) |

!!! note "E o `ENGINE=InnoDB`?"
    O MariaDB **já assume `InnoDB`** como engine padrão de qualquer tabela nova — você
    pode conferir isso com `SHOW CREATE TABLE`. É possível declarar a cláusula de forma
    explícita, se quiser deixar documentado:

    ```sql
    CREATE TABLE IF NOT EXISTS exemplo (
        ...
    ) ENGINE=InnoDB;
    ```

    mas, no dia a dia das empresas, isso **raramente é escrito** — confiar no padrão do
    SGBD é o normal (Aula 03, Seção 6.1). Não é necessário declarar `ENGINE=InnoDB` em
    nenhuma tabela desta atividade.

---

## 🎯 O que se espera em cada exercício

Para cada um dos 7 exercícios abaixo, a partir do cenário e da lista de requisitos de
negócio apresentados — do seu próprio modelo lógico, e não de um já pronto — você deve
escrever o SQL completo que:

1. **Crie o banco de dados** com `CREATE DATABASE`, aplicando o charset e a collation
   corretos para um sistema em português — nunca os padrões do servidor. Consulte a
   Aula 03, Seção 4, para o comando idiomático completo e os valores certos (o
   Checkpoint 2 daquela aula resolve exatamente esse comando).
2. **Declare todas as colunas com o tipo e o tamanho corretos** (Regra 8, Aula 03,
   Seção 5) — use a Tabela de Tipos abaixo.
3. **Declare a `PRIMARY KEY`** de cada tabela e, quando houver `FOREIGN KEY`, a
   cláusula `CONSTRAINT ... FOREIGN KEY (...) REFERENCES ...` apontando para a PK
   referenciada (Aula 03, Seção 6.3/7.1).
4. **Decida e justifique, em comentário SQL, o `ON DELETE` e o `ON UPDATE` de cada
   FK** — `RESTRICT`, `CASCADE` ou `SET NULL` — a partir do que a regra de negócio diz
   sobre o que deveria acontecer quando o registro pai for removido ou tiver a PK
   alterada (Aula 03, Seção 7.2). Cada exercício traz uma 💭 **Pergunta-guia** para
   ajudar nessa decisão — não existe resposta genérica igual para todo FK.
5. **Aplique `UNIQUE`** onde a regra de negócio exigir unicidade — inclusive `UNIQUE`
   composto, quando necessário (Aula 03, Seção 7.4).
6. **Aplique `CHECK`** onde fizer sentido validar um domínio de valores — preço ≥ 0,
   nota dentro de uma faixa, datas coerentes entre si etc. (Aula 03, Seção 7.4).
7. **Siga as 9 regras de nomenclatura** e inclua os **três campos de log obrigatórios**
   em toda tabela — `criado_em` (`DEFAULT CURRENT_TIMESTAMP`), `alterado_em`
   (`DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`) e `deletado_em`
   (`NULL`, sem default).

---

## 🧩 Tabela de Tipos Permitidos (SQL real — MariaDB)

Os mesmos tipos da atividade de modelagem, agora na sintaxe **sem aspas** do SQL
real — as aspas duplas em tipos compostos (`"BIGINT UNSIGNED"`) eram uma exigência
exclusiva do parser do DBML, que não existe aqui.

| Tipo (MariaDB) | Tamanho / faixa | Quando usar |
|---|---|---|
| `BIGINT UNSIGNED` | 8 bytes · 0 a ~18,4 quintilhões | Toda PK (`id_...`) e toda FK que aponta para uma PK |
| `INT UNSIGNED` | 4 bytes · 0 a ~4,29 bilhões | Contadores que não cabem em `TINYINT` |
| `SMALLINT UNSIGNED` | 2 bytes · 0 a 65.535 | Contadores pequenos com folga |
| `TINYINT UNSIGNED` | 1 byte · 0 a 255 | Quantidades bem pequenas e limitadas |
| `VARCHAR(n)` | até 65.535 bytes | Texto de tamanho variável e imprevisível — padrão defensivo `VARCHAR(255)` |
| `CHAR(n)` | n bytes fixos | Texto de tamanho **sempre igual** (placa, CNH) |
| `TEXT` | até 65.535 bytes | Texto longo e livre |
| `DECIMAL(p, s)` | exato · até 65 dígitos | Todo valor monetário ou medida exata — nunca `FLOAT`/`DOUBLE` |
| `DATE` | AAAA-MM-DD | Datas sem horário |
| `DATETIME` | AAAA-MM-DD HH:MM:SS | Datas com horário, incluindo os três campos de log |
| `BOOLEAN` (`TINYINT(1)`) | 0 ou 1 | Indicadores verdadeiro/falso |
| `ENUM(...)` | lista fechada | Conjunto **pequeno e estável** de valores |

---

## 🧾 Exemplo Completo e Comentado — Cupom Fiscal (em SQL real)

Mesmo domínio do exemplo comentado da atividade de modelagem, agora levado até o fim —
das regras de negócio ao `CREATE TABLE` de verdade — para você ver as duas etapas
(modelo lógico e SQL) uma depois da outra, na ordem recomendada pela dica acima.

**Regras de negócio do exemplo:** uma loja emite cupons fiscais para clientes
cadastrados; cada cupom tem uma ou mais linhas de item, cada linha referenciando um
produto do catálogo com a quantidade comprada e o valor unitário **no momento da
venda** (o preço de um produto pode mudar depois, então o cupom precisa guardar o
valor histórico, não recalcular a partir do preço atual do produto). Todo cliente é
também um usuário do sistema de autoatendimento, com um tipo básico de acesso.

**Passo 1 — Modelo Lógico** (o que deveria ser feito antes de qualquer linha de SQL):

```
CLIENTES (id_cliente PK, nome, cpf UNIQUE, email UNIQUE, senha_hash, tipo_usuario)
PRODUTOS (id_produto PK, descricao, valor_unitario)
CUPONS_FISCAIS (id_cupom_fiscal PK, cliente_id FK -> CLIENTES, numero_cupom UNIQUE,
                data_emissao, forma_pagamento, valor_total)
ITENS_CUPOM (cupom_fiscal_id PK FK -> CUPONS_FISCAIS, produto_id PK FK -> PRODUTOS,
             quantidade, valor_unitario)
```

**Passo 2 — SQL real**, traduzindo o modelo lógico acima com as convenções da Aula 03:

```sql
-- Regra 4 (plural) + Regra 9 (campos de log em toda tabela)
-- Banco criado com charset/collation corretos ANTES de qualquer tabela (Aula 03, Seção 4)
CREATE DATABASE IF NOT EXISTS cupom_fiscal
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE cupom_fiscal;

CREATE TABLE IF NOT EXISTS clientes (
    id_cliente     BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome           VARCHAR(255)     NOT NULL,
    cpf            CHAR(11)         NOT NULL,
    email          VARCHAR(255)     NOT NULL,
    senha_hash     VARCHAR(255)     NOT NULL,
    tipo_usuario   ENUM('administrador', 'usuario') NOT NULL DEFAULT 'usuario',
    criado_em      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                               ON UPDATE CURRENT_TIMESTAMP,
    deletado_em    DATETIME         NULL,

    PRIMARY KEY (id_cliente),
    CONSTRAINT uq_cliente_cpf   UNIQUE (cpf),
    CONSTRAINT uq_cliente_email UNIQUE (email)
);

CREATE TABLE IF NOT EXISTS produtos (
    id_produto      BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    descricao       VARCHAR(255)     NOT NULL,
    valor_unitario  DECIMAL(10,2)    NOT NULL,
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME         NULL,

    PRIMARY KEY (id_produto),
    CONSTRAINT ck_produto_valor CHECK (valor_unitario >= 0)
);

CREATE TABLE IF NOT EXISTS cupons_fiscais (
    id_cupom_fiscal  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    cliente_id       BIGINT UNSIGNED  NOT NULL,
    numero_cupom     VARCHAR(20)      NOT NULL,
    data_emissao     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    forma_pagamento  ENUM('dinheiro', 'pix', 'cartao_credito', 'cartao_debito') NOT NULL,
    valor_total      DECIMAL(10,2)    NOT NULL,
    criado_em        DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                 ON UPDATE CURRENT_TIMESTAMP,
    deletado_em      DATETIME         NULL,

    PRIMARY KEY (id_cupom_fiscal),
    CONSTRAINT uq_cupom_numero UNIQUE (numero_cupom),
    CONSTRAINT ck_cupom_valor  CHECK (valor_total >= 0),
    -- Um cupom fiscal já emitido é documento contábil: o cliente não pode ser apagado
    -- enquanto existir cupom emitido em nome dele.
    CONSTRAINT fk_cupom_cliente FOREIGN KEY (cliente_id)
                                REFERENCES clientes (id_cliente)
                                ON DELETE RESTRICT
                                ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS itens_cupom (
    cupom_fiscal_id  BIGINT UNSIGNED  NOT NULL,
    produto_id       BIGINT UNSIGNED  NOT NULL,
    quantidade       INT UNSIGNED     NOT NULL,
    valor_unitario   DECIMAL(10,2)    NOT NULL,  -- snapshot do preço na venda (Aula 02, 4.2)
    criado_em        DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                 ON UPDATE CURRENT_TIMESTAMP,
    deletado_em      DATETIME         NULL,

    PRIMARY KEY (cupom_fiscal_id, produto_id),
    CONSTRAINT ck_item_qtd CHECK (quantidade > 0),
    -- Item só existe dentro de um cupom: excluir o cupom exclui seus itens.
    CONSTRAINT fk_item_cupom FOREIGN KEY (cupom_fiscal_id)
                             REFERENCES cupons_fiscais (id_cupom_fiscal)
                             ON DELETE CASCADE
                             ON UPDATE CASCADE,
    -- Produto já vendido não pode ser apagado do catálogo silenciosamente.
    CONSTRAINT fk_item_produto FOREIGN KEY (produto_id)
                               REFERENCES produtos (id_produto)
                               ON DELETE RESTRICT
                               ON UPDATE CASCADE
);
```

Repare no padrão que se repete nos 7 exercícios: **RESTRICT protege registro
histórico/documental** (não deixa apagar quem já tem movimento vinculado), **CASCADE
remove o que só existe "dentro" do pai** (um item de cupom sem cupom não significa
nada), e **SET NULL** entra quando a FK já é opcional e perder a referência é aceitável
— nenhum dos três é "o certo" universal; a regra de negócio de cada exercício decide.

---

## 📋 Os 7 Exercícios

Mesma dificuldade progressiva e os mesmos 7 cenários da prática de modelagem: dois
fáceis, três intermediários, dois avançados. O último exercício de cada nível é
apresentado como uma especificação formal de **Requisitos Funcionais (RF)** e
**Requisitos Não Funcionais (RNF)** — o mesmo tipo de documento que você vai receber em
projetos reais, em vez do texto corrido usado nos demais.

### 🟢 Exercício 1 (Fácil) — VoltGo: aluguel de patinetes elétricos compartilhados

A **VoltGo** é um aplicativo de aluguel de patinetes elétricos compartilhados,
espalhados por pontos fixos da cidade. Requisitos de negócio:

- Usuários se cadastram e fazem login (e-mail e senha) para poder alugar um patinete.
- A empresa mantém uma frota de **patinetes**, cada um com um código de identificação
  único, o nível atual de bateria (em %) e se está disponível para aluguel no momento.
- Quando um usuário aluga um patinete, o sistema registra uma **locação**: qual
  patinete, qual usuário, o horário de início, o horário de término (que fica **em
  aberto**, sem valor, enquanto a locação ainda está em andamento) e o valor cobrado ao
  final.
- Um mesmo patinete pode ser alugado várias vezes ao longo do tempo, por usuários
  diferentes, sempre em locações separadas — mas nunca em duas locações em andamento ao
  mesmo tempo.
- Gestão de acesso no nível básico: `administrador` (gerencia a frota de patinetes) e
  `usuario` (aluga patinetes).

💭 **Pergunta-guia:** o que deveria acontecer com o histórico de `LOCACOES` se um
`PATINETE` for removido da frota (baixa por dano, por exemplo)? E se um `USUARIO`
cancelar a conta? As duas respostas precisam ser iguais?

---

### 🟢 Exercício 2 (Fácil) — TreinoZen: gestão de treinos e rotina fitness

**Especificação formal:**

**Requisitos Funcionais**

- **RF01** — O sistema deve permitir que um usuário se cadastre e faça login com e-mail
  e senha.
- **RF02** — O sistema deve permitir que um usuário crie suas próprias rotinas de
  treino, vinculadas somente a ele.
- **RF03** — Uma rotina de treino deve ser composta por vários exercícios, em uma
  ordem específica, cada um com número de séries, repetições e carga planejados para
  aquela rotina.
- **RF04** — O sistema deve manter um catálogo único de exercícios (nome, grupo
  muscular, instruções de execução), reaproveitável em rotinas de usuários diferentes.
- **RF05** — O sistema deve registrar cada execução real de uma rotina, com data/hora,
  duração em minutos e uma nota de esforço percebido (1 a 10).
- **RF06** — O sistema deve diferenciar dois tipos de acesso: `administrador` (mantém
  o catálogo de exercícios) e `usuario` (monta e executa treinos).

**Requisitos Não Funcionais**

- **RNF01** — Toda tabela deve manter os campos de auditoria `criado_em`,
  `alterado_em` e `deletado_em` (soft delete), conforme a Regra 9 de nomenclatura da
  disciplina.
- **RNF02** — Toda chave primária e estrangeira deve usar `BIGINT UNSIGNED`, conforme
  as Regras 5 e 6.
- **RNF03** — A exclusão de um usuário não pode apagar silenciosamente o histórico de
  execuções de treino já registrado — a integridade referencial deve impedir ou tratar
  esse caso de forma explícita, nunca por acidente.
- **RNF04** — A remoção de um exercício do catálogo não pode quebrar rotinas que já o
  referenciam sem uma decisão explícita de projeto sobre o que fazer com elas.

💭 **Pergunta-guia:** RNF03 e RNF04 são pistas diretas sobre o `ON DELETE` de duas FKs
específicas — qual decisão (`RESTRICT`, `CASCADE` ou `SET NULL`) satisfaz cada um dos
dois requisitos?

---

### 🟡 Exercício 3 (Intermediário) — RachaConta: divisão de contas entre amigos

O **RachaConta** é um app que ajuda grupos de amigos a dividir despesas em viagens,
repúblicas ou saídas, sem precisar de planilha. Requisitos de negócio:

- O sistema permite cadastro de usuários com autenticação por e-mail e senha.
- Um usuário pode criar um **grupo** (ex.: "Viagem para Bonito", "Apê 402") e convidar
  outros usuários cadastrados para participar dele. Um mesmo usuário pode participar de
  vários grupos diferentes, e um grupo reúne vários membros — é uma associação **N:M**
  entre usuários e grupos.
- Dentro de um grupo, qualquer membro pode registrar uma **despesa** (ex.: um jantar),
  informando **quem pagou** (um único membro do grupo), o valor total e a data.
- **Exemplo concreto para fixar a regra a seguir:** o grupo "Viagem para Bonito" tem 4
  membros — Ana, Bruno, Carla e Diego. Ana paga um jantar de R$ 200 que só ela, Bruno e
  Carla comeram (Diego ficou no hotel). O sistema precisa guardar duas coisas
  **separadas** sobre essa despesa: (1) que **Ana foi quem pagou** os R$ 200 inteiros,
  e (2) que a despesa foi **dividida entre Ana, Bruno e Carla** — não entre os 4
  membros do grupo — cada um dos três com sua própria parcela em reais.
- Ou seja: toda despesa tem **um único pagador**, mas pode ser **dividida entre um
  subconjunto qualquer dos membros do grupo** (às vezes todos, às vezes só alguns) — e
  o sistema guarda quanto cada participante daquela divisão deve.
- O **saldo** de cada membro dentro de um grupo (quanto deve ou tem a receber, no
  total) nunca é digitado por ninguém — ele é sempre **calculado**, somando o que a
  pessoa pagou e subtraindo o que ela deve nas divisões registradas. Pense bem em que
  tipo de atributo isso é, e se ele deveria ocupar uma coluna própria no seu modelo
  (releia a Aula 01, Seção 3.1, sobre atributos derivados).
- Gestão de acesso no nível básico: `administrador` (gerencia a plataforma, pode
  desativar contas) e `usuario` (uso normal do app).

💭 **Pergunta-guia:** `DESPESAS.grupo_id` e `MEMBROS_GRUPO.grupo_id` apontam para a
mesma tabela `GRUPOS` — faz sentido as duas terem o mesmo `ON DELETE`? Pense no que
significa, na prática, excluir um grupo que já tem despesas registradas.

---

### 🟡 Exercício 4 (Intermediário) — OndaCast: streaming de podcasts e audiolivros

A **OndaCast** é uma plataforma de streaming de áudio por assinatura, especializada em
podcasts e audiolivros. Requisitos de negócio:

- A plataforma oferece dois tipos de conteúdo de áudio: **episódios de podcast**
  (agrupados em programas/podcasts) e **capítulos de audiolivro** (agrupados em
  obras/audiolivros).
- Todo conteúdo, seja episódio ou capítulo, tem título, duração em segundos e data de
  publicação — mas **só** episódios de podcast têm número do episódio e indicação de
  transcrição disponível; **só** capítulos de audiolivro têm número do capítulo e
  narrador. Um podcast agrupa vários episódios; um audiolivro agrupa vários capítulos.
- Usuários podem criar **playlists pessoais** que misturam episódios de podcast e
  capítulos de audiolivro, em qualquer ordem escolhida por eles.
- A plataforma funciona por assinatura: existem **planos** (ex.: "Básico", "Premium")
  com preço mensal e limite de downloads offline. Um usuário assina um plano por vez,
  mas o sistema precisa manter o **histórico** de todos os planos que aquele usuário já
  assinou, com data de início e de término (nula se ainda estiver ativo).
- Gestão de acesso no nível básico: `administrador` (cadastra podcasts, audiolivros e
  planos) e `usuario` (assina planos e ouve conteúdo).

💭 **Pergunta-guia:** `EPISODIOS_PODCAST.id_conteudo` e `CAPITULOS_AUDIOLIVRO.id_conteudo`
são, ao mesmo tempo, PK e FK para `CONTEUDOS` (padrão de generalização/especialização,
Aula 01, 8.7) — qual `ON DELETE` faz sentido aqui, sabendo que uma linha em
`EPISODIOS_PODCAST` **não existe sem** a linha correspondente em `CONTEUDOS`?

---

### 🟡 Exercício 5 (Intermediário) — CaronaViva: caronas urbanas compartilhadas

**Especificação formal:**

**Requisitos Funcionais**

- **RF01** — Toda pessoa deve se cadastrar uma única vez na plataforma (nome, CPF,
  e-mail, telefone) e fazer login.
- **RF02** — Uma pessoa deve poder assumir o papel de motorista (com CNH e dados do
  veículo), de passageira, os dois papéis simultaneamente, ou nenhum dos dois ainda.
- **RF03** — Um motorista deve poder oferecer várias caronas, cada uma com origem,
  destino, data e hora de saída, número de vagas disponíveis e valor por vaga.
- **RF04** — Um passageiro deve poder reservar vaga em várias caronas diferentes, e
  cada reserva deve ter um status (`solicitada`, `confirmada`, `cancelada`,
  `concluída`).
- **RF05** — Depois de concluída uma carona, motorista e passageiro devem poder se
  avaliar mutuamente (nota de 1 a 5 e comentário), com o sistema distinguindo com
  clareza quem avaliou quem.
- **RF06** — O sistema deve diferenciar dois tipos de acesso: `administrador` (modera
  denúncias, pode suspender contas) e `usuario` (usa a plataforma como motorista e/ou
  passageiro).

**Requisitos Não Funcionais**

- **RNF01** — Toda tabela deve manter os campos de auditoria `criado_em`,
  `alterado_em` e `deletado_em` (soft delete), conforme a Regra 9.
- **RNF02** — CPF, CNH e placa de veículo devem ser armazenados com restrição de
  unicidade — o sistema nunca pode aceitar dois cadastros com o mesmo valor nesses
  campos.
- **RNF03** — Nenhuma nota de avaliação pode ser aceita fora da faixa de 1 a 5 — a
  validação deve ocorrer no próprio banco, não só na aplicação.
- **RNF04** — Excluir uma `CARONA` que já possui reservas ou avaliações vinculadas não
  pode apagar silenciosamente esse histórico de viagens já realizadas.

💭 **Pergunta-guia:** RNF04 dá a resposta para o `ON DELETE` de
`RESERVAS_CARONA.carona_id` e `AVALIACOES.carona_id` — qual ação dos três
(`RESTRICT`/`CASCADE`/`SET NULL`) impede exatamente esse apagamento silencioso?
RNF03 aponta para um tipo de constraint que não é `FOREIGN KEY` — qual é?

---

### 🔴 Exercício 6 (Avançado) — PlayHub: marketplace de jogos digitais

A **PlayHub** é um marketplace de jogos digitais (pense em Steam ou Epic Games Store),
com biblioteca de jogos, conquistas e avaliações. Requisitos de negócio:

- A plataforma vende **jogos** e **conteúdos adicionais (DLCs)** publicados por
  estúdios desenvolvedores parceiros. Todo produto vendido é obrigatoriamente um
  jogo-base **ou** uma DLC — nunca as duas coisas ao mesmo tempo — e toda DLC pertence
  a exatamente um jogo-base.
- Um usuário compra produtos (jogos e/ou DLCs) e eles passam a fazer parte da sua
  biblioteca; o sistema registra cada compra com o valor efetivamente pago e a data —
  o preço de um jogo pode mudar ao longo do tempo, então o valor pago numa compra
  antiga não deve mudar junto com o preço atual do catálogo.
- Cada jogo tem um catálogo próprio de **conquistas** (achievements) que os jogadores
  desbloqueiam jogando; o sistema registra quando cada usuário desbloqueou cada
  conquista.
- Usuários que compraram um produto podem avaliá-lo **uma única vez** (nota de 1 a 5 +
  comentário) — não é permitido avaliar duas vezes o mesmo produto.
- **Controle de acesso com papéis e permissões (obrigatório neste exercício):** a
  plataforma tem múltiplos tipos de acesso interno — `administrador` (gerencia toda a
  plataforma), `desenvolvedor` (gerencia apenas o catálogo dos jogos do próprio
  estúdio), `suporte` (processa reembolsos e modera avaliações denunciadas) e
  `jogador` (usuário comum, compra e joga). **Um mesmo usuário pode acumular mais de
  um papel** (ex.: alguém do estúdio que também joga na própria plataforma), e cada
  papel tem um conjunto específico de permissões que precisa poder ser
  criado/ajustado **sem alterar código-fonte**.

💭 **Pergunta-guia:** `COMPRAS.produto_id` e `CONQUISTAS.jogo_id` — um produto ou jogo
já comprado/conquistado por algum usuário pode simplesmente sumir do catálogo se um
`administrador` o remover por engano? E `PAPEIS_PERMISSOES`/`USUARIOS_PAPEIS`, que só
existem para amarrar duas outras tabelas — o mesmo raciocínio se aplica a elas?

---

### 🔴 Exercício 7 (Avançado) — TrampoJá: marketplace de prestadores de serviço

**Especificação formal:**

**Requisitos Funcionais**

- **RF01** — Todo usuário deve se cadastrar uma vez na plataforma e fazer login.
- **RF02** — Um usuário que deseja oferecer serviços deve poder criar um perfil de
  prestador (biografia, categoria principal) — nem todo usuário cadastrado precisa ser
  prestador.
- **RF03** — Um prestador deve poder anunciar vários serviços, cada um com título,
  descrição, preço-base e categoria.
- **RF04** — Um cliente deve poder enviar uma proposta de contratação para um serviço
  anunciado, informando o valor que está disposto a pagar; o prestador deve poder
  aceitar ou recusar.
- **RF05** — Uma proposta aceita deve virar um contrato, com data de início, previsão
  de conclusão e status; um contrato deve poder ter mais de um pagamento associado
  (parcelamento).
- **RF06** — Ao final do contrato, cliente e prestador devem poder se avaliar
  mutuamente (nota e comentário), com o sistema registrando com clareza quem avaliou
  quem.
- **RF07** — O sistema deve suportar quatro tipos de acesso — `administrador`,
  `moderador`, `cliente` e `prestador` — sendo que um mesmo usuário pode acumular
  `cliente` e `prestador` simultaneamente, com permissões de cada papel configuráveis
  sem alteração de código.

**Requisitos Não Funcionais**

- **RNF01** — Toda tabela deve manter os campos de auditoria `criado_em`,
  `alterado_em` e `deletado_em` (soft delete), conforme a Regra 9.
- **RNF02** — Uma proposta só pode originar **no máximo um** contrato — o banco deve
  impedir, estruturalmente, duas linhas de `CONTRATOS` para a mesma proposta.
- **RNF03** — Nenhum valor de pagamento, proposta ou contrato pode ser aceito como
  negativo.
- **RNF04** — Um `SERVICOS_OFERTADOS` não pode existir vinculado a um usuário sem
  perfil de prestador — a própria estrutura do banco, não a aplicação, deve garantir
  essa regra.

💭 **Pergunta-guia:** RNF02 aponta exatamente para uma constraint que você já usou no
Exemplo Completo desta atividade, mas aplicada a uma FK em vez de a uma coluna comum —
qual é, e em qual coluna de `CONTRATOS` ela entra? RNF04 é sobre `SERVICOS_OFERTADOS.
prestador_id` — para qual tabela essa FK deveria apontar para tornar a regra
estrutural?

---

## 🔑 Gabarito desta Atividade

!!! danger "⚠️ Só abra depois de terminar — copiar não é aprender"
    O [Gabarito desta atividade](Pratica_DDL_Estruturas_Gabarito.md) existe para você
    **conferir** sua própria tentativa depois de escrever o SQL dos 7 exercícios — não
    para consultar no meio do caminho. Escreva o `CREATE TABLE` completo de cada
    cenário — mesmo errando o `ON DELETE`/`ON UPDATE` de alguma FK — antes de abrir o
    link.

---

⬅️ [Voltar para Atividades e Avaliações](index.md)

---

*Fatec Jahu · IBD015 · Prof. Ronan Adriel Zenatti · 2026*
