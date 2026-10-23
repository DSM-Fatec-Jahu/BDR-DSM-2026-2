# 🗄️ Banco de Dados — Relacional (IBD015)

<div align="center" markdown>

![Fatec Jahu](https://img.shields.io/badge/Fatec-Jahu-blue?style=for-the-badge)
![Semestre](https://img.shields.io/badge/2º%20Semestre-2026-green?style=for-the-badge)
![Carga Horária](https://img.shields.io/badge/Carga%20Horária-80h-orange?style=for-the-badge)

</div>

!!! info "Conteúdo em construção progressiva"
    Os tópicos deste semestre são publicados progressivamente, conforme a turma avança. A tabela abaixo mostra o planejamento completo — os itens marcados com 🔒 ainda não foram liberados.

<div align="center" markdown>
[:material-clipboard-text-clock: Ver Atividades e Avaliações](atividades/index.md){ .md-button .md-button--primary }
</div>

---

## 🏫 Informações da Disciplina

| Campo | Informação |
|---|---|
| **Instituição** | Fatec Jahu — Centro Paula Souza |
| **Curso** | Tecnologia em Desenvolvimento de Software Multiplataforma |
| **Disciplina** | Banco de Dados — Relacional |
| **Sigla** | IBD015 |
| **Semestre/Ano** | 2º Semestre / 2026 |
| **Professor** | Ronan Adriel Zenatti |
| **E-mail** | ronan.zenatti@cps.sp.gov.br |
| **Carga Horária Semestral** | 80 horas |

---

## 📋 Ementa

Esta disciplina abrange o projeto e a implementação de bancos de dados relacionais, desde a modelagem conceitual até aspectos avançados de programação e administração. Os principais temas trabalhados são:

Projeto e implementação de banco de dados relacionais; consultas complexas com agrupamentos e subconsultas; implementação de restrições de integridade; criação de consultas utilizando visões; aspectos de programação em ambiente de banco de dados com procedimentos armazenados, gatilhos e funções; cópia de segurança e restauração de bancos de dados; estruturas de índices; processamento e otimização de consultas; processamento de transações e controle de concorrência; recuperação de falhas; e novas tecnologias aplicadas a banco de dados.

---

## 🎯 Objetivos

Ao final da disciplina, o aluno será capaz de:

- Aplicar normalização para implementação de Banco de Dados, utilizando adequadamente os conceitos de linguagem de definição, manipulação e consulta de dados (DDL, DML e DQL);
- Implementar *Stored Procedures* e Gatilhos (*Triggers*) para soluções de problemas em sistemas;
- Identificar as características de recuperação após falha e de segurança dos SGBDs.

---

## 📐 Metodologia

Os tópicos são conduzidos no formato **expositivo e prático**, combinando explicações conceituais com exercícios aplicados diretamente no SGBD. A ênfase é sempre na resolução de problemas reais, preparando o aluno para o mercado de trabalho.

---

## 📊 Critérios de Avaliação

A nota final é calculada pela seguinte fórmula:

> **Nota Final = (T1 + P1 + P2) × 1 + E** (limitada a 10,0)

| Componente | Descrição | Peso |
|---|---|---|
| **T1** | Entrega da modelagem (conceitual e lógica) e do script de criação (DDL) do Projeto Integrador (PI) | 2 pts |
| **P1** | Avaliação em dupla teórica e prática sobre modelagem e SQL fundamental | 4 pts |
| **P2** | Avaliação individual sobre consultas avançadas e programação em banco de dados | 4 pts |
| **R** | Avaliação Substitutiva — substitui a menor nota entre P1 e P2 | 4 pts** |
| **E** | Ponto extra — para quem realizou a Maratona de CiberEducação da Cisco | +1,0 pt |

---

## 📑 Sumário de Tópicos

| # | Tópico | Conteúdo Principal | Status |
|---|---|---|---|
| 01 | [Revisão de Modelagem de Dados (Conceitual)](topicos/Topico_01_Revisao_Modelagem_Conceitual.md) | Abordagem Entidade-Relacionamento (MER); Entidades, Atributos e Relacionamentos | ✅ Disponível |
| 02 | [Normalização](topicos/Topico_02_Normalizacao.md) | Dependências funcionais; 1ª, 2ª e 3ª Formas Normais; modelo conceitual ao lógico relacional | ✅ Disponível |
| 03 | [SQL — DDL: Definição de Estruturas](topicos/Topico_03_SQL_DDL.md) | Comandos DDL (CREATE, ALTER, DROP); Tipos de dados; Restrições básicas (PK) | ✅ Disponível |
| 04 | [SQL DML: Manipulação de Dados](topicos/Topico_04_SQL_DML.md) | Comandos DML (INSERT, UPDATE, DELETE); Controle de transação básico | ✅ Disponível |
| 05 | [SQL: Consultas Básicas](topicos/Topico_05_SQL_Consultas_Basicas.md) | SELECT; WHERE; Operadores lógicos e relacionais; ORDER BY | ✅ Disponível |
| 06 | SQL — DQL: Consultas e Agregação | Filtros avançados (LIKE, BETWEEN, IN); Funções de agregação (COUNT, SUM, AVG, MIN, MAX); GROUP BY e HAVING | 🔒 Em breve |
| 07 | Junções (JOINs), Subconsultas e Visões | INNER JOIN, LEFT JOIN, RIGHT JOIN; Subqueries; Criação e uso de VIEW | 🔒 Em breve |
| 08 | Integridade Referencial e Restrições | FOREIGN KEY com ON DELETE/UPDATE CASCADE e RESTRICT; CHECK; Índices básicos | 🔒 Em breve |
| 09 | Stored Procedures | Lógica procedural; PROCEDURE com parâmetros IN/OUT; Tratamento de erros | 🔒 Em breve |
| 10 | Triggers (Gatilhos) | Gatilhos BEFORE/AFTER (ROW e STATEMENT); Auditoria de dados; Boas práticas | 🔒 Em breve |
| 11 | Functions (UDF) e Transações | UDFs escalares e de tabela; diferença entre FUNCTION e PROCEDURE; ACID; BEGIN, COMMIT, ROLLBACK; Controle de concorrência | 🔒 Em breve |
| 12 | Backup, Restauração e Segurança | Backup completo, incremental e diferencial; DUMP e restauração; CREATE USER, GRANT, REVOKE | 🔒 Em breve |
| 13 | Otimização de Consultas e Índices | Estruturas B-Tree e Hash; EXPLAIN / EXPLAIN ANALYZE; Otimização de JOINs e subconsultas | 🔒 Em breve |
| 14 | Revisão Geral | Consolidação de todos os tópicos; Exercícios integradores | 🔒 Em breve |
| 15 | Novas Tecnologias em BD e Encerramento | NewSQL, DBaaS, Big Data, introdução a BD Não Relacional; Fechamento e portfólio | 🔒 Em breve |

---

## 📝 Atividades e Avaliações

!!! tip "Lista completa e sempre atualizada"
    Todas as atividades práticas e avaliações da disciplina — enunciados, prazos e links — estão centralizados em uma página própria.

    <div align="center" markdown>
    [:material-clipboard-text-clock: Acessar Atividades e Avaliações](atividades/index.md){ .md-button .md-button--primary }
    </div>

---

## 📖 Bibliografia

### Básica

- DATE, C. J. *Introdução a sistemas de bancos de dados*. Rio de Janeiro: Elsevier/Campus, 2004.
- ELMASRI, R.; NAVATHE, S. B. *Sistemas de Banco de Dados*. 7 ed. São Paulo: Pearson, 2018.
- SILBERSCHATZ, A.; SUNDARSHAN, S.; KORTH, H. F. *Sistema de banco de dados*. Rio de Janeiro: Elsevier Brasil, 2016.

### Complementar

- BEAULIEU, A. *Aprendendo SQL*. São Paulo: Novatec, 2010.
- GILLENSON, M. L. *Fundamentos de Sistemas de Gerência de Banco de Dados*. Rio de Janeiro: LTC, 2006.
- MACHADO, F. N. R. *Banco de Dados: Projeto e Implementação*. São Paulo: Érica, 2005.
- RAMAKRISHNAN, R.; GEHRKE, J. *Sistemas de Gerenciamento de Bancos de Dados*. 3 ed. Porto Alegre: Bookman, 2008.
- ROB, P.; CORONEL, C. *Sistemas de Banco de Dados: Projeto, Implementação e Gerenciamento*. 8 ed. São Paulo: Cengage Learning, 2011.
- TEOREY, T.; LIGHTSTONE, S.; NADEAU, T. *Projeto e Modelagem de Bancos de Dados*. São Paulo: Campus, 2006.

### Referência

- DEBARROS, A. *SQL Prático: um guia para iniciantes*. 2 ed. São Paulo: Novatec, 2022.
- TANIMURA, C. *SQL para Análise de Dados: técnicas avançadas para transformar dados em insights*. São Paulo: Novatec, 2022.
- FORTA, B. *SQL em 10 Minutos por Dia*. 5 ed. São Paulo: Novatec, 2021.

---

## 💬 Contato

📧 [ronan.zenatti@cps.sp.gov.br](mailto:ronan.zenatti@cps.sp.gov.br)

> *"Dados bem modelados são a fundação de qualquer sistema confiável."*

---

<div align="center">
<sub>Fatec Jahu · Centro Paula Souza · Governo do Estado de São Paulo · 2026</sub>
</div>
