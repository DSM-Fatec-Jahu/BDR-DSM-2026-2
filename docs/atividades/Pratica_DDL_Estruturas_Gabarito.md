# Gabarito — Prática: SQL DDL — Criando as Estruturas

> ⚠️ Esta página não aparece no índice de atividades nem no menu do site — só é
> alcançável pelo link no final do enunciado da atividade, de propósito, para não
> tropeçar na resposta antes da hora. Tente escrever o SQL dos 7 exercícios sozinho
> antes de ler qualquer coisa abaixo.

Para cada exercício: o `CREATE TABLE` completo em SQL (MariaDB), pronto para rodar, e
os comentários sobre as decisões de `ON DELETE`/`ON UPDATE`, `UNIQUE` e `CHECK` mais
importantes — inclusive a resposta direta da 💭 Pergunta-guia de cada exercício.

Um fio condutor se repete nas 7 respostas: **`RESTRICT` protege registros com valor
histórico ou financeiro** (compra, pagamento, avaliação, aluguel já realizado) —
forçando a aplicação a usar o soft delete da Regra 9 (`deletado_em`) em vez de um
`DELETE` de verdade; **`CASCADE` remove o que só existe "dentro" do pai** — seja um
item de um documento (`itens_cupom`, `itens_treino`), uma linha de tabela de junção
pura sem valor próprio (`papeis_permissoes`, `usuarios_papeis`), ou a linha de uma
subclasse que não significa nada sem a superclasse (`jogos` → `produtos`).

---

## Exercício 1 — VoltGo {: #exercicio-1 }

**Modelo Lógico:**

```
USUARIOS (id_usuario PK, nome, email UNIQUE, senha_hash, tipo_usuario)
PATINETES (id_patinete PK, codigo UNIQUE, nivel_bateria, disponivel)
LOCACOES (id_locacao PK, patinete_id FK -> PATINETES, usuario_id FK -> USUARIOS,
          inicio, fim, valor_cobrado)
```

```sql
CREATE DATABASE IF NOT EXISTS voltgo
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE voltgo;

CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario    BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome          VARCHAR(255)     NOT NULL,
    email         VARCHAR(255)     NOT NULL,
    senha_hash    VARCHAR(255)     NOT NULL,
    tipo_usuario  ENUM('administrador', 'usuario') NOT NULL DEFAULT 'usuario',
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME         NULL,

    PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_email UNIQUE (email)
);

CREATE TABLE IF NOT EXISTS patinetes (
    id_patinete    BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    codigo         VARCHAR(20)      NOT NULL,
    nivel_bateria  TINYINT UNSIGNED NOT NULL,
    disponivel     BOOLEAN          NOT NULL DEFAULT TRUE,
    criado_em      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                    ON UPDATE CURRENT_TIMESTAMP,
    deletado_em    DATETIME         NULL,

    PRIMARY KEY (id_patinete),
    CONSTRAINT uq_patinete_codigo UNIQUE (codigo),
    CONSTRAINT ck_patinete_bateria CHECK (nivel_bateria <= 100)
);

CREATE TABLE IF NOT EXISTS locacoes (
    id_locacao     BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    patinete_id    BIGINT UNSIGNED  NOT NULL,
    usuario_id     BIGINT UNSIGNED  NOT NULL,
    inicio         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fim            DATETIME         NULL,
    valor_cobrado  DECIMAL(6,2)     NULL,
    criado_em      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                    ON UPDATE CURRENT_TIMESTAMP,
    deletado_em    DATETIME         NULL,

    PRIMARY KEY (id_locacao),
    CONSTRAINT ck_locacao_valor CHECK (valor_cobrado IS NULL OR valor_cobrado >= 0),
    -- Locação é histórico de uso real: não pode sumir se o patinete for baixado da frota
    CONSTRAINT fk_locacao_patinete FOREIGN KEY (patinete_id)
                                    REFERENCES patinetes (id_patinete)
                                    ON DELETE RESTRICT
                                    ON UPDATE CASCADE,
    -- Mesmo raciocínio: histórico de locação não pode sumir se a conta for encerrada
    CONSTRAINT fk_locacao_usuario FOREIGN KEY (usuario_id)
                                   REFERENCES usuarios (id_usuario)
                                   ON DELETE RESTRICT
                                   ON UPDATE CASCADE
);
```

**Comentários:**

- 💭 Resposta à pergunta-guia: **sim, as duas respostas devem ser iguais** —
  `RESTRICT` nos dois casos, pela mesma razão nos dois: `LOCACOES` é um registro
  histórico real (algo que de fato aconteceu), então nem `PATINETES` nem `USUARIOS`
  podem ser removidos com `DELETE` enquanto tiverem locações vinculadas. Na prática,
  "remover" um patinete danificado ou uma conta cancelada nunca é um `DELETE` de
  verdade nesta disciplina — é o soft delete da Regra 9 (`deletado_em`), que não
  aciona a FK.
- `disponivel` não tem `CHECK`, mas `nivel_bateria` tem `ck_patinete_bateria` — porque
  bateria tem um limite superior real (100%) que o tipo `TINYINT UNSIGNED` sozinho não
  garante (ele aceita até 255).

---

## Exercício 2 — TreinoZen {: #exercicio-2 }

**Modelo Lógico:**

```
USUARIOS (id_usuario PK, nome, email UNIQUE, senha_hash, tipo_usuario)
EXERCICIOS (id_exercicio PK, nome UNIQUE, grupo_muscular, instrucoes)
TREINOS (id_treino PK, usuario_id FK -> USUARIOS, nome)
ITENS_TREINO (treino_id PK FK -> TREINOS, exercicio_id PK FK -> EXERCICIOS,
              ordem, series, repeticoes, carga_kg)
EXECUCOES_TREINO (id_execucao PK, treino_id FK -> TREINOS, executado_em,
                   duracao_minutos, esforco_percebido)
```

