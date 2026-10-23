-- =============================================================================
-- Script de apoio (NÃO faz parte do site) — Tópico 14 — Revisão Geral
-- GABARITO DO DESAFIO INTEGRADOR: rede de eletropostos (carregadores de veículos elétricos)
-- Disciplina: IBD015 — Banco de Dados Relacional — Fatec Jahu — 2º Sem/2026
-- Professor: Ronan Adriel Zenatti
--
-- Este arquivo reúne, em ordem, a solução completa dos 9 passos do Desafio
-- Integrador do Tópico 14 (docs/topicos/Topico_14_Revisao_Geral.md e seu gabarito).
-- Executa do início ao fim SEM ERROS em um MariaDB 10.4 do XAMPP padrão.
--
-- Como executar (Windows / XAMPP):
--   "C:\xampp\mysql\bin\mysql.exe" -u root -p --default-character-set=utf8mb4 < sql\Topico_14_Desafio_Integrador.sql
--
-- ATENÇÃO: o script apaga e recria o banco "eletropostos" (um banco só deste
-- desafio — não toca no loja_virtual). Os comandos de segurança do Passo 8
-- criam usuários e roles no servidor; no final do arquivo há os comandos
-- (comentados) para removê-los.
-- =============================================================================

DROP DATABASE IF EXISTS eletropostos;
CREATE DATABASE eletropostos CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE eletropostos;


-- =============================================================================
-- PASSO 3 — DDL: modelo lógico em 3FN, seguindo as 9 regras de nomenclatura
-- (Passo 1 = MER conceitual e Passo 2 = normalização estão no texto do gabarito)
-- =============================================================================

CREATE TABLE clientes (
    id_cliente   BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome         VARCHAR(255)     NOT NULL,
    cpf          CHAR(11)         NOT NULL COMMENT 'Apenas dígitos',
    email        VARCHAR(255)     NOT NULL,
    criado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deletado_em  DATETIME             NULL,

    CONSTRAINT pk_cliente  PRIMARY KEY (id_cliente),
    CONSTRAINT uq_cliente_cpf   UNIQUE (cpf),
    CONSTRAINT uq_cliente_email UNIQUE (email)
);

CREATE TABLE veiculos (
    id_veiculo      BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    cliente_id      BIGINT UNSIGNED  NOT NULL,
    placa           CHAR(7)          NOT NULL COMMENT 'Padrão Mercosul, sem hífen',
    modelo          VARCHAR(100)     NOT NULL,
    capacidade_kwh  DECIMAL(5, 1)    NOT NULL COMMENT 'Capacidade da bateria',
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_veiculo          PRIMARY KEY (id_veiculo),
    CONSTRAINT uq_veiculo_placa    UNIQUE (placa),
    CONSTRAINT fk_veiculo_cliente  FOREIGN KEY (cliente_id)
                                   REFERENCES clientes (id_cliente)
                                   ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_veiculo_capacidade CHECK (capacidade_kwh > 0)
);

CREATE TABLE eletropostos (
    id_eletroposto  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(255)     NOT NULL,
    cidade          VARCHAR(255)     NOT NULL,
    estado          CHAR(2)          NOT NULL,
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_eletroposto     PRIMARY KEY (id_eletroposto),
    CONSTRAINT uq_eletroposto_nome UNIQUE (nome),
    CONSTRAINT ck_eletroposto_uf  CHECK (LENGTH(estado) = 2)
);

CREATE TABLE carregadores (
    id_carregador   BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    eletroposto_id  BIGINT UNSIGNED  NOT NULL,
    codigo          VARCHAR(10)      NOT NULL COMMENT 'Identificação dentro do eletroposto (ex.: A1)',
    potencia_kw     DECIMAL(5, 1)    NOT NULL,
    status          ENUM('livre', 'ocupado', 'manutencao') NOT NULL DEFAULT 'livre',
    criado_em       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deletado_em     DATETIME             NULL,

    CONSTRAINT pk_carregador              PRIMARY KEY (id_carregador),
    CONSTRAINT uq_carregador_eletroposto_codigo UNIQUE (eletroposto_id, codigo),
    CONSTRAINT fk_carregador_eletroposto  FOREIGN KEY (eletroposto_id)
                                          REFERENCES eletropostos (id_eletroposto)
                                          ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_carregador_potencia     CHECK (potencia_kw > 0)
);

