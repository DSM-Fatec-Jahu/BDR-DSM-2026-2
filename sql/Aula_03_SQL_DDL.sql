-- =============================================================================
-- Script de apoio (NÃO faz parte do site) — Aula 03 — SQL e DDL
-- Disciplina: IBD015 — Banco de Dados Relacional — Fatec Jahu — 2º Sem/2026
-- Professor: Ronan Adriel Zenatti
--
-- Objetivo: reunir TODO o SQL "de verdade" apresentado em
-- docs/aulas/Aula_03_SQL_DDL.md em um único arquivo que executa do início ao
-- fim SEM ERROS em um MariaDB do XAMPP padrão (usuário root, senha vazia,
-- host 127.0.0.1, porta 3306).
--
-- Como executar (Windows / XAMPP):
--   "C:\xampp\mysql\bin\mysql.exe" -u root -p < sql\Aula_03_SQL_DDL.sql
--   (pressione Enter na senha — é vazia)
-- ou cole o conteúdo no phpMyAdmin > SQL.
--
-- O QUE FICOU DE FORA DESTE ARQUIVO (e por quê):
--   1) Exemplos propositalmente ERRADOS usados como enunciado de exercício
--      (Checkpoint 1 — tabela "Criador"; Exercício 1 — tabela "Produto"):
--      dariam erro de propósito (FK para tabela inexistente) — não fazem
--      sentido em um script que precisa rodar sem erro.
--   2) Trechos de sintaxe PostgreSQL (equivalentes mostrados na aula para
--      comparação) — outro SGBD, quebrariam no MariaDB.
--   3) Fragmentos de coluna isolados (ex.: "id_produto INT(11) NOT NULL"
--      fora de um CREATE TABLE) — não são comandos executáveis por si só.
--   4) Enunciados de Checkpoints/Exercícios que pedem para O ALUNO escrever
--      o SQL — a resposta mora só no arquivo de gabarito da aula, não no
--      corpo da aula, então não há código para extrair aqui.
--   5) "ALTER TABLE produtos ADD CONSTRAINT fk_produto_fornecedor ..."
--      (Seção 8): referencia a coluna produtos.fornecedor_id e a tabela
--      fornecedores — NENHUMA das duas existe em qualquer CREATE TABLE
--      desta aula. É um exemplo genérico/isolado no texto. Sinalizado aqui
--      em vez de inventar uma tabela "fornecedores" que o professor não
--      escreveu — avise se quiser que essa tabela seja criada de fato.
--   6) A sequência de DROP da Seção 9 está incluída, mas COMENTADA no final
--      deste arquivo: se executasse, apagaria o schema que este próprio
--      script acabou de montar — e a Aula 04 (SQL DML) depende dessas
--      tabelas para os exemplos de INSERT/UPDATE/DELETE.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Seção 2 — Verificando a conexão e a versão do servidor
-- -----------------------------------------------------------------------------
SELECT VERSION();


-- -----------------------------------------------------------------------------
-- Seção 4.5 / 11 — Criação do banco (forma final e idiomática)
-- Remove o banco se existir e recria do zero (útil em desenvolvimento)
-- -----------------------------------------------------------------------------
DROP DATABASE IF EXISTS loja_virtual;

CREATE DATABASE IF NOT EXISTS loja_virtual
    CHARACTER SET utf8mb4          -- UTF-8 completo: suporta todos os caracteres Unicode
    COLLATE utf8mb4_unicode_ci;    -- Comparação case-insensitive seguindo o padrão Unicode

USE loja_virtual;

-- Confirmar configurações aplicadas
SHOW CREATE DATABASE loja_virtual;


