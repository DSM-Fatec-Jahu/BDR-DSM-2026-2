# Gabarito — Simulado: Aulas 01 a 03

> ⚠️ Esta página não aparece no índice de atividades nem no menu do site — só é
> alcançável pelo link no final do enunciado do simulado, de propósito, para não
> tropeçar na resposta antes da hora. Resolva os quatro exercícios sozinho antes de ler
> qualquer coisa abaixo.

Todo o SQL abaixo foi executado em um MariaDB 10.4.32 (a mesma versão do XAMPP usado
nas aulas), duas vezes seguidas, sem erro — inclusive as constraints, que foram
testadas com inserções válidas e inválidas.

---

## Exercício 1 — Cardinalidade e chave estrangeira

**Resposta esperada:** a posição da chave estrangeira é determinada pela cardinalidade
do relacionamento, e o critério de fundo é sempre o mesmo — *uma célula guarda um único
valor*.

- **1:N — a FK vai sempre para a tabela do lado N.** Cada linha do lado N se relaciona
  com **uma única** linha do lado 1, então um único valor de FK basta para representar
  o vínculo. Ex.: `departamentos` (1) e `funcionarios` (N) → `departamento_id` em
  `funcionarios`. Colocar a FK no lado 1 exigiria guardar **vários** valores numa
  mesma célula (um departamento tem muitos funcionários), violando a 1FN.
- **1:1 — a FK pode ir para qualquer um dos lados**, com uma restrição de unicidade
  sobre ela para que o relacionamento continue sendo 1:1 no banco. A escolha se baseia
  na **participação** (a FK vai preferencialmente para o lado de participação parcial,
  pois assim pode ser `NULL` quando não há associação) e na **semântica** (vai para a
  entidade que "depende" ou "pertence a" a outra). Ex.: `pessoas` e `cnhs` →
  `pessoa_id UNIQUE` em `cnhs`.
- **N:M — a FK não vai para nenhuma das duas entidades.** O relacionamento se
  transforma em uma **nova tabela** (associativa), que recebe as duas chaves
  estrangeiras — juntas, formam a chave primária composta — e os atributos do próprio
  relacionamento. Ex.: `alunos` e `disciplinas` → `historicos (aluno_id, disciplina_id,
  nota, semestre)`.

**O que observar na correção:**

| Critério | Esperado |
|---|---|
| Distingue os três casos | Não responde de forma única para todos |
| 1:N | FK no lado N, com a justificativa de o vínculo ser de valor único |
| 1:1 | Cita a possibilidade dos dois lados e o critério de escolha, e a unicidade da FK |
| N:M | Cria tabela intermediária; não põe FK direta em nenhuma das entidades |
| Exemplos | Um exemplo coerente para cada tipo |

---

## Exercício 2 — JogaJunto (SQL)

Uma solução completa. O local aparece como **atributos de `partidas`** (`nome_local` e
`endereco_local`) — o problema de normalização que isso causa é o tema do Exercício 3.