```sql
CREATE DATABASE IF NOT EXISTS treinozen
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE treinozen;

CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario    BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome          VARCHAR(255)     NOT NULL,
    email         VARCHAR(255)     NOT NULL,
    senha_hash    VARCHAR(255)     NOT NULL,
    tipo_usuario  ENUM('administrador', 'usuario') NOT NULL DEFAULT 'usuario',
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME         NULL,

    PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_email UNIQUE (email)
);

CREATE TABLE IF NOT EXISTS exercicios (
    id_exercicio    BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(255)     NOT NULL,
    grupo_muscular  VARCHAR(100)     NOT NULL,
    instrucoes      TEXT             NULL,
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                     ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME         NULL,

    PRIMARY KEY (id_exercicio),
    CONSTRAINT uq_exercicio_nome UNIQUE (nome)
);

CREATE TABLE IF NOT EXISTS treinos (
    id_treino    BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    usuario_id   BIGINT UNSIGNED  NOT NULL,
    nome         VARCHAR(255)     NOT NULL,
    criado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                  ON UPDATE CURRENT_TIMESTAMP,
    deletado_em  DATETIME         NULL,

    PRIMARY KEY (id_treino),
    -- RNF03: histórico de treinos do usuário não pode sumir silenciosamente
    CONSTRAINT fk_treino_usuario FOREIGN KEY (usuario_id)
                                  REFERENCES usuarios (id_usuario)
                                  ON DELETE RESTRICT
                                  ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS itens_treino (
    treino_id     BIGINT UNSIGNED   NOT NULL,
    exercicio_id  BIGINT UNSIGNED   NOT NULL,
    ordem         TINYINT UNSIGNED  NOT NULL,
    series        TINYINT UNSIGNED  NOT NULL,
    repeticoes    TINYINT UNSIGNED  NOT NULL,
    carga_kg      DECIMAL(5,2)      NOT NULL,
    criado_em     DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP
                                    ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME          NULL,

    PRIMARY KEY (treino_id, exercicio_id),
    CONSTRAINT ck_item_carga CHECK (carga_kg >= 0),
    -- Item só existe como composição de um treino específico: some junto com o treino
    CONSTRAINT fk_item_treino FOREIGN KEY (treino_id)
                               REFERENCES treinos (id_treino)
                               ON DELETE CASCADE
                               ON UPDATE CASCADE,
    -- RNF04: exercício do catálogo referenciado em alguma rotina não pode ser removido
    CONSTRAINT fk_item_exercicio FOREIGN KEY (exercicio_id)
                                  REFERENCES exercicios (id_exercicio)
                                  ON DELETE RESTRICT
                                  ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS execucoes_treino (
    id_execucao        BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    treino_id          BIGINT UNSIGNED   NOT NULL,
    executado_em       DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    duracao_minutos    INT UNSIGNED      NOT NULL,
    esforco_percebido  TINYINT UNSIGNED  NOT NULL,
    criado_em          DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em        DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP
                                         ON UPDATE CURRENT_TIMESTAMP,
    deletado_em        DATETIME          NULL,

    PRIMARY KEY (id_execucao),
    CONSTRAINT ck_execucao_esforco CHECK (esforco_percebido BETWEEN 1 AND 10),
    -- Execução é fato histórico real (o treino aconteceu): protege mesmo que o
    -- "molde" do treino (ITENS_TREINO) já tenha sido apagado
    CONSTRAINT fk_execucao_treino FOREIGN KEY (treino_id)
                                   REFERENCES treinos (id_treino)
                                   ON DELETE RESTRICT
                                   ON UPDATE CASCADE
);
```

**Comentários:**

- 💭 Resposta à pergunta-guia: `RNF03` → `fk_treino_usuario` com `ON DELETE
  RESTRICT`; `RNF04` → `fk_item_exercicio` com `ON DELETE RESTRICT`.
- Repare a **assimetria intencional** em `treino_id`: `fk_item_treino` é `CASCADE`
  (a composição de exercícios de um treino não tem valor fora do próprio treino),
  mas `fk_execucao_treino` é `RESTRICT` (uma execução já realizada é fato histórico
  — apagar o treino-molde não pode apagar o registro de que o usuário efetivamente
  treinou). Duas FKs para a mesma tabela `TREINOS`, com ações diferentes, porque o
  papel de cada tabela filha é diferente — não existe regra única "toda FK para X
  usa a mesma ação".
- `RNF02` (`BIGINT UNSIGNED` em toda PK/FK) já está satisfeito em todas as tabelas.

---

## Exercício 3 — RachaConta {: #exercicio-3 }

**Modelo Lógico:**

```
USUARIOS (id_usuario PK, nome, email UNIQUE, senha_hash, tipo_usuario)
GRUPOS (id_grupo PK, nome, criador_id FK -> USUARIOS)
MEMBROS_GRUPO (grupo_id PK FK -> GRUPOS, usuario_id PK FK -> USUARIOS, entrou_em)
DESPESAS (id_despesa PK, grupo_id FK -> GRUPOS, pagador_id FK -> USUARIOS,
          descricao, valor_total, data_despesa)
PARTICIPANTES_DESPESA (despesa_id PK FK -> DESPESAS, usuario_id PK FK -> USUARIOS,
                        valor_devido)
```

```sql
CREATE DATABASE IF NOT EXISTS rachaconta
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE rachaconta;

CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario    BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome          VARCHAR(255)     NOT NULL,
    email         VARCHAR(255)     NOT NULL,
    senha_hash    VARCHAR(255)     NOT NULL,
    tipo_usuario  ENUM('administrador', 'usuario') NOT NULL DEFAULT 'usuario',
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME         NULL,

    PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_email UNIQUE (email)
);

CREATE TABLE IF NOT EXISTS grupos (
    id_grupo     BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    criador_id   BIGINT UNSIGNED  NOT NULL,
    nome         VARCHAR(255)     NOT NULL,
    criado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                  ON UPDATE CURRENT_TIMESTAMP,
    deletado_em  DATETIME         NULL,

    PRIMARY KEY (id_grupo),
    -- Regra 7 — papel "criador", não "usuario_id"
    CONSTRAINT fk_grupo_criador FOREIGN KEY (criador_id)
                                 REFERENCES usuarios (id_usuario)
                                 ON DELETE RESTRICT
                                 ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS membros_grupo (
    grupo_id     BIGINT UNSIGNED  NOT NULL,
    usuario_id   BIGINT UNSIGNED  NOT NULL,
    entrou_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    criado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                  ON UPDATE CURRENT_TIMESTAMP,
    deletado_em  DATETIME         NULL,

    PRIMARY KEY (grupo_id, usuario_id),
    -- Ser membro de um grupo não tem valor histórico próprio: se o grupo sumir, a
    -- lista de membros some junto
    CONSTRAINT fk_membro_grupo FOREIGN KEY (grupo_id)
                                REFERENCES grupos (id_grupo)
                                ON DELETE CASCADE
                                ON UPDATE CASCADE,
    CONSTRAINT fk_membro_usuario FOREIGN KEY (usuario_id)
                                  REFERENCES usuarios (id_usuario)
                                  ON DELETE RESTRICT
                                  ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS despesas (
    id_despesa    BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    grupo_id      BIGINT UNSIGNED  NOT NULL,
    pagador_id    BIGINT UNSIGNED  NOT NULL,
    descricao     VARCHAR(255)     NOT NULL,
    valor_total   DECIMAL(10,2)    NOT NULL,
    data_despesa  DATE             NOT NULL,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME         NULL,

    PRIMARY KEY (id_despesa),
    CONSTRAINT ck_despesa_valor CHECK (valor_total >= 0),
    -- Diferente de MEMBROS_GRUPO: despesa é histórico financeiro real — um grupo
    -- com despesas registradas não pode ser removido com DELETE
    CONSTRAINT fk_despesa_grupo FOREIGN KEY (grupo_id)
                                 REFERENCES grupos (id_grupo)
                                 ON DELETE RESTRICT
                                 ON UPDATE CASCADE,
    -- Regra 7 — papel "pagador"
    CONSTRAINT fk_despesa_pagador FOREIGN KEY (pagador_id)
                                   REFERENCES usuarios (id_usuario)
                                   ON DELETE RESTRICT
                                   ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS participantes_despesa (
    despesa_id    BIGINT UNSIGNED  NOT NULL,
    usuario_id    BIGINT UNSIGNED  NOT NULL,
    valor_devido  DECIMAL(10,2)    NOT NULL,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME         NULL,

    PRIMARY KEY (despesa_id, usuario_id),
    CONSTRAINT ck_participante_valor CHECK (valor_devido >= 0),
    -- Divisão só existe como parte de uma despesa específica
    CONSTRAINT fk_participante_despesa FOREIGN KEY (despesa_id)
                                        REFERENCES despesas (id_despesa)
                                        ON DELETE CASCADE
                                        ON UPDATE CASCADE,
    CONSTRAINT fk_participante_usuario FOREIGN KEY (usuario_id)
                                        REFERENCES usuarios (id_usuario)
                                        ON DELETE RESTRICT
                                        ON UPDATE CASCADE
);
```

