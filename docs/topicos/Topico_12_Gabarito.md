<!--
GABARITO — não faz parte do fluxo principal do tópico e fica fora do `nav` do
mkdocs.yml de propósito. É acessível só pelo link no final de
Topico_12_Backup_Seguranca.md.
-->

# Gabarito — Tópico 12 — Backup, Restauração e Segurança

**Disciplina:** Banco de Dados — Relacional (IBD015)
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br
**Fatec Jahu — 2º Semestre/2026**

> ⚠️ Este gabarito é para conferência **depois** de você tentar resolver os checkpoints
> e os Exercícios de Fixação por conta própria no [Tópico 12](Topico_12_Backup_Seguranca.md).
> Resolver antes de tentar reduz o benefício de treinar a recuperação ativa do
> conteúdo.

---

## Checkpoint 1 — Definindo a estratégia: telemedicina {: #checkpoint-1 }

**(a) Estratégia proposta** (uma de várias possíveis; o que importa é cobrir RPO e RTO):

| Camada | Frequência | Função |
|---|---|---|
| **Log binário** ligado e copiado para fora do servidor | Contínuo; a cópia dos arquivos a cada 5–10 min | Garante o **RPO de 15 min** e permite recuperar até um instante (PITR) |
| **Backup físico completo** (`mariabackup`) | Semanal (ex.: domingo 02h — roda a quente, em ~3 h) | Base de toda restauração |
| **Backup físico diferencial** (`mariabackup --incremental-basedir=<completo>`) | Diário | Reduz a restauração a **2 passos** (completo + último diferencial) e o log binário |
| **Dump lógico** (`mysqldump`) | Semanal (ou mensal) | Portabilidade e recuperação de **uma tabela** específica |
| **Cópia externa e criptografada** de tudo | A cada backup | Regra 3-2-1 |

**(b) Incremental × diferencial.** Para este caso o **diferencial** é preferível: com 5% de
alteração diária (~10 GB/dia), o incremental seria pequeno, mas a restauração na pior hora
(sábado) exigiria o completo + até **6** incrementais em sequência — mais tempo e uma cadeia
frágil (um arquivo corrompido invalida os seguintes). O diferencial cresce ao longo da semana
(no máximo algumas dezenas de GB), mas a restauração é sempre "completo + 1 diferencial + log
binário", o que ajuda a cumprir o **RTO de 2 h**. O custo extra de armazenamento é aceitável.

**(c) Confiança no RTO.** Fazendo um **ensaio de restauração** completo, periodicamente (por
exemplo, a cada trimestre), em um servidor separado: restaurar o completo, aplicar o
diferencial, reaplicar o log binário, validar contagens e **cronometrar cada etapa**. O tempo
total medido é o RTO real; se passar de 2 h, é preciso ajustar (discos mais rápidos,
mais frequência de completos, réplica pronta para assumir, etc.). O ensaio também valida
que os arquivos não estão corrompidos e que a equipe conhece o procedimento.

**(d) Falhas de "um `mysqldump` por noite, no próprio servidor":** (1) **RPO de 24 h**, 96
vezes pior que o exigido; (2) a restauração de um dump de 200 GB reexecuta todos os
`INSERT`s e reconstrói os índices — facilmente **muito mais que 2 h** (viola o RTO); (3) o
backup fica no **mesmo servidor** — a falha de disco, o ransomware ou o incêndio levam banco e
backup juntos (fere a regra 3-2-1); (4) não há log binário nem PITR; (5) arquivo em texto
puro com **dados de saúde** (sensíveis, pela LGPD) sem criptografia; (6) sem teste de
restauração, não se sabe se o backup funciona.

---

## Checkpoint 2 — Montando os comandos: monitoramento de energia solar {: #checkpoint-2 }

**Respostas (PowerShell, com o XAMPP em `C:\xampp`):**

