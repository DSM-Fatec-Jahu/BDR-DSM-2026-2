# CLAUDE.md — Banco de Dados — Relacional (IBD015) — 2º Semestre/2026

Este repositório é o material publicado da disciplina IBD015 (Fatec Jahu, curso DSM), servido como
site estático via **MkDocs Material + GitHub Pages**. O professor (Ronan) é a única
autoridade sobre conteúdo pedagógico — este arquivo governa como o Claude Code deve se
comportar ao lidar com o repositório, não substitui o julgamento dele.

> ⚠️ **Regra inegociável: nunca corte ou resuma conteúdo original para economizar
> espaço/tempo/tokens.** Se o texto de uma aula já existe, ele é preservado por
> completo ao remodelar — só se adicionam seções novas ao redor (mapa mental,
> flashcards, quiz, conquista). Edições no texto original só são permitidas quando o
> professor autorizar explicitamente, e mesmo assim devem ser cautelosas (corrigir,
> não encurtar). Se em algum momento não for possível fazer algo com qualidade
> completa, **diga isso explicitamente ao professor** em vez de entregar uma versão
> resumida, incompleta ou malfeita.

## Stack e comandos

- **MkDocs Material** (`mkdocs.yml` na raiz, `docs_dir: docs`)
- **Mermaid** para diagramas — via `pymdownx.superfences` (fence ` ```mermaid `), sem plugin extra
- **mkdocs-quiz** para quizzes interativos — sintaxe `<quiz>...</quiz>`
- Flashcards via admonition colapsável nativa do Material (`??? question "..."`) — sem dependência nova
- Deploy: `.github/workflows/deploy-docs.yml`, roda `mkdocs build` e publica em GitHub Pages a cada push em `main`

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
mkdocs build          # build de produção — rode SEMPRE antes de considerar uma aula pronta
mkdocs serve           # preview local em http://127.0.0.1:8000
```

## Estrutura

```
templates/
  AULA_TEMPLATE.md       # gabarito estrutural — fora de docs_dir, não entra no site
docs/
  index.md              # home do site — ementa, trilha, sumário de aulas
  aulas/
    Aula_NN_Titulo.md    # uma aula por arquivo, adicionada progressivamente pelo professor
  imgs/                  # imagens referenciadas pelas aulas (../imgs/arquivo.png)
mkdocs.yml               # nav é EXPLÍCITO — arquivo novo não aparece no site sozinho
```

---

## O pipeline: processando uma aula nova ou alterada em `docs/aulas/`

As aulas chegam **progressivamente**: o professor adiciona ou edita um `.md` em
`docs/aulas/` (em geral conteúdo cru — anotações, rascunho, texto ainda não formatado
no padrão do site) e pede para processá-lo, seja diretamente na conversa ou via
`/nova-aula caminho/do/arquivo.md`. Sempre que isso acontecer, siga as três fases
abaixo **nesta ordem**. Não pule a Fase 1 mesmo que o conteúdo pareça óbvio.

### Fase 1 — Validar o conteúdo e perguntar antes de aplicar

**Não edite nada ainda.** Primeiro leia:
- o arquivo novo/alterado, por completo;
- pelo menos 1-2 aulas já publicadas em `docs/aulas/`, para calibrar terminologia,
  convenções de nomenclatura (SQL em maiúsculas, tabelas no plural, etc.) e nível de
  profundidade já estabelecido;
- `docs/index.md`, para checar se a aula é coerente com a trilha e o bloco em que está.

Depois, escreva um resumo curto do que entendeu e faça perguntas específicas sempre que
houver qualquer um destes casos — não assuma a resposta:

- **Ambiguidade ou lacuna conceitual**: a explicação pula uma etapa, ou um termo é usado
  sem definição prévia.
- **Inconsistência com aulas anteriores**: nomenclatura, convenção de SQL, ou nível de
  profundidade diferente do padrão já estabelecido.
- **Imagem referenciada que não existe em `docs/imgs/`**: nunca invente o caminho nem
  remova a referência silenciosamente — pergunte se a imagem vem depois ou se o trecho
  deve ser reescrito sem ela.
- **Pré-requisito ainda não coberto**: a aula assume um conceito que ainda não apareceu
  em nenhuma aula publicada até agora.
- **Exemplos/dados**: se os exemplos numéricos ou a tabela de dados do rascunho puderem
  ser adaptados para caber melhor em um mapa mental ou flashcard, confirme antes de
  alterá-los — são escolha pedagógica do professor, não só formatação.
- **Objetivos de aprendizagem ausentes**: se o rascunho não deixar claro o que o aluno
  deve saber fazer ao final, pergunte em vez de inventar objetivos genéricos.

Só depois de receber as respostas (ou uma confirmação explícita de "pode aplicar sem
ajustes") siga para a Fase 2.

### Fase 2 — Remodelar com gamificação e múltiplas formas de aprendizagem

Use `templates/AULA_TEMPLATE.md` como estrutura-base. Toda aula remodelada deve
conter, nesta ordem (pule uma seção só se genuinamente não fizer sentido para o
conteúdo — ex. aulas que são só enunciado de prova não precisam de mapa mental):

1. Cabeçalho padrão (disciplina/professor/semestre)
2. 🎯 Objetivos da aula
3. 🗺️ **Mapa mental** — `flowchart LR` com subgraphs por tópico (NÃO o diagrama
   `mindmap` do Mermaid, e NÃO `flowchart TD` — ver "Armadilhas já conhecidas"
   abaixo), resumindo os conceitos antes do detalhe. Gabarito em
   `templates/AULA_TEMPLATE.md`.
4. Conteúdo — mantém a didática problema→conceito→exemplo já usada no 1º semestre
5. 🃏 **Flashcards de revisão** (3–6 por aula) — sintaxe:
   ```
   ??? question "Pergunta objetiva?"
       Resposta curta e direta.
   ```
6. ✅ **Quiz de fixação** (3–5 perguntas, `mkdocs-quiz`) — pelo menos uma de múltipla resposta
7. 📝 Resumo
8. 🏆 **Conquista da aula** — selo temático em `!!! success "Selo desbloqueado: ..."`,
   seguindo o **tema de gamificação do semestre** definido abaixo. Isso é reforço
   motivacional impresso na página, não um sistema de pontos real: o site é estático e
   não tem login nem banco de dados, então não há XP persistido entre sessões. Se o
   professor quiser gamificação com estado real (streak, ranking entre alunos), isso
   exige um backend — fora do escopo deste site; sinalize a ele em vez de simular.

   **Tema de gamificação do semestre — "Trilha do(a) Arquiteto(a) de Dados":** a
   jornada do aluno é enquadrada como uma progressão de carreira em BD, do primeiro
   contato até o domínio prático. Cada bloco tem um arco, e cada aula um selo dentro
   dele — mantenha o tom técnico/profissional, nunca infantil. O plano de 20 aulas
   desta disciplina (IBD015) é organizado em **4 blocos** — veja `docs/index.md` para
   o Sumário de Aulas completo:

   - **Bloco 1 — "Trilha do(a) Modelador(a) de Dados" (Aulas 1–5, Fundamentos e
     Modelagem)**: Aula 1 → `🧭 Explorador(a) de Dados`, Aula 2 → `🧹 Guardião(ã) da
     Normalização`, Aula 3 → `🛠️ Construtor(a) DDL`, Aula 4 → `✍️ Manipulador(a) de
     Dados`, Aula 5 (T1 — Modelagem Streaming) → `📐 Modelador(a) Certificado(a)`.
   - **Bloco 2 — "Trilha do(a) Consultor(a) SQL" (Aulas 6–9, Consultas e Visões)**:
     Aula 6 → `🔍 Investigador(a) de Dados`, Aula 7 → `📊 Analista de Agregações`,
     Aula 8 → `🧩 Mestre dos Joins`, Aula 9 (P1) → `🎖️ Veterano(a) de Modelagem e
     Consultas`.
   - **Bloco 3 — "Trilha do(a) Programador(a) de Banco de Dados" (Aulas 10–15,
     Programação e Administração de BD)**: Aula 10 → `🔒 Guardião(ã) da Integridade`,
     Aula 11 → `⚙️ Engenheiro(a) de Procedures`, Aula 12 → `⚡ Vigilante de Gatilhos`,
     Aula 13 → `🔁 Mestre das Transações`, Aula 14 → `🛡️ Guardião(ã) da Segurança`,
     Aula 15 → `🚀 Otimizador(a) de Consultas`.
   - **Bloco 4 — "Trilha do(a) Arquiteto(a) Sênior" (Aulas 16–20, Encerramento e
     Avaliações Finais)**: Aula 16 → `🧠 Revisor(a) Mestre`, Aula 17 (T2) → `🤝
     Integrador(a) de Sistemas`, Aula 18 (P2) → `🎓 Especialista Certificado(a)`,
     Aula 19 (R) → `🔄 Persistente`, Aula 20 → selo final `🏆 Arquiteto(a) de Dados —
     IBD015`.
   - Ao remodelar uma aula fora dessa lista de exemplos, escolha um nome de selo
     consistente com o tema (progressão de carreira/habilidade em BD) em vez de
     inventar temas novos a cada aula.
9. 🔗 Navegação (aula anterior / próxima) — **só linke a próxima aula se o arquivo dela
   já existir em `docs/aulas/`.** Como as aulas chegam progressivamente, a mais recente
   deve mostrar `🔒 Aula NN+1 — em breve.` no lugar do link. Ao adicionar essa próxima
   aula depois, volte na aula anterior e troque o placeholder pelo link real.

Depois de remodelar o conteúdo:
- Atualize `docs/index.md`: mude o status da aula de 🔒 "Em breve" para ✅ "Disponível"
  com link, no bloco correto do Sumário de Aulas e na trilha Mermaid.
- Atualize `mkdocs.yml`: adicione a entrada da aula no `nav`, na seção de bloco correta
  (o nav não descobre arquivos novos sozinho — esse passo é obrigatório).

### Fase 3 — Garantir a exibição completa no site publicado

Antes de considerar a aula pronta:

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
3. Se possível, abra `mkdocs serve` e navegue até a página da aula para conferir
   visualmente o mapa mental, os flashcards (clique para expandir) e o quiz.
4. Só então faça commit. Mensagem de commit deve indicar a aula (ex.: `Adiciona Aula 07
   — SQL DDL, com mapa mental, flashcards e quiz`). Não dê push automaticamente sem
   avisar o professor — ele decide quando publicar.

---

## Armadilhas já conhecidas neste projeto

- **`md_in_html` ausente** já causou badges/imagens dentro de `<div markdown>` serem
  exibidos como código cru em vez de renderizar. Está corrigido no `mkdocs.yml`
  original — se algum dia recriar a configuração do zero, não esqueça essa extensão.
- **O `nav` do `mkdocs.yml` é explícito.** Um arquivo `.md` novo em `docs/aulas/` não
  aparece no site até ser adicionado ao `nav` — isso é intencional (permite manter
  aulas "em rascunho" fora do site publicado), mas é fácil esquecer esse passo.
- **Caminhos de imagem são relativos** (`../imgs/arquivo.png` a partir de
  `docs/aulas/*.md`). Ao mover ou renomear arquivos, esses caminhos quebram
  silenciosamente — sempre rode `mkdocs build` depois.
- **`docs/atividades/index.md` é a tabela-índice de atividades** (nome, descrição,
  link) — mesma lógica do Sumário de Aulas em `docs/index.md`. Toda atividade nova em
  `docs/atividades/` precisa de uma linha nessa tabela e de uma entrada no `nav`, senão
  fica órfã (existe como página mas não aparece linkada em lugar nenhum).
- **Nunca use `mindmap` do Mermaid para o "Mapa Mental da Aula".** Já causou linhas de
  conexão cruzando por cima dos rótulos, ilegível (visto ao vivo na Aula 01). O layout
  desse tipo de diagrama é orgânico/de força, sem controle de colisão entre aresta e
  texto, e a versão do Mermaid empacotada pelo Material não inclui o layout `tidy-tree`
  nem plugins de layout tipo ELK que resolveriam isso. Use `flowchart LR` com
  `subgraph` por tópico — mesmo efeito de visão geral, sem sobreposição. Padrão em
  `templates/AULA_TEMPLATE.md`.
- **No mapa mental, use `flowchart LR` (esquerda→direita), nunca `TD`/`TB`.** Com 4-6
  subgraphs irmãos, `TD` os espalha lado a lado — o diagrama fica mais largo que a
  coluna de conteúdo do site, o Material encolhe o SVG inteiro para caber e o texto
  vira ilegível (visto ao vivo na Aula 01). Em `LR` os mesmos subgraphs empilham na
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
