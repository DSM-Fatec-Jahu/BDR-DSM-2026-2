<!--
GABARITO — não faz parte do fluxo principal do tópico e fica fora do `nav` do
mkdocs.yml de propósito. É acessível só pelo link no final de
Topico_15_Novas_Tecnologias_Encerramento.md.
-->

# Gabarito — Tópico 15 — Novas Tecnologias em BD e Encerramento

**Disciplina:** Banco de Dados — Relacional (IBD015)
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br
**Fatec Jahu — 2º Semestre/2026**

> ⚠️ Este gabarito é para conferência **depois** de você tentar resolver os checkpoints
> e os Exercícios de Fixação por conta própria no [Tópico 15](Topico_15_Novas_Tecnologias_Encerramento.md).
> Resolver antes de tentar reduz o benefício de treinar a recuperação ativa do
> conteúdo.

---

## Checkpoint 1 — Relacional × documento: marketplace de criadores {: #checkpoint-1 }

**(a) Tabela com colunas fixas + coluna JSON:**

```sql
CREATE TABLE produtos_digitais (
    id_produto_digital  BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    tipo                ENUM('curso', 'ebook', 'preset') NOT NULL,
    titulo              VARCHAR(255)     NOT NULL,
    preco               DECIMAL(10, 2)   NOT NULL,
    atributos           JSON             NOT NULL,
    criado_em           DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alterado_em         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deletado_em         DATETIME             NULL,

    CONSTRAINT pk_produto_digital       PRIMARY KEY (id_produto_digital),
    CONSTRAINT ck_produto_digital_preco CHECK (preco >= 0)
);

INSERT INTO produtos_digitais (tipo, titulo, preco, atributos) VALUES
    ('curso', 'SQL na Prática',        199.90, '{"carga_horaria": 32, "modulos": ["Modelagem", "Consultas", "Índices"]}'),
    ('ebook', 'Guia de Normalização',   39.90, '{"paginas": 120, "formato": "PDF"}');
```

O que é comum a todos os produtos (título, preço, tipo) fica em **colunas normais** — com tipo,
`NOT NULL`, `CHECK` e possibilidade de índice. Só o que realmente varia por tipo vai para o JSON.

**(b) Consulta:**

```sql
SELECT titulo,
       JSON_VALUE(atributos, '$.carga_horaria') AS carga_horaria
FROM   produtos_digitais
WHERE  tipo = 'curso'
  AND  CAST(JSON_VALUE(atributos, '$.carga_horaria') AS UNSIGNED) > 20;
```

`JSON_VALUE` devolve **texto**; por isso a conversão com `CAST` antes de comparar numericamente
(sem ela, `'32' > 20` funcionaria por conversão implícita, mas `'9' > '20'` como texto daria o resultado
errado). Filtrar antes por `tipo = 'curso'` reduz o trabalho — e evita avaliar o JSON em e-books.

**(c) Desvantagens:** (1) o banco **não valida** o conteúdo do JSON além de ser JSON válido — nada impede
`carga_horaria` de ser texto, negativa ou de faltar (as `CHECK`, `NOT NULL` e os tipos das colunas normais
desaparecem para esses campos); (2) consultas e índices sobre campos dentro do JSON são mais
trabalhosos e mais lentos (é preciso extrair o valor, converter tipos e criar colunas virtuais para
indexar), e estatísticas/relatórios ficam mais difíceis. Além disso, o JSON não permite `FOREIGN KEY`
para valores dentro dele.

**Quando preferir tabelas separadas por tipo (ou colunas):** quando os atributos são **estáveis, conhecidos e
consultados o tempo todo** (por exemplo, `carga_horaria` usado em filtros e relatórios diários), quando
precisam de integridade (FK, `CHECK`) ou quando a quantidade de tipos é pequena. O JSON compensa quando o conjunto de atributos é
realmente variável e pouco consultado individualmente.

---

## Checkpoint 2 — Escolhendo a tecnologia: aplicativo de mobilidade urbana {: #checkpoint-2 }