-- -----------------------------------------------------------------------------
-- Seção 11 — Tabela: pessoas
-- Cadastro base de pessoas físicas — clientes e funcionários compartilham esta tabela
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pessoas (
    id_pessoa        BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome             VARCHAR(255)     NOT NULL,
    cpf              CHAR(11)         NOT NULL COMMENT 'Apenas dígitos, sem formatação',
    email            VARCHAR(255)     NOT NULL,
    data_nascimento  DATE             NOT NULL,
    telefone         VARCHAR(20)      NULL COMMENT 'Formato livre: nem todo telefone tem 11 dígitos, e pode ser número estrangeiro',
    criado_em        DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                               ON UPDATE CURRENT_TIMESTAMP,
    deletado_em      DATETIME             NULL,

    CONSTRAINT pk_pessoa   PRIMARY KEY (id_pessoa),
    CONSTRAINT uq_cpf      UNIQUE (cpf),
    CONSTRAINT uq_email    UNIQUE (email)
)
  COMMENT='Cadastro base de pessoas físicas';


-- -----------------------------------------------------------------------------
-- Seção 1, Regra 7 — Tabela: vendas
-- Exemplo canônico de FK pelo PAPEL semântico (cliente_id / funcionario_id),
-- ambas referenciando a mesma tabela "pessoas" com papéis diferentes.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS vendas (
    id_venda        BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    cliente_id      BIGINT UNSIGNED  NOT NULL,                  -- referencia pessoas (papel: cliente)
    funcionario_id  BIGINT UNSIGNED  NOT NULL,                  -- referencia pessoas (papel: vendedor)
    data_venda      DATE             NOT NULL,
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,
    CONSTRAINT pk_venda              PRIMARY KEY (id_venda),
    CONSTRAINT fk_venda_cliente      FOREIGN KEY (cliente_id)     REFERENCES pessoas (id_pessoa),
    CONSTRAINT fk_venda_funcionario  FOREIGN KEY (funcionario_id) REFERENCES pessoas (id_pessoa)
);


-- -----------------------------------------------------------------------------
-- Seção 11 — Tabela: enderecos
-- Um relacionamento 1:N: uma pessoa pode ter múltiplos endereços
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS enderecos (
    id_endereco   BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    pessoa_id     BIGINT UNSIGNED  NOT NULL,
    logradouro    VARCHAR(255)     NOT NULL,
    numero        VARCHAR(10)      NOT NULL,
    complemento   VARCHAR(50)          NULL,
    bairro        VARCHAR(255)     NOT NULL,
    cidade        VARCHAR(255)     NOT NULL,
    estado        CHAR(2)          NOT NULL,
    cep           CHAR(8)          NOT NULL COMMENT 'Apenas dígitos',
    principal     TINYINT(1)       NOT NULL DEFAULT 0 COMMENT '1 = endereço principal',
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                            ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME             NULL,

    CONSTRAINT pk_endereco       PRIMARY KEY (id_endereco),
    CONSTRAINT fk_endereco_pessoa FOREIGN KEY (pessoa_id)
                                  REFERENCES pessoas (id_pessoa)
                                  ON DELETE CASCADE
                                  ON UPDATE CASCADE,
    CONSTRAINT ck_estado         CHECK (LENGTH(estado) = 2)
);


-- -----------------------------------------------------------------------------
-- Seção 11 — Tabela: categorias
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS categorias (
    id_categoria  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome          VARCHAR(255)     NOT NULL,
    descricao     TEXT                 NULL,
    ativa         TINYINT(1)       NOT NULL DEFAULT 1,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                            ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME             NULL,

    CONSTRAINT pk_categoria  PRIMARY KEY (id_categoria),
    CONSTRAINT uq_cat_nome   UNIQUE (nome)
);


-- -----------------------------------------------------------------------------
-- Seção 11 — Tabela: produtos
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS produtos (
    id_produto    BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    categoria_id  BIGINT UNSIGNED  NOT NULL,
    nome          VARCHAR(255)     NOT NULL,
    descricao     TEXT                 NULL,
    preco         DECIMAL(10, 2)   NOT NULL,
    estoque       INT UNSIGNED     NOT NULL DEFAULT 0,
    ativo         TINYINT(1)       NOT NULL DEFAULT 1,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                            ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME             NULL,

    CONSTRAINT pk_produto          PRIMARY KEY (id_produto),
    CONSTRAINT fk_produto_categoria FOREIGN KEY (categoria_id)
                                    REFERENCES categorias (id_categoria)
                                    ON DELETE RESTRICT
                                    ON UPDATE CASCADE,
    CONSTRAINT ck_preco            CHECK (preco >= 0),
    CONSTRAINT ck_estoque          CHECK (estoque >= 0)
);


