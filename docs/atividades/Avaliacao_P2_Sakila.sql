/* =====================================================================
   AVALIAÇÃO P2 — INSERÇÕES, CONSULTAS E EXCLUSÕES NO sakila_pt
   Tópicos 04 a 07
   Disciplina: Banco de Dados — Relacional (IBD015)
   Fatec Jahu — DSM — 2º Semestre/2026
   Valor: 4,0 pontos — em dupla

   ---------------------------------------------------------------------
   ONDE ESTÁ O ENUNCIADO COMPLETO
   ---------------------------------------------------------------------
   A página desta avaliação NÃO aparece no menu do site da disciplina.
   Acesse pelo endereço direto:

     https://dsm-fatec-jahu.github.io/BDR-DSM-2026-2/atividades/Avaliacao_P2_Sakila/

   Download direto deste modelo:

     https://dsm-fatec-jahu.github.io/BDR-DSM-2026-2/atividades/Avaliacao_P2_Sakila.sql

   (No repositório: docs/atividades/Avaliacao_P2_Sakila.md e
    docs/atividades/Avaliacao_P2_Sakila.sql)

   ---------------------------------------------------------------------
   IDENTIFICAÇÃO DA DUPLA
   ---------------------------------------------------------------------
   Integrante 1: ______________________________________________
   Integrante 2: ______________________________________________
   Número do computador: _______

   ---------------------------------------------------------------------
   INSTRUÇÕES
   ---------------------------------------------------------------------
   1. Entregue UM ÚNICO arquivo .sql (este mesmo, preenchido) com TODOS
      os comandos. Os dois integrantes entregam o MESMO arquivo na
      atividade desta avaliação no Google Classroom.
   2. Consulta permitida: a folha de anotações escrita à mão e o portal
      da disciplina SOMENTE nas páginas de conteúdo dos tópicos.
      Proibido consultar exercícios, checkpoints, gabaritos, práticas,
      simulados, avaliações ou outras atividades do portal.
   3. Composição da nota (todas as duplas fazem as três atividades):
        - Atividade 1: contratação de funcionário ............... 1,5 pt
        - Atividade 2: 1 SELECT da Parte 1 + 1 da Parte 2 ....... 1,5 pt
                       (livre escolha, 0,75 pt cada)
        - Atividade 3: exclusão 3.1 (obrigatória) + 1 entre as
                       exclusões 3.2 e 3.3 (0,5 pt cada) ........ 1,0 pt
   4. Escreva os comandos SOMENTE nas seções delimitadas abaixo.
   5. Passos marcados com (RECOMENDADO) — DESCRIBE e verificar se o
      registro já existe — ajudam, mas não são obrigatórios e não valem
      nota.
   6. USE SEMPRE O ÚLTIMO ID GERADO: depois de cada INSERT em tabela com
      PK autoincrementável, a etapa seguinte usa o id que acabou de ser
      gerado.
   7. Atualizações (UPDATE) e exclusões (DELETE) sempre filtrando pela
      chave primária.
   8. A execução pode ser parcial: deixe COMENTADO qualquer trecho
      incompleto ou com erro, para não impedir a execução do restante.
   ===================================================================== */


/* #####################################################################
   ATIVIDADE 1 — FLUXO DE CONTRATAÇÃO DE FUNCIONÁRIO             1,5 pt
   Cadeia: paises -> cidades -> enderecos -> funcionarios
           (com consulta em lojas)
   ##################################################################### */

/* ---------------------------------------------------------------------
   1.1 — Consulte paises e localize 'Argentina' (ou 'Brasil').
   --------------------------------------------------------------------- */



/* ---------------------------------------------------------------------
   1.2 — (RECOMENDADO) Verifique em cidades se já existe 'Mendoza'
         (Argentina) ou 'Jaú' (Brasil).
   --------------------------------------------------------------------- */



