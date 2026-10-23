# CLAUDE.md — Banco de Dados — Relacional (IBD015) — 2º Semestre/2026

Este repositório é o material publicado da disciplina IBD015 (Fatec Jahu, curso DSM), servido como
site estático via **MkDocs Material + GitHub Pages**. O professor (Ronan) é a única
autoridade sobre conteúdo pedagógico — este arquivo governa como o Claude Code deve se
comportar ao lidar com o repositório, não substitui o julgamento dele.

> ⚠️ **Regra inegociável: nunca corte ou resuma conteúdo original para economizar
> espaço/tempo/tokens.** Se o texto de um tópico já existe, ele é preservado por
> completo ao remodelar — só se adicionam seções novas ao redor (mapa mental,
> flashcards, quiz, conquista). Edições no texto original só são permitidas quando o
> professor autorizar explicitamente, e mesmo assim devem ser cautelosas (corrigir,
> não encurtar). Se em algum momento não for possível fazer algo com qualidade
> completa, **diga isso explicitamente ao professor** em vez de entregar uma versão
> resumida, incompleta ou malfeita.

## Terminologia: "tópico", não "aula"

A turma não acompanhou o ritmo originalmente planejado (uma aula por semana), então o
termo **"aula" foi aposentado em favor de "tópico"** em todo o repositório. Esta seção é
a fonte de verdade — ao criar, remodelar ou revisar qualquer coisa, siga-a:

- **Unidade de conteúdo = "tópico".** Vale para títulos, texto corrido, links, quizzes,
  flashcards, mensagens de commit e comentários em SQL. Escreva "Tópico 03", "este
  tópico", "no próximo tópico", "Gabarito do Tópico 03", "Objetivos do Tópico", "Mapa
  Mental do Tópico", "Conquista do Tópico" — com concordância no masculino ("o tópico",
  "do tópico", "no tópico").
- **Nomes de arquivo, pasta e imagem** usam `Topico` (sem acento): `docs/topicos/`,
  `Topico_NN_Titulo.md`, `Topico_NN_Gabarito.md`, `docs/imgs/Topico_NN_IMG_01.png`,
  `sql/Topico_NN_*.sql`, `templates/TOPICO_TEMPLATE.md`, `Simulado_Topicos_01_03.md`.
  Nunca crie arquivo, pasta ou link com `Aula` no nome.
- **Numeração sequencial, sem buracos: 15 tópicos (01 a 15).** O plano completo está no
  Sumário de Tópicos de `docs/index.md`; o número do arquivo, da imagem e do gabarito
  deve ser o mesmo número do tópico no sumário. Se a ordem do sumário mudar, renumere
  arquivos, links, imagens e referências cruzadas ("veremos no Tópico NN") juntos e
  rode `mkdocs build`.
- **Não existem "blocos" do curso.** A divisão em Bloco 1–4 foi extinta: não use no
  sumário, no `nav` (seção única "Tópicos"), na gamificação nem no texto. ("Bloco" no
  sentido de *trecho de conteúdo dentro de um tópico* — "bloco de conceito fechado",
  "bloco de código" — é outro uso e continua válido.)
- **Avaliações e entregas (T1, P1, P2, R, E) não são tópicos.** Não entram no Sumário de
  Tópicos nem têm número de tópico ou selo; vivem em `docs/atividades/` e nos Critérios
  de Avaliação de `docs/index.md`. Material de apoio e treino também fica em
  `docs/atividades/` e se refere aos tópicos que cobre ("Tópicos 01 a 03").
