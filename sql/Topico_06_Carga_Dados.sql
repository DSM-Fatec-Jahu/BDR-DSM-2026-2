-- =============================================================================
-- Script de apoio (NÃO faz parte do site) — Tópico 06 — Carga de dados de exemplo
-- Disciplina: IBD015 — Banco de Dados Relacional — Fatec Jahu — 2º Sem/2026
-- Professor: Ronan Adriel Zenatti
--
-- Objetivo: popular o schema loja_virtual (Tópico 03) com um volume de dados
-- suficiente para praticar agregação, JOINs, subconsultas, views, procedures,
-- triggers, transações e otimização (Tópicos 06 a 13). Esta mesma carga é o
-- ponto de partida dos scripts dos tópicos seguintes.
--
-- PRÉ-REQUISITO: o schema loja_virtual criado pelos CREATE TABLE do Tópico 03
-- (sql/Topico_03_SQL_DDL.sql, Seção 11). Rode só os CREATE TABLE — NÃO os ALTER
-- TABLE demonstrativos do final daquele script (eles renomeiam pessoas.telefone
-- para celular, removem o UNIQUE de e-mail etc., e este script usa os nomes
-- originais das colunas).
--
-- ATENÇÃO: este script ESVAZIA as tabelas do loja_virtual antes de carregar
-- (a estrutura é mantida, só os registros são apagados). É seguro rodar de novo
-- para "voltar ao estado inicial" quando um exercício bagunçar os dados.
--
-- Como executar (Windows / XAMPP):
--   "C:\xampp\mysql\bin\mysql.exe" -u root -p --default-character-set=utf8mb4 < sql\Topico_06_Carga_Dados.sql
-- ou cole o conteúdo no phpMyAdmin > SQL.
--
-- Esta carga reaproveita os registros do Tópico 04 (as 5 pessoas, 3 categorias,
-- 5 produtos e o pedido #1 da Ana Lima) e acrescenta mais dados por cima.
-- =============================================================================

USE loja_virtual;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE itens_pedidos;
TRUNCATE TABLE vendas;
TRUNCATE TABLE pedidos;
TRUNCATE TABLE produtos;
TRUNCATE TABLE categorias;
TRUNCATE TABLE enderecos;
TRUNCATE TABLE pessoas;
SET FOREIGN_KEY_CHECKS = 1;


-- -----------------------------------------------------------------------------
-- Pessoas — clientes e funcionários compartilham a tabela
--   Funcionários (atendentes): 4 Diego, 5 Ronan, 12 Marina
--   Cliente sem nenhum pedido (útil para LEFT JOIN): 11 Lucas
-- -----------------------------------------------------------------------------
INSERT INTO pessoas (nome, cpf, email, data_nascimento, telefone) VALUES
    ('Ana Lima',        '11122233344', 'ana@email.com',        '1990-05-10', '14999990001'),
    ('Carlos Melo',     '22233344455', 'carlos@email.com',     '1985-11-22', '19988880002'),
    ('Beatriz Costa',   '33344455566', 'bi@email.com',         '1998-07-03', NULL),
    ('Diego Rocha',     '44455566677', 'diego@email.com',      '1992-02-28', '11977770003'),
    ('Prof. Ronan',     '55566677788', 'ronan@fatec.edu.br',   '1988-09-15', '14966660004'),
    ('Fernanda Alves',  '66677788899', 'fernanda@email.com',   '1996-01-20', '14955550005'),
    ('Gustavo Lima',    '77788899900', 'gustavo@email.com',    '1983-12-05', NULL),
    ('Helena Souza',    '88899900011', 'helena@email.com',     '2001-03-30', '11944440006'),
    ('Igor Martins',    '99900011122', 'igor@email.com',       '1994-08-18', '19933330007'),
    ('Juliana Pires',   '10011122233', 'juliana@email.com',    '1989-06-12', '14922220008'),
    ('Lucas Ferreira',  '12300045678', 'lucas@email.com',      '2003-10-01', '14911110009'),
    ('Marina Duarte',   '23411156789', 'marina@email.com',     '1991-04-25', '11900000010');


-- -----------------------------------------------------------------------------
-- Endereços — a Ana (pessoa 1) tem dois; Lucas (11) e Diego/Marina não têm
-- -----------------------------------------------------------------------------
INSERT INTO enderecos (pessoa_id, logradouro, numero, complemento, bairro, cidade, estado, cep, principal) VALUES
    (1,  'Rua das Flores',        '120',  NULL,       'Centro',        'Jahu',      'SP', '17201000', 1),
    (1,  'Avenida Paulista',      '1000', 'Apto 52',  'Bela Vista',    'São Paulo', 'SP', '01310100', 0),
    (2,  'Rua Barão de Jaguara',  '455',  NULL,       'Centro',        'Campinas',  'SP', '13015001', 1),
    (3,  'Rua Quinze de Agosto',  '78',   NULL,       'Jardim Paulista','Jahu',     'SP', '17201010', 1),
    (6,  'Avenida Nações Unidas', '2310', 'Bloco B',  'Vila Nova Cidade Universitária', 'Bauru', 'SP', '17012100', 1),
    (7,  'Rua Augusta',           '900',  NULL,       'Consolação',    'São Paulo', 'SP', '01304001', 1),
    (8,  'Rua Oscar Freire',      '350',  'Apto 11',  'Jardins',       'São Paulo', 'SP', '01426001', 1),
    (9,  'Avenida Norte-Sul',     '640',  NULL,       'Centro',        'Campinas',  'SP', '13010020', 1),
    (10, 'Rua Edgard Ferraz',     '215',  NULL,       'Centro',        'Jahu',      'SP', '17201030', 1),
    (5,  'Rua Dom Pedro II',      '60',   NULL,       'Centro',        'Jahu',      'SP', '17201040', 1);


-- -----------------------------------------------------------------------------
-- Categorias — "Games" (id 5) fica sem nenhum produto de propósito
-- -----------------------------------------------------------------------------
INSERT INTO categorias (nome, descricao, ativa) VALUES
    ('Eletrônicos', 'Computadores, smartphones e acessórios',   1),
    ('Periféricos', 'Mouse, teclado, headset e similares',      1),
    ('Livros',      'Técnicos, acadêmicos e literatura',        1),
    ('Casa',        'Utensílios, iluminação e mobiliário',      1),
    ('Games',       'Consoles, jogos e acessórios gamer',       1);


-- -----------------------------------------------------------------------------
-- Produtos — alguns propositalmente "incompletos" para exercitar NULL e filtros:
--   descricao NULL: ids 2, 4, 8 · estoque 0: id 7 · inativo: id 10
-- -----------------------------------------------------------------------------
INSERT INTO produtos (categoria_id, nome, descricao, preco, estoque, ativo) VALUES
    (1, 'Notebook Lenovo IdeaPad',                 'Notebook 15" com 16 GB de RAM e SSD de 512 GB',  3499.90, 15, 1),
    (1, 'Smartphone Samsung A55',                  NULL,                                             1899.00, 30, 1),
    (2, 'Mouse Logitech MX Master',                'Mouse sem fio ergonômico com 7 botões',           399.90, 50, 1),
    (2, 'Teclado Mecânico Redragon',               NULL,                                              299.90, 40, 1),
    (3, 'Sistemas de Banco de Dados — Elmasri',    'Livro-texto clássico de banco de dados',          189.90, 20, 1),
    (1, 'Monitor LG UltraWide 29"',                'Monitor ultrawide IPS Full HD',                  1299.00,  8, 1),
    (2, 'Headset HyperX Cloud',                    'Headset gamer com microfone removível',           449.90,  0, 1),
    (2, 'Webcam Full HD',                          NULL,                                              229.90, 25, 1),
    (3, 'SQL para Análise de Dados — Tanimura',    'Técnicas avançadas de SQL para análise',          129.90, 35, 1),
    (3, 'Introdução a Sistemas de Bancos de Dados — Date', 'Edição antiga, fora de linha',            159.90,  5, 0),
    (4, 'Luminária de Mesa LED',                   'Luminária com 3 níveis de brilho',                 89.90, 60, 1),
    (4, 'Cadeira Ergonômica',                      'Cadeira com ajuste lombar e apoio de braço',     1199.00,  6, 1);


-- -----------------------------------------------------------------------------
-- Pedidos — o valor_total é calculado logo abaixo, a partir dos itens
-- (cliente 11 nunca comprou; produtos 7 e 10 nunca foram vendidos)
-- -----------------------------------------------------------------------------
INSERT INTO pedidos (cliente_id, funcionario_id, endereco_id, data_pedido, status) VALUES
    (1,  5,    1, '2026-02-10 10:15:00', 'confirmado'),   -- pedido 1  (o mesmo do Tópico 04)
    (2,  NULL, 3, '2026-02-18 14:40:00', 'entregue'),     -- pedido 2
    (3,  4,    4, '2026-03-05 09:05:00', 'entregue'),     -- pedido 3
    (6,  NULL, 5, '2026-03-22 20:30:00', 'cancelado'),    -- pedido 4
    (1,  5,    2, '2026-04-09 16:10:00', 'entregue'),     -- pedido 5
    (7,  NULL, 6, '2026-04-27 11:00:00', 'entregue'),     -- pedido 6
    (8,  12,   7, '2026-05-14 13:25:00', 'entregue'),     -- pedido 7
    (9,  NULL, 8, '2026-06-02 18:50:00', 'enviado'),      -- pedido 8
    (10, 4,    9, '2026-06-19 10:00:00', 'entregue'),     -- pedido 9
    (2,  NULL, 3, '2026-07-08 15:35:00', 'em_separacao'), -- pedido 10
    (6,  12,   5, '2026-08-15 12:20:00', 'confirmado'),   -- pedido 11
    (1,  NULL, 1, '2026-09-03 21:45:00', 'pendente'),     -- pedido 12
    (7,  5,    6, '2026-09-21 09:30:00', 'entregue'),     -- pedido 13
    (3,  NULL, 4, '2026-10-05 17:15:00', 'enviado'),      -- pedido 14
    (8,  4,    7, '2026-10-12 10:40:00', 'entregue');     -- pedido 15


-- -----------------------------------------------------------------------------
-- Itens dos pedidos — (pedido_id, produto_id, quantidade, preco_unitario, desconto)
-- preco_unitario é o snapshot do preço no momento da compra
-- -----------------------------------------------------------------------------
INSERT INTO itens_pedidos (pedido_id, produto_id, quantidade, preco_unitario, desconto) VALUES
    (1,  1, 1, 3499.90,  0.00),
    (1,  3, 1,  399.90,  0.00),
    (2,  2, 1, 1899.00,  0.00),
    (2,  8, 2,  229.90,  0.00),
    (3,  5, 1,  189.90,  0.00),
    (3,  9, 1,  129.90,  0.00),
    (4,  6, 1, 1299.00,  0.00),
    (5,  4, 1,  299.90,  0.00),
    (5,  3, 1,  399.90, 10.00),
    (6,  1, 1, 3499.90,  5.00),
    (7,  9, 2,  129.90,  0.00),
    (7,  5, 1,  189.90,  0.00),
    (7, 11, 3,   89.90,  0.00),
    (8,  2, 2, 1899.00,  0.00),
    (8,  3, 1,  399.90,  0.00),
    (9,  6, 1, 1299.00,  0.00),
    (9,  4, 1,  299.90,  0.00),
    (10, 8, 1,  229.90,  0.00),
    (10,12, 1, 1199.00,  0.00),
    (11, 2, 1, 1899.00,  0.00),
    (11, 4, 2,  299.90,  5.00),
    (12, 9, 1,  129.90,  0.00),
    (13, 6, 1, 1299.00,  0.00),
    (13, 3, 2,  399.90,  0.00),
    (14,12, 1, 1199.00,  0.00),
    (15, 1, 1, 3499.90,  0.00),
    (15, 5, 2,  189.90,  0.00);


-- -----------------------------------------------------------------------------
-- valor_total = soma dos itens (quantidade × preço × (1 − desconto/100))
-- -----------------------------------------------------------------------------
UPDATE pedidos p
SET    p.valor_total = (
           SELECT COALESCE(SUM(i.quantidade * i.preco_unitario * (1 - i.desconto / 100)), 0)
           FROM   itens_pedidos i
           WHERE  i.pedido_id = p.id_pedido
       );


-- -----------------------------------------------------------------------------
-- Conferência rápida da carga
-- -----------------------------------------------------------------------------
SELECT 'pessoas'       AS tabela, COUNT(*) AS linhas FROM pessoas
UNION ALL SELECT 'enderecos',     COUNT(*) FROM enderecos
UNION ALL SELECT 'categorias',    COUNT(*) FROM categorias
UNION ALL SELECT 'produtos',      COUNT(*) FROM produtos
UNION ALL SELECT 'pedidos',       COUNT(*) FROM pedidos
UNION ALL SELECT 'itens_pedidos', COUNT(*) FROM itens_pedidos;