**Comentários:**

- 💭 Resposta à pergunta-guia: **não, as duas FKs que apontam para `GRUPOS` não devem
  ter o mesmo `ON DELETE`**, mesmo apontando para a mesma tabela pai. `MEMBROS_GRUPO`
  é pura lista de participação, sem valor próprio fora do grupo — `CASCADE`.
  `DESPESAS` é histórico financeiro real — `RESTRICT`. A ação certa depende do **papel
  da tabela filha**, não de qual tabela é a pai.
- `participantes_despesa` segue o mesmo padrão de `itens_cupom`/`itens_pedido` do
  Exemplo Completo: item de divisão que só existe dentro de uma despesa → `CASCADE`
  com a despesa, `RESTRICT` com o usuário (protege o histórico de "quem deve o quê").

---

## Exercício 4 — OndaCast {: #exercicio-4 }

**Modelo Lógico:**

```
USUARIOS (id_usuario PK, nome, email UNIQUE, senha_hash, tipo_usuario)
PLANOS (id_plano PK, nome UNIQUE, preco_mensal, limite_downloads_offline)
ASSINATURAS (id_assinatura PK, usuario_id FK -> USUARIOS, plano_id FK -> PLANOS,
             data_inicio, data_fim)
PODCASTS (id_podcast PK, titulo, categoria, apresentador)
AUDIOLIVROS (id_audiolivro PK, titulo, autor, narrador_principal)
CONTEUDOS (id_conteudo PK, titulo, duracao_segundos, data_publicacao)
EPISODIOS_PODCAST (id_conteudo PK FK -> CONTEUDOS, podcast_id FK -> PODCASTS,
                    numero_episodio, transcricao_disponivel)
CAPITULOS_AUDIOLIVRO (id_conteudo PK FK -> CONTEUDOS, audiolivro_id FK -> AUDIOLIVROS,
                       numero_capitulo, narrador)
PLAYLISTS (id_playlist PK, usuario_id FK -> USUARIOS, nome)
ITENS_PLAYLIST (playlist_id PK FK -> PLAYLISTS, conteudo_id PK FK -> CONTEUDOS, ordem)
```

```sql
CREATE DATABASE IF NOT EXISTS ondacast
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE ondacast;

CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario    BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome          VARCHAR(255)     NOT NULL,
    email         VARCHAR(255)     NOT NULL,
    senha_hash    VARCHAR(255)     NOT NULL,
    tipo_usuario  ENUM('administrador', 'usuario') NOT NULL DEFAULT 'usuario',
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME         NULL,

    PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_email UNIQUE (email)
);

CREATE TABLE IF NOT EXISTS planos (
    id_plano                  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome                      VARCHAR(100)     NOT NULL,
    preco_mensal              DECIMAL(8,2)     NOT NULL,
    limite_downloads_offline  INT UNSIGNED     NOT NULL,
    criado_em                 DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em               DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                               ON UPDATE CURRENT_TIMESTAMP,
    deletado_em               DATETIME         NULL,

    PRIMARY KEY (id_plano),
    CONSTRAINT uq_plano_nome UNIQUE (nome),
    CONSTRAINT ck_plano_preco CHECK (preco_mensal >= 0)
);

CREATE TABLE IF NOT EXISTS assinaturas (
    id_assinatura  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    usuario_id     BIGINT UNSIGNED  NOT NULL,
    plano_id       BIGINT UNSIGNED  NOT NULL,
    data_inicio    DATE             NOT NULL,
    data_fim       DATE             NULL,
    criado_em      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                    ON UPDATE CURRENT_TIMESTAMP,
    deletado_em    DATETIME         NULL,

    PRIMARY KEY (id_assinatura),
    CONSTRAINT ck_assinatura_datas CHECK (data_fim IS NULL OR data_fim >= data_inicio),
    -- Histórico de assinaturas não pode perder a referência de quem assinou
    CONSTRAINT fk_assinatura_usuario FOREIGN KEY (usuario_id)
                                      REFERENCES usuarios (id_usuario)
                                      ON DELETE RESTRICT
                                      ON UPDATE CASCADE,
    -- ...nem qual plano foi contratado, mesmo que o plano seja descontinuado depois
    CONSTRAINT fk_assinatura_plano FOREIGN KEY (plano_id)
                                    REFERENCES planos (id_plano)
                                    ON DELETE RESTRICT
                                    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS podcasts (
    id_podcast    BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    titulo        VARCHAR(255)     NOT NULL,
    categoria     VARCHAR(100)     NOT NULL,
    apresentador  VARCHAR(255)     NOT NULL,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME         NULL,

    PRIMARY KEY (id_podcast)
);

CREATE TABLE IF NOT EXISTS audiolivros (
    id_audiolivro       BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    titulo              VARCHAR(255)     NOT NULL,
    autor               VARCHAR(255)     NOT NULL,
    narrador_principal  VARCHAR(255)     NOT NULL,
    criado_em           DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                         ON UPDATE CURRENT_TIMESTAMP,
    deletado_em         DATETIME         NULL,

    PRIMARY KEY (id_audiolivro)
);

-- Superclasse (Estratégia 2 — Aula 01, 8.7)
CREATE TABLE IF NOT EXISTS conteudos (
    id_conteudo       BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    titulo            VARCHAR(255)     NOT NULL,
    duracao_segundos  INT UNSIGNED     NOT NULL,
    data_publicacao   DATE             NOT NULL,
    criado_em         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                       ON UPDATE CURRENT_TIMESTAMP,
    deletado_em       DATETIME         NULL,

    PRIMARY KEY (id_conteudo)
);

-- Subclasse — a PK é, ao mesmo tempo, FK única para a superclasse
CREATE TABLE IF NOT EXISTS episodios_podcast (
    id_conteudo             BIGINT UNSIGNED  NOT NULL,
    podcast_id              BIGINT UNSIGNED  NOT NULL,
    numero_episodio         INT UNSIGNED     NOT NULL,
    transcricao_disponivel  BOOLEAN          NOT NULL DEFAULT FALSE,
    criado_em               DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em             DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                             ON UPDATE CURRENT_TIMESTAMP,
    deletado_em             DATETIME         NULL,

    PRIMARY KEY (id_conteudo),
    -- Linha de EPISODIOS_PODCAST não existe sem a linha de CONTEUDOS correspondente
    CONSTRAINT fk_episodio_conteudo FOREIGN KEY (id_conteudo)
                                     REFERENCES conteudos (id_conteudo)
                                     ON DELETE CASCADE
                                     ON UPDATE CASCADE,
    CONSTRAINT fk_episodio_podcast FOREIGN KEY (podcast_id)
                                    REFERENCES podcasts (id_podcast)
                                    ON DELETE RESTRICT
                                    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS capitulos_audiolivro (
    id_conteudo      BIGINT UNSIGNED  NOT NULL,
    audiolivro_id    BIGINT UNSIGNED  NOT NULL,
    numero_capitulo  INT UNSIGNED     NOT NULL,
    narrador         VARCHAR(255)     NOT NULL,
    criado_em        DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                      ON UPDATE CURRENT_TIMESTAMP,
    deletado_em      DATETIME         NULL,

    PRIMARY KEY (id_conteudo),
    CONSTRAINT fk_capitulo_conteudo FOREIGN KEY (id_conteudo)
                                     REFERENCES conteudos (id_conteudo)
                                     ON DELETE CASCADE
                                     ON UPDATE CASCADE,
    CONSTRAINT fk_capitulo_audiolivro FOREIGN KEY (audiolivro_id)
                                       REFERENCES audiolivros (id_audiolivro)
                                       ON DELETE RESTRICT
                                       ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS playlists (
    id_playlist  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    usuario_id   BIGINT UNSIGNED  NOT NULL,
    nome         VARCHAR(255)     NOT NULL,
    criado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                  ON UPDATE CURRENT_TIMESTAMP,
    deletado_em  DATETIME         NULL,

    PRIMARY KEY (id_playlist),
    CONSTRAINT fk_playlist_usuario FOREIGN KEY (usuario_id)
                                    REFERENCES usuarios (id_usuario)
                                    ON DELETE RESTRICT
                                    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS itens_playlist (
    playlist_id  BIGINT UNSIGNED  NOT NULL,
    conteudo_id  BIGINT UNSIGNED  NOT NULL,
    ordem        SMALLINT UNSIGNED NOT NULL,
    criado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                  ON UPDATE CURRENT_TIMESTAMP,
    deletado_em  DATETIME         NULL,

    PRIMARY KEY (playlist_id, conteudo_id),
    CONSTRAINT fk_item_playlist FOREIGN KEY (playlist_id)
                                 REFERENCES playlists (id_playlist)
                                 ON DELETE CASCADE
                                 ON UPDATE CASCADE,
    -- Conteúdo referenciado em playlists de usuários não pode sumir do catálogo
    CONSTRAINT fk_item_conteudo FOREIGN KEY (conteudo_id)
                                 REFERENCES conteudos (id_conteudo)
                                 ON DELETE RESTRICT
                                 ON UPDATE CASCADE
);
```