CREATE TABLE recargas (
    id_recarga       BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    veiculo_id       BIGINT UNSIGNED  NOT NULL,
    carregador_id    BIGINT UNSIGNED  NOT NULL,
    iniciada_em      DATETIME         NOT NULL,
    finalizada_em    DATETIME             NULL,
    kwh_consumidos   DECIMAL(7, 2)        NULL,
    valor_total      DECIMAL(10, 2)       NULL,
    status           ENUM('em_andamento', 'concluida', 'cancelada') NOT NULL DEFAULT 'em_andamento',
    criado_em        DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deletado_em      DATETIME             NULL,

    CONSTRAINT pk_recarga             PRIMARY KEY (id_recarga),
    CONSTRAINT fk_recarga_veiculo     FOREIGN KEY (veiculo_id)
                                      REFERENCES veiculos (id_veiculo)
                                      ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_recarga_carregador  FOREIGN KEY (carregador_id)
                                      REFERENCES carregadores (id_carregador)
                                      ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_recarga_kwh         CHECK (kwh_consumidos IS NULL OR kwh_consumidos >= 0),
    CONSTRAINT ck_recarga_valor       CHECK (valor_total IS NULL OR valor_total >= 0),
    CONSTRAINT ck_recarga_periodo     CHECK (finalizada_em IS NULL OR finalizada_em >= iniciada_em)
);


-- =============================================================================
-- PASSO 4 — DML: carga inicial (em transação)
-- =============================================================================

START TRANSACTION;

INSERT INTO clientes (nome, cpf, email) VALUES
    ('Ana Lima',      '11122233344', 'ana@email.com'),
    ('Carlos Melo',   '22233344455', 'carlos@email.com'),
    ('Beatriz Costa', '33344455566', 'bi@email.com'),
    ('Diego Rocha',   '44455566677', 'diego@email.com'),
    ('Fernanda Alves','66677788899', 'fernanda@email.com'),
    ('Gustavo Lima',  '77788899900', 'gustavo@email.com');   -- Gustavo nunca recarregou

INSERT INTO veiculos (cliente_id, placa, modelo, capacidade_kwh) VALUES
    (1, 'ABC1D23', 'BYD Dolphin',      44.9),
    (1, 'ABC1D24', 'Renault Kwid E-Tech', 26.8),
    (2, 'DEF2E34', 'Volvo EX30',       69.0),
    (3, 'GHI3F45', 'GWM Ora 03',       48.0),
    (4, 'JKL4G56', 'BYD Seal',         82.5),
    (5, 'MNO5H67', 'Chevrolet Bolt',   66.0),
    (2, 'PQR6I78', 'Caoa Chery iCar',  55.0);

INSERT INTO eletropostos (nome, cidade, estado) VALUES
    ('Voltaja Centro',  'Jahu',     'SP'),
    ('Voltaja Rodovia', 'Bauru',    'SP'),
    ('Voltaja Shopping','Campinas', 'SP');

INSERT INTO carregadores (eletroposto_id, codigo, potencia_kw, status) VALUES
    (1, 'A1',  7.4, 'livre'),
    (1, 'A2', 22.0, 'livre'),
    (2, 'B1', 50.0, 'livre'),
    (2, 'B2', 120.0,'manutencao'),
    (3, 'C1', 22.0, 'livre'),
    (3, 'C2', 60.0, 'livre');