```powershell
$mysqldump = "C:\xampp\mysql\bin\mysqldump.exe"
$mysql     = "C:\xampp\mysql\bin\mysql.exe"

# (a) Backup completo e consistente, com rotinas, gatilhos e eventos
& $mysqldump -u root -p --default-character-set=utf8mb4 --single-transaction `
    --routines --triggers --events --databases energia_solar `
    --result-file="C:\backup\energia_solar.sql"

# (b) Somente a estrutura
& $mysqldump -u root -p --no-data --databases energia_solar --result-file="C:\backup\energia_solar_estrutura.sql"

# (c) Somente os dados de duas tabelas
& $mysqldump -u root -p --no-create-info energia_solar inversores leituras_inversores `
    --result-file="C:\backup\energia_solar_dados.sql"

# (d) Restaurar em um banco de teste — veja a observação abaixo antes de executar!
& $mysql -u root -p -e "CREATE DATABASE energia_solar_teste CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
& $mysqldump -u root -p --single-transaction --routines --triggers energia_solar --result-file="C:\backup\energia_solar_sem_db.sql"
& $mysql -u root -p energia_solar_teste -e "source C:/backup/energia_solar_sem_db.sql"
```

**Observação sobre (d):** o arquivo do item (a) foi gerado com `--databases`, portanto contém
`CREATE DATABASE energia_solar` e `USE energia_solar`. Restaurá-lo reescreveria o banco **real**,
não um banco de teste. Por isso a restauração em outro nome usa um dump gerado **sem**
`--databases` (a terceira linha de comando), que não menciona o nome do banco e é aplicado no
banco que você escolher.

**(e) Conferência:**

```sql
SHOW TABLES FROM energia_solar_teste;                               -- mesmas tabelas do original?
SHOW PROCEDURE STATUS WHERE Db = 'energia_solar_teste';             -- rotinas restauradas?

SELECT 'original' AS origem, COUNT(*) AS leituras FROM energia_solar.leituras_inversores
UNION ALL
SELECT 'copia',              COUNT(*)            FROM energia_solar_teste.leituras_inversores;
```

Contagens iguais (e as rotinas listadas) indicam que a restauração funcionou. Em um ensaio
mais rigoroso, compare também somas de colunas numéricas (`SUM(kwh_gerado)`) e a presença dos
gatilhos (`SHOW TRIGGERS FROM energia_solar_teste`).

---

## Checkpoint 3 — Recuperação até um ponto no tempo: gig economy {: #checkpoint-3 }

**Passos, em ordem:**

1. **Conter o dano:** tirar a aplicação do ar (ou colocá-la em modo somente leitura) para que
   nenhuma nova escrita misture dados novos com a recuperação.
2. **Preservar as evidências:** **copiar os arquivos de log binário** (`mysql-bin.000014` e
   os seguintes) para uma pasta segura **antes de qualquer outra ação**. Eles contêm tudo o
   que aconteceu desde as 03h, inclusive o `DELETE`.
3. **Achar o ponto do erro:**
   ```powershell
   & "C:\xampp\mysql\bin\mysqlbinlog.exe" --database=entregas_db --start-position=120 `
       "C:\xampp\mysql\data\mysql-bin.000014" "C:\xampp\mysql\data\mysql-bin.000015" |
       Select-String -Pattern "DELETE FROM entregas" -Context 6,0
   ```
   A linha `#AAMMDD hh:mm:ss ... end_log_pos N` que antecede o comando informa o instante e a posição
   do `DELETE` (por exemplo, 15:07:12).
4. **Restaurar o último backup completo** (das 03h) — idealmente em um servidor de recuperação,
   para validar antes de trocar; se for no próprio servidor, só depois de preservar os logs:
   ```powershell
   & "C:\xampp\mysql\bin\mysql.exe" -u root -p -e "source C:/backup/entregas_db_0300.sql"
   ```