/* ---------------------------------------------------------------------
   1.3 — (RECOMENDADO: DESCRIBE cidades) Cadastre a cidade vinculada ao
         id_pais do país escolhido (subconsulta) e confira o registro
         pelo último id gerado (id_cidade).
   --------------------------------------------------------------------- */



/* ---------------------------------------------------------------------
   1.4 — (RECOMENDADO: DESCRIBE enderecos) Cadastre um endereço completo
         (logradouro, complemento opcional, bairro, código postal e
         telefone) vinculado à cidade recém-criada e confira o registro
         pelo último id gerado (id_endereco).
   --------------------------------------------------------------------- */



/* ---------------------------------------------------------------------
   1.5 — Consulte lojas para ver quais id_loja existem.
   --------------------------------------------------------------------- */



/* ---------------------------------------------------------------------
   1.6 — (RECOMENDADO) Inspecione a estrutura de funcionarios e
         identifique os campos obrigatórios.
   --------------------------------------------------------------------- */



/* ---------------------------------------------------------------------
   1.7 — Cadastre o funcionário vinculado ao endereço recém-criado e à
         loja 1 (foto e senha podem ficar nulos).
   --------------------------------------------------------------------- */



/* ---------------------------------------------------------------------
   1.8 — Consulte o funcionário pelo último id gerado (id_funcionario)
         para confirmar o cadastro.
   --------------------------------------------------------------------- */



/* ---------------------------------------------------------------------
   1.9 — Atualize o funcionário recém-criado (filtrando pelo
         id_funcionario): email, nome_usuario e loja_id = 2. Depois,
         consulte o registro novamente para validar.
   --------------------------------------------------------------------- */




/* #####################################################################
   ATIVIDADE 2 — CONSULTAS ANALÍTICAS COM SELECT                 1,5 pt

   ESCOLHA 1 item da Parte 1 e 1 item da Parte 2 (0,75 pt cada).
   Marque com X os itens escolhidos e responda SOMENTE esses.

   Regras:
   - Somente: SELECT, FROM, WHERE, INNER JOIN, GROUP BY, ORDER BY, LIMIT.
   - Use EXATAMENTE a função indicada, NO CAMPO indicado.
   - Item que não indica função = sem nenhuma função e sem GROUP BY.
   - Itens 1 a 5: SEM INNER JOIN.  Itens 6 a 10: COM INNER JOIN.

   Escolhido na Parte 1:  [ ] 1   [ ] 2   [ ] 3   [ ] 4   [ ] 5
   Escolhido na Parte 2:  [ ] 6   [ ] 7   [ ] 8   [ ] 9   [ ] 10
   ##################################################################### */

/* =====================================================================
   PARTE 1 — TABELA ÚNICA (SEM INNER JOIN) — ESCOLHA 1
   ===================================================================== */

/* ---------------------------------------------------------------------
   2.1
   Tabela: filmes
   titulo, taxa_aluguel e duracao dos filmes com classificacao 'PG-13',
   ordenados por titulo (A-Z).
   --------------------------------------------------------------------- */



/* ---------------------------------------------------------------------
   2.2
   Tabela: filmes
   Os 10 filmes com maior custo_reposicao: titulo, classificacao e
   custo_reposicao, do maior para o menor (LIMIT 10).
   --------------------------------------------------------------------- */



/* ---------------------------------------------------------------------
   2.3 — Função: AVG no campo taxa_aluguel (sem GROUP BY)
   Tabela: filmes
   Média da taxa_aluguel dos filmes com classificacao 'G'.
   --------------------------------------------------------------------- */



/* ---------------------------------------------------------------------
   2.4 — Função: MAX no campo duracao
   Tabela: filmes  |  GROUP BY: classificacao
   classificacao e maior duracao de cada classificação, da maior para a
   menor duração.
   --------------------------------------------------------------------- */



/* ---------------------------------------------------------------------
   2.5 — Função: SUM no campo valor
   Tabela: pagamentos  |  WHERE: valor > 0  |  GROUP BY: cliente_id
   cliente_id e total pago dos 5 clientes que mais gastaram, do maior
   para o menor total (LIMIT 5).
   --------------------------------------------------------------------- */