-- -----------------------------------------------------------------------------
-- Seção 11 — Tabela: pedidos
-- Demonstra FKs semânticas duplas referenciando a mesma tabela (pessoas)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pedidos (
    id_pedido      BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    cliente_id     BIGINT UNSIGNED  NOT NULL,   -- pessoa no papel de cliente
    funcionario_id BIGINT UNSIGNED      NULL,   -- pessoa no papel de atendente
    endereco_id    BIGINT UNSIGNED      NULL,   -- endereço de entrega
    data_pedido    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status         ENUM(
                       'pendente',
                       'confirmado',
                       'em_separacao',
                       'enviado',
                       'entregue',
                       'cancelado'
                   )                NOT NULL DEFAULT 'pendente',
    valor_total    DECIMAL(12, 2)   NOT NULL DEFAULT 0.00,
    observacoes    TEXT                 NULL,
    criado_em      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                             ON UPDATE CURRENT_TIMESTAMP,
    deletado_em    DATETIME             NULL,

    CONSTRAINT pk_pedido             PRIMARY KEY (id_pedido),
    CONSTRAINT fk_pedido_cliente     FOREIGN KEY (cliente_id)
                                     REFERENCES pessoas (id_pessoa)
                                     ON DELETE RESTRICT
                                     ON UPDATE CASCADE,
    CONSTRAINT fk_pedido_funcionario FOREIGN KEY (funcionario_id)
                                     REFERENCES pessoas (id_pessoa)
                                     ON DELETE SET NULL
                                     ON UPDATE CASCADE,
    CONSTRAINT fk_pedido_endereco    FOREIGN KEY (endereco_id)
                                     REFERENCES enderecos (id_endereco)
                                     ON DELETE SET NULL
                                     ON UPDATE CASCADE,
    CONSTRAINT ck_valor_total        CHECK (valor_total >= 0)
);


-- -----------------------------------------------------------------------------
-- Seção 11 — Tabela: itens_pedidos
-- Resolve o N:M entre pedidos e produtos
-- Armazena snapshot do preço no momento da compra
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS itens_pedidos (
    pedido_id      BIGINT UNSIGNED  NOT NULL,
    produto_id     BIGINT UNSIGNED  NOT NULL,
    quantidade     INT UNSIGNED     NOT NULL,
    preco_unitario DECIMAL(10, 2)   NOT NULL COMMENT 'Preço no momento da compra',
    desconto       DECIMAL(5, 2)    NOT NULL DEFAULT 0.00 COMMENT 'Percentual de desconto',
    criado_em      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                             ON UPDATE CURRENT_TIMESTAMP,
    deletado_em    DATETIME             NULL,

    CONSTRAINT pk_item_pedido   PRIMARY KEY (pedido_id, produto_id),
    CONSTRAINT fk_item_pedido   FOREIGN KEY (pedido_id)
                                REFERENCES pedidos (id_pedido)
                                ON DELETE CASCADE
                                ON UPDATE CASCADE,
    CONSTRAINT fk_item_produto  FOREIGN KEY (produto_id)
                                REFERENCES produtos (id_produto)
                                ON DELETE RESTRICT
                                ON UPDATE CASCADE,
    CONSTRAINT ck_item_qtd      CHECK (quantidade > 0),
    CONSTRAINT ck_item_preco    CHECK (preco_unitario >= 0),
    CONSTRAINT ck_item_desconto CHECK (desconto >= 0 AND desconto <= 100)
);