5. **Reaplicar o log binário até logo antes do erro.** `--start-position=120` vale para o
   **primeiro** arquivo listado; os seguintes são lidos do início:
   ```powershell
   & "C:\xampp\mysql\bin\mysqlbinlog.exe" --database=entregas_db --start-position=120 `
       --stop-datetime="2026-10-23 15:07:12" `
       "C:\xampp\mysql\data\mysql-bin.000014" "C:\xampp\mysql\data\mysql-bin.000015" `
       --result-file="C:\backup\replay_ate_antes_do_erro.sql"
   & "C:\xampp\mysql\bin\mysql.exe" -u root -p -e "source C:/backup/replay_ate_antes_do_erro.sql"
   ```
   (Se vários comandos ocorreram no mesmo segundo do erro, use `--stop-position=<end_log_pos do
   comando imediatamente anterior ao DELETE>`, que é exato.)
6. **Recuperar o que aconteceu depois do erro, se for legítimo:** se a aplicação continuou
   recebendo entregas entre 15:07 e o momento em que foi desligada, reaplique esse trecho do
   log **pulando o `DELETE`**: um segundo `mysqlbinlog` com `--start-position=<posição logo
   depois do DELETE>`.
7. **Validar** (contagem de `entregas` coerente com o esperado, amostra de entregas da
   manhã) e só então religar a aplicação.
8. **Fechar o ciclo:** novo backup completo; revisar a causa (acesso de escrita em produção
   por um desenvolvedor, falta de `sql_safe_updates`...) e aplicar **menor privilégio**.

**Por que restaurar só o backup das 03h seria insuficiente:** o banco voltaria ao estado das
03h e **todas as entregas registradas entre 03h e 15h07** (12 horas de operação) seriam
perdidas. O log binário é o que preenche essa lacuna.

---

## Checkpoint 4 — Perfis de acesso: app de saúde digital {: #checkpoint-4 }

**Resposta:**

```sql
-- (a) A aplicação: lê e escreve nos dados, sem poder alterar a estrutura
CREATE USER 'app_saude'@'localhost' IDENTIFIED BY 'Senha#Forte#App1';
GRANT SELECT, INSERT, UPDATE, DELETE ON saude_digital.pacientes   TO 'app_saude'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON saude_digital.consultas   TO 'app_saude'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON saude_digital.prescricoes TO 'app_saude'@'localhost';

-- (b) O pesquisador: consultas e prescrições, e só colunas não identificáveis de pacientes
CREATE USER 'pesquisador'@'localhost' IDENTIFIED BY 'Senha#Forte#Pesq2';
GRANT SELECT (id_paciente, data_nascimento) ON saude_digital.pacientes TO 'pesquisador'@'localhost';
GRANT SELECT ON saude_digital.consultas   TO 'pesquisador'@'localhost';
GRANT SELECT ON saude_digital.prescricoes TO 'pesquisador'@'localhost';   -- se a pesquisa precisar

-- (c) O auditor: somente leitura nas três tabelas
CREATE USER 'auditor'@'localhost' IDENTIFIED BY 'Senha#Forte#Aud3';
GRANT SELECT ON saude_digital.pacientes   TO 'auditor'@'localhost';
GRANT SELECT ON saude_digital.consultas   TO 'auditor'@'localhost';
GRANT SELECT ON saude_digital.prescricoes TO 'auditor'@'localhost';
```

(Liste em `GRANT SELECT (...)` apenas as colunas realmente necessárias à pesquisa; `id_paciente` e
`data_nascimento` são exemplos. Não conceda `GRANT OPTION` a ninguém, e confira tudo com
`SHOW GRANTS FOR ...`.)

**Um comando que cada conta não deve conseguir e o erro esperado:**

| Conta | Comando | Erro |
|---|---|---|
| `app_saude` | `ALTER TABLE saude_digital.pacientes ADD COLUMN x INT;` ou `DROP TABLE ...` | `ERROR 1142: ALTER (ou DROP) command denied to user 'app_saude'@'localhost' for table ...` |
| `pesquisador` | `SELECT cpf FROM saude_digital.pacientes;` (ou `SELECT *`, que inclui `cpf`) | `ERROR 1143: SELECT command denied to user 'pesquisador'@'localhost' for column 'cpf' in table 'pacientes'` |
| `auditor` | `INSERT INTO saude_digital.consultas ...;` ou `DELETE FROM ...` | `ERROR 1142: INSERT command denied to user 'auditor'@'localhost' for table ...` |

---

## Checkpoint 5 — Roles: rede de hospitais {: #checkpoint-5 }

**Resposta:**

```sql
-- Papéis e privilégios (definidos uma única vez)
CREATE ROLE recepcao;
GRANT SELECT                 ON clinica.pacientes    TO recepcao;
GRANT SELECT, INSERT, UPDATE ON clinica.agendamentos TO recepcao;