INSERT INTO recargas (veiculo_id, carregador_id, iniciada_em, finalizada_em, kwh_consumidos, valor_total, status) VALUES
    (1, 1, '2026-09-02 08:10:00', '2026-09-02 12:40:00', 30.50,  36.60, 'concluida'),
    (2, 2, '2026-09-04 18:00:00', '2026-09-04 19:30:00', 15.00,  18.00, 'concluida'),
    (3, 3, '2026-09-05 10:00:00', '2026-09-05 10:50:00', 40.00,  72.00, 'concluida'),
    (3, 3, '2026-09-12 09:00:00', '2026-09-12 09:45:00', 35.00,  63.00, 'concluida'),
    (4, 5, '2026-09-15 20:00:00', '2026-09-15 23:30:00', 28.00,  33.60, 'concluida'),
    (5, 6, '2026-09-18 14:00:00', '2026-09-18 14:40:00', 52.00,  93.60, 'concluida'),
    (6, 2, '2026-09-20 07:30:00', '2026-09-20 10:00:00', 20.00,  24.00, 'concluida'),
    (1, 1, '2026-10-01 08:00:00', '2026-10-01 11:00:00', 22.00,  26.40, 'concluida'),
    (7, 3, '2026-10-03 16:00:00', '2026-10-03 16:55:00', 45.00,  81.00, 'concluida'),
    (3, 6, '2026-10-07 12:00:00', '2026-10-07 12:40:00', 38.00,  68.40, 'concluida'),
    (5, 6, '2026-10-10 19:00:00', '2026-10-10 19:50:00', 60.00, 108.00, 'concluida'),
    (4, 5, '2026-10-12 21:00:00', NULL,                  NULL,   NULL,  'cancelada'),
    (6, 2, '2026-10-15 07:45:00', '2026-10-15 09:30:00', 18.00,  21.60, 'concluida');

COMMIT;


-- =============================================================================
-- PASSO 5 — Consultas (JOIN, agregação, anti-join, subconsulta, visão)
-- =============================================================================

-- 5a) kWh e receita por eletroposto em setembro/2026 (INNER JOIN + GROUP BY)
SELECT e.nome AS eletroposto,
       COUNT(*)                   AS recargas,
       SUM(r.kwh_consumidos)      AS total_kwh,
       SUM(r.valor_total)         AS receita
FROM   recargas r
INNER JOIN carregadores c ON c.id_carregador = r.carregador_id
INNER JOIN eletropostos e ON e.id_eletroposto = c.eletroposto_id
WHERE  r.status = 'concluida'
  AND  r.iniciada_em >= '2026-09-01' AND r.iniciada_em < '2026-10-01'
GROUP BY e.id_eletroposto, e.nome
ORDER BY receita DESC;

-- 5b) Clientes que nunca recarregaram (anti-join)
SELECT cli.nome
FROM   clientes cli
LEFT JOIN veiculos v  ON v.cliente_id = cli.id_cliente
LEFT JOIN recargas r  ON r.veiculo_id = v.id_veiculo
WHERE  r.id_recarga IS NULL;

-- 5c) Os 3 veículos que mais consumiram (com o nome do cliente)
SELECT v.placa, v.modelo, cli.nome AS cliente, SUM(r.kwh_consumidos) AS total_kwh
FROM   recargas r
INNER JOIN veiculos v   ON v.id_veiculo = r.veiculo_id
INNER JOIN clientes cli ON cli.id_cliente = v.cliente_id
WHERE  r.status = 'concluida'
GROUP BY v.id_veiculo, v.placa, v.modelo, cli.nome
ORDER BY total_kwh DESC
LIMIT 3;

-- 5d) Recargas acima da média de kWh (subconsulta escalar)
SELECT r.id_recarga, r.kwh_consumidos
FROM   recargas r
WHERE  r.status = 'concluida'
  AND  r.kwh_consumidos > (SELECT AVG(kwh_consumidos) FROM recargas WHERE status = 'concluida')
ORDER BY r.kwh_consumidos DESC;