-- =============================================================================
-- Seção 8 — ALTER TABLE (exemplos da aula, aplicados sobre o schema acima)
-- =============================================================================

-- Adicionar uma nova coluna ao final da tabela:
ALTER TABLE produtos
    ADD COLUMN peso DECIMAL(8, 3) NULL COMMENT 'Peso em quilogramas';

-- Adicionar coluna em posição específica (MariaDB/MySQL — não existe no PostgreSQL):
ALTER TABLE produtos
    ADD COLUMN codigo_barras VARCHAR(13) NULL AFTER nome;

-- Adicionar coluna como a primeira da tabela:
ALTER TABLE produtos
    ADD COLUMN codigo_interno VARCHAR(20) NOT NULL FIRST;

-- Modificar o tipo ou constraints de uma coluna existente:
-- MODIFY (MariaDB/MySQL) — redefine a coluna inteira
ALTER TABLE pessoas
    MODIFY COLUMN telefone VARCHAR(20) NULL;

-- CHANGE (MariaDB/MySQL) — renomeia E redefine a coluna
-- Sintaxe: CHANGE nome_antigo novo_nome tipo_novo [constraints]
ALTER TABLE pessoas
    CHANGE COLUMN telefone celular VARCHAR(20) NULL;

-- Remover uma coluna:
ALTER TABLE produtos
    DROP COLUMN codigo_interno;

-- NOTA: o exemplo da aula "ADD CONSTRAINT fk_produto_fornecedor ... REFERENCES
-- fornecedores (id_fornecedor)" foi omitido aqui de propósito — nem a coluna
-- produtos.fornecedor_id nem a tabela fornecedores existem em nenhum
-- CREATE TABLE desta aula, então executá-lo geraria erro. Avise o professor
-- se quiser essa tabela fornecedores modelada de fato.

ALTER TABLE pessoas
    DROP INDEX uq_email;  -- UNIQUE é armazenado como índice no MariaDB/MySQL

-- Renomear a tabela (sintaxe ALTER TABLE ... RENAME TO):
ALTER TABLE itens_pedidos RENAME TO itens_pedido;

-- Equivalente no MariaDB (sintaxe alternativa RENAME TABLE) — usada aqui para
-- desfazer a renomeação acima e manter o nome no plural (Regra 4):
RENAME TABLE itens_pedido TO itens_pedidos;


-- =============================================================================
-- Seções 7 e 8 — ALTER TABLE: adicionando e excluindo CONSTRAINTS
--
-- A CREATE TABLE já demonstra PK/FK/UNIQUE/CHECK definidos na criação; este
-- bloco demonstra o outro cenário comum na Seção 8: uma tabela que já existe
-- (com dados) e precisa RECEBER ou PERDER uma constraint depois, via
-- ALTER TABLE — sem precisar recriar a tabela do zero.
--
-- Para não arriscar as tabelas reais do schema (que a Aula 04 usa), a
-- demonstração roda em uma tabela isolada, criada e destruída só para este
-- bloco: demo_constraints. Ela nasce sem PK e sem as demais constraints —
-- fugindo de propósito da Regra 5 nesta única tabela de exemplo — só para
-- que dê para demonstrar o ADD de cada constraint em seguida.
-- =============================================================================

CREATE TABLE IF NOT EXISTS demo_constraints (
    id_demo       BIGINT UNSIGNED  NOT NULL,           -- vai virar PK via ALTER, não inline
    categoria_id  BIGINT UNSIGNED      NULL,           -- vai virar FK via ALTER
    codigo        VARCHAR(20)      NOT NULL,           -- vai virar UNIQUE via ALTER
    quantidade    INT              NOT NULL DEFAULT 0, -- vai virar CHECK via ALTER
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                             ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME             NULL
);

-- --- PRIMARY KEY -------------------------------------------------------------
-- Adicionar:
ALTER TABLE demo_constraints
    ADD CONSTRAINT pk_demo PRIMARY KEY (id_demo);
