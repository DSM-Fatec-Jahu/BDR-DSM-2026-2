DROP DATABASE IF EXISTS sakila_pt;

-- sakila_pt_corrigido

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

DROP SCHEMA IF EXISTS sakila_pt;
CREATE SCHEMA sakila_pt CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sakila_pt;

--
-- Tabelas base (sem dependências externas)
--

CREATE TABLE atores (
  id_ator INT UNSIGNED NOT NULL AUTO_INCREMENT,
  primeiro_nome VARCHAR(45) NOT NULL,
  ultimo_nome VARCHAR(45) NOT NULL,
  alterado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deletado_em DATETIME NULL DEFAULT NULL,
  PRIMARY KEY  (id_ator),
  KEY idx_actor_last_name (ultimo_nome)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE categorias (
  id_categoria INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome VARCHAR(25) NOT NULL,
  alterado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deletado_em DATETIME NULL DEFAULT NULL,
  PRIMARY KEY  (id_categoria)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE paises (
  id_pais INT UNSIGNED NOT NULL AUTO_INCREMENT,
  pais VARCHAR(50) NOT NULL,
  alterado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deletado_em DATETIME NULL DEFAULT NULL,
  PRIMARY KEY  (id_pais)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE idiomas (
  id_idioma INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome CHAR(20) NOT NULL,
  alterado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deletado_em DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (id_idioma)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Tabelas dependentes (Nível 1)
--

CREATE TABLE cidades (
  id_cidade INT UNSIGNED NOT NULL AUTO_INCREMENT,
  cidade VARCHAR(50) NOT NULL,
  pais_id INT UNSIGNED NOT NULL,
  alterado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deletado_em DATETIME NULL DEFAULT NULL,
  PRIMARY KEY  (id_cidade),
  KEY idx_fk_paises_id (pais_id),
  CONSTRAINT `fk_cidades_paises` FOREIGN KEY (pais_id) REFERENCES paises (id_pais) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE filmes (
  id_filme INT UNSIGNED NOT NULL AUTO_INCREMENT,
  titulo VARCHAR(255) NOT NULL,
  descricao TEXT DEFAULT NULL,
  ano_lancamento YEAR DEFAULT NULL,
  idioma_id INT UNSIGNED NOT NULL,
  idioma_original_id INT UNSIGNED DEFAULT NULL,
  duracao_aluguel TINYINT UNSIGNED NOT NULL DEFAULT 3,
  taxa_aluguel DECIMAL(4,2) NOT NULL DEFAULT 4.99,
  duracao SMALLINT UNSIGNED DEFAULT NULL,
  custo_reposicao DECIMAL(5,2) NOT NULL DEFAULT 19.99,
  classificacao ENUM('G','PG','PG-13','R','NC-17') DEFAULT 'G',
  recursos_especiais SET('Trailers','Comentários','Cenas Deletadas','Bastidores') DEFAULT NULL,
  alterado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deletado_em DATETIME NULL DEFAULT NULL,
  PRIMARY KEY  (id_filme),
  KEY idx_title (titulo),
  KEY idx_fk_idiomas_id (idioma_id),
  KEY idx_fk_original_language_id (idioma_original_id),
  CONSTRAINT fk_filmes_idiomas FOREIGN KEY (idioma_id) REFERENCES idiomas (id_idioma) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_filmes_language_original FOREIGN KEY (idioma_original_id) REFERENCES idiomas (id_idioma) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Tabelas dependentes (Nível 2)
--

CREATE TABLE enderecos (
  id_endereco INT UNSIGNED NOT NULL AUTO_INCREMENT,
  logradouro VARCHAR(50) NOT NULL,
  complemento VARCHAR(50) DEFAULT NULL,
  bairro VARCHAR(20) NOT NULL,
  cidade_id INT UNSIGNED NOT NULL,
  codigo_postal VARCHAR(10) DEFAULT NULL,
  telefone VARCHAR(20) NOT NULL,
  alterado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deletado_em DATETIME NULL DEFAULT NULL,
  PRIMARY KEY  (id_endereco),
  KEY idx_fk_cidades_id (cidade_id),
  CONSTRAINT `fk_enderecos_cidades` FOREIGN KEY (cidade_id) REFERENCES cidades (id_cidade) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE filmes_atores (
  ator_id INT UNSIGNED NOT NULL,
  filme_id INT UNSIGNED NOT NULL,
  alterado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deletado_em DATETIME NULL DEFAULT NULL,
  PRIMARY KEY  (ator_id,filme_id),
  KEY idx_fk_filmes_id (`filme_id`),
  CONSTRAINT fk_filmes_actor_atores FOREIGN KEY (ator_id) REFERENCES atores (id_ator) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_filmes_actor_filmes FOREIGN KEY (filme_id) REFERENCES filmes (id_filme) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE filmes_categorias (
  filme_id INT UNSIGNED NOT NULL,
  categoria_id INT UNSIGNED NOT NULL,
  alterado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deletado_em DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (filme_id, categoria_id),
  CONSTRAINT fk_filmes_category_filmes FOREIGN KEY (filme_id) REFERENCES filmes (id_filme) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_filmes_category_categorias FOREIGN KEY (categoria_id) REFERENCES categorias (id_categoria) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE filmes_texto (
  filme_id INT NOT NULL,
  titulo VARCHAR(255) NOT NULL,
  descricao TEXT,
  deletado_em DATETIME NULL DEFAULT NULL,
  PRIMARY KEY  (filme_id),
  FULLTEXT KEY idx_title_description (titulo,descricao)
)ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

--
-- Triggers
--

DELIMITER ;;
CREATE TRIGGER `ins_film` AFTER INSERT ON `filmes`
FOR EACH ROW
BEGIN
    INSERT INTO filmes_texto (filme_id, titulo, descricao)
        VALUES (NEW.id_filme, NEW.titulo, NEW.descricao);
  END;;


CREATE TRIGGER `upd_film` AFTER UPDATE ON `filmes`
FOR EACH ROW
BEGIN
    IF (OLD.titulo != NEW.titulo) OR (OLD.descricao != NEW.descricao)
    THEN
        UPDATE filmes_texto
            SET titulo = NEW.titulo,
                descricao = NEW.descricao
        WHERE id_filme = OLD.id_filme;
    END IF;
END ;;


CREATE TRIGGER `del_film` AFTER DELETE ON `filmes`
FOR EACH ROW
BEGIN
    DELETE FROM filmes_texto WHERE id_filme = OLD.id_filme;
  END;;

DELIMITER ;

--
-- Resolvendo Dependência Circular (Funcionarios <-> Lojas)
--

-- 1. Criar funcionarios primeiro, mas SEM a FK para lojas
CREATE TABLE funcionarios (
  id_funcionario INT UNSIGNED NOT NULL AUTO_INCREMENT,
  primeiro_nome VARCHAR(45) NOT NULL,
  ultimo_nome VARCHAR(45) NOT NULL,
  endereco_id INT UNSIGNED NOT NULL,
  foto MEDIUMBLOB DEFAULT NULL,
  email VARCHAR(50) DEFAULT NULL,
  loja_id INT UNSIGNED NOT NULL,
  ativo BOOLEAN NOT NULL DEFAULT TRUE,
  nome_usuario VARCHAR(16) NOT NULL,
  senha VARCHAR(40) BINARY DEFAULT NULL,
  alterado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deletado_em DATETIME NULL DEFAULT NULL,
  PRIMARY KEY  (id_funcionario),
  KEY idx_fk_lojas_id (loja_id),
  KEY idx_fk_enderecos_id (endereco_id),
  -- A FK para lojas será adicionada via ALTER TABLE
  CONSTRAINT fk_funcionarios_enderecos FOREIGN KEY (endereco_id) REFERENCES enderecos (id_endereco) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Criar lojas (agora funcionarios existe)
CREATE TABLE lojas (
  id_loja INT UNSIGNED NOT NULL AUTO_INCREMENT,
  funcionario_gerente_id INT UNSIGNED NOT NULL,
  endereco_id INT UNSIGNED NOT NULL,
  alterado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deletado_em DATETIME NULL DEFAULT NULL,
  PRIMARY KEY  (id_loja),
  UNIQUE KEY idx_unique_manager (funcionario_gerente_id),
  KEY idx_fk_enderecos_id (endereco_id),
  CONSTRAINT fk_lojas_funcionarios FOREIGN KEY (funcionario_gerente_id) REFERENCES funcionarios (id_funcionario) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_lojas_enderecos FOREIGN KEY (endereco_id) REFERENCES enderecos (id_endereco) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Adicionar a FK que faltava em funcionarios
ALTER TABLE funcionarios
  ADD CONSTRAINT fk_funcionarios_lojas FOREIGN KEY (loja_id) REFERENCES lojas (id_loja) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Tabelas dependentes (Nível 3)
--

CREATE TABLE clientes (
  id_cliente INT UNSIGNED NOT NULL AUTO_INCREMENT,
  loja_id INT UNSIGNED NOT NULL,
  primeiro_nome VARCHAR(45) NOT NULL,
  ultimo_nome VARCHAR(45) NOT NULL,
  email VARCHAR(50) DEFAULT NULL,
  endereco_id INT UNSIGNED NOT NULL,
  ativo BOOLEAN NOT NULL DEFAULT TRUE,
  criado_em DATETIME NOT NULL,
  alterado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deletado_em DATETIME NULL DEFAULT NULL,
  PRIMARY KEY  (id_cliente),
  KEY idx_fk_lojas_id (loja_id),
  KEY idx_fk_enderecos_id (endereco_id),
  KEY idx_last_name (ultimo_nome),
  CONSTRAINT fk_clientes_enderecos FOREIGN KEY (endereco_id) REFERENCES enderecos (id_endereco) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_clientes_lojas FOREIGN KEY (loja_id) REFERENCES lojas (id_loja) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE inventarios (
  id_inventario INT UNSIGNED NOT NULL AUTO_INCREMENT,
  filme_id INT UNSIGNED NOT NULL,
  loja_id INT UNSIGNED NOT NULL,
  alterado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deletado_em DATETIME NULL DEFAULT NULL,
  PRIMARY KEY  (id_inventario),
  KEY idx_fk_filmes_id (filme_id),
  KEY idx_store_id_film_id (loja_id,filme_id),
  CONSTRAINT fk_inventarios_lojas FOREIGN KEY (loja_id) REFERENCES lojas (id_loja) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_inventarios_filmes FOREIGN KEY (filme_id) REFERENCES filmes (id_filme) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Tabelas dependentes (Nível 4)
--

CREATE TABLE alugueis (
  id_aluguel INT NOT NULL AUTO_INCREMENT,
  data_aluguel DATETIME NOT NULL,
  inventario_id INT UNSIGNED NOT NULL,
  cliente_id INT UNSIGNED NOT NULL,
  data_devolucao DATETIME DEFAULT NULL,
  funcionario_id INT UNSIGNED NOT NULL,
  alterado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deletado_em DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (id_aluguel),
  UNIQUE KEY  (data_aluguel,inventario_id,cliente_id),
  KEY idx_fk_inventarios_id (inventario_id),
  KEY idx_fk_clientes_id (cliente_id),
  KEY idx_fk_funcionarios_id (funcionario_id),
  CONSTRAINT fk_alugueis_funcionarios FOREIGN KEY (funcionario_id) REFERENCES funcionarios (id_funcionario) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_alugueis_inventarios FOREIGN KEY (inventario_id) REFERENCES inventarios (id_inventario) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_alugueis_clientes FOREIGN KEY (cliente_id) REFERENCES clientes (id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Tabelas dependentes (Nível 5)
--

CREATE TABLE pagamentos (
  id_pagamento INT UNSIGNED NOT NULL AUTO_INCREMENT,
  cliente_id INT UNSIGNED NOT NULL,
  funcionario_id INT UNSIGNED NOT NULL,
  aluguel_id INT DEFAULT NULL,
  valor DECIMAL(5,2) NOT NULL,
  data_pagamento DATETIME NOT NULL,
  alterado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deletado_em DATETIME NULL DEFAULT NULL,
  PRIMARY KEY  (id_pagamento),
  KEY idx_fk_funcionarios_id (funcionario_id),
  KEY idx_fk_clientes_id (cliente_id),
  CONSTRAINT fk_pagamentos_alugueis FOREIGN KEY (aluguel_id) REFERENCES alugueis (id_aluguel) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_pagamentos_clientes FOREIGN KEY (cliente_id) REFERENCES clientes (id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pagamentos_funcionarios FOREIGN KEY (funcionario_id) REFERENCES funcionarios (id_funcionario) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Views (dependem de tabelas múltiplas)
--

CREATE VIEW lista_clientes
AS
SELECT cu.id_cliente AS ID, CONCAT(cu.primeiro_nome, _utf8mb4' ', cu.ultimo_nome) AS nome, a.logradouro AS logradouro, a.codigo_postal AS cep,
	a.telefone AS telefone, cidade.cidade AS cidade, pais.pais AS pais, IF(cu.ativo, _utf8mb4'ativo',_utf8mb4'') AS observacoes, cu.loja_id AS SID
FROM clientes AS cu JOIN enderecos AS a ON cu.endereco_id = a.id_endereco JOIN cidades AS cidade ON a.cidade_id = cidade.id_cidade
	JOIN paises AS pais ON cidade.pais_id = pais.id_pais;

CREATE VIEW lista_filmes
AS
SELECT film.id_filme AS FID, film.titulo AS titulo, film.descricao AS descricao, category.nome AS categoria, film.taxa_aluguel AS preco,
	film.duracao AS duracao, film.classificacao AS classificacao, GROUP_CONCAT(CONCAT(actor.primeiro_nome, _utf8mb4' ', actor.ultimo_nome) SEPARATOR ', ') AS atores
FROM categorias AS category LEFT JOIN filmes_categorias AS film_category ON category.id_categoria = film_category.categoria_id LEFT JOIN filmes AS film ON film_category.filme_id = film.id_filme
        JOIN filmes_atores AS film_actor ON film.id_filme = film_actor.filme_id
	JOIN atores AS actor ON film_actor.ator_id = actor.id_ator
GROUP BY film.id_filme, film.titulo, film.descricao, film.taxa_aluguel, film.duracao, film.classificacao, category.nome;

CREATE VIEW lista_filmes_formatada
AS
SELECT film.id_filme AS FID, film.titulo AS titulo, film.descricao AS descricao, category.nome AS categoria, film.taxa_aluguel AS preco,
	film.duracao AS duracao, film.classificacao AS classificacao, GROUP_CONCAT(CONCAT(CONCAT(UCASE(SUBSTR(actor.primeiro_nome,1,1)),
	LCASE(SUBSTR(actor.primeiro_nome,2,LENGTH(actor.primeiro_nome))),_utf8mb4' ',CONCAT(UCASE(SUBSTR(actor.ultimo_nome,1,1)),
	LCASE(SUBSTR(actor.ultimo_nome,2,LENGTH(actor.ultimo_nome)))))) SEPARATOR ', ') AS atores
FROM categorias AS category LEFT JOIN filmes_categorias AS film_category ON category.id_categoria = film_category.categoria_id LEFT JOIN filmes AS film ON film_category.filme_id = film.id_filme
        JOIN filmes_atores AS film_actor ON film.id_filme = film_actor.filme_id
	JOIN atores AS actor ON film_actor.ator_id = actor.id_ator
GROUP BY film.id_filme, film.titulo, film.descricao, film.taxa_aluguel, film.duracao, film.classificacao, category.nome;

CREATE VIEW lista_funcionarios
AS
SELECT s.id_funcionario AS ID, CONCAT(s.primeiro_nome, _utf8mb4' ', s.ultimo_nome) AS nome, a.logradouro AS logradouro, a.codigo_postal AS cep, a.telefone AS telefone,
	cidade.cidade AS cidade, pais.pais AS pais, s.loja_id AS SID
FROM funcionarios AS s JOIN enderecos AS a ON s.endereco_id = a.id_endereco JOIN cidades AS cidade ON a.cidade_id = cidade.id_cidade
	JOIN paises AS pais ON cidade.pais_id = pais.id_pais;

CREATE VIEW vendas_por_loja
AS
SELECT
CONCAT(c.cidade, _utf8mb4',', cy.pais) AS loja
, CONCAT(m.primeiro_nome, _utf8mb4' ', m.ultimo_nome) AS gerente
, SUM(p.valor) AS vendas_totais
FROM pagamentos AS p
INNER JOIN alugueis AS r ON p.aluguel_id = r.id_aluguel
INNER JOIN inventarios AS i ON r.inventario_id = i.id_inventario
INNER JOIN lojas AS s ON i.loja_id = s.id_loja
INNER JOIN enderecos AS a ON s.endereco_id = a.id_endereco
INNER JOIN cidades AS c ON a.cidade_id = c.id_cidade
INNER JOIN paises AS cy ON c.pais_id = cy.id_pais
INNER JOIN funcionarios AS m ON s.funcionario_gerente_id = m.id_funcionario
GROUP BY s.id_loja
ORDER BY cy.pais, c.cidade;

CREATE VIEW vendas_por_categoria
AS
SELECT
c.nome AS categoria
, SUM(p.valor) AS vendas_totais
FROM pagamentos AS p
INNER JOIN alugueis AS r ON p.aluguel_id = r.id_aluguel
INNER JOIN inventarios AS i ON r.inventario_id = i.id_inventario
INNER JOIN filmes AS f ON i.filme_id = f.id_filme
INNER JOIN filmes_categorias AS fc ON f.id_filme = fc.filme_id
INNER JOIN categorias AS c ON fc.categoria_id = c.id_categoria
GROUP BY c.nome
ORDER BY vendas_totais DESC;

CREATE DEFINER=CURRENT_USER SQL SECURITY INVOKER VIEW info_atores
AS
SELECT
a.id_ator,
a.primeiro_nome,
a.ultimo_nome,
GROUP_CONCAT(DISTINCT CONCAT(c.nome, ': ',
		(SELECT GROUP_CONCAT(f.titulo ORDER BY f.titulo SEPARATOR ', ')
                    FROM sakila_pt.filmes f
                    INNER JOIN sakila_pt.filmes_categorias fc
                      ON f.id_filme = fc.filme_id
                    INNER JOIN sakila_pt.filmes_atores fa
                      ON f.id_filme = fa.filme_id
                    WHERE fc.categoria_id = c.id_categoria
                    AND fa.ator_id = a.id_ator
                 )
             )
             ORDER BY c.nome SEPARATOR '; ')
AS info_filmes
FROM sakila_pt.atores a
LEFT JOIN sakila_pt.filmes_atores fa
  ON a.id_ator = fa.ator_id
LEFT JOIN sakila_pt.filmes_categorias fc
  ON fa.filme_id = fc.filme_id
LEFT JOIN sakila_pt.categorias c
  ON fc.categoria_id = c.id_categoria
GROUP BY a.id_ator, a.primeiro_nome, a.ultimo_nome;

--
-- Estrutura da procedure `relatorio_recompensas`
--

DELIMITER //

CREATE PROCEDURE relatorio_recompensas (
    IN min_compras_mensais TINYINT UNSIGNED
    , IN min_valor_comprado DECIMAL(10,2) UNSIGNED
    , OUT contagem_recompensados INT
)
LANGUAGE SQL
NOT DETERMINISTIC
READS SQL DATA
SQL SECURITY DEFINER
COMMENT 'Fornece um relatório personalizável sobre os melhores clientes'
proc: BEGIN

    DECLARE last_month_start DATE;
    DECLARE last_month_end DATE;

    /* Algumas verificações... */
    IF min_compras_mensais = 0 THEN
        SELECT 'O parâmetro de compras mensais mínimas deve ser > 0';
        LEAVE proc;
    END IF;
    IF min_valor_comprado = 0.00 THEN
        SELECT 'O parâmetro de valor mínimo comprado deve ser > $0.00';
        LEAVE proc;
    END IF;

    /* Determina os períodos de início e fim */
    SET last_month_start = DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH);
    SET last_month_start = STR_TO_DATE(CONCAT(YEAR(last_month_start),'-',MONTH(last_month_start),'-01'),'%Y-%m-%d');
    SET last_month_end = LAST_DAY(last_month_start);

    /*
        Cria uma área de armazenamento temporária para
        os IDs dos Clientes.
    */
    CREATE TEMPORARY TABLE tmpClientes (id_cliente INT UNSIGNED NOT NULL PRIMARY KEY);

    /*
        Encontra todos os clientes que atendem aos
        requisitos de compras mensais
    */
    INSERT INTO tmpClientes (id_cliente)
    SELECT p.cliente_id
    FROM pagamentos AS p
    WHERE DATE(p.data_pagamento) BETWEEN last_month_start AND last_month_end
    GROUP BY cliente_id
    HAVING SUM(p.valor) > min_valor_comprado
    AND COUNT(cliente_id) > min_compras_mensais;

    /* Preenche o parâmetro OUT com a contagem de clientes encontrados */
    SELECT COUNT(*) FROM tmpClientes INTO contagem_recompensados;

    /*
        Retorna TODA a informação dos clientes que correspondem.
        Personalize a saída conforme necessário.
    */
    SELECT c.*
    FROM tmpClientes AS t
    INNER JOIN clientes AS c ON t.id_cliente = c.id_cliente;

    /* Limpeza */
    DROP TABLE tmpClientes;
END //

DELIMITER ;

DELIMITER $$

CREATE FUNCTION obter_saldo_cliente(p_cliente_id INT, p_data_efetiva DATETIME) RETURNS DECIMAL(5,2)
    DETERMINISTIC
    READS SQL DATA
BEGIN

       #PRECISAMOS CALCULAR O SALDO ATUAL DADO UM ID DE CLIENTE E UMA DATA
       #PARA A QUAL QUEREMOS QUE O SALDO SEJA EFETIVO. O SALDO É:
       #   1) TAXAS DE ALUGUEL PARA TODOS OS ALUGUÉIS ANTERIORES
       #   2) UMA TAXA (EX: 1.00) POR DIA DE ATRASO DOS ALUGUÉIS ANTERIORES
       #   3) SE UM FILME ESTIVER ATRASADO POR MAIS QUE O DOBRO DA DURACAO_ALUGUEL, COBRAR O CUSTO_REPOSICAO
       #   4) SUBTRAIR TODOS OS PAGAMENTOS FEITOS ANTES DA DATA ESPECIFICADA

  DECLARE v_taxas_aluguel DECIMAL(5,2); #TAXAS PAGAS PARA ALUGAR OS VÍDEOS INICIALMENTE
  DECLARE v_taxas_atraso INTEGER;      #TAXAS DE ATRASO PARA ALUGUÉIS ANTERIORES
  DECLARE v_pagamentos DECIMAL(5,2); #SOMA DOS PAGAMENTOS FEITOS ANTERIORMENTE

  SELECT IFNULL(SUM(film.taxa_aluguel),0) INTO v_taxas_aluguel
    FROM filmes AS film, inventarios AS inventory, alugueis AS rental
    WHERE film.id_filme = inventory.filme_id
      AND inventory.id_inventario = rental.inventario_id
      AND rental.data_aluguel <= p_data_efetiva
      AND rental.cliente_id = p_cliente_id;

  SELECT IFNULL(SUM(IF((TO_DAYS(rental.data_devolucao) - TO_DAYS(rental.data_aluguel)) > film.duracao_aluguel,
        ((TO_DAYS(rental.data_devolucao) - TO_DAYS(rental.data_aluguel)) - film.duracao_aluguel),0)),0) INTO v_taxas_atraso
    FROM alugueis AS rental, inventarios AS inventory, filmes AS film
    WHERE film.id_filme = inventory.filme_id
      AND inventory.id_inventario = rental.inventario_id
      AND rental.data_aluguel <= p_data_efetiva
      AND rental.cliente_id = p_cliente_id;


  SELECT IFNULL(SUM(payment.valor),0) INTO v_pagamentos
    FROM pagamentos AS payment

    WHERE payment.data_pagamento <= p_data_efetiva
    AND payment.cliente_id = p_cliente_id;

  RETURN v_taxas_aluguel + v_taxas_atraso - v_pagamentos;
END $$

DELIMITER ;

DELIMITER $$

CREATE FUNCTION inventario_em_estoque(p_inventario_id INT) RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE v_alugueis INT;
    DECLARE v_fora_de_estoque INT;

    #UM ITEM ESTÁ EM ESTOQUE SE NÃO HOUVER LINHAS NA TABELA alugueis
    #PARA O ITEM, OU SE TODAS AS LINHAS TIVEREM A data_devolucao PREENCHIDA

    SELECT COUNT(*) INTO v_alugueis
    FROM alugueis
    WHERE inventario_id = p_inventario_id;

    IF v_alugueis = 0 THEN
      RETURN TRUE;
    END IF;

    SELECT COUNT(id_aluguel) INTO v_fora_de_estoque
    FROM inventarios AS inventory LEFT JOIN alugueis AS rental USING(id_inventario)
    WHERE inventory.id_inventario = p_inventario_id
    AND rental.data_devolucao IS NULL;

    IF v_fora_de_estoque > 0 THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE filme_em_estoque(IN p_filme_id INT, IN p_loja_id INT, OUT p_contagem_filmes INT)
READS SQL DATA
BEGIN
     SELECT id_inventario
     FROM inventarios
     WHERE filme_id = p_filme_id
     AND loja_id = p_loja_id
     AND inventario_em_estoque(id_inventario);

     SELECT FOUND_ROWS() INTO p_contagem_filmes;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE filme_fora_estoque(IN p_filme_id INT, IN p_loja_id INT, OUT p_contagem_filmes INT)
READS SQL DATA
BEGIN
     SELECT id_inventario
     FROM inventarios
     WHERE filme_id = p_filme_id
     AND loja_id = p_loja_id
     AND NOT inventario_em_estoque(id_inventario);

     SELECT FOUND_ROWS() INTO p_contagem_filmes;
END $$

DELIMITER ;

DELIMITER $$

CREATE FUNCTION inventario_com_cliente(p_inventario_id INT) RETURNS INT
READS SQL DATA
BEGIN
  DECLARE v_cliente_id INT;
  DECLARE EXIT HANDLER FOR NOT FOUND RETURN NULL;

  SELECT cliente_id INTO v_cliente_id
  FROM alugueis
  WHERE data_devolucao IS NULL
  AND inventario_id = p_inventario_id;

  RETURN v_cliente_id;
END $$

DELIMITER ;


SET SQL_MODE=@OLD_SQL_MODE;

USE sakila_pt;