-- 5e) Visão que esconde o CPF e junta tudo
CREATE VIEW vw_recargas_detalhadas AS
SELECT r.id_recarga,
       cli.nome       AS cliente,
       v.placa,
       e.nome         AS eletroposto,
       c.codigo       AS carregador,
       c.potencia_kw,
       r.iniciada_em,
       r.finalizada_em,
       r.kwh_consumidos,
       r.valor_total,
       r.status
FROM   recargas r
INNER JOIN veiculos v     ON v.id_veiculo = r.veiculo_id
INNER JOIN clientes cli   ON cli.id_cliente = v.cliente_id
INNER JOIN carregadores c ON c.id_carregador = r.carregador_id
INNER JOIN eletropostos e ON e.id_eletroposto = c.eletroposto_id;

SELECT * FROM vw_recargas_detalhadas WHERE cliente = 'Ana Lima' ORDER BY iniciada_em;


-- =============================================================================
-- PASSO 6 — Programação: função, gatilhos e procedures
-- =============================================================================

DELIMITER $$

-- Tarifa: R$ 1,20/kWh em carregadores até 22 kW (corrente alternada) e R$ 1,80/kWh
-- acima disso (corrente contínua, recarga rápida); cobrança mínima de R$ 5,00.
CREATE FUNCTION fn_valor_recarga(p_kwh DECIMAL(7, 2), p_potencia_kw DECIMAL(5, 1))
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE v_tarifa DECIMAL(4, 2);

    IF p_kwh < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Consumo (kWh) não pode ser negativo';
    END IF;

    SET v_tarifa = IF(p_potencia_kw <= 22, 1.20, 1.80);

    RETURN GREATEST(5.00, ROUND(p_kwh * v_tarifa, 2));
END$$

-- Auditoria das mudanças de status dos carregadores
CREATE TABLE log_status_carregadores (
    id_log           BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    carregador_id    BIGINT UNSIGNED  NOT NULL,
    status_anterior  VARCHAR(20)      NOT NULL,
    status_novo      VARCHAR(20)      NOT NULL,
    criado_em        DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deletado_em      DATETIME             NULL,
    CONSTRAINT pk_log_status_carregador PRIMARY KEY (id_log),
    CONSTRAINT fk_log_status_carregador FOREIGN KEY (carregador_id)
                                        REFERENCES carregadores (id_carregador)
                                        ON DELETE CASCADE ON UPDATE CASCADE
)$$

CREATE TRIGGER trg_carregadores_logar_status
AFTER UPDATE ON carregadores
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO log_status_carregadores (carregador_id, status_anterior, status_novo)
        VALUES (OLD.id_carregador, OLD.status, NEW.status);
    END IF;
END$$

-- Uma recarga concluída ou cancelada é um registro financeiro: não pode ser alterada
CREATE TRIGGER trg_recargas_proteger_finalizadas
BEFORE UPDATE ON recargas
FOR EACH ROW
BEGIN
    IF OLD.status IN ('concluida', 'cancelada') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Recarga concluída ou cancelada não pode ser alterada';
    END IF;
END$$

CREATE PROCEDURE sp_iniciar_recarga(
    IN  p_veiculo_id    BIGINT UNSIGNED,
    IN  p_carregador_id BIGINT UNSIGNED,
    OUT p_recarga_id    BIGINT UNSIGNED
)
BEGIN
    DECLARE v_status_carregador  VARCHAR(20);
    DECLARE v_recargas_ativas    INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Trava a linha do carregador: duas pessoas não passam ao mesmo tempo pela verificação
    SELECT status INTO v_status_carregador
    FROM   carregadores
    WHERE  id_carregador = p_carregador_id
    FOR UPDATE;

    IF v_status_carregador IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Carregador inexistente';
    ELSEIF v_status_carregador <> 'livre' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Carregador indisponível';
    END IF;

    SELECT COUNT(*) INTO v_recargas_ativas
    FROM   recargas
    WHERE  veiculo_id = p_veiculo_id AND status = 'em_andamento';

    IF v_recargas_ativas > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O veículo já tem uma recarga em andamento';
    END IF;

    INSERT INTO recargas (veiculo_id, carregador_id, iniciada_em)
    VALUES (p_veiculo_id, p_carregador_id, NOW());

    SET p_recarga_id = LAST_INSERT_ID();

    UPDATE carregadores SET status = 'ocupado' WHERE id_carregador = p_carregador_id;

    COMMIT;
