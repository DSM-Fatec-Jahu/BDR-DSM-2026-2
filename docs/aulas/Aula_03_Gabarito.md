<!--
GABARITO — não faz parte do fluxo principal da aula e fica fora do `nav` do
mkdocs.yml de propósito. É acessível só pelo link no final de Aula_03_SQL_DDL.md.
-->

# Gabarito — Aula 03 — SQL e DDL: Definição de Estruturas

**Disciplina:** Banco de Dados — Relacional (IBD015)
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br
**Fatec Jahu — 2º Semestre/2026**

> ⚠️ Este gabarito é para conferência **depois** de você tentar resolver os checkpoints
> e os Exercícios de Fixação por conta própria na [Aula 03](Aula_03_SQL_DDL.md).
> Resolver antes de tentar reduz o benefício de treinar a recuperação ativa do
> conteúdo.

---

## Checkpoint 1 — Nomenclatura: plataforma de criadores de conteúdo {: #checkpoint-1 }

**Resposta:**

| Erro encontrado | Regra violada |
|---|---|
| Nome da tabela `Criador` no singular e com inicial maiúscula | Regras 2 e 4 (minúsculo e plural: `criadores`) |
| `IdCriador` em PascalCase | Regras 1 e 5 (`id_criador`, snake_case) |
| `int primary key` — palavra reservada minúscula, e tipo errado para PK | Regra 3 (`PRIMARY KEY` maiúsculo) e Regra 5 (deveria ser `BIGINT UNSIGNED AUTO_INCREMENT`) |
| `NomeCanal` em PascalCase | Regras 1 e 2 (`nome_canal`) |
| `Inscritos` maiúsculo, tipo sem `UNSIGNED` (inscritos nunca é negativo) | Regras 1/2 e 8 |
| `ReceitaMensal float` | Regras 1/2 (`receita_mensal`) e Regra 8 (nunca `FLOAT` para dinheiro — usar `DECIMAL`) |
| `ID_PLANO int` em maiúsculas e tipo incompatível com a PK referenciada | Regras 2 e 6 (`plano_id BIGINT UNSIGNED`, mesmo tipo da PK) |
| `REFERENCES Plano(id)` — tabela no singular/maiúscula e PK chamada apenas `id` | Regras 2, 4 e 5 (`planos (id_plano)`) |
| `FOREIGN KEY` sem nome de constraint | Boa prática desta disciplina (facilita depuração — ver Seção 6.5/6.6) |
| Faltam `NOT NULL` nas colunas obrigatórias | — |
| Faltam os campos de log `criado_em`, `atualizado_em`, `deletado_em` | Regra 9 |

Versão corrigida:

```sql
CREATE TABLE IF NOT EXISTS criadores (
    id_criador     BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    plano_id       BIGINT UNSIGNED  NOT NULL,
    nome_canal     VARCHAR(255)     NOT NULL,
    inscritos      INT UNSIGNED     NOT NULL DEFAULT 0,
    receita_mensal DECIMAL(10, 2)   NOT NULL DEFAULT 0.00,
    criado_em      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                             ON UPDATE CURRENT_TIMESTAMP,
    deletado_em    DATETIME             NULL,

    CONSTRAINT pk_criador       PRIMARY KEY (id_criador),
    CONSTRAINT fk_criador_plano FOREIGN KEY (plano_id)
                                REFERENCES planos (id_plano)
                                ON DELETE RESTRICT
                                ON UPDATE CASCADE
);
```

---

## Checkpoint 2 — CREATE DATABASE: carteira digital {: #checkpoint-2 }

**Resposta:**

```sql
CREATE DATABASE IF NOT EXISTS carteira_digital
    CHARACTER SET utf8mb4          -- UTF-8 completo: suporta emojis usados nas notificações do app
    COLLATE utf8mb4_unicode_ci;    -- comparação case-insensitive, correta para português

USE carteira_digital;

SHOW CREATE DATABASE carteira_digital;
```

---

## Checkpoint 3 — Tipos de Dados: geração de energia solar residencial {: #checkpoint-3 }

**Resposta:**

```sql
numero_serie_inversor            CHAR(12)        NOT NULL,  -- tamanho sempre fixo (Regra 8: CHAR para tamanho fixo)
potencia_instalada_kwp           DECIMAL(6, 2)   NOT NULL,  -- valor exato, nunca FLOAT para medidas de faturamento
energia_gerada_hoje_kwh          DECIMAL(8, 3)   NOT NULL DEFAULT 0.000,
data_instalacao                  DATE            NOT NULL,  -- só data, sem hora
valor_credito_energia_acumulado  DECIMAL(10, 2)  NOT NULL DEFAULT 0.00,  -- é dinheiro: DECIMAL, nunca FLOAT/DOUBLE
esta_ativo                       TINYINT(1)      NOT NULL DEFAULT 1,    -- booleano
observacoes_tecnicas             TEXT                NULL              -- texto livre, tamanho imprevisível, opcional
```