**Comentários:**

- 💭 Resposta à pergunta-guia: `ON DELETE CASCADE` — uma linha em `EPISODIOS_PODCAST`
  (ou `CAPITULOS_AUDIOLIVRO`) não tem sentido sem a linha correspondente em
  `CONTEUDOS`; é exatamente essa dependência de existência que caracteriza a
  Estratégia 2 de generalização/especialização (Aula 01, 8.7) — se a superclasse
  some, a subclasse tem que sumir junto.
- Já `fk_episodio_podcast`/`fk_capitulo_audiolivro` (para `PODCASTS`/`AUDIOLIVROS`)
  são `RESTRICT`: um podcast com episódios cadastrados não pode ser removido do
  catálogo com um simples `DELETE`.

---

## Exercício 5 — CaronaViva {: #exercicio-5 }

**Modelo Lógico:**

```
PESSOAS (id_pessoa PK, nome, cpf UNIQUE, email UNIQUE, telefone, senha_hash, tipo_usuario)
MOTORISTAS (id_pessoa PK FK -> PESSOAS, cnh UNIQUE, placa_veiculo UNIQUE, modelo_veiculo)
PASSAGEIROS (id_pessoa PK FK -> PESSOAS, endereco_padrao_embarque)
CARONAS (id_carona PK, motorista_id FK -> MOTORISTAS, origem, destino,
         data_hora_saida, vagas_disponiveis, valor_por_vaga)
RESERVAS_CARONA (carona_id PK FK -> CARONAS, passageiro_id PK FK -> PASSAGEIROS, status)
AVALIACOES (id_avaliacao PK, carona_id FK -> CARONAS, avaliador_id FK -> PESSOAS,
            avaliado_id FK -> PESSOAS, nota, comentario)
```