END$$

CREATE PROCEDURE sp_finalizar_recarga(
    IN p_recarga_id  BIGINT UNSIGNED,
    IN p_kwh         DECIMAL(7, 2)
)
BEGIN
    DECLARE v_status      VARCHAR(20);
    DECLARE v_carregador  BIGINT UNSIGNED;
    DECLARE v_potencia    DECIMAL(5, 1);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT status, carregador_id INTO v_status, v_carregador
    FROM   recargas
    WHERE  id_recarga = p_recarga_id
    FOR UPDATE;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Recarga inexistente';
    ELSEIF v_status <> 'em_andamento' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A recarga não está em andamento';
    END IF;

    SELECT potencia_kw INTO v_potencia FROM carregadores WHERE id_carregador = v_carregador;

    UPDATE recargas
    SET    finalizada_em  = NOW(),
           kwh_consumidos = p_kwh,
           valor_total    = fn_valor_recarga(p_kwh, v_potencia),
           status         = 'concluida'
    WHERE  id_recarga = p_recarga_id;

    UPDATE carregadores SET status = 'livre' WHERE id_carregador = v_carregador;

    COMMIT;
END$$

DELIMITER ;

-- Teste do fluxo completo
SELECT fn_valor_recarga(30.5, 7.4)  AS valor_ac,       -- 36.60
       fn_valor_recarga(40,  50.0)  AS valor_dc,       -- 72.00
       fn_valor_recarga(1,   7.4)   AS valor_minimo;   -- 5.00

CALL sp_iniciar_recarga(1, 1, @nova);
SELECT @nova AS recarga_iniciada;
SELECT id_carregador, status FROM carregadores WHERE id_carregador = 1;      -- ocupado

-- Estes dois devem falhar (descomente para ver):
-- CALL sp_iniciar_recarga(2, 1, @x);   -- Carregador indisponível
-- CALL sp_iniciar_recarga(1, 3, @x);   -- O veículo já tem uma recarga em andamento
-- CALL sp_iniciar_recarga(2, 4, @x);   -- Carregador indisponível (em manutenção)

CALL sp_finalizar_recarga(@nova, 25.00);
SELECT id_recarga, status, kwh_consumidos, valor_total FROM recargas WHERE id_recarga = @nova;   -- 30.00
SELECT * FROM log_status_carregadores;                                       -- livre → ocupado → livre


-- =============================================================================
-- PASSO 8 — Segurança: usuários, privilégios e roles
-- =============================================================================

DROP USER IF EXISTS 'app_eletropostos'@'localhost';
DROP USER IF EXISTS 'analista_eletropostos'@'localhost';
DROP USER IF EXISTS 'backup_eletropostos'@'localhost';
DROP ROLE IF EXISTS role_analista_eletropostos;

CREATE USER 'app_eletropostos'@'localhost' IDENTIFIED BY 'Troque#App2026';
GRANT SELECT, INSERT, UPDATE, DELETE ON eletropostos.* TO 'app_eletropostos'@'localhost';
GRANT EXECUTE ON eletropostos.* TO 'app_eletropostos'@'localhost';

CREATE ROLE role_analista_eletropostos;
GRANT SELECT ON eletropostos.vw_recargas_detalhadas TO role_analista_eletropostos;
GRANT SELECT ON eletropostos.eletropostos TO role_analista_eletropostos;
GRANT SELECT ON eletropostos.carregadores TO role_analista_eletropostos;
GRANT SELECT (id_cliente, nome) ON eletropostos.clientes TO role_analista_eletropostos;
CREATE USER 'analista_eletropostos'@'localhost' IDENTIFIED BY 'Troque#Analista2026';
GRANT role_analista_eletropostos TO 'analista_eletropostos'@'localhost';
SET DEFAULT ROLE role_analista_eletropostos FOR 'analista_eletropostos'@'localhost';