```sql
-- Garante a reexecução: remove o banco antes de recriá-lo
DROP DATABASE IF EXISTS partidas_esportivas;

CREATE DATABASE IF NOT EXISTS partidas_esportivas
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE partidas_esportivas;

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

CREATE TABLE IF NOT EXISTS esportes (
    id_esporte      BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(255)     NOT NULL,
    minimo_pessoas  TINYINT UNSIGNED NOT NULL,
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                     ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME         NULL,

    PRIMARY KEY (id_esporte),
    CONSTRAINT uq_esporte_nome    UNIQUE (nome),
    CONSTRAINT ck_esporte_minimo  CHECK (minimo_pessoas >= 1)
);

CREATE TABLE IF NOT EXISTS partidas (
    id_partida         BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    esporte_id         BIGINT UNSIGNED   NOT NULL,
    organizador_id     BIGINT UNSIGNED   NOT NULL,
    data_hora_partida  DATETIME          NOT NULL,
    nome_local         VARCHAR(255)      NOT NULL,
    endereco_local     VARCHAR(255)      NOT NULL,
    pessoas_faltantes  SMALLINT UNSIGNED NOT NULL,
    situacao           ENUM('aberta', 'realizada', 'cancelada') NOT NULL DEFAULT 'aberta',
    criado_em          DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em        DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP
                                         ON UPDATE CURRENT_TIMESTAMP,
    deletado_em        DATETIME          NULL,

    PRIMARY KEY (id_partida),
    CONSTRAINT fk_partida_esporte     FOREIGN KEY (esporte_id)
                                      REFERENCES esportes (id_esporte)
                                      ON DELETE RESTRICT
                                      ON UPDATE CASCADE,
    CONSTRAINT fk_partida_organizador FOREIGN KEY (organizador_id)
                                      REFERENCES usuarios (id_usuario)
                                      ON DELETE RESTRICT
                                      ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS participacoes (
    partida_id   BIGINT UNSIGNED  NOT NULL,
    usuario_id   BIGINT UNSIGNED  NOT NULL,
    situacao     ENUM('pendente', 'confirmada', 'recusada') NOT NULL DEFAULT 'pendente',
    criado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                  ON UPDATE CURRENT_TIMESTAMP,
    deletado_em  DATETIME         NULL,

    PRIMARY KEY (partida_id, usuario_id),
    CONSTRAINT fk_participacao_partida FOREIGN KEY (partida_id)
                                       REFERENCES partidas (id_partida)
                                       ON DELETE RESTRICT
                                       ON UPDATE CASCADE,
    CONSTRAINT fk_participacao_usuario FOREIGN KEY (usuario_id)
                                       REFERENCES usuarios (id_usuario)
                                       ON DELETE RESTRICT
                                       ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS avaliacoes (
    id_avaliacao  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    partida_id    BIGINT UNSIGNED  NOT NULL,
    avaliador_id  BIGINT UNSIGNED  NOT NULL,
    avaliado_id   BIGINT UNSIGNED  NOT NULL,
    nota          TINYINT UNSIGNED NOT NULL,
    comentario    TEXT             NULL,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME         NULL,

    PRIMARY KEY (id_avaliacao),
    CONSTRAINT uq_avaliacao_partida_par UNIQUE (partida_id, avaliador_id, avaliado_id),
    CONSTRAINT ck_avaliacao_nota        CHECK (nota BETWEEN 1 AND 5),
    CONSTRAINT ck_avaliacao_pessoas     CHECK (avaliador_id <> avaliado_id),
    CONSTRAINT fk_avaliacao_partida     FOREIGN KEY (partida_id)
                                        REFERENCES partidas (id_partida)
                                        ON DELETE RESTRICT
                                        ON UPDATE CASCADE,
    CONSTRAINT fk_avaliacao_avaliador   FOREIGN KEY (avaliador_id)
                                        REFERENCES usuarios (id_usuario)
                                        ON DELETE RESTRICT
                                        ON UPDATE CASCADE,
    CONSTRAINT fk_avaliacao_avaliado    FOREIGN KEY (avaliado_id)
                                        REFERENCES usuarios (id_usuario)
                                        ON DELETE RESTRICT
                                        ON UPDATE CASCADE
);
```

**Mapeamento dos requisitos para o modelo:**

| Requisito | Onde aparece |
|---|---|
| RF02 | `usuarios.tipo_usuario` |
| RF03 | `esportes` (`nome`, `minimo_pessoas`); a restrição de "só o administrador" é regra de aplicação — o banco só guarda o tipo de acesso |
| RF04, RF05 | `partidas` (`data_hora_partida`, `nome_local`, `endereco_local`, `pessoas_faltantes`, sem limite superior ligado ao mínimo do esporte) |
| RF06 | `partidas.situacao` |
| RF07 | `participacoes` — tabela associativa do N:M `usuarios` × `partidas`, com `situacao` |
| RF08 | **Atributo derivado**: calculado (contagem de `participacoes` confirmadas comparada a `esportes.minimo_pessoas`), não armazenado |
| RF09 | `avaliacoes`, com `partida_id`, `avaliador_id` e `avaliado_id` |
| RNF02 | `uq_usuario_email`, `uq_esporte_nome` |
| RNF03 | `senha_hash` |
| RNF04 | `ck_esporte_minimo`; `SMALLINT UNSIGNED` em `pessoas_faltantes` |
| RNF05 | `ck_avaliacao_nota` |
| RNF06 | `ck_avaliacao_pessoas` (não avalia a si mesmo) e `uq_avaliacao_partida_par` (uma vez por par por partida) |
| RNF07 | Chave primária composta `(partida_id, usuario_id)` em `participacoes` |
| RNF08 | `ON DELETE RESTRICT` em todas as chaves estrangeiras |