Justificativas: `numero_serie_inversor` usa `CHAR` (não `VARCHAR`) porque o tamanho é sempre exatamente 12 — o mesmo raciocínio do `cpf CHAR(11)` visto na Seção 6.2. `potencia_instalada_kwp`, `energia_gerada_hoje_kwh` e `valor_credito_energia_acumulado` usam `DECIMAL` porque envolvem valores que entram em cálculos de faturamento — `FLOAT`/`DOUBLE` introduziriam erros de arredondamento inaceitáveis nesse contexto (mesma lógica da Seção 5.2). `esta_ativo` é um booleano clássico (`TINYINT(1)`). `observacoes_tecnicas` usa `TEXT` porque o tamanho é imprevisível e pode ser longo — `VARCHAR(255)` arriscaria truncamento.

---

## Checkpoint 4 — CREATE TABLE e Constraints: plataforma de cursos online {: #checkpoint-4 }

**Resposta:**

```sql
CREATE TABLE IF NOT EXISTS matriculas_cursos (
    aluno_id             BIGINT UNSIGNED  NOT NULL,
    curso_id             BIGINT UNSIGNED  NOT NULL,
    progresso_percentual DECIMAL(5, 2)    NOT NULL DEFAULT 0.00,
    nota_final           DECIMAL(4, 2)        NULL,
    data_matricula       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    criado_em            DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em        DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                    ON UPDATE CURRENT_TIMESTAMP,
    deletado_em          DATETIME             NULL,

    CONSTRAINT pk_matricula_curso  PRIMARY KEY (aluno_id, curso_id),

    CONSTRAINT fk_matricula_aluno  FOREIGN KEY (aluno_id)
                                   REFERENCES alunos (id_aluno)
                                   ON DELETE CASCADE
                                   ON UPDATE CASCADE,

    CONSTRAINT fk_matricula_curso  FOREIGN KEY (curso_id)
                                   REFERENCES cursos (id_curso)
                                   ON DELETE RESTRICT
                                   ON UPDATE CASCADE,

    CONSTRAINT ck_progresso    CHECK (progresso_percentual >= 0 AND progresso_percentual <= 100),
    CONSTRAINT ck_nota_final   CHECK (nota_final IS NULL OR (nota_final >= 0 AND nota_final <= 10))
);
```

---

## Checkpoint 5 — ALTER TABLE: marketplace de freelancers {: #checkpoint-5 }

**Resposta:**

```sql
-- (a) Nova coluna
ALTER TABLE freelancers
    ADD COLUMN valor_hora DECIMAL(8, 2) NOT NULL DEFAULT 0.00;

-- (b) Renomear mantendo o tipo (CHANGE exige repetir o tipo, mesmo sem alterá-lo)
ALTER TABLE freelancers
    CHANGE COLUMN email email_contato VARCHAR(255) NOT NULL;

-- (c) FK para categoria — primeiro adiciona a coluna, depois a constraint
ALTER TABLE freelancers
    ADD COLUMN categoria_id BIGINT UNSIGNED NULL;

ALTER TABLE freelancers
    ADD CONSTRAINT fk_freelancer_categoria
        FOREIGN KEY (categoria_id)
        REFERENCES categorias_servico (id_categoria_servico)
        ON DELETE RESTRICT
        ON UPDATE CASCADE;

-- (d) CHECK de domínio
ALTER TABLE freelancers
    ADD CONSTRAINT ck_freelancer_valor_hora CHECK (valor_hora > 0);
```

---

## Checkpoint 6 — DROP e ordem de exclusão: rede de lockers inteligentes {: #checkpoint-6 }

**Resposta:**

**a)** `DROP TABLE lockers;` falha, porque a tabela `compartimentos` tem uma `FOREIGN KEY` que referencia `lockers`. O MariaDB rejeita a operação para preservar a integridade referencial — ele não permite remover uma tabela "pai" enquanto existir uma tabela "filha" apontando para ela.

**b)** Sequência correta — filhos antes dos pais:

```sql
DROP TABLE IF EXISTS entregas;
DROP TABLE IF EXISTS compartimentos;
DROP TABLE IF EXISTS lockers;
```

**c)** Com `SET FOREIGN_KEY_CHECKS`:

```sql
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS lockers;
DROP TABLE IF EXISTS compartimentos;
DROP TABLE IF EXISTS entregas;

SET FOREIGN_KEY_CHECKS = 1;
```

Isso é útil em scripts de **setup ou reset de ambiente de desenvolvimento/teste**, onde você quer derrubar e recriar um schema inteiro com muitas tabelas interdependentes rapidamente, sem ter que calcular manualmente a ordem exata de dependências toda vez — sempre lembrando de reabilitar a verificação (`= 1`) logo em seguida.

---

## Exercícios de Fixação (Seção 12)

### Exercício 1 — Identifique os erros