CREATE USER 'backup_eletropostos'@'localhost' IDENTIFIED BY 'Troque#Backup2026';
GRANT SELECT, SHOW VIEW, TRIGGER, EVENT, LOCK TABLES ON eletropostos.* TO 'backup_eletropostos'@'localhost';
GRANT SELECT ON mysql.proc TO 'backup_eletropostos'@'localhost';

SHOW GRANTS FOR 'app_eletropostos'@'localhost';
SHOW GRANTS FOR 'analista_eletropostos'@'localhost';
SHOW GRANTS FOR role_analista_eletropostos;


-- =============================================================================
-- PASSO 9 — Desempenho: volume + EXPLAIN + índices
-- Gera 100.000 recargas concluídas (usando o motor SEQUENCE do MariaDB) em uma
-- tabela de apoio, para ver os planos de execução com volume realista.
-- =============================================================================

CREATE TABLE recargas_volume (
    id_recarga      BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    veiculo_id      BIGINT UNSIGNED  NOT NULL,
    carregador_id   BIGINT UNSIGNED  NOT NULL,
    iniciada_em     DATETIME         NOT NULL,
    kwh_consumidos  DECIMAL(7, 2)    NOT NULL,
    valor_total     DECIMAL(10, 2)   NOT NULL,
    status          ENUM('em_andamento', 'concluida', 'cancelada') NOT NULL,
    CONSTRAINT pk_recarga_volume PRIMARY KEY (id_recarga)
);

INSERT INTO recargas_volume (veiculo_id, carregador_id, iniciada_em, kwh_consumidos, valor_total, status)
SELECT 1 + (seq * 7919) % 20000,
       1 + seq % 6,
       '2026-01-01 00:00:00' + INTERVAL (seq * 311) % 25000000 SECOND,
       5 + (seq * 13) % 70,
       10 + (seq * 17) % 120,
       CASE WHEN seq % 25 = 0 THEN 'em_andamento'
            WHEN seq % 40 = 0 THEN 'cancelada'
            ELSE                   'concluida'
       END
FROM seq_1_to_100000;

ANALYZE TABLE recargas_volume;

-- Consulta frequente: histórico recente de um veículo (sem índice → varredura completa)
EXPLAIN SELECT id_recarga, iniciada_em, kwh_consumidos, valor_total
FROM   recargas_volume
WHERE  veiculo_id = 777 AND status = 'concluida'
ORDER BY iniciada_em DESC
LIMIT  10;

CREATE INDEX idx_recargas_volume_veiculo_status_iniciada
    ON recargas_volume (veiculo_id, status, iniciada_em);

EXPLAIN SELECT id_recarga, iniciada_em, kwh_consumidos, valor_total
FROM   recargas_volume
WHERE  veiculo_id = 777 AND status = 'concluida'
ORDER BY iniciada_em DESC
LIMIT  10;

-- Não sargável: função na coluna
EXPLAIN SELECT COUNT(*) FROM recargas_volume WHERE DATE(iniciada_em) = '2026-03-15';
-- Sargável
CREATE INDEX idx_recargas_volume_iniciada ON recargas_volume (iniciada_em);
EXPLAIN SELECT COUNT(*) FROM recargas_volume WHERE iniciada_em >= '2026-03-15' AND iniciada_em < '2026-03-16';


-- =============================================================================
-- LIMPEZA (opcional) — remove usuários, role e banco criados por este script
-- =============================================================================
-- DROP USER IF EXISTS 'app_eletropostos'@'localhost';
-- DROP USER IF EXISTS 'analista_eletropostos'@'localhost';
-- DROP USER IF EXISTS 'backup_eletropostos'@'localhost';
-- DROP ROLE IF EXISTS role_analista_eletropostos;
-- DROP DATABASE IF EXISTS eletropostos;