```sql
CREATE DATABASE IF NOT EXISTS caronaviva
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE caronaviva;

CREATE TABLE IF NOT EXISTS pessoas (
    id_pessoa     BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome          VARCHAR(255)     NOT NULL,
    cpf           CHAR(11)         NOT NULL,
    email         VARCHAR(255)     NOT NULL,
    telefone      VARCHAR(20)      NOT NULL,
    senha_hash    VARCHAR(255)     NOT NULL,
    tipo_usuario  ENUM('administrador', 'usuario') NOT NULL DEFAULT 'usuario',
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME         NULL,

    PRIMARY KEY (id_pessoa),
    CONSTRAINT uq_pessoa_cpf   UNIQUE (cpf),
    CONSTRAINT uq_pessoa_email UNIQUE (email)
);

-- Subclasse — identifying relationship com PESSOAS (Estratégia 2)
CREATE TABLE IF NOT EXISTS motoristas (
    id_pessoa       BIGINT UNSIGNED  NOT NULL,
    cnh             VARCHAR(20)      NOT NULL,
    placa_veiculo   CHAR(7)          NOT NULL,
    modelo_veiculo  VARCHAR(100)     NOT NULL,
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                     ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME         NULL,

    PRIMARY KEY (id_pessoa),
    CONSTRAINT uq_motorista_cnh   UNIQUE (cnh),
    CONSTRAINT uq_motorista_placa UNIQUE (placa_veiculo),
    CONSTRAINT fk_motorista_pessoa FOREIGN KEY (id_pessoa)
                                    REFERENCES pessoas (id_pessoa)
                                    ON DELETE CASCADE
                                    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS passageiros (
    id_pessoa                 BIGINT UNSIGNED  NOT NULL,
    endereco_padrao_embarque  VARCHAR(255)     NULL,
    criado_em                 DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em               DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                               ON UPDATE CURRENT_TIMESTAMP,
    deletado_em               DATETIME         NULL,

    PRIMARY KEY (id_pessoa),
    CONSTRAINT fk_passageiro_pessoa FOREIGN KEY (id_pessoa)
                                     REFERENCES pessoas (id_pessoa)
                                     ON DELETE CASCADE
                                     ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS caronas (
    id_carona          BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    motorista_id       BIGINT UNSIGNED  NOT NULL,
    origem             VARCHAR(255)     NOT NULL,
    destino            VARCHAR(255)     NOT NULL,
    data_hora_saida    DATETIME         NOT NULL,
    vagas_disponiveis  TINYINT UNSIGNED NOT NULL,
    valor_por_vaga     DECIMAL(8,2)     NOT NULL,
    criado_em          DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em        DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                        ON UPDATE CURRENT_TIMESTAMP,
    deletado_em        DATETIME         NULL,

    PRIMARY KEY (id_carona),
    CONSTRAINT ck_carona_valor CHECK (valor_por_vaga >= 0),
    -- Carona é registro histórico de viagem: não pode ser removida enquanto o
    -- motorista existir referenciando-a (RNF04)
    CONSTRAINT fk_carona_motorista FOREIGN KEY (motorista_id)
                                    REFERENCES motoristas (id_pessoa)
                                    ON DELETE RESTRICT
                                    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS reservas_carona (
    carona_id      BIGINT UNSIGNED  NOT NULL,
    passageiro_id  BIGINT UNSIGNED  NOT NULL,
    status         ENUM('solicitada', 'confirmada', 'cancelada', 'concluida')
                                    NOT NULL DEFAULT 'solicitada',
    criado_em      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                    ON UPDATE CURRENT_TIMESTAMP,
    deletado_em    DATETIME         NULL,

    PRIMARY KEY (carona_id, passageiro_id),
    -- RNF04: RESTRICT impede apagar uma carona que já tem reserva vinculada
    CONSTRAINT fk_reserva_carona FOREIGN KEY (carona_id)
                                  REFERENCES caronas (id_carona)
                                  ON DELETE RESTRICT
                                  ON UPDATE CASCADE,
    CONSTRAINT fk_reserva_passageiro FOREIGN KEY (passageiro_id)
                                      REFERENCES passageiros (id_pessoa)
                                      ON DELETE RESTRICT
                                      ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS avaliacoes (
    id_avaliacao  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    carona_id     BIGINT UNSIGNED  NOT NULL,
    avaliador_id  BIGINT UNSIGNED  NOT NULL,
    avaliado_id   BIGINT UNSIGNED  NOT NULL,
    nota          TINYINT UNSIGNED NOT NULL,
    comentario    TEXT             NULL,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME         NULL,

    PRIMARY KEY (id_avaliacao),
    -- RNF03: CHECK (não FK) garante nota dentro da faixa válida
    CONSTRAINT ck_avaliacao_nota CHECK (nota BETWEEN 1 AND 5),
    CONSTRAINT fk_avaliacao_carona FOREIGN KEY (carona_id)
                                    REFERENCES caronas (id_carona)
                                    ON DELETE RESTRICT
                                    ON UPDATE CASCADE,
    -- Regra 7 — papéis "avaliador"/"avaliado", ambos sobre PESSOAS
    CONSTRAINT fk_avaliacao_avaliador FOREIGN KEY (avaliador_id)
                                       REFERENCES pessoas (id_pessoa)
                                       ON DELETE RESTRICT
                                       ON UPDATE CASCADE,
    CONSTRAINT fk_avaliacao_avaliado FOREIGN KEY (avaliado_id)
                                      REFERENCES pessoas (id_pessoa)
                                      ON DELETE RESTRICT
                                      ON UPDATE CASCADE
);
```

**Comentários:**

- 💭 Resposta à pergunta-guia: `RNF04` → `ON DELETE RESTRICT` em `fk_reserva_carona` e
  `fk_avaliacao_carona`, exatamente a mesma ação usada em `fk_carona_motorista` — o
  registro de uma viagem que já ocorreu (ou está reservada) não pode desaparecer.
  `RNF03` → não é `FOREIGN KEY`, é `CHECK` (`ck_avaliacao_nota`): validação de domínio
  de valor, não integridade referencial.
- `MOTORISTAS`/`PASSAGEIROS` usam `ON DELETE CASCADE` para a FK com `PESSOAS` — ao
  contrário das FKs anteriores, aqui é a mesma relação de "não existe sem"
  (Estratégia 2) já vista em `EPISODIOS_PODCAST`/`CONTEUDOS`, não um histórico a
  proteger.

---

## Exercício 6 — PlayHub {: #exercicio-6 }

**Modelo Lógico:**

```
USUARIOS (id_usuario PK, nome_exibicao, email UNIQUE, senha_hash)
PAPEIS (id_papel PK, nome UNIQUE)
PERMISSOES (id_permissao PK, codigo UNIQUE, descricao)
PAPEIS_PERMISSOES (papel_id PK FK -> PAPEIS, permissao_id PK FK -> PERMISSOES)
USUARIOS_PAPEIS (usuario_id PK FK -> USUARIOS, papel_id PK FK -> PAPEIS, atribuido_em)
DESENVOLVEDORAS (id_desenvolvedora PK, nome_estudio, pais_sede)
PRODUTOS (id_produto PK, desenvolvedora_id FK -> DESENVOLVEDORAS, titulo, preco_base,
          data_lancamento)
JOGOS (id_produto PK FK -> PRODUTOS, classificacao_etaria, tamanho_download_gb)
DLCS (id_produto PK FK -> PRODUTOS, jogo_base_id FK -> JOGOS)
COMPRAS (id_compra PK, usuario_id FK -> USUARIOS, produto_id FK -> PRODUTOS,
         valor_pago, data_compra)
CONQUISTAS (id_conquista PK, jogo_id FK -> JOGOS, nome, descricao, pontos)
CONQUISTAS_DESBLOQUEADAS (usuario_id PK FK -> USUARIOS, conquista_id PK FK -> CONQUISTAS,
                           desbloqueada_em)
AVALIACOES (id_avaliacao PK, usuario_id FK -> USUARIOS, produto_id FK -> PRODUTOS,
            nota, comentario) — UNIQUE (usuario_id, produto_id)
```