**Pontos de correção que costumam aparecer:**

- **Regra 7 (FK pelo papel):** `avaliador_id`/`avaliado_id` e `organizador_id`, todos
  apontando para `usuarios` — nunca `usuario1_id`/`usuario2_id`.
- **Regra 8:** `minimo_pessoas` e `nota` em `TINYINT UNSIGNED` (faixa pequena e
  conhecida); e-mail e nomes em `VARCHAR(255)`; data e horário juntos em `DATETIME`.
- **Regra 9:** os três campos de log em **todas** as tabelas, inclusive na associativa.
- **Reexecução:** aceita-se tanto `DROP DATABASE IF EXISTS` (como acima) quanto
  `DROP TABLE IF EXISTS` das tabelas na ordem correta (filhas antes das pais), desde
  que os `CREATE` também estejam protegidos.
- O `ENUM` é aceitável para `tipo_usuario` e para as situações; tabela de domínio
  também seria válida.

---

## Exercício 3 — Normalização

**Resposta esperada:** **sim, há problema de normalização, e ele não foi resolvido no
script do Exercício 2.** Está em `partidas`, nas colunas `nome_local` e
`endereco_local`.

- **Forma normal violada: 3FN.** `endereco_local` depende do **local** (`nome_local`),
  e não da partida em si: `id_partida → nome_local → endereco_local` é uma dependência
  transitiva.
- **Consequência prática (anomalias):** o mesmo local, usado em várias partidas, tem
  nome e endereço **repetidos** em cada uma delas. Corrigir o endereço de uma quadra
  exige alterar várias linhas (anomalia de atualização); grafias diferentes do mesmo
  local (`"Quadra Central"` × `"quadra central "`) viram locais "diferentes"
  (inconsistência); e não é possível cadastrar um local que ainda não teve partida.
- **Complemento aceitável:** o próprio `endereco_local` é um campo composto (rua,
  número, bairro, cidade) — se o enunciado exigisse consultas por cidade, isso seria
  uma preocupação com a 1FN. Não é obrigatório para este simulado.
- **As demais tabelas estão normalizadas.** `usuarios` e `esportes` têm apenas
  atributos que dependem da própria chave. `participacoes` tem chave composta e o
  único atributo (`situacao`) depende da chave inteira. `avaliacoes` tem apenas
  atributos que dependem de `id_avaliacao`.

**Correção — apenas as tabelas afetadas** (a nova `locais` e a `partidas`, que passa a
ter `local_id` no lugar de `nome_local` e `endereco_local`). Como `locais` precisa
existir antes de `partidas`, a ordem de criação importa:

```sql
USE partidas_esportivas;

CREATE TABLE IF NOT EXISTS locais (
    id_local     BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome         VARCHAR(255)     NOT NULL,
    endereco     VARCHAR(255)     NOT NULL,
    criado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                  ON UPDATE CURRENT_TIMESTAMP,
    deletado_em  DATETIME         NULL,

    PRIMARY KEY (id_local),
    CONSTRAINT uq_local_nome_endereco UNIQUE (nome, endereco)
);

CREATE TABLE IF NOT EXISTS partidas (
    id_partida         BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    esporte_id         BIGINT UNSIGNED   NOT NULL,
    organizador_id     BIGINT UNSIGNED   NOT NULL,
    local_id           BIGINT UNSIGNED   NOT NULL,
    data_hora_partida  DATETIME          NOT NULL,
    pessoas_faltantes  SMALLINT UNSIGNED NOT NULL,
    situacao           ENUM('aberta', 'realizada', 'cancelada') NOT NULL DEFAULT 'aberta',
    criado_em          DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em        DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP
                                         ON UPDATE CURRENT_TIMESTAMP,
    deletado_em        DATETIME          NULL,

    PRIMARY KEY (id_partida),
    CONSTRAINT fk_partida_esporte     FOREIGN KEY (esporte_id)
                                      REFERENCES esportes (id_esporte)
                                      ON DELETE RESTRICT
                                      ON UPDATE CASCADE,
    CONSTRAINT fk_partida_organizador FOREIGN KEY (organizador_id)
                                      REFERENCES usuarios (id_usuario)
                                      ON DELETE RESTRICT
                                      ON UPDATE CASCADE,
    CONSTRAINT fk_partida_local       FOREIGN KEY (local_id)
                                      REFERENCES locais (id_local)
                                      ON DELETE RESTRICT
                                      ON UPDATE CASCADE
);
```