| Item | Tecnologia | Justificativa | ACID essencial? |
|---|---|---|---|
| **(a)** Usuários, viagens e cobrança | **Relacional** (MariaDB/PostgreSQL) | Dinheiro, estornos e integridade entre entidades (FK, transações); consultas ad hoc e relatórios | **Sim** |
| **(b)** GPS de 50 mil veículos a cada 2 s, por 30 dias | **Série temporal / colunar** (TimescaleDB, InfluxDB, Cassandra) | ~25 mil escritas/s, quase sem atualização e sem junções; consultas por intervalo de tempo; expiração dos dados antigos por política de retenção | Não |
| **(c)** Tokens de sessão (24 h) | **Chave-valor** (Redis) | Acesso exato por chave, latência mínima e **expiração automática** (`EX`) | Não |
| **(d)** "Amigos que andaram juntos" | **Grafo** (Neo4j) | Relacionamentos são o dado: "amigos de amigos" vira uma travessia, enquanto em SQL exigiria auto-`JOIN`s sucessivos | Não (em geral) |
| **(e)** Busca textual de endereços | **Motor de busca** (Elasticsearch/OpenSearch) | Texto livre com relevância, tolerância a erros de digitação e filtros | Não |
| **(f)** Painel de receita de 3 anos por cidade e semana | **Data warehouse colunar** (BigQuery, ClickHouse...) alimentado por ETL do relacional | Análise (OLAP) de grande histórico; não deve competir com a carga transacional (OLTP) do item (a) | Não |

O sistema como um todo é **poliglota**. Observe que o **único** item em que o ACID é essencial (a cobrança)
fica no banco relacional, a fonte da verdade; os demais podem usar modelos mais frouxos. Para um aplicativo
que ainda está começando, a prudência é manter (a) no relacional e **só acrescentar** as outras peças
quando uma necessidade medida (volume de GPS, latência de sessão, qualidade da busca) as justificar —
no início, JSON/colunas e índices no próprio relacional costumam bastar.

---

## Checkpoint 3 — Um README que vende o projeto {: #checkpoint-3 }

**Exemplo de esqueleto** (adapte ao seu projeto):

```markdown
# Voltaja — Banco de Dados da Rede de Eletropostos

Banco relacional que controla clientes, veículos, carregadores e recargas de uma rede de eletropostos.

## O problema que resolve
Uma rede de carregadores de veículos elétricos registrava tudo em uma planilha: dados repetidos,
cobranças inconsistentes e impossibilidade de saber a receita por posto. Este banco normaliza os dados,
automatiza o cálculo da cobrança e protege o acesso a informações pessoais.

## Tecnologias
MariaDB 10.4 (XAMPP) · SQL · dbdiagram.io (diagramas) · PowerShell (backup)

## Como executar
1. Inicie o MySQL pelo painel do XAMPP.
2. `mysql -u root -p < sql/01_criar_banco.sql`
3. `mysql -u root -p eletropostos < sql/02_carga_dados.sql`
4. Rode `sql/03_consultas.sql`, `04_programacao.sql`, `05_seguranca.sql` e `06_desempenho.sql`, nessa ordem.

## Modelo
Entidades: clientes, veículos, eletropostos, carregadores e recargas. Cardinalidades: cliente 1:N veículo;
eletroposto 1:N carregador; veículo N:M carregador (resolvido pela tabela associativa `recargas`).
![Modelo lógico](docs/modelo_logico.png)

## Consultas de negócio que o banco responde
1. Receita e kWh por eletroposto em um mês
2. Clientes que nunca recarregaram
3. Os 3 veículos que mais consumiram
4. Recargas acima do consumo médio
5. Histórico de recargas de um cliente (via view, sem expor o CPF)

## Decisões de projeto
- **Modelagem:** 3FN — os dados do cliente, do veículo e do posto deixaram de se repetir a cada recarga.
- **Integridade/segurança:** FKs com `RESTRICT` (histórico financeiro não pode perder a origem) e privilégio por coluna para que
  o analista não enxergue o CPF.
- **Desempenho:** índice composto `(veiculo_id, status, iniciada_em)` em recargas — o `EXPLAIN` passou de `ALL` (~100 mil linhas)
  para `ref` (5 linhas), sem `filesort`.
```

O que torna esse README bom: abre com o **problema** (não com a tecnologia), permite **reproduzir** o projeto em quatro comandos,
mostra o modelo, lista perguntas de negócio concretas e justifica as decisões **com evidência** (o `EXPLAIN`). Dados fictícios,
sem senhas, sem backups reais no repositório.

---

## Exercícios de Fixação (Seção 8)

### Exercício 1 — CP × AP