```sql
CREATE DATABASE IF NOT EXISTS playhub
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE playhub;

CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario     BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome_exibicao  VARCHAR(255)     NOT NULL,
    email          VARCHAR(255)     NOT NULL,
    senha_hash     VARCHAR(255)     NOT NULL,
    criado_em      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                    ON UPDATE CURRENT_TIMESTAMP,
    deletado_em    DATETIME         NULL,

    PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_email UNIQUE (email)

    -- Sem coluna tipo_usuario — controle de acesso é 100% via PAPEIS/PERMISSOES (RBAC)
);

CREATE TABLE IF NOT EXISTS papeis (
    id_papel     BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome         VARCHAR(100)     NOT NULL,
    criado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                  ON UPDATE CURRENT_TIMESTAMP,
    deletado_em  DATETIME         NULL,

    PRIMARY KEY (id_papel),
    CONSTRAINT uq_papel_nome UNIQUE (nome)
);

CREATE TABLE IF NOT EXISTS permissoes (
    id_permissao  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    codigo        VARCHAR(100)     NOT NULL,
    descricao     VARCHAR(255)     NOT NULL,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME         NULL,

    PRIMARY KEY (id_permissao),
    CONSTRAINT uq_permissao_codigo UNIQUE (codigo)
);

-- RBAC: tabela de junção pura — não guarda histórico próprio
CREATE TABLE IF NOT EXISTS papeis_permissoes (
    papel_id      BIGINT UNSIGNED  NOT NULL,
    permissao_id  BIGINT UNSIGNED  NOT NULL,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME         NULL,

    PRIMARY KEY (papel_id, permissao_id),
    CONSTRAINT fk_papel_permissao FOREIGN KEY (papel_id)
                                   REFERENCES papeis (id_papel)
                                   ON DELETE CASCADE
                                   ON UPDATE CASCADE,
    CONSTRAINT fk_permissao_papel FOREIGN KEY (permissao_id)
                                   REFERENCES permissoes (id_permissao)
                                   ON DELETE CASCADE
                                   ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS usuarios_papeis (
    usuario_id    BIGINT UNSIGNED  NOT NULL,
    papel_id      BIGINT UNSIGNED  NOT NULL,
    atribuido_em  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME         NULL,

    PRIMARY KEY (usuario_id, papel_id),
    CONSTRAINT fk_usuario_papel FOREIGN KEY (usuario_id)
                                 REFERENCES usuarios (id_usuario)
                                 ON DELETE CASCADE
                                 ON UPDATE CASCADE,
    CONSTRAINT fk_papel_usuario FOREIGN KEY (papel_id)
                                 REFERENCES papeis (id_papel)
                                 ON DELETE CASCADE
                                 ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS desenvolvedoras (
    id_desenvolvedora  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome_estudio       VARCHAR(255)     NOT NULL,
    pais_sede          VARCHAR(100)     NOT NULL,
    criado_em          DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em        DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                        ON UPDATE CURRENT_TIMESTAMP,
    deletado_em        DATETIME         NULL,

    PRIMARY KEY (id_desenvolvedora)
);

-- Superclasse (Estratégia 2)
CREATE TABLE IF NOT EXISTS produtos (
    id_produto         BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    desenvolvedora_id  BIGINT UNSIGNED  NOT NULL,
    titulo             VARCHAR(255)     NOT NULL,
    preco_base         DECIMAL(10,2)    NOT NULL,
    data_lancamento    DATE             NOT NULL,
    criado_em          DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em        DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                        ON UPDATE CURRENT_TIMESTAMP,
    deletado_em        DATETIME         NULL,

    PRIMARY KEY (id_produto),
    CONSTRAINT ck_produto_preco CHECK (preco_base >= 0),
    CONSTRAINT fk_produto_dev FOREIGN KEY (desenvolvedora_id)
                               REFERENCES desenvolvedoras (id_desenvolvedora)
                               ON DELETE RESTRICT
                               ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS jogos (
    id_produto            BIGINT UNSIGNED  NOT NULL,
    classificacao_etaria  VARCHAR(10)      NOT NULL,
    tamanho_download_gb   DECIMAL(6,2)     NOT NULL,
    criado_em             DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em           DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                           ON UPDATE CURRENT_TIMESTAMP,
    deletado_em           DATETIME         NULL,

    PRIMARY KEY (id_produto),
    CONSTRAINT fk_jogo_produto FOREIGN KEY (id_produto)
                                REFERENCES produtos (id_produto)
                                ON DELETE CASCADE
                                ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS dlcs (
    id_produto    BIGINT UNSIGNED  NOT NULL,
    jogo_base_id  BIGINT UNSIGNED  NOT NULL,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME         NULL,

    PRIMARY KEY (id_produto),
    CONSTRAINT fk_dlc_produto FOREIGN KEY (id_produto)
                               REFERENCES produtos (id_produto)
                               ON DELETE CASCADE
                               ON UPDATE CASCADE,
    -- Jogo-base com DLCs vendidas não pode ser removido do catálogo
    CONSTRAINT fk_dlc_jogo_base FOREIGN KEY (jogo_base_id)
                                 REFERENCES jogos (id_produto)
                                 ON DELETE RESTRICT
                                 ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS compras (
    id_compra    BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    usuario_id   BIGINT UNSIGNED  NOT NULL,
    produto_id   BIGINT UNSIGNED  NOT NULL,
    valor_pago   DECIMAL(10,2)    NOT NULL,
    data_compra  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    criado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                  ON UPDATE CURRENT_TIMESTAMP,
    deletado_em  DATETIME         NULL,

    PRIMARY KEY (id_compra),
    CONSTRAINT ck_compra_valor CHECK (valor_pago >= 0),
    -- Histórico financeiro: nem usuário nem produto já comprado podem sumir
    CONSTRAINT fk_compra_usuario FOREIGN KEY (usuario_id)
                                  REFERENCES usuarios (id_usuario)
                                  ON DELETE RESTRICT
                                  ON UPDATE CASCADE,
    CONSTRAINT fk_compra_produto FOREIGN KEY (produto_id)
                                  REFERENCES produtos (id_produto)
                                  ON DELETE RESTRICT
                                  ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS conquistas (
    id_conquista  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    jogo_id       BIGINT UNSIGNED  NOT NULL,
    nome          VARCHAR(255)     NOT NULL,
    descricao     TEXT             NULL,
    pontos        TINYINT UNSIGNED NOT NULL,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME         NULL,

    PRIMARY KEY (id_conquista),
    CONSTRAINT fk_conquista_jogo FOREIGN KEY (jogo_id)
                                  REFERENCES jogos (id_produto)
                                  ON DELETE RESTRICT
                                  ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS conquistas_desbloqueadas (
    usuario_id       BIGINT UNSIGNED  NOT NULL,
    conquista_id     BIGINT UNSIGNED  NOT NULL,
    desbloqueada_em  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    criado_em        DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                      ON UPDATE CURRENT_TIMESTAMP,
    deletado_em      DATETIME         NULL,

    PRIMARY KEY (usuario_id, conquista_id),
    -- Diferente de PAPEIS_PERMISSOES/USUARIOS_PAPEIS: aqui a linha É o fato histórico
    -- "o jogador desbloqueou esta conquista nesta data" — não pode sumir
    CONSTRAINT fk_desbloq_usuario FOREIGN KEY (usuario_id)
                                   REFERENCES usuarios (id_usuario)
                                   ON DELETE RESTRICT
                                   ON UPDATE CASCADE,
    CONSTRAINT fk_desbloq_conquista FOREIGN KEY (conquista_id)
                                     REFERENCES conquistas (id_conquista)
                                     ON DELETE RESTRICT
                                     ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS avaliacoes (
    id_avaliacao  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    usuario_id    BIGINT UNSIGNED  NOT NULL,
    produto_id    BIGINT UNSIGNED  NOT NULL,
    nota          TINYINT UNSIGNED NOT NULL,
    comentario    TEXT             NULL,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME         NULL,

    PRIMARY KEY (id_avaliacao),
    CONSTRAINT ck_avaliacao_nota CHECK (nota BETWEEN 1 AND 5),
    -- Um usuário só pode avaliar o mesmo produto uma vez
    CONSTRAINT uq_avaliacao_usuario_produto UNIQUE (usuario_id, produto_id),
    CONSTRAINT fk_avaliacao_usuario FOREIGN KEY (usuario_id)
                                     REFERENCES usuarios (id_usuario)
                                     ON DELETE RESTRICT
                                     ON UPDATE CASCADE,
    CONSTRAINT fk_avaliacao_produto FOREIGN KEY (produto_id)
                                     REFERENCES produtos (id_produto)
                                     ON DELETE RESTRICT
                                     ON UPDATE CASCADE
);
```