- **Sessão presencial não é "aula" nem "tópico".** Quando o sentido for o encontro com a
  turma, use "sala", "encontro presencial" ou "horário da disciplina" ("tirar dúvidas em
  sala").
- **Exceções legítimas:** a palavra "aula(s)" continua só como *dado de exemplo* de
  domínio (ex.: "app de aulas de idiomas", "aulas particulares") e na menção histórica
  deste próprio parágrafo. Palavras que apenas contêm o trecho, como "Paula" (Centro Paula Souza),
  não contam.

## Convenções de Nomenclatura desta Disciplina

Estas são as **9 regras oficiais** de nomenclatura SQL da disciplina (formalizadas no Tópico 03 — SQL DDL, `docs/topicos/Topico_03_SQL_DDL.md`, Seção 1). Todo SQL, pseudo-schema
ou notação de modelo lógico/físico gerado ou revisado neste repositório — em qualquer
tópico, não só no Tópico 03 — deve seguir estas regras. Ao criar ou remodelar um tópico que
contenha exemplos de tabelas/colunas, **verifique a aderência a cada regra abaixo** e,
sempre que fizer sentido pedagogicamente, **aponte no texto qual regra está sendo
aplicada** (ex.: "`id_pedido` segue a Regra 5") — isso é o que já fazemos no Tópico 03 e
ajuda o aluno a entender *por que* está aprendendo a nomear dessa forma, não só *que*
deve nomear assim.

1. **snake_case em tudo** — palavras separadas por underline, nunca espaço, hífen ou
   camelCase. `data_nascimento`, não `DataNascimento`.
2. **Minúsculas para nomes criados pelo usuário** — tabelas, colunas, schemas, aliases.
   Maiúsculas são reservadas às palavras-chave do SQL.
3. **Palavras reservadas em MAIÚSCULAS** — `SELECT`, `CREATE TABLE`, `NOT NULL`,
   `PRIMARY KEY` etc., para contraste visual entre linguagem e dado.
4. **Nomes de tabelas sempre no plural** — `clientes`, `pedidos`, `produtos`, nunca
   `cliente`, `pedido`, `produto`.
5. **Chave primária no padrão `id_nome_tabela_singular`**, tipo `BIGINT UNSIGNED
   AUTO_INCREMENT PRIMARY KEY`. Tabela `clientes` → PK `id_cliente`.
6. **Chave estrangeira no padrão `tabela_referencia_id`** — nome da tabela referenciada
   no singular + `_id`, mesmo tipo da PK referenciada (`BIGINT UNSIGNED`). Ordem das
   palavras se inverte em relação à PK (`id_cliente` → `cliente_id`).
7. **Chave estrangeira pelo papel semântico quando a entidade referenciada exerce papéis
   diferentes** — nunca `pessoa1_id`/`pessoa2_id`; use o papel (`cliente_id`,
   `funcionario_id`, `supervisor_id`).
8. **Tipos e tamanhos adequados ao dado, não ao que parece mais simples** —
   `VARCHAR(255)` como padrão defensivo para texto de tamanho imprevisível; dimensionar
   exatamente quando o domínio é conhecido e **realmente fixo** (CEP, UF, CPF); nunca
   `FLOAT`/`DOUBLE` para dinheiro — sempre `DECIMAL(p, s)`. **Atenção com o que parece
   fixo mas não é:** `telefone`/`celular` é `VARCHAR` (nunca `CHAR` de tamanho fixo) —
   o Brasil não tem um único formato de telefone (fixo tem 10 dígitos, celular tem 11,
   alguns cadastros ainda guardam DDI, e um número estrangeiro tem outro tamanho ainda),
   então travar um tamanho fixo é assumir uma regra que não existe no domínio real.
9. **Toda tabela tem campos de log** — `criado_em`, `alterado_em` (com `ON UPDATE
   CURRENT_TIMESTAMP`) e `deletado_em` (soft delete, `NULL` até ser excluído).

> 📌 **Nível conceitual vs. nível de convenção:** tópicos de modelagem pura (ex.: Tópico 01
> — MER conceitual) usam entidades no formato clássico de Peter Chen antes de qualquer
> convenção de nomenclatura SQL ter sido ensinada — isso é esperado e não é uma
> violação. Já a partir do momento em que um tópico apresenta explicitamente um "modelo
> lógico" ou schema (pseudo-SQL ou SQL de verdade), as 9 regras acima já deveriam estar
> refletidas nos nomes usados. Se encontrar um exemplo de modelo lógico/físico que
> contraria alguma regra, **não corrija silenciosamente** — sinalize ao professor
> (mesma lógica da regra inegociável no topo deste arquivo).

## Stack e comandos

- **MkDocs Material** (`mkdocs.yml` na raiz, `docs_dir: docs`)
- **Mermaid** para diagramas — via `pymdownx.superfences` (fence ` ```mermaid `), sem plugin extra
- **mkdocs-quiz** para quizzes interativos — sintaxe `<quiz>...</quiz>`
- Flashcards via admonition colapsável nativa do Material (`??? question "..."`) — sem dependência nova
- Deploy: `.github/workflows/deploy-docs.yml`, roda `mkdocs build` e publica em GitHub Pages a cada push em `main`

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
mkdocs build          # build de produção — rode SEMPRE antes de considerar um tópico pronto
mkdocs serve           # preview local em http://127.0.0.1:8000
```

## Estrutura

```
templates/
  TOPICO_TEMPLATE.md       # gabarito estrutural — fora de docs_dir, não entra no site
sql/
  Topico_NN_Titulo.sql     # scripts de apoio executáveis de um tópico (não entram no site)
docs/
  index.md                 # home do site — ementa, critérios, sumário de tópicos
  topicos/
    Topico_NN_Titulo.md    # um tópico por arquivo, adicionado progressivamente pelo professor
    Topico_NN_Gabarito.md  # gabarito do tópico — fora do nav
    Cardinalidade_MER_Completo.md  # material de apoio do Tópico 01 (no nav)
  atividades/              # avaliações (T1, P1, P2, R, E), práticas e simulados
    index.md               # tabela-índice de atividades
  imgs/                    # imagens referenciadas pelos tópicos (../imgs/arquivo.png)
mkdocs.yml                 # nav é EXPLÍCITO — arquivo novo não aparece no site sozinho
```

---

## O pipeline: processando um tópico novo ou alterado em `docs/topicos/`

Os tópicos chegam **progressivamente**: o professor adiciona ou edita um `.md` em
`docs/topicos/` (em geral conteúdo cru — anotações, rascunho, texto ainda não formatado
no padrão do site) e pede para processá-lo, seja diretamente na conversa ou via
`/novo-topico caminho/do/arquivo.md`. Sempre que isso acontecer, siga as três fases
abaixo **nesta ordem**. Não pule a Fase 1 mesmo que o conteúdo pareça óbvio.

### Fase 1 — Validar o conteúdo e perguntar antes de aplicar

**Não edite nada ainda.** Primeiro leia:
- o arquivo novo/alterado, por completo;
- pelo menos 1-2 tópicos já publicados em `docs/topicos/`, para calibrar terminologia,
  convenções de nomenclatura (SQL em maiúsculas, tabelas no plural, etc.) e nível de
  profundidade já estabelecido;
- `docs/index.md`, para checar se o tópico é coerente com a trilha e com a ordem do Sumário de Tópicos.

Depois, escreva um resumo curto do que entendeu e faça perguntas específicas sempre que
houver qualquer um destes casos — não assuma a resposta:

- **Ambiguidade ou lacuna conceitual**: a explicação pula uma etapa, ou um termo é usado
  sem definição prévia.
- **Inconsistência com tópicos anteriores**: nomenclatura, convenção de SQL, ou nível de
  profundidade diferente do padrão já estabelecido.
- **Imagem referenciada que não existe em `docs/imgs/`**: nunca invente o caminho nem
  remova a referência silenciosamente — pergunte se a imagem vem depois ou se o trecho
  deve ser reescrito sem ela.
- **Pré-requisito ainda não coberto**: o tópico assume um conceito que ainda não apareceu
  em nenhum tópico publicado até agora.
- **Exemplos/dados**: se os exemplos numéricos ou a tabela de dados do rascunho puderem
  ser adaptados para caber melhor em um mapa mental ou flashcard, confirme antes de
  alterá-los — são escolha pedagógica do professor, não só formatação.
- **Objetivos de aprendizagem ausentes**: se o rascunho não deixar claro o que o aluno
  deve saber fazer ao final, pergunte em vez de inventar objetivos genéricos.

Só depois de receber as respostas (ou uma confirmação explícita de "pode aplicar sem
ajustes") siga para a Fase 2.

### Fase 2 — Remodelar com gamificação e múltiplas formas de aprendizagem

Use `templates/TOPICO_TEMPLATE.md` como estrutura-base. Todo tópico remodelado deve
conter, nesta ordem (pule uma seção só se genuinamente não fizer sentido para o
conteúdo — ex. tópicos que são só prática não precisam de mapa mental):

1. Cabeçalho padrão (disciplina/professor/semestre)
2. 🎯 Objetivos do tópico
3. 🗺️ **Mapa mental** — `flowchart LR` com subgraphs por assunto (NÃO o diagrama
   `mindmap` do Mermaid, e NÃO `flowchart TD` — ver "Armadilhas já conhecidas"
   abaixo), resumindo os conceitos antes do detalhe. Gabarito em
   `templates/TOPICO_TEMPLATE.md`.
4. Conteúdo — mantém a didática problema→conceito→exemplo já usada no 1º semestre.
   **Após cada bloco de conceito fechado, intercale uma verificação parcial de
   entendimento** (não deixe toda a prática empilhada só no fim do tópico — esse é
   exatamente o erro pedagógico que este padrão corrige):
   - Prefira um **exercício prático** (`🔍 Checkpoint N`) sempre que o bloco permitir —
     escrever SQL, montar um MER, classificar atributos, apontar violação de regra
     etc. — sem a resposta no corpo do tópico; a resolução vive só no arquivo de
     gabarito do tópico (ver item 8.5 abaixo), linkada a partir do checkpoint.
   - Só quando o bloco for puramente teórico/conceitual (sem material para exercício
     prático), use **dois `<quiz>` normais** no lugar do checkpoint — a resposta já é
     revelada na hora pelo próprio componente, então não entra no gabarito.
   - Os temas desses exercícios devem usar **cenários atuais de 2026**, evitando o
     óbvio de livro-texto (biblioteca, escola, aluno/nota) — prefira domínios como
     mobilidade elétrica, fintech/carteira digital, streaming e plataformas de
     criadores, e-sports, gig economy, energia solar residencial, saúde digital,
     entrega por drone. Troque de domínio a cada checkpoint dentro do mesmo tópico.
   - Gabarito em `templates/TOPICO_TEMPLATE.md`.
5. 🃏 **Flashcards de revisão** (3–6 por tópico) — sintaxe:
   ```
   ??? question "Pergunta objetiva?"
       Resposta curta e direta.
   ```
6. ✅ **Quiz de fixação** (3–5 perguntas, `mkdocs-quiz`) — pelo menos uma de múltipla resposta
7. 📝 Resumo
8. 🏆 **Conquista do tópico** — selo temático em `!!! success "Selo desbloqueado: ..."`,
   seguindo o **tema de gamificação do semestre** definido abaixo. Isso é reforço
   motivacional impresso na página, não um sistema de pontos real: o site é estático e
   não tem login nem banco de dados, então não há XP persistido entre sessões. Se o
   professor quiser gamificação com estado real (streak, ranking entre alunos), isso
   exige um backend — fora do escopo deste site; sinalize a ele em vez de simular.

   **Tema de gamificação do semestre — "Trilha do(a) Arquiteto(a) de Dados":** a
   jornada do aluno é enquadrada como uma progressão de carreira em BD, do primeiro
   contato até o domínio prático. Há uma **trilha única**, sem divisão em blocos, e cada
   tópico tem um selo dentro dela — mantenha o tom técnico/profissional, nunca infantil.
   O plano de 15 tópicos desta disciplina (IBD015) está no Sumário de Tópicos de
   `docs/index.md`. Avaliações e entregas (T1, P1, P2, R, E) não são tópicos e não têm selo.

   - Tópico 1 → `🧭 Explorador(a) de Dados`, Tópico 2 → `🧹 Guardião(ã) da Normalização`,
     Tópico 3 → `🛠️ Construtor(a) DDL`, Tópico 4 → `✍️ Manipulador(a) de Dados`,
     Tópico 5 → `🔍 Investigador(a) de Dados`, Tópico 6 → `📊 Analista de Agregações`,
     Tópico 7 → `🧩 Mestre dos Joins`, Tópico 8 → `🔒 Guardião(ã) da Integridade`,
     Tópico 9 → `⚙️ Engenheiro(a) de Procedures`, Tópico 10 → `⚡ Vigilante de Gatilhos`,
     Tópico 11 → `🔁 Mestre das Transações`, Tópico 12 → `🛡️ Guardião(ã) da Segurança`,
     Tópico 13 → `🚀 Otimizador(a) de Consultas`, Tópico 14 → `🧠 Revisor(a) Mestre`,
     Tópico 15 → selo final `🏆 Arquiteto(a) de Dados — IBD015`.
   - Ao remodelar um tópico fora dessa lista de exemplos, escolha um nome de selo
     consistente com o tema (progressão de carreira/habilidade em BD) em vez de
     inventar temas novos a cada tópico.
8.5. 🔑 **Gabarito deste Tópico** — link para `Topico_NN_Gabarito.md`, um arquivo **separado**
   por tópico, criado em `docs/topicos/`, **fora do `nav` do `mkdocs.yml`** (mesmo padrão do
   `Cardinalidade_MER_Completo.md`: existe como página do site, acessível pelo link, mas
   não aparece no menu lateral — assim o aluno não tropeça na resposta antes de tentar).
   Contém a resolução de cada `🔍 Checkpoint N` do tópico (heading `## Checkpoint N —
   [tema] {: #checkpoint-N }`, usando `attr_list` para fixar o id do link) e, se o tópico
   tiver Exercícios de Fixação com resposta, a resolução deles também — nunca deixe
   resposta de exercício solto no corpo do tópico fora desse arquivo.
9. 🔗 Navegação (tópico anterior / próximo) — **só linke o próximo tópico se o arquivo dele
   já existir em `docs/topicos/`.** Como os tópicos chegam progressivamente, o mais recente
   deve mostrar `🔒 Tópico NN+1 — em breve.` no lugar do link. Ao adicionar esse próximo
   tópico depois, volte no tópico anterior e troque o placeholder pelo link real.

Depois de remodelar o conteúdo:
- Atualize `docs/index.md`: mude o status do tópico de 🔒 "Em breve" para ✅ "Disponível"
  com link, na posição correta do Sumário de Tópicos.
- Atualize `mkdocs.yml`: adicione a entrada do tópico no `nav`, na ordem correta
  (o nav não descobre arquivos novos sozinho — esse passo é obrigatório).

### Fase 3 — Garantir a exibição completa no site publicado

Antes de considerar o tópico pronto:

1. Rode `mkdocs build` (sem `--strict`, mas leia os warnings) e confirme que o arquivo
   novo/alterado **não introduziu** nenhum warning novo de link ou imagem quebrada.
2. Confira especificamente:
   - todo bloco `<div ... markdown>` usado (ex. badges centralizados) só funciona
     porque `md_in_html` está habilitado em `markdown_extensions` — **nunca remova essa
     extensão do `mkdocs.yml`**, é a causa raiz de um bug já visto neste projeto onde
     Markdown dentro de HTML cru aparecia como texto puro em vez de renderizar;
   - blocos ` ```mermaid ` fecham corretamente (não há crase/backtick sobrando dentro);
   - blocos `<quiz>...</quiz>` têm pelo menos uma alternativa `- [x]`;
   - toda imagem referenciada com `../imgs/arquivo.png` existe de fato em `docs/imgs/`.
3. Se possível, abra `mkdocs serve` e navegue até a página do tópico para conferir
   visualmente o mapa mental, os flashcards (clique para expandir) e o quiz.
4. Só então faça commit. Mensagem de commit deve indicar o tópico (ex.: `Adiciona Tópico 05
   — SQL: Consultas Básicas, com mapa mental, flashcards e quiz`). Não dê push automaticamente sem
   avisar o professor — ele decide quando publicar.

---

## Armadilhas já conhecidas neste projeto

- **`md_in_html` ausente** já causou badges/imagens dentro de `<div markdown>` serem
  exibidos como código cru em vez de renderizar. Está corrigido no `mkdocs.yml`
  original — se algum dia recriar a configuração do zero, não esqueça essa extensão.
- **O `nav` do `mkdocs.yml` é explícito.** Um arquivo `.md` novo em `docs/topicos/` não
  aparece no site até ser adicionado ao `nav` — isso é intencional (permite manter
  tópicos "em rascunho" fora do site publicado), mas é fácil esquecer esse passo.
- **Caminhos de imagem são relativos** (`../imgs/arquivo.png` a partir de
  `docs/topicos/*.md`). Ao mover ou renomear arquivos, esses caminhos quebram
  silenciosamente — sempre rode `mkdocs build` depois.
- **`docs/atividades/index.md` é a tabela-índice de atividades** (nome, descrição,
  link) — mesma lógica do Sumário de Tópicos em `docs/index.md`. Toda atividade nova em
  `docs/atividades/` precisa de uma linha nessa tabela e de uma entrada no `nav`, senão
  fica órfã (existe como página mas não aparece linkada em lugar nenhum).
- **Critérios de Avaliação vivem em dois lugares que precisam ficar iguais:** a fórmula
  e a tabela de componentes (T1, P1, P2, R, E) em `docs/index.md`, e a tabela-índice de
  `docs/atividades/index.md`. Hoje: **Nota Final = (T1 + P1 + P2) × 1 + E**, limitada a
  10,0, onde T1 = entrega da modelagem (conceitual e lógica) e do script de criação
  (DDL) do Projeto Integrador (PI) e E = +1,0 ponto extra para quem realizou a Maratona
  de CiberEducação da Cisco. Ao alterar um, altere o outro.
- **Nunca use `mindmap` do Mermaid para o "Mapa Mental do Tópico".** Já causou linhas de
  conexão cruzando por cima dos rótulos, ilegível (visto ao vivo no Tópico 01). O layout
  desse tipo de diagrama é orgânico/de força, sem controle de colisão entre aresta e
  texto, e a versão do Mermaid empacotada pelo Material não inclui o layout `tidy-tree`
  nem plugins de layout tipo ELK que resolveriam isso. Use `flowchart LR` com
  `subgraph` por assunto — mesmo efeito de visão geral, sem sobreposição. Padrão em
  `templates/TOPICO_TEMPLATE.md`.
- **No mapa mental, use `flowchart LR` (esquerda→direita), nunca `TD`/`TB`.** Com 4-6
  subgraphs irmãos, `TD` os espalha lado a lado — o diagrama fica mais largo que a
  coluna de conteúdo do site, o Material encolhe o SVG inteiro para caber e o texto
  vira ilegível (visto ao vivo no Tópico 01). Em `LR` os mesmos subgraphs empilham na
  vertical (a página rola, isso não é problema); a largura fica controlada porque só
  cresce com a profundidade da árvore, não com o número de ramos. Já é o padrão nos
  arquivos deste projeto — ao criar um mapa mental do zero, comece direto com `LR`.
  Se o mapa tiver muitos ramos (mais de ~6) mesmo assim, considere dividir em dois
  diagramas menores em vez de forçar tudo em um só.
- **Sempre valide um mapa mental novo visualmente antes de dar por pronto**, não só
  com `mkdocs build` (que não pega problemas de layout/tamanho, só link/imagem
  quebrada). Se houver Playwright disponível no ambiente, renderize o bloco Mermaid
  isolado (`mermaid.min.js` local + HTML mínimo) dentro de um container com a largura
  aproximada da coluna de conteúdo (~760px) e tire um screenshot antes de aplicar.
- **No DBML (dbdiagram.io), todo tipo composto por duas palavras precisa de aspas
  duplas — `UNSIGNED` em especial.** O parser do DBML só aceita um nome de tipo "de
  uma palavra" (mais tamanho entre parênteses, ex. `VARCHAR(255)`); escrever
  `id_cliente BIGINT UNSIGNED [PK, INCREMENT]` sem aspas quebra o diagrama no
  dbdiagram.io. A forma correta é envolver o tipo inteiro em aspas duplas, como uma
  string literal: `id_cliente "BIGINT UNSIGNED" [PK, INCREMENT]` — vale para
  `"BIGINT UNSIGNED"`, `"INT UNSIGNED"`, `"SMALLINT UNSIGNED"` e
  `"TINYINT UNSIGNED"`. **Isso é exclusivo do DBML** — no SQL real do MariaDB
  (`CREATE TABLE`, Tópico 03), `UNSIGNED` é escrito normalmente, sem aspas; não
  confunda os dois contextos ao gerar exemplos. Sempre que gerar ou revisar um bloco
  ` ```dbml ` neste repositório (tópicos, atividades, gabaritos), verifique essa regra
  antes de publicar — descoberto originalmente na
  `docs/atividades/Pratica_Modelagem_dbdiagram.md` e seu gabarito.
- **No DBML, os modificadores de coluna `pk`, `increment`, `not null`, `null` e
  `unique` (dentro dos colchetes `[...]`) devem ser escritos em MAIÚSCULAS —
  `[PK, INCREMENT]`, `[NOT NULL]`, `[NULL]`, `[UNIQUE]` — seguindo a Regra 3
  (palavras reservadas da linguagem em maiúsculas), mesmo o dbdiagram.io aceitando
  minúsculas silenciosamente. Chaves de atributo como `note:` e `default:` **não**
  são palavras reservadas nesse sentido e continuam em minúsculas. Ao gerar ou
  revisar qualquer bloco ` ```dbml ` neste repositório, confira essa formatação
  antes de publicar.