Um banco prioriza **consistência** (CP): se não for possível garantir que todos os nós concordam sobre o saldo (por
exemplo, durante uma falha de rede), é preferível **recusar ou atrasar** a operação do que mostrar/permitir um saldo errado — um
saque duplicado custa dinheiro real. Uma rede social, para o **contador de curtidas**, prioriza **disponibilidade** (AP): o
aplicativo precisa continuar respondendo, e mostrar 1.203 curtidas em vez de 1.205 por alguns segundos não prejudica ninguém. **Consistência
eventual** significa que, sem novas escritas, todas as réplicas acabam convergindo para o mesmo valor; para o usuário, aparece
como um número que pode estar levemente defasado, ou como curtir em um aparelho e demorar um instante a aparecer em outro.

### Exercício 2 — Pedido nº 1 como documento

```json
{
  "id_pedido": 1,
  "cliente": { "id_pessoa": 1, "nome": "Ana Lima" },
  "status": "confirmado",
  "data_pedido": "2026-02-10T10:15:00",
  "itens": [
    { "id_produto": 1, "produto": "Notebook Lenovo IdeaPad",  "quantidade": 1, "preco_unitario": 3499.90, "desconto": 0 },
    { "id_produto": 3, "produto": "Mouse Logitech MX Master", "quantidade": 1, "preco_unitario": 399.90,  "desconto": 0 }
  ],
  "valor_total": 3899.80
}
```

**Vantagens:** (1) ler o pedido completo é **uma só leitura**, sem `JOIN`; (2) o documento é o *retrato* do pedido no momento da compra
(nome do produto e preço congelados — o que o `preco_unitario` já faz no relacional); (3) esquema flexível para campos que só
alguns pedidos têm (cupom, observações de entrega).
**Desvantagens:** (1) o nome do cliente/produto fica **copiado** em muitos documentos — corrigir exige atualizar todos
(redundância, anomalias de atualização); (2) consultas **transversais** ("quantas unidades do produto 3 foram vendidas?")
exigem varrer ou indexar o interior dos documentos, e a integridade (produto existente, cliente existente) deixa de ser garantida por
`FOREIGN KEY`.

### Exercício 3 — Consultas JSON

```sql
-- (a) Nome do segundo item dos pedidos que têm mais de um item
SELECT id_pedido,
       JSON_VALUE(documento, '$.itens[1].produto') AS segundo_item
FROM   pedidos_documento
WHERE  JSON_LENGTH(documento, '$.itens') > 1;

-- (b) Cancelar os pedidos pendentes do cliente 2
UPDATE pedidos_documento
SET    documento = JSON_SET(documento, '$.status', 'cancelado')
WHERE  JSON_VALUE(documento, '$.cliente.id') = '2'
  AND  JSON_VALUE(documento, '$.status') = 'pendente';
```

`JSON_VALUE` sempre devolve texto, por isso comparar com `'2'` (ou converter com `CAST`). O caminho `$.itens[1]` usa índice base zero
(`[0]` é o primeiro item). O `JSON_SET` altera apenas o campo informado, preservando o restante do documento.

### Exercício 4 — Sistema real e tecnologias (exemplo: plataforma de streaming de música)

| Dado | Tecnologia | Justificativa |
|---|---|---|
| Assinantes, planos e cobranças | **Relacional** (ACID) | Dinheiro e cadastro: integridade e transações |
| Catálogo de músicas, artistas e álbuns | **Relacional**, ou **documentos** se os metadados variarem muito | Relacionamentos claros (artista–álbum–faixa); JSON para metadados extras |
| Sessão do usuário e "tocando agora" | **Chave-valor** (Redis) | Acesso por chave, latência mínima, expiração |
| Histórico de reproduções (bilhões de eventos) | **Colunar/série temporal** + data lake | Escrita massiva, sem atualização, consultas por período |
| "Quem ouviu o quê / playlists parecidas" | **Grafo** ou busca **vetorial** (embeddings) | Recomendação por similaridade e relacionamentos |
| Busca por nome de música/artista | **Motor de busca** | Texto livre, tolerância a erros |
| Painéis de negócio (reproduções por país/mês) | **Data warehouse** colunar | Análise do histórico (OLAP), isolada do sistema transacional |

Qualquer sistema bem escolhido pela sua área de interesse serve — o que se avalia é a **justificativa**: o requisito dominante de
cada tipo de dado (correção, latência, volume, relacionamento, busca, análise) e o cuidado de manter a fonte da verdade no relacional.

---

⬅️ [Voltar ao Tópico 15 — Novas Tecnologias em BD e Encerramento](./Topico_15_Novas_Tecnologias_Encerramento.md)

---

*Fatec Jahu · IBD015 · Prof. Ronan Adriel Zenatti · 2026*