-- Excluir (MariaDB/MySQL: não se nomeia a PK no DROP — só existe uma por tabela):
ALTER TABLE demo_constraints
    DROP PRIMARY KEY;

-- --- FOREIGN KEY -------------------------------------------------------------
-- Adicionar (referenciando categorias, que já existe neste schema):
ALTER TABLE demo_constraints
    ADD CONSTRAINT fk_demo_categoria FOREIGN KEY (categoria_id)
        REFERENCES categorias (id_categoria)
        ON DELETE SET NULL
        ON UPDATE CASCADE;
-- Excluir (pelo nome da constraint):
ALTER TABLE demo_constraints
    DROP FOREIGN KEY fk_demo_categoria;

-- --- UNIQUE --------------------------------------------------------------
-- Adicionar:
ALTER TABLE demo_constraints
    ADD CONSTRAINT uq_demo_codigo UNIQUE (codigo);
-- Excluir (UNIQUE é armazenado como índice — mesma sintaxe do DROP INDEX visto acima):
ALTER TABLE demo_constraints
    DROP INDEX uq_demo_codigo;

-- --- CHECK ---------------------------------------------------------------
-- Adicionar:
ALTER TABLE demo_constraints
    ADD CONSTRAINT ck_demo_quantidade CHECK (quantidade >= 0);
-- Excluir (MariaDB aceita DROP CONSTRAINT para CHECK; MySQL 8+ usa DROP CHECK):
ALTER TABLE demo_constraints
    DROP CONSTRAINT ck_demo_quantidade;

-- Encerrada a demonstração, remove a tabela de exemplo — ela não faz parte
-- do schema de e-commerce ensinado na aula, só existiu para este bloco.
DROP TABLE IF EXISTS demo_constraints;


-- =============================================================================
-- Seção 10 — Comandos utilitários essenciais
-- =============================================================================

-- Listar todos os databases disponíveis:
SHOW DATABASES;

-- Selecionar o banco para uso:
USE loja_virtual;

-- Verificar qual banco está selecionado:
SELECT DATABASE();

-- Listar tabelas do banco atual:
SHOW TABLES;

-- Ver a estrutura de uma tabela:
DESCRIBE produtos;
-- ou:
DESC produtos;

-- Ver o CREATE TABLE completo (com todas as constraints como foram definidas):
SHOW CREATE TABLE produtos;

-- Ver todos os índices de uma tabela (PKs, UNIQUEs, FKs geram índices):
SHOW INDEX FROM produtos;

-- Ver as constraints de FK de uma tabela específica (usando information_schema):
SELECT
    constraint_name,
    column_name,
    referenced_table_name,
    referenced_column_name
FROM
    information_schema.key_column_usage
WHERE
    table_schema    = 'loja_virtual'
    AND table_name  = 'produtos'
    AND referenced_table_name IS NOT NULL;


-- =============================================================================
-- Seção 9 — DROP (mantido como REFERÊNCIA, mas COMENTADO)
--
-- Executar isto apagaria o schema inteiro montado acima — e a Aula 04 (SQL
-- DML) usa estas mesmas tabelas para os exemplos de INSERT/UPDATE/DELETE.
-- Remova os "--" de cada linha abaixo apenas se quiser mesmo destruir e
-- recomeçar o banco loja_virtual.
-- =============================================================================

-- SET FOREIGN_KEY_CHECKS = 0;  -- desabilita verificação temporariamente
--
-- DROP TABLE IF EXISTS itens_pedidos;  -- filhos primeiro
-- DROP TABLE IF EXISTS vendas;
-- DROP TABLE IF EXISTS pedidos;
-- DROP TABLE IF EXISTS produtos;
-- DROP TABLE IF EXISTS categorias;
-- DROP TABLE IF EXISTS enderecos;
-- DROP TABLE IF EXISTS pessoas;
--
-- SET FOREIGN_KEY_CHECKS = 1;  -- sempre reabilite
--
-- DROP DATABASE IF EXISTS loja_virtual;