**Comentários:**

- 💭 Resposta à pergunta-guia: `COMPRAS.produto_id` e `CONQUISTAS.jogo_id` são
  `RESTRICT` — um produto comprado ou um jogo com conquistas desbloqueadas não pode
  sumir do catálogo. Já `PAPEIS_PERMISSOES` e `USUARIOS_PAPEIS` são `CASCADE` **dos
  dois lados**, inclusive no lado que aponta para `USUARIOS` — o raciocínio **não** é
  o mesmo: uma linha de atribuição de papel não é um fato histórico com valor próprio
  (é só "este usuário tem este papel agora"), então não há nada para proteger quando o
  usuário ou o papel deixam de existir.
- `CONQUISTAS_DESBLOQUEADAS`, apesar de também ter PK composta como uma tabela de
  junção, é `RESTRICT` nos dois lados — porque, ao contrário de `USUARIOS_PAPEIS`, a
  linha aqui **é** o fato histórico ("o jogador desbloqueou esta conquista"), não uma
  atribuição substituível.

---

## Exercício 7 — TrampoJá {: #exercicio-7 }

**Modelo Lógico:**

```
USUARIOS (id_usuario PK, nome, email UNIQUE, senha_hash)
PAPEIS (id_papel PK, nome UNIQUE)
PERMISSOES (id_permissao PK, codigo UNIQUE, descricao)
PAPEIS_PERMISSOES (papel_id PK FK -> PAPEIS, permissao_id PK FK -> PERMISSOES)
USUARIOS_PAPEIS (usuario_id PK FK -> USUARIOS, papel_id PK FK -> PAPEIS)
CATEGORIAS_SERVICO (id_categoria_servico PK, nome UNIQUE)
PERFIS_PRESTADOR (id_usuario PK FK -> USUARIOS, biografia,
                   categoria_principal_id FK -> CATEGORIAS_SERVICO)
SERVICOS_OFERTADOS (id_servico PK, prestador_id FK -> PERFIS_PRESTADOR,
                     categoria_id FK -> CATEGORIAS_SERVICO, titulo, descricao, preco_base)
PROPOSTAS (id_proposta PK, servico_id FK -> SERVICOS_OFERTADOS,
           cliente_id FK -> USUARIOS, mensagem, valor_proposto, status, data_proposta)
CONTRATOS (id_contrato PK, proposta_id FK UNIQUE -> PROPOSTAS, data_inicio,
           data_conclusao_prevista, data_conclusao_real, status, valor_final)
PAGAMENTOS (id_pagamento PK, contrato_id FK -> CONTRATOS, valor, forma_pagamento,
            status, data_pagamento)
AVALIACOES (id_avaliacao PK, contrato_id FK -> CONTRATOS, avaliador_id FK -> USUARIOS,
            avaliado_id FK -> USUARIOS, nota, comentario)
```