CREATE ROLE medico;
GRANT recepcao TO medico;                                   -- herda tudo o que a recepção faz
GRANT SELECT, INSERT ON clinica.prontuarios TO medico;      -- e ganha acesso a prontuários

CREATE ROLE ti_suporte;
GRANT SELECT ON clinica.* TO ti_suporte;

-- Usuário com o papel já ativo no login
CREATE USER 'ana_recepcao'@'localhost' IDENTIFIED BY 'Senha#Forte#Ana1';
GRANT recepcao TO 'ana_recepcao'@'localhost';
SET DEFAULT ROLE recepcao FOR 'ana_recepcao'@'localhost';

-- Remover só o direito de atualizar, mantendo os demais
REVOKE UPDATE ON clinica.agendamentos FROM recepcao;
SHOW GRANTS FOR recepcao;
```

**Reaproveitamento:** uma role pode ser concedida a **outra role** (`GRANT recepcao TO medico`).
Quem tem o papel `medico` ativo recebe os privilégios de `medico` **mais** os de `recepcao` —
sem repetir um único `GRANT`. Mais: o `REVOKE UPDATE` aplicado a `recepcao` vale
automaticamente para todos que a herdam (`ana_recepcao`, o `medico`...). No teste, a
`ana_recepcao` passou a receber `UPDATE command denied` em `agendamentos`, ainda podia
inserir, e levava `SELECT command denied` em `prontuarios`; um usuário com `medico` ativo lia
`pacientes` (herdado) e inseria em `prontuarios`.

---

## Checkpoint 6 — Injeção de SQL: app de delivery {: #checkpoint-6 }

**(a) Entrada maliciosa.** No campo e-mail: `joao@email.com' -- ` (com um espaço depois dos
dois hífens). O comando que o banco recebe:

```sql
SELECT id_cliente FROM clientes WHERE email = 'joao@email.com' -- ' AND senha_hash = '...'
```

O `-- ` inicia um comentário e **anula a verificação da senha**: o login passa como o cliente
`joao@email.com` sabendo apenas o e-mail. (Outra entrada clássica: `' OR 1=1 -- `, que casa com a
primeira linha da tabela, geralmente um administrador.) No teste da disciplina, o mesmo padrão
aplicado em `pessoas` devolveu a linha da Ana mesmo com um "CPF" errado.

**(b) Versão segura (consulta parametrizada):**

```sql
PREPARE login FROM 'SELECT id_cliente, senha_hash FROM clientes WHERE email = ?';
SET @email = 'joao@email.com'' -- ';          -- (a entrada hostil é só um texto de e-mail)
EXECUTE login USING @email;                    -- 0 linhas: nenhum cliente tem esse e-mail
DEALLOCATE PREPARE login;
```

Na aplicação, o equivalente é `execute("SELECT ... WHERE email = ?", [email])`. Há ainda um
detalhe de projeto: como `senha_hash` é um *hash com sal* (bcrypt/Argon2), ele **não pode ser
comparado por igualdade no SQL**. O correto é buscar o hash pelo **e-mail** (consulta acima) e
verificar a senha digitada **na aplicação** (`bcrypt.verify(senha, senha_hash)`). A senha
nunca entra em um `WHERE`.

