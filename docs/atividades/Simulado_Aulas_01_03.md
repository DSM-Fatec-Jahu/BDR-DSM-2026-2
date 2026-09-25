# Simulado — Aulas 01 a 03

**Disciplina:** Banco de Dados — Relacional (IBD015)
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br
**Fatec Jahu — 2º Semestre/2026**

!!! warning "🧪 Esta atividade não vale nota"
    Ela é uma **réplica do que pode ser solicitado na avaliação**. Resolva como se
    fosse a prova de verdade: sozinho, sem consultar respostas, e traga suas dúvidas
    para a aula.

---

## 📦 Como entregar

A entrega é **um único arquivo `.sql`**. Baixe o modelo e preencha-o:

📥 [Simulado_Aulas_01_03.sql](Simulado_Aulas_01_03.sql){: download }

- **Marque o que concluiu.** No início de cada exercício do modelo há uma linha
  `-- [ ] Exercício N`. Ao terminar o exercício, troque `[ ]` por `[x]`. Só os
  exercícios marcados serão considerados.
- **A execução pode ser completa ou parcial.** Deixe **comentado** qualquer trecho
  incompleto ou com erro, para que ele não impeça a execução do restante do arquivo.
- **Os exercícios 1 e 3 são respondidos em comentário**, dentro do próprio arquivo.
  Os exercícios 2 e 4 são respondidos em SQL.
- **O script deve poder ser executado várias vezes seguidas, sem gerar erro.** Nos
  exercícios de SQL, garanta a remoção prévia dos objetos que serão criados e proteja
  tanto a remoção quanto a criação contra a existência ou a inexistência deles.
- **Os exercícios 2 e 4 são independentes entre si**: cada um deve executar sozinho.

### Convenções e conteúdo esperado

Todo SQL entregue deve seguir as **9 regras de nomenclatura da disciplina** (Aula 03
— SQL DDL, Seção 1).

Espera-se que você utilize os conceitos de modelagem e de definição de estruturas
apresentados nas **Aulas 01, 02 e 03**. Não é necessário citá-los nas respostas — o
que se avalia é se você os compreendeu o suficiente para aplicá-los.

---

## 📋 Os Exercícios

### Exercício 1 — Cardinalidade e chave estrangeira *(resposta em comentário)*

Na passagem do modelo conceitual para o modelo lógico relacional, cada relacionamento
do MER é materializado por meio de chaves estrangeiras. Considerando os três tipos de
cardinalidade — 1:1, 1:N e N:M —, responda:

> **Em qual tabela deve ser adicionada a chave estrangeira e como a cardinalidade
> influencia essa escolha?**

Para cada tipo de cardinalidade, fundamente a sua resposta e ilustre-a com um exemplo
de entidades de sua escolha.

---

### Exercício 2 — JogaJunto: agendamento de partidas esportivas *(resposta em SQL)*

A **JogaJunto** é uma plataforma que aproxima pessoas que querem jogar, mas não
conseguem fechar a partida sozinhas: quem tem um time incompleto, quem quer organizar
uma partida e não tem com quem jogar, ou quem precisa de reservas ou de um segundo
time para um confronto. Quem organiza a partida informa quantas pessoas ainda faltam,
e os demais usuários se candidatam a participar.

A partir da especificação abaixo, faça a modelagem e escreva o SQL que cria o banco de
dados **`partidas_esportivas`**, com uma configuração adequada a um sistema em
português.

**Requisitos Funcionais**

- **RF01** — O sistema deve permitir que uma pessoa se cadastre (nome, e-mail e senha)
  e faça login.
- **RF02** — O sistema deve diferenciar dois tipos de acesso: `administrador` e
  `usuario`.
- **RF03** — Somente o administrador pode cadastrar esportes, informando o nome do
  esporte e a quantidade mínima de pessoas necessária para que uma partida dele
  aconteça.
- **RF04** — Um usuário deve poder organizar uma partida, informando o esporte, o dia
  e o horário, o nome e o endereço do local e quantas pessoas ainda faltam para
  completá-la.
- **RF05** — A quantidade de pessoas faltantes informada pelo organizador é livre:
  pode ser maior do que o mínimo do esporte, por exemplo, para reunir reservas ou dois
  times que se enfrentarão.
- **RF06** — Uma partida deve ter uma situação: aberta, realizada ou cancelada.
- **RF07** — Um usuário deve poder se candidatar a participar de várias partidas. Cada
  candidatura tem uma situação — pendente, confirmada ou recusada — decidida pelo
  organizador da partida.
- **RF08** — O sistema deve ser capaz de informar se uma partida já reúne o mínimo de
  pessoas exigido pelo esporte.
- **RF09** — Depois de realizada a partida, seus participantes (o organizador e os
  candidatos confirmados) podem, de forma **opcional**, avaliar cada um dos demais
  participantes **daquela partida**, com uma nota de 1 a 5 e um comentário opcional.
  A avaliação pertence à partida: as mesmas duas pessoas podem se avaliar novamente em
  outra partida.

**Requisitos Não Funcionais**

- **RNF01** — Todo o SQL deve seguir as convenções de nomenclatura da disciplina.
- **RNF02** — Não pode haver dois usuários com o mesmo e-mail, nem dois esportes com o
  mesmo nome.
- **RNF03** — Senhas não podem ser armazenadas de forma legível.
- **RNF04** — A quantidade mínima de pessoas de um esporte deve ser de pelo menos 1, e
  a quantidade de pessoas faltantes de uma partida não pode ser negativa.
- **RNF05** — Nenhuma nota de avaliação pode ser aceita fora da faixa de 1 a 5.
- **RNF06** — Ninguém pode avaliar a si mesmo, nem avaliar a mesma pessoa mais de uma
  vez na mesma partida.
- **RNF07** — Um usuário não pode ter mais de uma candidatura para a mesma partida.
- **RNF08** — Remover um esporte, um usuário ou uma partida que já possua histórico
  associado (candidaturas, avaliações) não pode apagar silenciosamente esse histórico.

---

### Exercício 3 — Normalização *(resposta em comentário)*

Após concluir o Exercício 2, analise o banco de dados que você criou sob a ótica da
normalização.

**Foram encontrados problemas de normalização?**

- **Em caso afirmativo**, indique quais são (tabela, coluna e forma normal violada) e se foram resolvidos no seu script.

- **Em caso negativo**, justifique por que atende às formas normais.

---

### Exercício 4 — Alterando uma estrutura existente *(resposta em SQL)*

Considere a tabela abaixo, que faz parte do cadastro de um sistema. Ela é apenas um
modelo, por isso não possui campos de auditoria:

```sql
CREATE TABLE pessoas (
    id_pessoa        BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nome             VARCHAR(255)    NOT NULL,
    cpf              INT             NOT NULL,
    rg               VARCHAR(20)     NOT NULL,
    data_nascimento  DATE            NOT NULL
);
```

Sem refazê-la do zero, altere a estrutura da tabela para atender ao que segue:

1. O campo `cpf` passa a se chamar `doc_federal` e o campo `rg` passa a se chamar
   `doc_estadual`. O `doc_federal` deve passar a armazenar, além de CPF, também CNPJ, que a partir de 2026 também possui letras.
2. Devem ser adicionados os campos `email` e `senha_hash`.
3. Deve ser adicionado o campo `tipo`, que aceita somente os valores `PF` e `PJ`,
   posicionado **imediatamente após** o campo `nome`.

---

⬅️ [Voltar para Atividades e Avaliações](index.md)

---

*Fatec Jahu · IBD015 · Prof. Ronan Adriel Zenatti · 2026*