No script completo do Exercício 2, basta trocar a definição de `partidas` por esta
e criar `locais` antes dela. Como `participacoes` e `avaliacoes` referenciam
`partidas`, elas continuam sem alteração.

---

## Exercício 4 — Alterando uma estrutura existente (SQL)

```sql
DROP DATABASE IF EXISTS cadastro_pessoas;

CREATE DATABASE IF NOT EXISTS cadastro_pessoas
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE cadastro_pessoas;

CREATE TABLE IF NOT EXISTS pessoas (
    id_pessoa        BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome             VARCHAR(255)    NOT NULL,
    cpf              INT             NOT NULL,
    rg               VARCHAR(20)     NOT NULL,
    data_nascimento  DATE            NOT NULL,
    PRIMARY KEY (id_pessoa)
);

-- 1. Renomear os documentos e converter o federal para texto que comporte CNPJ
ALTER TABLE pessoas
    CHANGE COLUMN cpf doc_federal VARCHAR(14) NOT NULL;

ALTER TABLE pessoas
    CHANGE COLUMN rg doc_estadual VARCHAR(20) NOT NULL;

-- 2. Adicionar email e senha_hash
ALTER TABLE pessoas
    ADD COLUMN email       VARCHAR(255) NOT NULL,
    ADD COLUMN senha_hash  VARCHAR(255) NOT NULL;

-- 3. Adicionar tipo logo após nome
ALTER TABLE pessoas
    ADD COLUMN tipo ENUM('PF', 'PJ') NOT NULL AFTER nome;
```

Resultado esperado (`SHOW CREATE TABLE pessoas`), na ordem das colunas: `id_pessoa`,
`nome`, `tipo`, `doc_federal`, `doc_estadual`, `data_nascimento`, `email`,
`senha_hash`.

**Pontos de correção:**

- **`CHANGE COLUMN` renomeia e redefine ao mesmo tempo** — por isso o `doc_federal`
  já nasce como texto na mesma instrução. `RENAME COLUMN` só existe a partir do
  MariaDB 10.5.2; no MariaDB 10.4.32 do XAMPP das aulas ele dá erro. `CHANGE COLUMN`
  funciona em qualquer versão.
- **`VARCHAR(14)`, não `CHAR`:** CPF tem 11 dígitos e CNPJ tem 14, então o campo passa
  a ter tamanho variável (Regra 8). O tamanho considera os documentos **sem
  pontuação**, já que a formatação é responsabilidade da camada de apresentação;
  `VARCHAR(18)` também é aceitável se o aluno justificar o uso de documentos
  formatados. Um `CHAR(11)` ou `CHAR(14)` fixo é erro.
- **`cpf INT` era o defeito intencional do modelo:** um `INT` nem sequer comporta um
  CPF (o maior valor de um `INT UNSIGNED` é 4.294.967.295, e um CPF pode chegar a
  99.999.999.999) e, mesmo que comportasse, perderia os zeros à esquerda. Em uma
  tabela com dados reais, a conversão para texto não recuperaria esses zeros
  sozinha.
- **`AFTER nome`** posiciona `tipo`; sem essa cláusula o campo iria para o fim da
  tabela.
- **`ENUM('PF', 'PJ')`:** os valores do domínio em maiúsculas são dado, não palavra
  reservada — não violam a Regra 2.
- **Reexecução:** aceita-se também usar o banco do Exercício 2, desde que o script
  proteja a remoção e a criação da tabela `pessoas`.
- **Aceitável:** um único `ALTER TABLE` com várias cláusulas separadas por vírgula, no
  lugar de quatro comandos, desde que o resultado final seja o mesmo.