Os erros são: nome da tabela em singular e com inicial maiúscula (deve ser `produtos` — Regras 2 e 4); `idProduto` usa camelCase (deve ser `id_produto` — Regras 1 e 5); o tipo da PK deve ser `BIGINT UNSIGNED AUTO_INCREMENT` e `INT(11)` está depreciado (Regra 5); `NomeProduto` mistura maiúsculas (deve ser `nome`); `Preco` com maiúscula (deve ser `preco`); `FLOAT` inapropriado para preço — use `DECIMAL(10,2)` (Regra 8); `ID_CATEGORIA` mistura maiúsculas e tipo errado (deve ser `categoria_id BIGINT UNSIGNED` — Regra 6); o nome da FK não segue o padrão semântico; faltam `NOT NULL` nas colunas obrigatórias; faltam os campos de log `criado_em`, `atualizado_em` e `deletado_em` (Regra 9). Note que **não** é erro a ausência de `ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci` — o MariaDB usa esse padrão automaticamente; declarar é apenas boa prática documental.

Versão corrigida:

```sql
CREATE TABLE IF NOT EXISTS produtos (
    id_produto    BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    categoria_id  BIGINT UNSIGNED  NOT NULL,
    nome          VARCHAR(255)     NOT NULL,
    preco         DECIMAL(10, 2)   NOT NULL,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                            ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME             NULL,

    CONSTRAINT pk_produto          PRIMARY KEY (id_produto),
    CONSTRAINT fk_produto_categoria FOREIGN KEY (categoria_id)
                                    REFERENCES categorias (id_categoria)
                                    ON DELETE RESTRICT
                                    ON UPDATE CASCADE,
    CONSTRAINT ck_preco            CHECK (preco >= 0)
);
```

### Exercício 2 — Criação guiada (sistema de biblioteca)

```sql
CREATE TABLE IF NOT EXISTS autores (
    id_autor      BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome          VARCHAR(255)     NOT NULL,
    nacionalidade VARCHAR(100)         NULL,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                            ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME             NULL,

    CONSTRAINT pk_autor PRIMARY KEY (id_autor)
);

CREATE TABLE IF NOT EXISTS livros (
    id_livro      BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    titulo        VARCHAR(255)     NOT NULL,
    isbn          CHAR(13)         NOT NULL,
    ano           INT UNSIGNED         NULL,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                            ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME             NULL,

    CONSTRAINT pk_livro  PRIMARY KEY (id_livro),
    CONSTRAINT uq_isbn   UNIQUE (isbn)
);

-- Resolve o N:M entre autores e livros
CREATE TABLE IF NOT EXISTS autorias (
    autor_id      BIGINT UNSIGNED  NOT NULL,
    livro_id      BIGINT UNSIGNED  NOT NULL,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                            ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME             NULL,

    CONSTRAINT pk_autoria        PRIMARY KEY (autor_id, livro_id),
    CONSTRAINT fk_autoria_autor  FOREIGN KEY (autor_id) REFERENCES autores (id_autor)
                                 ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_autoria_livro  FOREIGN KEY (livro_id) REFERENCES livros (id_livro)
                                 ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario    BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome          VARCHAR(255)     NOT NULL,
    email         VARCHAR(255)     NOT NULL,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                            ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME             NULL,

    CONSTRAINT pk_usuario  PRIMARY KEY (id_usuario),
    CONSTRAINT uq_email    UNIQUE (email)
);

-- Um usuário pode ter múltiplos empréstimos; cada empréstimo é de um único livro
-- (por isso EMPRESTIMOS tem PK própria — é um evento histórico, não uma associação simples)
CREATE TABLE IF NOT EXISTS emprestimos (
    id_emprestimo          BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    usuario_id             BIGINT UNSIGNED  NOT NULL,
    livro_id               BIGINT UNSIGNED  NOT NULL,
    data_retirada           DATE            NOT NULL,
    data_devolucao_prevista DATE            NOT NULL,
    data_devolucao_efetiva  DATE                NULL,
    status                  VARCHAR(20)     NOT NULL DEFAULT 'em_andamento',
    criado_em               DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em           DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                     ON UPDATE CURRENT_TIMESTAMP,
    deletado_em              DATETIME           NULL,

    CONSTRAINT pk_emprestimo          PRIMARY KEY (id_emprestimo),
    CONSTRAINT fk_emprestimo_usuario  FOREIGN KEY (usuario_id) REFERENCES usuarios (id_usuario)
                                      ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_emprestimo_livro    FOREIGN KEY (livro_id) REFERENCES livros (id_livro)
                                      ON DELETE RESTRICT ON UPDATE CASCADE
);
```

### Exercício 3 — ALTER TABLE

```sql
-- (a)
ALTER TABLE produtos
    ADD COLUMN peso DECIMAL(8, 3) NULL;

-- (b)
ALTER TABLE produtos
    CHANGE COLUMN ativo disponivel TINYINT(1) NOT NULL DEFAULT 1;

-- (c) — peso é opcional (NULL permitido), então o CHECK precisa aceitar NULL explicitamente
ALTER TABLE produtos
    ADD CONSTRAINT ck_produto_peso CHECK (peso IS NULL OR peso > 0);
```

---

⬅️ [Voltar à Aula 03 — SQL e DDL](./Aula_03_SQL_DDL.md)

---

*Fatec Jahu · IBD015 · Prof. Ronan Adriel Zenatti · 2026*
