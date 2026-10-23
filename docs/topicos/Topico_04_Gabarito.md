<!--
GABARITO — não faz parte do fluxo principal da aula e fica fora do `nav` do
mkdocs.yml de propósito. É acessível só pelo link no final de Aula_04_SQL_DML.md.
-->

# Gabarito — Aula 04 — SQL DML: Manipulação de Dados

**Disciplina:** Banco de Dados — Relacional (IBD015)
**Professor:** Ronan Adriel Zenatti · ronan.zenatti@cps.sp.gov.br
**Fatec Jahu — 2º Semestre/2026**

> ⚠️ Este gabarito é para conferência **depois** de você tentar resolver os checkpoints
> e os Exercícios de Fixação por conta própria na [Aula 04](Aula_04_SQL_DML.md).
> Resolver antes de tentar reduz o benefício de treinar a recuperação ativa do
> conteúdo.

---

## Checkpoint 1 — INSERT: bike-sharing elétrico {: #checkpoint-1 }

**Resposta:**

```sql
INSERT INTO bicicletas (modelo, nivel_bateria, estacao_id, disponivel) VALUES
    ('Aro 29 E-bike',      100, 1, 1),
    ('Urbana Compacta',     87, 1, 1),
    ('Urbana Compacta',     45, 2, 1);
```

Um único `INSERT` com lista de colunas e três tuplas separadas por vírgula após
`VALUES` — a forma múltipla, muito mais eficiente que três comandos `INSERT`
separados.

---

## Checkpoint 2 — UPDATE: app de doação de sangue {: #checkpoint-2 }

**Resposta:**

```sql
UPDATE agendamentos
SET    status = 'compareceu'
WHERE  hemocentro_id = 3
  AND  data_agendada = CURDATE();
```

Esquecer o `WHERE` aqui marcaria **todo agendamento de todo hemocentro, de qualquer
data**, como comparecido — inclusive agendamentos futuros que ainda nem aconteceram.
Nesse domínio isso é especialmente grave porque o sistema de doação de sangue depende
dessa informação para calcular estoque de bolsas de sangue disponível; um dado de
comparecimento falso poderia levar a decisões clínicas erradas sobre quanto sangue
está realmente disponível.

---

## Checkpoint 3 — DELETE: app de reciclagem com recompensas {: #checkpoint-3 }

**Resposta:**

```sql
DELETE FROM resgates
WHERE  validade < CURDATE()
  AND  status = 'pendente';
```

`TRUNCATE TABLE resgates` removeria **todos** os resgates da tabela — inclusive os
válidos e os já retirados — além de reiniciar o `AUTO_INCREMENT`, o que quebraria
qualquer referência histórica a `id_resgate` em relatórios ou notificações já
enviadas ao usuário. O `TRUNCATE` não tem `WHERE`: ele é tudo ou nada, e aqui
precisamos remover exatamente um subconjunto bem definido (vencidos e ainda
pendentes), preservando o resto.

---

## Checkpoint 4 — Transações: marketplace de ingressos para shows {: #checkpoint-4 }

**Resposta:**

```sql
BEGIN;

INSERT INTO vendas (evento_id, comprador_id, quantidade, data_venda)
VALUES (7, 15, 2, NOW());

UPDATE eventos
SET    ingressos_disponiveis = ingressos_disponiveis - 2
WHERE  id_evento = 7;

COMMIT;
```

Você usaria `ROLLBACK` em vez de `COMMIT` se, entre as duas operações, descobrisse que
`ingressos_disponiveis` ficaria negativo (ou seja, não havia mais ingressos suficientes
no momento da venda) — nesse caso, a venda não deve existir de forma alguma, e o
`ROLLBACK` desfaz o `INSERT` em `vendas` junto com o decremento, evitando vender um
ingresso que não existe.

---

## Exercícios de Fixação (Seção 6)

### Exercício 1 — Inserir 3 produtos

```sql
INSERT INTO produtos (categoria_id, nome, preco, estoque) VALUES
    (1, 'Fone de Ouvido Bluetooth', 149.90, 25),
    (2, 'Webcam Full HD',           199.90, 12),
    (3, 'Clean Code — Robert C. Martin', 129.90, 0);
```

### Exercício 2 — Aumentar 5% no preço da categoria Periféricos

```sql
UPDATE produtos
SET    preco = preco * 1.05
WHERE  categoria_id = (SELECT id_categoria FROM categorias WHERE nome = 'Periféricos');
```

### Exercício 3 — Transação com ROLLBACK

```sql
BEGIN;

INSERT INTO pedidos (cliente_id, funcionario_id, status, valor_total)
VALUES (2, NULL, 'pendente', 549.80);

INSERT INTO itens_pedidos (pedido_id, produto_id, quantidade, preco_unitario)
VALUES
    (LAST_INSERT_ID(), 4, 1, 299.90),
    (LAST_INSERT_ID(), 3, 1, 249.90);

-- Verifica antes de desfazer:
SELECT * FROM pedidos WHERE cliente_id = 2 ORDER BY id_pedido DESC LIMIT 1;

ROLLBACK;

-- Confirma que não sobrou nada: a consulta abaixo não deve retornar o pedido criado acima
SELECT * FROM pedidos WHERE cliente_id = 2 ORDER BY id_pedido DESC LIMIT 1;
```

### Exercício 4 — DELETE vs TRUNCATE

`DELETE FROM produtos` remove as linhas uma a uma (podendo ter `WHERE`), registra cada
remoção no log de transação, mantém o valor atual do `AUTO_INCREMENT`, e pode ser
revertido com `ROLLBACK` dentro de uma transação. `TRUNCATE TABLE produtos` remove a
tabela inteira de uma vez (nunca aceita `WHERE`), é muito mais rápido, reinicia o
`AUTO_INCREMENT` para 1, e **não** pode ser desfeito com `ROLLBACK` no MariaDB.
Use `DELETE` quando precisar remover um subconjunto específico de linhas ou quando a
segurança transacional importar; use `TRUNCATE` só para esvaziar uma tabela por
completo, tipicamente em ambiente de desenvolvimento/teste ou em uma limpeza
deliberada e irreversível.

---

⬅️ [Voltar à Aula 04 — SQL DML](./Aula_04_SQL_DML.md)

---

*Fatec Jahu · IBD015 · Prof. Ronan Adriel Zenatti · 2026*