**(c) Duas medidas de redução de dano:** (1) **menor privilégio** na conta da aplicação —
sem `DROP`, `ALTER`, `FILE` nem acesso ao schema `mysql`, a injeção não consegue apagar tabelas
nem ler arquivos do servidor; (2) **não exibir mensagens de erro do banco** ao usuário (elas
revelam nomes de tabelas e colunas). Também valem: validar tipo/tamanho/formato das entradas,
limitar tentativas de login (anti-força-bruta) e separar contas para leitura e para escrita.

---

## Exercícios de Fixação (Seção 10)

### Exercício 1 — Backup com data no nome e verificação

```powershell
New-Item -ItemType Directory -Force C:\backup | Out-Null
$data    = Get-Date -Format "yyyy-MM-dd"
$arquivo = "C:\backup\loja_virtual_$data.sql"

& "C:\xampp\mysql\bin\mysqldump.exe" -u root -p --default-character-set=utf8mb4 `
    --single-transaction --routines --triggers --events `
    --databases loja_virtual --result-file=$arquivo

# Verificação
Get-Item $arquivo | Select-Object Name, Length                     # tamanho > 0 e coerente
Get-Content $arquivo -Tail 2                                        # "-- Dump completed on ..."
(Select-String -Path $arquivo -Pattern "CREATE TABLE").Count        # 7
Select-String -Path $arquivo -Pattern "PROCEDURE|FUNCTION|TRIGGER" | Select-Object -First 5
```

Se as rotinas e gatilhos que você criou nos Tópicos 09 a 11 não aparecerem, o usuário do
backup provavelmente não tem permissão de lê-los (Seção 3.2 do tópico).

### Exercício 2 — Restaurar em `loja_virtual_teste` e comparar

```powershell
& "C:\xampp\mysql\bin\mysqldump.exe" -u root -p --single-transaction --routines --triggers loja_virtual --result-file="C:\backup\loja_sem_db.sql"
& "C:\xampp\mysql\bin\mysql.exe" -u root -p -e "CREATE DATABASE loja_virtual_teste CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
& "C:\xampp\mysql\bin\mysql.exe" -u root -p loja_virtual_teste -e "source C:/backup/loja_sem_db.sql"
```

```sql
SELECT 'pessoas' AS tabela,
       (SELECT COUNT(*) FROM loja_virtual.pessoas)       AS original,
       (SELECT COUNT(*) FROM loja_virtual_teste.pessoas) AS copia
UNION ALL SELECT 'enderecos',     (SELECT COUNT(*) FROM loja_virtual.enderecos),     (SELECT COUNT(*) FROM loja_virtual_teste.enderecos)
UNION ALL SELECT 'categorias',    (SELECT COUNT(*) FROM loja_virtual.categorias),    (SELECT COUNT(*) FROM loja_virtual_teste.categorias)
UNION ALL SELECT 'produtos',      (SELECT COUNT(*) FROM loja_virtual.produtos),      (SELECT COUNT(*) FROM loja_virtual_teste.produtos)
UNION ALL SELECT 'pedidos',       (SELECT COUNT(*) FROM loja_virtual.pedidos),       (SELECT COUNT(*) FROM loja_virtual_teste.pedidos)
UNION ALL SELECT 'itens_pedidos', (SELECT COUNT(*) FROM loja_virtual.itens_pedidos), (SELECT COUNT(*) FROM loja_virtual_teste.itens_pedidos)
UNION ALL SELECT 'vendas',        (SELECT COUNT(*) FROM loja_virtual.vendas),        (SELECT COUNT(*) FROM loja_virtual_teste.vendas);
```

Use `COUNT(*)` exato. A coluna `table_rows` de `information_schema.tables` é apenas uma
**estimativa** no InnoDB e pode divergir mesmo com os dados idênticos.

### Exercício 3 — Usuário `app_loja` e as negativas

```sql
CREATE USER 'app_loja'@'localhost' IDENTIFIED BY 'Troque#Esta123';
GRANT SELECT, INSERT, UPDATE, DELETE ON loja_virtual.* TO 'app_loja'@'localhost';
```

