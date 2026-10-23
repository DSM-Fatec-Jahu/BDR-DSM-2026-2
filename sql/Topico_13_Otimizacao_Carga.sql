-- =============================================================================
-- Script de apoio (NÃO faz parte do site) — Tópico 13 — Tabela de 200 mil linhas
-- Disciplina: IBD015 — Banco de Dados Relacional — Fatec Jahu — 2º Sem/2026
-- Professor: Ronan Adriel Zenatti
--
-- Objetivo: criar, no schema loja_virtual, a tabela acessos_site (registro de
-- navegação de um site, com 200.000 linhas) usada nos experimentos de
-- EXPLAIN e de índices do Tópico 13.
--
-- Como a carga funciona: o MariaDB tem um "motor de sequências" que cria, sem
-- precisar de tabela alguma, a tabela virtual seq_1_to_200000 (números de 1 a
-- 200.000). O INSERT ... SELECT usa esses números para gerar valores variados.
-- ATENÇÃO: o motor SEQUENCE é do MariaDB — não existe no MySQL.
--
-- A tabela nasce SEM índice algum além da chave primária, de propósito: o
-- tópico ensina a criar cada índice na hora certa. Não é uma FK para pessoas
-- porque tabelas de log de eventos de alto volume costumam registrar o
-- visitante (inclusive anônimo) sem validar contra outra tabela.
--
-- PRÉ-REQUISITO: schema loja_virtual criado (Tópico 03). Pode ser executado
-- várias vezes (ele recria a tabela).
--
-- Como executar (Windows / XAMPP):
--   "C:\xampp\mysql\bin\mysql.exe" -u root -p --default-character-set=utf8mb4 < sql\Topico_13_Otimizacao_Carga.sql
-- =============================================================================

USE loja_virtual;

DROP TABLE IF EXISTS acessos_site;

CREATE TABLE acessos_site (
    id_acesso     BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    visitante_id  BIGINT UNSIGNED  NOT NULL,
    pagina        VARCHAR(100)     NOT NULL,
    tipo_evento   ENUM('visualizacao', 'clique', 'busca', 'compra') NOT NULL,
    duracao_ms    INT UNSIGNED     NOT NULL,
    dispositivo   VARCHAR(20)      NOT NULL,
    ocorrido_em   DATETIME         NOT NULL,
    criado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                                            ON UPDATE CURRENT_TIMESTAMP,
    deletado_em   DATETIME             NULL,

    CONSTRAINT pk_acesso PRIMARY KEY (id_acesso)
);

INSERT INTO acessos_site (visitante_id, pagina, tipo_evento, duracao_ms, dispositivo, ocorrido_em)
SELECT 1 + (seq * 7919) % 5000,                                    -- 5.000 visitantes distintos
       CONCAT('/produto/', 1 + (seq * 31) % 40),                   -- 40 páginas
       ELT(1 + seq % 4, 'visualizacao', 'clique', 'busca', 'compra'),
       100 + (seq * 13) % 9000,                                    -- 100 a 9.099 ms
       ELT(1 + seq % 3, 'desktop', 'celular', 'tablet'),
       '2026-07-25 00:00:00' + INTERVAL (seq * 37) % 7776000 SECOND  -- ~90 dias a partir de 25/07/2026
FROM seq_1_to_200000;

-- Atualiza as estatísticas que o otimizador usa para escolher o plano
ANALYZE TABLE acessos_site;

-- Conferência
SELECT COUNT(*)                    AS linhas,
       COUNT(DISTINCT visitante_id) AS visitantes,
       MIN(ocorrido_em)             AS primeiro_acesso,
       MAX(ocorrido_em)             AS ultimo_acesso
FROM   acessos_site;
