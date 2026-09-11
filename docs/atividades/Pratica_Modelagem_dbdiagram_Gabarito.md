# Gabarito — Prática: Modelagem com dbdiagram.io

> ⚠️ Esta página não aparece no índice de atividades nem no menu do site — só é
> alcançável pelo link no final do enunciado da atividade, de propósito, para não
> tropeçar na resposta antes da hora. Tente resolver os 6 exercícios sozinho antes de
> ler qualquer coisa abaixo — copiar a resposta pronta não é a mesma coisa que
> aprender a modelar.

Para cada exercício: entidades identificadas, o Modelo Lógico em notação textual
(`TABELA (coluna PK, coluna FK, ...)`, o mesmo padrão usado na Aula 02, Seção 8), o
código DBML pronto para colar em [dbdiagram.io](https://dbdiagram.io), e os comentários
sobre as decisões de modelagem mais importantes.

---

## Exercício 1 — VoltGo {: #exercicio-1 }

**Entidades identificadas:** `USUARIOS`, `PATINETES`, `LOCACOES`. Sem generalização e
sem nenhuma tabela associativa N:M — as três entidades se conectam por relacionamentos
1:N simples.

**Modelo Lógico:**

```
USUARIOS (id_usuario PK, nome, email UNIQUE, senha_hash, tipo_usuario)
PATINETES (id_patinete PK, codigo UNIQUE, nivel_bateria, disponivel)
LOCACOES (id_locacao PK, patinete_id FK -> PATINETES, usuario_id FK -> USUARIOS,
          inicio, fim, valor_cobrado)
```

```dbml
Enum tipo_usuario_enum {
  administrador
  usuario
}

Table usuarios {
  id_usuario     "BIGINT UNSIGNED" [PK, INCREMENT]
  nome           VARCHAR(255)    [NOT NULL]
  email          VARCHAR(255)    [NOT NULL, UNIQUE]
  senha_hash     VARCHAR(255)    [NOT NULL]
  tipo_usuario   tipo_usuario_enum [NOT NULL, default: 'usuario']
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

Table patinetes {
  id_patinete     "BIGINT UNSIGNED" [PK, INCREMENT]
  codigo          VARCHAR(20)     [NOT NULL, UNIQUE, note: 'código de identificação físico do patinete']
  nivel_bateria   "TINYINT UNSIGNED" [NOT NULL, note: 'percentual de 0 a 100']
  disponivel      BOOLEAN         [NOT NULL, default: true]
  criado_em       DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em     DATETIME        [NOT NULL]
  deletado_em     DATETIME
}

// LOCACOES tem PK própria — NÃO é tabela associativa N:M: o mesmo par
// (patinete, usuário) pode se repetir livremente em locações diferentes ao longo do tempo
Table locacoes {
  id_locacao      "BIGINT UNSIGNED" [PK, INCREMENT]
  patinete_id     "BIGINT UNSIGNED" [NOT NULL]
  usuario_id      "BIGINT UNSIGNED" [NOT NULL]
  inicio          DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  fim             DATETIME        [note: 'NULL enquanto a locação estiver em andamento']
  valor_cobrado   DECIMAL(6,2)    [note: 'só é preenchido quando a locação termina']
  criado_em       DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em     DATETIME        [NOT NULL]
  deletado_em     DATETIME
}

Ref fk_locacao_patinete: locacoes.patinete_id > patinetes.id_patinete
Ref fk_locacao_usuario:  locacoes.usuario_id  > usuarios.id_usuario
```

**Comentários:**

- `LOCACOES` **não** é uma tabela associativa N:M, mesmo conectando `USUARIOS` e
  `PATINETES` — ela tem PK própria (`id_locacao`), porque o mesmo usuário pode alugar o
  mesmo patinete várias vezes em dias diferentes, cada aluguel virando uma **nova
  linha**. Uma tabela associativa de PK composta (como as N:M dos outros exercícios)
  só faz sentido quando o par de FKs deve ser **único** — aqui não deve.
- `fim` e `valor_cobrado` ficam `NULL` enquanto a locação está em andamento. Isso
  dispensa uma coluna extra `status`: o próprio `NULL` em `fim` já responde "essa
  locação ainda está rolando?".
- `disponivel`, em `PATINETES`, é uma informação que, em teoria, dá para descobrir
  consultando `LOCACOES` (um patinete está indisponível se existe uma locação dele com
  `fim IS NULL`). Guardá-la à parte é uma decisão de **performance** — evita varrer
  `LOCACOES` toda vez que o app precisa listar patinetes livres no mapa — não uma
  violação de normalização; voltaremos a esse tipo de troca quando o curso chegar em
  índices e otimização de consultas.

---

## Exercício 2 — TreinoZen {: #exercicio-2 }

**Entidades identificadas:** `USUARIOS`, `EXERCICIOS`, `TREINOS`, `ITENS_TREINO`
(associativa, com atributos do relacionamento), `EXECUCOES_TREINO`. Sem generalização.

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

```dbml
Enum tipo_usuario_enum {
  administrador
  usuario
}

Table usuarios {
  id_usuario     "BIGINT UNSIGNED" [PK, INCREMENT]
  nome           VARCHAR(255)    [NOT NULL]
  email          VARCHAR(255)    [NOT NULL, UNIQUE]
  senha_hash     VARCHAR(255)    [NOT NULL]
  tipo_usuario   tipo_usuario_enum [NOT NULL, default: 'usuario']
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

Table exercicios {
  id_exercicio    "BIGINT UNSIGNED" [PK, INCREMENT]
  nome            VARCHAR(255)    [NOT NULL, UNIQUE]
  grupo_muscular  VARCHAR(100)    [NOT NULL]
  instrucoes      TEXT
  criado_em       DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em     DATETIME        [NOT NULL]
  deletado_em     DATETIME
}

Table treinos {
  id_treino      "BIGINT UNSIGNED" [PK, INCREMENT]
  usuario_id     "BIGINT UNSIGNED" [NOT NULL]
  nome           VARCHAR(255)    [NOT NULL]
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

// N:M treinos <-> exercicios, com atributos próprios do relacionamento
Table itens_treino {
  treino_id      "BIGINT UNSIGNED" [PK, NOT NULL]
  exercicio_id   "BIGINT UNSIGNED" [PK, NOT NULL]
  ordem          "TINYINT UNSIGNED" [NOT NULL, note: 'ordem de execução dentro do treino']
  series         "TINYINT UNSIGNED" [NOT NULL]
  repeticoes     "TINYINT UNSIGNED" [NOT NULL]
  carga_kg       DECIMAL(5,2)    [NOT NULL]
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

Table execucoes_treino {
  id_execucao        "BIGINT UNSIGNED" [PK, INCREMENT]
  treino_id          "BIGINT UNSIGNED" [NOT NULL]
  executado_em       DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  duracao_minutos    "INT UNSIGNED"    [NOT NULL]
  esforco_percebido  "TINYINT UNSIGNED" [NOT NULL, note: 'escala de 1 a 10']
  criado_em          DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em        DATETIME        [NOT NULL]
  deletado_em        DATETIME
}

Ref fk_treino_usuario:    treinos.usuario_id           > usuarios.id_usuario
Ref fk_item_treino:       itens_treino.treino_id       > treinos.id_treino
Ref fk_item_exercicio:    itens_treino.exercicio_id    > exercicios.id_exercicio
Ref fk_execucao_treino:   execucoes_treino.treino_id   > treinos.id_treino
```

**Comentários:**

- `EXECUCOES_TREINO` **não** repete `usuario_id` — o usuário já é alcançável via
  `execucoes_treino.treino_id → treinos.usuario_id`. Guardar `usuario_id` direto em
  `EXECUCOES_TREINO` recriaria exatamente a **dependência transitiva** que a Aula 02
  ensinou a eliminar (o mesmo padrão de `TURMAS.professor_nome` na Seção 7 daquela
  aula).
- `carga_kg`, `series` e `repeticoes` pertencem a `ITENS_TREINO`, não a `EXERCICIOS`
  nem a `TREINOS` isoladamente — são o resultado do **encontro** entre um treino
  específico e um exercício específico (mesma lógica do método das quatro perguntas,
  Aula 01, Seção 10.1, pergunta 4).
- `ordem` como `TINYINT UNSIGNED` é suficiente porque nenhum treino terá centenas de
  exercícios — dimensionar pelo domínio real (Regra 8), não por hábito de sempre usar
  `INT`.

---

## Exercício 3 — RachaConta {: #exercicio-3 }

**Entidades identificadas:** `USUARIOS`, `GRUPOS`, `MEMBROS_GRUPO` (associativa),
`DESPESAS`, `PARTICIPANTES_DESPESA` (associativa). Sem generalização — não há
necessidade, todos os usuários compartilham o mesmo conjunto de atributos.

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

```dbml
Enum tipo_usuario_enum {
  administrador
  usuario
}

Table usuarios {
  id_usuario     "BIGINT UNSIGNED" [PK, INCREMENT]
  nome           VARCHAR(255)    [NOT NULL]
  email          VARCHAR(255)    [NOT NULL, UNIQUE]
  senha_hash     VARCHAR(255)    [NOT NULL]
  tipo_usuario   tipo_usuario_enum [NOT NULL, default: 'usuario']
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

Table grupos {
  id_grupo       "BIGINT UNSIGNED" [PK, INCREMENT]
  criador_id     "BIGINT UNSIGNED" [NOT NULL, note: 'Regra 7 — papel "criador", não "usuario_id"']
  nome           VARCHAR(255)    [NOT NULL]
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

// N:M usuarios <-> grupos — PK composta (Aula 02, 8.3)
Table membros_grupo {
  grupo_id       "BIGINT UNSIGNED" [PK, NOT NULL]
  usuario_id     "BIGINT UNSIGNED" [PK, NOT NULL]
  entrou_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

Table despesas {
  id_despesa     "BIGINT UNSIGNED" [PK, INCREMENT]
  grupo_id       "BIGINT UNSIGNED" [NOT NULL]
  pagador_id     "BIGINT UNSIGNED" [NOT NULL, note: 'Regra 7 — papel "pagador"']
  descricao      VARCHAR(255)    [NOT NULL]
  valor_total    DECIMAL(10,2)   [NOT NULL]
  data_despesa   DATE            [NOT NULL]
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

// N:M despesas <-> usuarios, com o atributo do próprio relacionamento (valor_devido)
Table participantes_despesa {
  despesa_id     "BIGINT UNSIGNED" [PK, NOT NULL]
  usuario_id     "BIGINT UNSIGNED" [PK, NOT NULL]
  valor_devido   DECIMAL(10,2)   [NOT NULL]
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

Ref fk_grupo_criador:        grupos.criador_id               > usuarios.id_usuario
Ref fk_membro_grupo:         membros_grupo.grupo_id          > grupos.id_grupo
Ref fk_membro_usuario:       membros_grupo.usuario_id        > usuarios.id_usuario
Ref fk_despesa_grupo:        despesas.grupo_id               > grupos.id_grupo
Ref fk_despesa_pagador:      despesas.pagador_id             > usuarios.id_usuario
Ref fk_participante_despesa: participantes_despesa.despesa_id > despesas.id_despesa
Ref fk_participante_usuario: participantes_despesa.usuario_id > usuarios.id_usuario
```

**Comentários:**

- O **saldo** de cada membro (quem deve para quem) nunca é armazenado — é um atributo
  **derivado**, calculado a partir da soma de `PARTICIPANTES_DESPESA.valor_devido`
  contra o que cada um pagou em `DESPESAS.pagador_id`. Armazená-lo diretamente
  duplicaria informação e criaria risco de inconsistência a cada nova despesa — o
  mesmo raciocínio de `idade` vs. `data_nascimento` da Aula 01.
- `criador_id` e `pagador_id` são dois exemplos de **Regra 7**: ambos referenciam
  `usuarios`, mas em papéis diferentes, então usam o nome do papel — nunca
  `usuario_id` genérico, que seria ambíguo.
- Nenhuma dependência parcial ou transitiva: em `PARTICIPANTES_DESPESA`,
  `valor_devido` depende da chave composta inteira `(despesa_id, usuario_id)`, não de
  apenas uma das duas partes — está em 3FN.

---

## Exercício 4 — OndaCast {: #exercicio-4 }

**Entidades identificadas:** `USUARIOS`, `PLANOS`, `ASSINATURAS` (histórico),
`PODCASTS`, `AUDIOLIVROS`, `CONTEUDOS` (superclasse), `EPISODIOS_PODCAST` e
`CAPITULOS_AUDIOLIVRO` (subclasses — Estratégia 2, Aula 01, 8.7), `PLAYLISTS`,
`ITENS_PLAYLIST` (associativa). Todo conteúdo cadastrado é episódio ou capítulo, nunca
os dois, nunca nenhum.

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

```dbml
Enum tipo_usuario_enum {
  administrador
  usuario
}

Table usuarios {
  id_usuario     "BIGINT UNSIGNED" [PK, INCREMENT]
  nome           VARCHAR(255)    [NOT NULL]
  email          VARCHAR(255)    [NOT NULL, UNIQUE]
  senha_hash     VARCHAR(255)    [NOT NULL]
  tipo_usuario   tipo_usuario_enum [NOT NULL, default: 'usuario']
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

Table planos {
  id_plano                    "BIGINT UNSIGNED" [PK, INCREMENT]
  nome                        VARCHAR(100)    [NOT NULL, UNIQUE]
  preco_mensal                DECIMAL(8,2)    [NOT NULL]
  limite_downloads_offline    "INT UNSIGNED"    [NOT NULL]
  criado_em                   DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em                 DATETIME        [NOT NULL]
  deletado_em                 DATETIME
}

// Histórico de assinaturas — 1:N a partir de usuarios e de planos
Table assinaturas {
  id_assinatura  "BIGINT UNSIGNED" [PK, INCREMENT]
  usuario_id     "BIGINT UNSIGNED" [NOT NULL]
  plano_id       "BIGINT UNSIGNED" [NOT NULL]
  data_inicio    DATE            [NOT NULL]
  data_fim       DATE            [note: 'NULL enquanto a assinatura estiver ativa']
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

Table podcasts {
  id_podcast     "BIGINT UNSIGNED" [PK, INCREMENT]
  titulo         VARCHAR(255)    [NOT NULL]
  categoria      VARCHAR(100)    [NOT NULL]
  apresentador   VARCHAR(255)    [NOT NULL]
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

Table audiolivros {
  id_audiolivro     "BIGINT UNSIGNED" [PK, INCREMENT]
  titulo            VARCHAR(255)   [NOT NULL]
  autor             VARCHAR(255)   [NOT NULL]
  narrador_principal VARCHAR(255)  [NOT NULL]
  criado_em         DATETIME       [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em       DATETIME       [NOT NULL]
  deletado_em       DATETIME
}

// Superclasse (Estratégia 2 — Aula 01, 8.7)
Table conteudos {
  id_conteudo       "BIGINT UNSIGNED" [PK, INCREMENT]
  titulo            VARCHAR(255)   [NOT NULL]
  duracao_segundos  "INT UNSIGNED"   [NOT NULL]
  data_publicacao   DATE           [NOT NULL]
  criado_em         DATETIME       [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em       DATETIME       [NOT NULL]
  deletado_em       DATETIME
}

// Subclasse — PK é, ao mesmo tempo, FK única para a superclasse
Table episodios_podcast {
  id_conteudo             "BIGINT UNSIGNED" [PK]
  podcast_id              "BIGINT UNSIGNED" [NOT NULL]
  numero_episodio         "INT UNSIGNED"    [NOT NULL]
  transcricao_disponivel  BOOLEAN         [NOT NULL, default: false]
  criado_em               DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em             DATETIME        [NOT NULL]
  deletado_em             DATETIME
}

Table capitulos_audiolivro {
  id_conteudo       "BIGINT UNSIGNED" [PK]
  audiolivro_id     "BIGINT UNSIGNED" [NOT NULL]
  numero_capitulo   "INT UNSIGNED"    [NOT NULL]
  narrador          VARCHAR(255)    [NOT NULL]
  criado_em         DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em       DATETIME        [NOT NULL]
  deletado_em       DATETIME
}

Table playlists {
  id_playlist    "BIGINT UNSIGNED" [PK, INCREMENT]
  usuario_id     "BIGINT UNSIGNED" [NOT NULL]
  nome           VARCHAR(255)    [NOT NULL]
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

// N:M playlists <-> conteudos (mistura episódios e capítulos livremente)
Table itens_playlist {
  playlist_id    "BIGINT UNSIGNED"  [PK, NOT NULL]
  conteudo_id    "BIGINT UNSIGNED"  [PK, NOT NULL]
  ordem          "SMALLINT UNSIGNED" [NOT NULL]
  criado_em      DATETIME         [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME         [NOT NULL]
  deletado_em    DATETIME
}

Ref fk_assinatura_usuario:  assinaturas.usuario_id             > usuarios.id_usuario
Ref fk_assinatura_plano:    assinaturas.plano_id               > planos.id_plano
Ref fk_episodio_conteudo:   episodios_podcast.id_conteudo      > conteudos.id_conteudo
Ref fk_episodio_podcast:    episodios_podcast.podcast_id       > podcasts.id_podcast
Ref fk_capitulo_conteudo:   capitulos_audiolivro.id_conteudo   > conteudos.id_conteudo
Ref fk_capitulo_audiolivro: capitulos_audiolivro.audiolivro_id > audiolivros.id_audiolivro
Ref fk_playlist_usuario:    playlists.usuario_id               > usuarios.id_usuario
Ref fk_item_playlist:       itens_playlist.playlist_id         > playlists.id_playlist
Ref fk_item_conteudo:       itens_playlist.conteudo_id         > conteudos.id_conteudo
```

**Comentários:**

- `ITENS_PLAYLIST` referencia `CONTEUDOS` (a superclasse), não `EPISODIOS_PODCAST` nem
  `CAPITULOS_AUDIOLIVRO` diretamente — é exatamente isso que permite misturar os dois
  tipos numa mesma playlist livremente, sem duas FKs opcionais e sem `UNION`. É o
  mesmo padrão do "item de playlist" citado na Aula 01, Seção 8.6, Exemplo 3.
- A regra de que todo conteúdo é episódio OU capítulo (nunca os dois, nunca nenhum)
  não é 100% garantida só pelo desenho das tabelas — o
  banco relacional puro não impede, por si só, que um `id_conteudo` exista em
  `EPISODIOS_PODCAST` e também em `CAPITULOS_AUDIOLIVRO`. Na prática, isso se reforça
  na camada de aplicação ou com uma coluna discriminadora extra em `CONTEUDOS` (ex.:
  `tipo_conteudo ENUM('podcast','audiolivro')`) combinada com um `CHECK` — vale
  levantar esse ponto em aula.
- `ASSINATURAS` guarda **histórico**, não o estado atual — por isso não há coluna
  "plano atual" em `USUARIOS`; o plano vigente é obtido consultando a assinatura mais
  recente com `data_fim IS NULL`.

---

## Exercício 5 — CaronaViva {: #exercicio-5 }

**Entidades identificadas:** `PESSOAS` (superclasse — e também a tabela de
autenticação), `MOTORISTAS` e `PASSAGEIROS` (subclasses — Estratégia 2), `CARONAS`,
`RESERVAS_CARONA` (associativa), `AVALIACOES`. Uma pessoa pode não assumir nenhum dos
dois papéis ainda, ou assumir os dois ao mesmo tempo (motorista e passageira
simultaneamente).

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

```dbml
Enum tipo_usuario_enum {
  administrador
  usuario
}

Enum status_reserva_enum {
  solicitada
  confirmada
  cancelada
  concluida
}

// Superclasse — também é a tabela de login/autenticação da plataforma
Table pessoas {
  id_pessoa      "BIGINT UNSIGNED" [PK, INCREMENT]
  nome           VARCHAR(255)    [NOT NULL]
  cpf            CHAR(11)        [NOT NULL, UNIQUE]
  email          VARCHAR(255)    [NOT NULL, UNIQUE]
  telefone       VARCHAR(20)     [NOT NULL]
  senha_hash     VARCHAR(255)    [NOT NULL]
  tipo_usuario   tipo_usuario_enum [NOT NULL, default: 'usuario']
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

Table motoristas {
  id_pessoa       "BIGINT UNSIGNED" [PK]
  cnh             VARCHAR(20)    [NOT NULL, UNIQUE]
  placa_veiculo   CHAR(7)        [NOT NULL, UNIQUE]
  modelo_veiculo  VARCHAR(100)   [NOT NULL]
  criado_em       DATETIME       [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em     DATETIME       [NOT NULL]
  deletado_em     DATETIME
}

Table passageiros {
  id_pessoa                  "BIGINT UNSIGNED" [PK]
  endereco_padrao_embarque   VARCHAR(255)
  criado_em                  DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em                DATETIME        [NOT NULL]
  deletado_em                DATETIME
}

Table caronas {
  id_carona          "BIGINT UNSIGNED" [PK, INCREMENT]
  motorista_id       "BIGINT UNSIGNED" [NOT NULL]
  origem             VARCHAR(255)    [NOT NULL]
  destino            VARCHAR(255)    [NOT NULL]
  data_hora_saida    DATETIME        [NOT NULL]
  vagas_disponiveis  "TINYINT UNSIGNED" [NOT NULL]
  valor_por_vaga     DECIMAL(8,2)    [NOT NULL]
  criado_em          DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em        DATETIME        [NOT NULL]
  deletado_em        DATETIME
}

// N:M caronas <-> passageiros
Table reservas_carona {
  carona_id      "BIGINT UNSIGNED" [PK, NOT NULL]
  passageiro_id  "BIGINT UNSIGNED" [PK, NOT NULL]
  status         status_reserva_enum [NOT NULL, default: 'solicitada']
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

// Avaliação mútua — motorista avalia passageiro E passageiro avalia motorista,
// ambos representados por FKs de PAPEL (Regra 7) apontando para a mesma tabela PESSOAS
Table avaliacoes {
  id_avaliacao   "BIGINT UNSIGNED" [PK, INCREMENT]
  carona_id      "BIGINT UNSIGNED" [NOT NULL]
  avaliador_id   "BIGINT UNSIGNED" [NOT NULL, note: 'Regra 7 — papel "avaliador"']
  avaliado_id    "BIGINT UNSIGNED" [NOT NULL, note: 'Regra 7 — papel "avaliado"']
  nota           "TINYINT UNSIGNED" [NOT NULL]
  comentario     TEXT
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

Ref fk_motorista_pessoa:     motoristas.id_pessoa           > pessoas.id_pessoa
Ref fk_passageiro_pessoa:    passageiros.id_pessoa          > pessoas.id_pessoa
Ref fk_carona_motorista:     caronas.motorista_id           > motoristas.id_pessoa
Ref fk_reserva_carona:       reservas_carona.carona_id      > caronas.id_carona
Ref fk_reserva_passageiro:   reservas_carona.passageiro_id  > passageiros.id_pessoa
Ref fk_avaliacao_carona:     avaliacoes.carona_id           > caronas.id_carona
Ref fk_avaliacao_avaliador:  avaliacoes.avaliador_id        > pessoas.id_pessoa
Ref fk_avaliacao_avaliado:   avaliacoes.avaliado_id         > pessoas.id_pessoa
```

**Comentários:**

- `PESSOAS` acumula dois papéis nesta modelagem: é a **superclasse** da hierarquia
  motorista/passageiro **e** a tabela de autenticação da plataforma (tem
  `senha_hash`/`tipo_usuario`). Isso evita criar uma tabela `USUARIOS` redundante
  paralela a `PESSOAS` — a pessoa *é* o usuário aqui, não faz sentido duplicar.
- `PASSAGEIROS` tem só um atributo próprio (`endereco_padrao_embarque`), bem menos que
  `MOTORISTAS`. Isso é aceitável porque a hierarquia não existe só por causa dos
  atributos: o próprio **fato de existir uma linha** em `PASSAGEIROS` já carrega
  informação de negócio relevante (esta pessoa já atuou/pode atuar como passageira) —
  é essa distinção que sustenta `RESERVAS_CARONA.passageiro_id` apontar para
  `PASSAGEIROS`, não direto para `PESSOAS`.
- `avaliador_id` e `avaliado_id` resolvem a avaliação mútua sem ambiguidade — o mesmo
  problema do auto-relacionamento `supervisor_id` da Aula 01, Seção 4.3, mas aqui via
  duas FKs numa tabela separada em vez de auto-relacionamento direto em `PESSOAS`.

---

## Exercício 6 — PlayHub {: #exercicio-6 }

**Entidades identificadas:** `USUARIOS`, `PAPEIS`, `PERMISSOES`, `PAPEIS_PERMISSOES` e
`USUARIOS_PAPEIS` (associativas — RBAC completo), `DESENVOLVEDORAS`, `PRODUTOS`
(superclasse), `JOGOS` e `DLCS` (subclasses), `COMPRAS`, `CONQUISTAS`,
`CONQUISTAS_DESBLOQUEADAS` (associativa), `AVALIACOES`. Todo `PRODUTOS` cadastrado é
obrigatoriamente um `JOGOS` ou uma `DLCS`, nunca os dois ao mesmo tempo.

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

```dbml
Table usuarios {
  id_usuario      "BIGINT UNSIGNED" [PK, INCREMENT]
  nome_exibicao   VARCHAR(255)    [NOT NULL]
  email           VARCHAR(255)    [NOT NULL, UNIQUE]
  senha_hash      VARCHAR(255)    [NOT NULL]
  criado_em       DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em     DATETIME        [NOT NULL]
  deletado_em     DATETIME

  Note: 'Sem coluna tipo_usuario — controle de acesso é 100% via PAPEIS/PERMISSOES (RBAC)'
}

Table papeis {
  id_papel       "BIGINT UNSIGNED" [PK, INCREMENT]
  nome           VARCHAR(100)    [NOT NULL, UNIQUE, note: "ex.: 'administrador', 'desenvolvedor', 'suporte', 'jogador'"]
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

Table permissoes {
  id_permissao   "BIGINT UNSIGNED" [PK, INCREMENT]
  codigo         VARCHAR(100)    [NOT NULL, UNIQUE, note: "ex.: 'gerenciar_catalogo_proprio', 'processar_reembolso'"]
  descricao      VARCHAR(255)    [NOT NULL]
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

// RBAC: um papel agrupa várias permissões (N:M)
Table papeis_permissoes {
  papel_id       "BIGINT UNSIGNED" [PK, NOT NULL]
  permissao_id   "BIGINT UNSIGNED" [PK, NOT NULL]
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

// RBAC: um usuário pode acumular mais de um papel (N:M)
Table usuarios_papeis {
  usuario_id     "BIGINT UNSIGNED" [PK, NOT NULL]
  papel_id       "BIGINT UNSIGNED" [PK, NOT NULL]
  atribuido_em   DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

Table desenvolvedoras {
  id_desenvolvedora  "BIGINT UNSIGNED" [PK, INCREMENT]
  nome_estudio       VARCHAR(255)   [NOT NULL]
  pais_sede          VARCHAR(100)   [NOT NULL]
  criado_em          DATETIME       [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em        DATETIME       [NOT NULL]
  deletado_em        DATETIME
}

// Superclasse (Estratégia 2)
Table produtos {
  id_produto        "BIGINT UNSIGNED" [PK, INCREMENT]
  desenvolvedora_id "BIGINT UNSIGNED" [NOT NULL]
  titulo            VARCHAR(255)   [NOT NULL]
  preco_base        DECIMAL(10,2)  [NOT NULL]
  data_lancamento   DATE           [NOT NULL]
  criado_em         DATETIME       [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em       DATETIME       [NOT NULL]
  deletado_em       DATETIME
}

Table jogos {
  id_produto            "BIGINT UNSIGNED" [PK]
  classificacao_etaria  VARCHAR(10)    [NOT NULL]
  tamanho_download_gb   DECIMAL(6,2)   [NOT NULL]
  criado_em             DATETIME       [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em           DATETIME       [NOT NULL]
  deletado_em           DATETIME
}

Table dlcs {
  id_produto     "BIGINT UNSIGNED" [PK]
  jogo_base_id   "BIGINT UNSIGNED" [NOT NULL, note: 'toda DLC pertence a exatamente um jogo-base']
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

Table compras {
  id_compra      "BIGINT UNSIGNED" [PK, INCREMENT]
  usuario_id     "BIGINT UNSIGNED" [NOT NULL]
  produto_id     "BIGINT UNSIGNED" [NOT NULL]
  valor_pago     DECIMAL(10,2)   [NOT NULL, note: 'snapshot do preço na compra — não recalcula pelo preco_base atual']
  data_compra    DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

Table conquistas {
  id_conquista   "BIGINT UNSIGNED" [PK, INCREMENT]
  jogo_id        "BIGINT UNSIGNED" [NOT NULL]
  nome           VARCHAR(255)    [NOT NULL]
  descricao      TEXT
  pontos         "TINYINT UNSIGNED" [NOT NULL]
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

// N:M usuarios <-> conquistas
Table conquistas_desbloqueadas {
  usuario_id       "BIGINT UNSIGNED" [PK, NOT NULL]
  conquista_id     "BIGINT UNSIGNED" [PK, NOT NULL]
  desbloqueada_em  DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  criado_em        DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em      DATETIME        [NOT NULL]
  deletado_em      DATETIME
}

Table avaliacoes {
  id_avaliacao   "BIGINT UNSIGNED" [PK, INCREMENT]
  usuario_id     "BIGINT UNSIGNED" [NOT NULL]
  produto_id     "BIGINT UNSIGNED" [NOT NULL]
  nota           "TINYINT UNSIGNED" [NOT NULL]
  comentario     TEXT
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME

  Indexes {
    (usuario_id, produto_id) [UNIQUE, note: 'um usuário só pode avaliar o mesmo produto uma vez']
  }
}

Ref fk_papel_permissao:    papeis_permissoes.papel_id           > papeis.id_papel
Ref fk_permissao_papel:    papeis_permissoes.permissao_id       > permissoes.id_permissao
Ref fk_usuario_papel:      usuarios_papeis.usuario_id           > usuarios.id_usuario
Ref fk_papel_usuario:      usuarios_papeis.papel_id             > papeis.id_papel
Ref fk_produto_dev:        produtos.desenvolvedora_id           > desenvolvedoras.id_desenvolvedora
Ref fk_jogo_produto:       jogos.id_produto                     > produtos.id_produto
Ref fk_dlc_produto:        dlcs.id_produto                      > produtos.id_produto
Ref fk_dlc_jogo_base:      dlcs.jogo_base_id                    > jogos.id_produto
Ref fk_compra_usuario:     compras.usuario_id                   > usuarios.id_usuario
Ref fk_compra_produto:     compras.produto_id                   > produtos.id_produto
Ref fk_conquista_jogo:     conquistas.jogo_id                   > jogos.id_produto
Ref fk_desbloq_usuario:    conquistas_desbloqueadas.usuario_id  > usuarios.id_usuario
Ref fk_desbloq_conquista:  conquistas_desbloqueadas.conquista_id > conquistas.id_conquista
Ref fk_avaliacao_usuario:  avaliacoes.usuario_id                > usuarios.id_usuario
Ref fk_avaliacao_produto:  avaliacoes.produto_id                > produtos.id_produto
```

**Comentários:**

- O RBAC completo usa **quatro tabelas**: `PAPEIS` e `PERMISSOES` são catálogos (o que
  existe), `USUARIOS_PAPEIS` e `PAPEIS_PERMISSOES` são as junções N:M que decidem quem
  tem o quê. Um `desenvolvedor` que também é `jogador` só precisa de duas linhas em
  `USUARIOS_PAPEIS` — nenhuma alteração de schema.
- `DLCS.jogo_base_id` aponta para `JOGOS.id_produto` (não para `PRODUTOS.id_produto`)
  — isso impede, no próprio desenho do banco, que uma DLC referencie outra DLC como
  "jogo base", reforçando a regra de negócio diretamente na estrutura.
- `COMPRAS.valor_pago` é outro exemplo do padrão "snapshot histórico" já visto no
  exemplo do cupom fiscal: o preço de catálogo (`PRODUTOS.preco_base`) muda com o
  tempo, mas o valor de uma compra já feita não pode mudar retroativamente.
- O índice único `(usuario_id, produto_id)` em `AVALIACOES` é a forma correta de
  implementar "só pode avaliar uma vez" — não dá para expressar essa regra só com PK/FK
  simples, por isso o bloco `Indexes`.

---

## Exercício 7 — TrampoJá {: #exercicio-7 }

**Entidades identificadas:** `USUARIOS`, `PAPEIS`, `PERMISSOES`, `PAPEIS_PERMISSOES` e
`USUARIOS_PAPEIS` (RBAC completo), `CATEGORIAS_SERVICO`, `PERFIS_PRESTADOR`
(especialização parcial de `USUARIOS` — nem todo usuário é prestador),
`SERVICOS_OFERTADOS`, `PROPOSTAS`, `CONTRATOS`, `PAGAMENTOS`, `AVALIACOES`.

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

```dbml
Enum status_proposta_enum {
  pendente
  aceita
  recusada
}

Enum status_contrato_enum {
  em_andamento
  concluido
  cancelado
}

Enum forma_pagamento_enum {
  pix
  cartao_credito
  boleto
}

Enum status_pagamento_enum {
  pendente
  aprovado
  estornado
}

Table usuarios {
  id_usuario     "BIGINT UNSIGNED" [PK, INCREMENT]
  nome           VARCHAR(255)    [NOT NULL]
  email          VARCHAR(255)    [NOT NULL, UNIQUE]
  senha_hash     VARCHAR(255)    [NOT NULL]
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME

  Note: 'Sem coluna tipo_usuario — controle de acesso é 100% via PAPEIS/PERMISSOES (RBAC)'
}

Table papeis {
  id_papel       "BIGINT UNSIGNED" [PK, INCREMENT]
  nome           VARCHAR(100)    [NOT NULL, UNIQUE, note: "ex.: 'administrador', 'moderador', 'cliente', 'prestador'"]
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

Table permissoes {
  id_permissao   "BIGINT UNSIGNED" [PK, INCREMENT]
  codigo         VARCHAR(100)    [NOT NULL, UNIQUE]
  descricao      VARCHAR(255)    [NOT NULL]
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

Table papeis_permissoes {
  papel_id       "BIGINT UNSIGNED" [PK, NOT NULL]
  permissao_id   "BIGINT UNSIGNED" [PK, NOT NULL]
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

Table usuarios_papeis {
  usuario_id     "BIGINT UNSIGNED" [PK, NOT NULL]
  papel_id       "BIGINT UNSIGNED" [PK, NOT NULL]
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

Table categorias_servico {
  id_categoria_servico  "BIGINT UNSIGNED" [PK, INCREMENT]
  nome                  VARCHAR(100)    [NOT NULL, UNIQUE]
  criado_em             DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em           DATETIME        [NOT NULL]
  deletado_em           DATETIME
}

// Especialização parcial de USUARIOS — só quem oferece serviço tem este perfil
Table perfis_prestador {
  id_usuario               "BIGINT UNSIGNED" [PK]
  biografia                TEXT
  categoria_principal_id   "BIGINT UNSIGNED" [NOT NULL]
  criado_em                DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em              DATETIME        [NOT NULL]
  deletado_em               DATETIME
}

Table servicos_ofertados {
  id_servico     "BIGINT UNSIGNED" [PK, INCREMENT]
  prestador_id   "BIGINT UNSIGNED" [NOT NULL]
  categoria_id   "BIGINT UNSIGNED" [NOT NULL]
  titulo         VARCHAR(255)    [NOT NULL]
  descricao      TEXT            [NOT NULL]
  preco_base     DECIMAL(10,2)   [NOT NULL]
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

Table propostas {
  id_proposta      "BIGINT UNSIGNED" [PK, INCREMENT]
  servico_id       "BIGINT UNSIGNED" [NOT NULL]
  cliente_id       "BIGINT UNSIGNED" [NOT NULL, note: 'Regra 7 — papel "cliente" sobre usuarios']
  mensagem         TEXT
  valor_proposto   DECIMAL(10,2)  [NOT NULL]
  status           status_proposta_enum [NOT NULL, default: 'pendente']
  data_proposta    DATETIME       [NOT NULL, default: `CURRENT_TIMESTAMP`]
  criado_em        DATETIME       [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em      DATETIME       [NOT NULL]
  deletado_em      DATETIME
}

// 1:1 com PROPOSTAS — só uma proposta aceita vira um contrato
Table contratos {
  id_contrato               "BIGINT UNSIGNED" [PK, INCREMENT]
  proposta_id               "BIGINT UNSIGNED" [NOT NULL, UNIQUE]
  data_inicio                DATE           [NOT NULL]
  data_conclusao_prevista    DATE           [NOT NULL]
  data_conclusao_real        DATE
  status                     status_contrato_enum [NOT NULL, default: 'em_andamento']
  valor_final                DECIMAL(10,2)  [NOT NULL]
  criado_em                  DATETIME       [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em                 DATETIME      [NOT NULL]
  deletado_em                 DATETIME
}

// 1:N a partir de CONTRATOS — permite pagamento parcelado
Table pagamentos {
  id_pagamento     "BIGINT UNSIGNED" [PK, INCREMENT]
  contrato_id      "BIGINT UNSIGNED" [NOT NULL]
  valor            DECIMAL(10,2)   [NOT NULL]
  forma_pagamento  forma_pagamento_enum [NOT NULL]
  status           status_pagamento_enum [NOT NULL, default: 'pendente']
  data_pagamento   DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  criado_em        DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em      DATETIME        [NOT NULL]
  deletado_em      DATETIME
}

Table avaliacoes {
  id_avaliacao   "BIGINT UNSIGNED" [PK, INCREMENT]
  contrato_id    "BIGINT UNSIGNED" [NOT NULL]
  avaliador_id   "BIGINT UNSIGNED" [NOT NULL, note: 'Regra 7 — papel "avaliador"']
  avaliado_id    "BIGINT UNSIGNED" [NOT NULL, note: 'Regra 7 — papel "avaliado"']
  nota           "TINYINT UNSIGNED" [NOT NULL]
  comentario     TEXT
  criado_em      DATETIME        [NOT NULL, default: `CURRENT_TIMESTAMP`]
  alterado_em    DATETIME        [NOT NULL]
  deletado_em    DATETIME
}

Ref fk_papel_permissao:     papeis_permissoes.papel_id            > papeis.id_papel
Ref fk_permissao_papel:     papeis_permissoes.permissao_id        > permissoes.id_permissao
Ref fk_usuario_papel:       usuarios_papeis.usuario_id            > usuarios.id_usuario
Ref fk_papel_usuario:       usuarios_papeis.papel_id              > papeis.id_papel
Ref fk_perfil_usuario:      perfis_prestador.id_usuario           > usuarios.id_usuario
Ref fk_perfil_categoria:    perfis_prestador.categoria_principal_id > categorias_servico.id_categoria_servico
Ref fk_servico_prestador:   servicos_ofertados.prestador_id       > perfis_prestador.id_usuario
Ref fk_servico_categoria:   servicos_ofertados.categoria_id       > categorias_servico.id_categoria_servico
Ref fk_proposta_servico:    propostas.servico_id                  > servicos_ofertados.id_servico
Ref fk_proposta_cliente:    propostas.cliente_id                  > usuarios.id_usuario
Ref fk_contrato_proposta:   contratos.proposta_id                 > propostas.id_proposta
Ref fk_pagamento_contrato:  pagamentos.contrato_id                > contratos.id_contrato
Ref fk_avaliacao_contrato:  avaliacoes.contrato_id                > contratos.id_contrato
Ref fk_avaliacao_avaliador: avaliacoes.avaliador_id               > usuarios.id_usuario
Ref fk_avaliacao_avaliado:  avaliacoes.avaliado_id                > usuarios.id_usuario
```

**Comentários:**

- `PERFIS_PRESTADOR` é uma especialização com **um único subtipo**. Ainda assim é um
  caso legítimo de especialização (Aula 01, Seção 8.2): nem todo `USUARIOS` tem uma
  linha correspondente em `PERFIS_PRESTADOR`, só quem decidiu virar prestador.
  `SERVICOS_OFERTADOS.prestador_id` aponta para `PERFIS_PRESTADOR.id_usuario` — não
  dá para um usuário sem perfil de prestador anunciar um serviço, e essa regra fica
  garantida pela própria FK, sem precisar de validação na aplicação.
- `CONTRATOS.proposta_id` é `UNIQUE` — é isso que transforma o 1:N natural (uma
  proposta pode gerar um contrato) num 1:1 de fato (Aula 02, Seção 8.1, Critério 1):
  sem o `UNIQUE`, nada impediria duas linhas de `CONTRATOS` para a mesma proposta.
  `PROPOSTAS` continua guardando `status` — inclusive `'aceita'` — mesmo depois de
  virar contrato, porque é o próprio histórico da negociação, não um dado redundante
  com `CONTRATOS.status`.
- `PAGAMENTOS` é 1:N a partir de `CONTRATOS` (não 1:1) exatamente para suportar
  parcelamento — cada linha é uma parcela, com seu próprio `status`.
- Assim como no Exercício 5, `USUARIOS` não tem coluna de tipo — todo o controle de
  acesso é resolvido por `USUARIOS_PAPEIS` + `PAPEIS_PERMISSOES`, permitindo que um
  mesmo usuário acumule `cliente` e `prestador` sem nenhuma mudança de schema.

---

*Fatec Jahu · IBD015 · Prof. Ronan Adriel Zenatti · 2026*