```powershell
& "C:\xampp\mysql\bin\mysql.exe" -u app_loja -p -e "DROP TABLE loja_virtual.pedidos"
#   ERROR 1142 (42000): DROP command denied to user 'app_loja'@'localhost' for table `loja_virtual`.`pedidos`
& "C:\xampp\mysql\bin\mysql.exe" -u app_loja -p -e "CREATE TABLE loja_virtual.x (id INT)"
#   ERROR 1142 (42000): CREATE command denied to user 'app_loja'@'localhost' for table `loja_virtual`.`x`
& "C:\xampp\mysql\bin\mysql.exe" -u app_loja -p -e "SELECT user FROM mysql.user"
#   ERROR 1142 (42000): SELECT command denied to user 'app_loja'@'localhost' for table `mysql`.`user`
```

(Cada comando foi executado em uma chamada separada — assim um erro não impede que o
próximo seja testado.)

### Exercício 4 — Privilégios por coluna × visão

```sql
-- Forma 1: privilégio por coluna
CREATE USER 'analista'@'localhost' IDENTIFIED BY 'Analista#456';
GRANT SELECT (id_pessoa, nome, email, data_nascimento) ON loja_virtual.pessoas TO 'analista'@'localhost';
GRANT SELECT ON loja_virtual.pedidos       TO 'analista'@'localhost';
GRANT SELECT ON loja_virtual.itens_pedidos TO 'analista'@'localhost';
```

```text
SELECT nome, email FROM loja_virtual.pessoas;     -- OK
SELECT * FROM loja_virtual.pessoas;               -- ERROR 1143: SELECT command denied ... for column 'cpf' in table 'pessoas'
```

O `SELECT *` falha porque inclui `cpf` e `telefone` — o analista precisa listar as colunas.

```sql
-- Forma 2: uma visão que já contém só as colunas liberadas
CREATE VIEW vw_pessoas_publico AS
SELECT id_pessoa, nome, email, data_nascimento FROM pessoas;

CREATE USER 'analista2'@'localhost' IDENTIFIED BY 'Analista2#456';
GRANT SELECT ON loja_virtual.vw_pessoas_publico TO 'analista2'@'localhost';
```

Com a visão, `SELECT * FROM loja_virtual.vw_pessoas_publico` **funciona** (a visão não tem as
colunas sensíveis), e a tabela `pessoas` continua inacessível para `analista2`. A visão é
mais prática para quem consulta e centraliza a regra "quais colunas são públicas"; o
privilégio por coluna é mais direto quando só uma ou duas colunas precisam ser escondidas.

### Exercício 5 — Plano de backup do Projeto Integrador (exemplo)

> **O quê:** o banco do PI (esquema + dados + procedures, funções e gatilhos).
> **Tipo e frequência:** `mysqldump` lógico completo (`--single-transaction --routines --triggers --events`) **diariamente às 23h** e **antes de cada entrega/apresentação**; scripts `.sql` de criação (DDL) versionados no repositório Git (sem dados reais).
> **Onde:** (1) cópia local em `C:\backup`; (2) cópia em outro disco/pendrive; (3) cópia em nuvem (Drive/OneDrive) — **criptografada/compactada com senha**, sem CPFs reais (regra 3-2-1).
> **Retenção:** 7 diários, 4 semanais e 3 mensais; o restante é apagado.
> **Acesso:** apenas a equipe do projeto; as senhas ficam fora do repositório.
> **Teste:** a cada duas semanas, restaurar o último dump em `pi_teste`, comparar contagens e rodar 3 consultas de conferência; registrar o tempo gasto.
> **Automação:** script `.ps1` agendado no Agendador de Tarefas do Windows.

---

⬅️ [Voltar ao Tópico 12 — Backup, Restauração e Segurança](./Topico_12_Backup_Seguranca.md)

---

*Fatec Jahu · IBD015 · Prof. Ronan Adriel Zenatti · 2026*