```sql
CREATE DATABASE IF NOT EXISTS trampoja
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE trampoja;

CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario   BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome         VARCHAR(255)     NOT NULL,
    email        VARCHAR(255)     NOT NULL,
    senha_hash   VARCHAR(255)     NOT NULL,
    criado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                  ON UPDATE CURRENT_TIMESTAMP,
    deletado_em  DATETIME         NULL,

    PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_email UNIQUE (email)

    -- Sem coluna tipo_usuario — controle de acesso é 100% via PAPEIS/PERMISSOES (RBAC)
);

CREATE TABLE IF NOT EXISTS papeis (
    id_papel     BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome         VARCHAR(100)     NOT NULL,
    criado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                  ON UPDATE CURRENT_TIMESTAMP,
    deletado_em  DATETIME         NULL,

    PRIMARY KEY (id_papel),
    CONSTRAINT uq_papel_nome UNIQUE (nome)
);

CREATE TABLE IF NOT EXISTS permissoes (
    id_permissao  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    codigo        VARCHAR(100)     NOT NULL,
    descricao     VARCHAR(255)     NOT NULL,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME         NULL,

    PRIMARY KEY (id_permissao),
    CONSTRAINT uq_permissao_codigo UNIQUE (codigo)
);

CREATE TABLE IF NOT EXISTS papeis_permissoes (
    papel_id      BIGINT UNSIGNED  NOT NULL,
    permissao_id  BIGINT UNSIGNED  NOT NULL,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME         NULL,

    PRIMARY KEY (papel_id, permissao_id),
    CONSTRAINT fk_papel_permissao FOREIGN KEY (papel_id)
                                   REFERENCES papeis (id_papel)
                                   ON DELETE CASCADE
                                   ON UPDATE CASCADE,
    CONSTRAINT fk_permissao_papel FOREIGN KEY (permissao_id)
                                   REFERENCES permissoes (id_permissao)
                                   ON DELETE CASCADE
                                   ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS usuarios_papeis (
    usuario_id   BIGINT UNSIGNED  NOT NULL,
    papel_id     BIGINT UNSIGNED  NOT NULL,
    criado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                  ON UPDATE CURRENT_TIMESTAMP,
    deletado_em  DATETIME         NULL,

    PRIMARY KEY (usuario_id, papel_id),
    CONSTRAINT fk_usuario_papel FOREIGN KEY (usuario_id)
                                 REFERENCES usuarios (id_usuario)
                                 ON DELETE CASCADE
                                 ON UPDATE CASCADE,
    CONSTRAINT fk_papel_usuario FOREIGN KEY (papel_id)
                                 REFERENCES papeis (id_papel)
                                 ON DELETE CASCADE
                                 ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS categorias_servico (
    id_categoria_servico  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome                  VARCHAR(100)     NOT NULL,
    criado_em             DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em           DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                           ON UPDATE CURRENT_TIMESTAMP,
    deletado_em           DATETIME         NULL,

    PRIMARY KEY (id_categoria_servico),
    CONSTRAINT uq_categoria_nome UNIQUE (nome)
);

-- Especialização parcial de USUARIOS — só quem oferece serviço tem este perfil.
-- RNF04: essa FK apontando para USUARIOS é o que torna a regra estrutural.
CREATE TABLE IF NOT EXISTS perfis_prestador (
    id_usuario              BIGINT UNSIGNED  NOT NULL,
    biografia               TEXT             NULL,
    categoria_principal_id  BIGINT UNSIGNED  NOT NULL,
    criado_em               DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em             DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                             ON UPDATE CURRENT_TIMESTAMP,
    deletado_em             DATETIME         NULL,

    PRIMARY KEY (id_usuario),
    CONSTRAINT fk_perfil_usuario FOREIGN KEY (id_usuario)
                                  REFERENCES usuarios (id_usuario)
                                  ON DELETE CASCADE
                                  ON UPDATE CASCADE,
    CONSTRAINT fk_perfil_categoria FOREIGN KEY (categoria_principal_id)
                                    REFERENCES categorias_servico (id_categoria_servico)
                                    ON DELETE RESTRICT
                                    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS servicos_ofertados (
    id_servico    BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    prestador_id  BIGINT UNSIGNED  NOT NULL,
    categoria_id  BIGINT UNSIGNED  NOT NULL,
    titulo        VARCHAR(255)     NOT NULL,
    descricao     TEXT             NOT NULL,
    preco_base    DECIMAL(10,2)    NOT NULL,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME         NULL,

    PRIMARY KEY (id_servico),
    CONSTRAINT ck_servico_preco CHECK (preco_base >= 0),
    -- RNF04: aponta para PERFIS_PRESTADOR, não direto para USUARIOS — só um usuário
    -- que já é prestador pode ter serviços ofertados, garantido pela própria FK
    CONSTRAINT fk_servico_prestador FOREIGN KEY (prestador_id)
                                     REFERENCES perfis_prestador (id_usuario)
                                     ON DELETE RESTRICT
                                     ON UPDATE CASCADE,
    CONSTRAINT fk_servico_categoria FOREIGN KEY (categoria_id)
                                     REFERENCES categorias_servico (id_categoria_servico)
                                     ON DELETE RESTRICT
                                     ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS propostas (
    id_proposta     BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    servico_id      BIGINT UNSIGNED  NOT NULL,
    cliente_id      BIGINT UNSIGNED  NOT NULL,
    mensagem        TEXT             NULL,
    valor_proposto  DECIMAL(10,2)    NOT NULL,
    status          ENUM('pendente', 'aceita', 'recusada')
                                     NOT NULL DEFAULT 'pendente',
    data_proposta   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                     ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME         NULL,

    PRIMARY KEY (id_proposta),
    CONSTRAINT ck_proposta_valor CHECK (valor_proposto >= 0),
    -- Regra 7 — papel "cliente" sobre usuarios
    CONSTRAINT fk_proposta_servico FOREIGN KEY (servico_id)
                                    REFERENCES servicos_ofertados (id_servico)
                                    ON DELETE RESTRICT
                                    ON UPDATE CASCADE,
    CONSTRAINT fk_proposta_cliente FOREIGN KEY (cliente_id)
                                    REFERENCES usuarios (id_usuario)
                                    ON DELETE RESTRICT
                                    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS contratos (
    id_contrato              BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    proposta_id              BIGINT UNSIGNED  NOT NULL,
    data_inicio              DATE             NOT NULL,
    data_conclusao_prevista  DATE             NOT NULL,
    data_conclusao_real      DATE             NULL,
    status                   ENUM('em_andamento', 'concluido', 'cancelado')
                                              NOT NULL DEFAULT 'em_andamento',
    valor_final              DECIMAL(10,2)    NOT NULL,
    criado_em                DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em              DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                              ON UPDATE CURRENT_TIMESTAMP,
    deletado_em              DATETIME         NULL,

    PRIMARY KEY (id_contrato),
    CONSTRAINT ck_contrato_valor CHECK (valor_final >= 0),
    CONSTRAINT ck_contrato_datas CHECK (
        data_conclusao_real IS NULL OR data_conclusao_real >= data_inicio
    ),
    -- RNF02: UNIQUE na própria coluna de FK transforma o 1:N natural em 1:1 de fato
    -- (Aula 02, 8.1, Critério 1) — impede duas linhas de CONTRATOS para a mesma proposta
    CONSTRAINT uq_contrato_proposta UNIQUE (proposta_id),
    CONSTRAINT fk_contrato_proposta FOREIGN KEY (proposta_id)
                                     REFERENCES propostas (id_proposta)
                                     ON DELETE RESTRICT
                                     ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS pagamentos (
    id_pagamento     BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    contrato_id      BIGINT UNSIGNED  NOT NULL,
    valor            DECIMAL(10,2)    NOT NULL,
    forma_pagamento  ENUM('pix', 'cartao_credito', 'boleto') NOT NULL,
    status           ENUM('pendente', 'aprovado', 'estornado')
                                      NOT NULL DEFAULT 'pendente',
    data_pagamento   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    criado_em        DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                      ON UPDATE CURRENT_TIMESTAMP,
    deletado_em      DATETIME         NULL,

    PRIMARY KEY (id_pagamento),
    CONSTRAINT ck_pagamento_valor CHECK (valor >= 0),
    -- Pagamento é registro financeiro: contrato com pagamento não pode ser removido
    CONSTRAINT fk_pagamento_contrato FOREIGN KEY (contrato_id)
                                      REFERENCES contratos (id_contrato)
                                      ON DELETE RESTRICT
                                      ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS avaliacoes (
    id_avaliacao  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    contrato_id   BIGINT UNSIGNED  NOT NULL,
    avaliador_id  BIGINT UNSIGNED  NOT NULL,
    avaliado_id   BIGINT UNSIGNED  NOT NULL,
    nota          TINYINT UNSIGNED NOT NULL,
    comentario    TEXT             NULL,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME         NULL,

    PRIMARY KEY (id_avaliacao),
    CONSTRAINT ck_avaliacao_nota CHECK (nota BETWEEN 1 AND 5),
    CONSTRAINT fk_avaliacao_contrato FOREIGN KEY (contrato_id)
                                      REFERENCES contratos (id_contrato)
                                      ON DELETE RESTRICT
                                      ON UPDATE CASCADE,
    -- Regra 7 — papéis "avaliador"/"avaliado", ambos sobre usuarios
    CONSTRAINT fk_avaliacao_avaliador FOREIGN KEY (avaliador_id)
                                       REFERENCES usuarios (id_usuario)
                                       ON DELETE RESTRICT
                                       ON UPDATE CASCADE,
    CONSTRAINT fk_avaliacao_avaliado FOREIGN KEY (avaliado_id)
                                      REFERENCES usuarios (id_usuario)
                                      ON DELETE RESTRICT
                                      ON UPDATE CASCADE
);
```

**Comentários:**

- 💭 Resposta à pergunta-guia: `RNF02` é `CONSTRAINT uq_contrato_proposta UNIQUE
  (proposta_id)` — a mesma ferramenta (`UNIQUE`) do Exemplo Completo desta atividade
  (`uq_cupom_numero`), aqui aplicada à própria coluna de FK, não a um dado de negócio.
  `RNF04` é resolvido por `fk_servico_prestador` apontar para
  `perfis_prestador.id_usuario` em vez de `usuarios.id_usuario` — a estrutura da FK
  garante que só quem já tem perfil de prestador pode ter serviço ofertado, sem
  precisar de validação na aplicação.
- `PERFIS_PRESTADOR` usa `ON DELETE CASCADE` com `USUARIOS` (é especialização parcial,
  a linha não existe sem o usuário), mas `SERVICOS_OFERTADOS` usa `RESTRICT` com
  `PERFIS_PRESTADOR` — mesmo padrão de assimetria já visto no Exercício 2
  (`ITENS_TREINO` vs. `EXECUCOES_TREINO`): a subclasse em si pode cascatear com sua
  superclasse, mas os registros de negócio que dependem dela (serviços já anunciados)
  precisam de proteção própria.

---

*Fatec Jahu · IBD015 · Prof. Ronan Adriel Zenatti · 2026*