/* =====================================================================
   PARTE 2 — RELACIONAIS (COM INNER JOIN) — ESCOLHA 1
   ===================================================================== */

/* ---------------------------------------------------------------------
   2.6
   Tabelas: clientes + enderecos
   primeiro_nome, ultimo_nome, email, logradouro e telefone dos clientes
   ativos (ativo = 1), ordenados por primeiro_nome (A-Z).
   --------------------------------------------------------------------- */



/* ---------------------------------------------------------------------
   2.7
   Tabelas: filmes + filmes_categorias + categorias
   filmes.titulo, filmes.classificacao e categorias.nome dos filmes com
   classificacao 'G', ordenados por categorias.nome e depois por
   filmes.titulo (A-Z).
   --------------------------------------------------------------------- */



/* ---------------------------------------------------------------------
   2.8 — Função: SUM no campo pagamentos.valor
   Tabelas: clientes + pagamentos  |  WHERE: ativo = 1
   GROUP BY: clientes.id_cliente, clientes.primeiro_nome,
             clientes.ultimo_nome, clientes.email
   Os 5 melhores clientes ativos: primeiro_nome, ultimo_nome, email e
   total gasto, do maior para o menor (LIMIT 5).
   --------------------------------------------------------------------- */



/* ---------------------------------------------------------------------
   2.9 — Função: SUM no campo pagamentos.valor
   Tabelas: funcionarios + pagamentos
   GROUP BY: funcionarios.id_funcionario, funcionarios.primeiro_nome,
             funcionarios.ultimo_nome
   O funcionário com maior total em vendas: primeiro_nome, ultimo_nome e
   total vendido, do maior para o menor (LIMIT 1).
   --------------------------------------------------------------------- */



/* ---------------------------------------------------------------------
   2.10 — Função: AVG no campo filmes.taxa_aluguel
   Tabelas: filmes + filmes_categorias + categorias
   GROUP BY: categorias.id_categoria, categorias.nome
   categorias.nome e taxa média de aluguel de cada categoria, da maior
   para a menor taxa média.
   --------------------------------------------------------------------- */




/* #####################################################################
   ATIVIDADE 3 — EXCLUSÃO SEGURA DE REGISTROS (DELETE)           1,0 pt

   Exclusão 3.1 OBRIGATÓRIA + ESCOLHA 1 entre 3.2 e 3.3 (0,5 pt cada).
   Marque com X a escolhida:   [ ] 3.2   [ ] 3.3

   Os ids NÃO são informados. Em cada exclusão:
     a) SELECT para BUSCAR o id pelas características descritas
        (se vier mais de uma linha, escolha UMA);
     b) DELETE filtrando PELA CHAVE PRIMÁRIA;
     c) SELECT pela mesma chave primária para CONFIRMAR que não existe
        mais.
   ##################################################################### */

/* ---------------------------------------------------------------------
   3.1 — Tabela funcionarios (OBRIGATÓRIA)
   Exclua o funcionário cadastrado pela dupla na Atividade 1.
   --------------------------------------------------------------------- */
-- a) buscar o id:

-- b) DELETE pela PK:

-- c) confirmar:



/* ---------------------------------------------------------------------
   3.2 — Tabela idiomas
   Exclua o idioma 'Alemão' (não vinculado a nenhum filme).
   --------------------------------------------------------------------- */
-- a) buscar o id:

-- b) DELETE pela PK:

-- c) confirmar:



/* ---------------------------------------------------------------------
   3.3 — Tabela pagamentos
   Exclua um pagamento de valor 1.99 sem aluguel vinculado
   (aluguel_id nulo).
   --------------------------------------------------------------------- */
-- a) buscar o id:

-- b) DELETE pela PK:

-- c) confirmar:



/* =====================================================================
   FIM DA AVALIAÇÃO — execute o arquivo inteiro antes de entregar e
   confira se nenhum erro interrompe a execução.
   ===================================================================== */
