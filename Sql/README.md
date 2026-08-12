# 📊 Análise de Dados de E-commerce — Dataset Olist (SQL)

Análise exploratória em **SQL Server (T-SQL)** do dataset público da Olist (marketplace brasileiro), com foco em vendas, comportamento de clientes e logística de entrega. Esta camada SQL serviu como base para um dashboard em Power BI.

![SQL Server](https://img.shields.io/badge/SQL_Server-CC2927?style=flat-square&logo=microsoftsqlserver&logoColor=white)
![T-SQL](https://img.shields.io/badge/T--SQL-4479A1?style=flat-square&logo=databricks&logoColor=white)

---

## 🔎 Insight: taxa de recompra dos clientes

Um dos achados mais relevantes da análise: de **96.096 clientes únicos** (`customer_unique_id`), apenas **2.997 (≈3,1%)** fizeram mais de uma compra no período coberto pelo dataset — os outros **93.099 (≈96,9%)** compraram uma única vez.

```sql
select
t2.customer_unique_id
,count(t1.order_id) as qtd_pedidos
from olist_orders_dataset as t1
inner join olist_customers_dataset as t2 on t2.customer_id = t1.customer_id
group by t2.customer_unique_id
having count(t1.order_id) > 1
```

Isso indica uma **taxa de recompra muito baixa**, o que é um ponto de atenção relevante para o negócio — sugere oportunidade de ações de retenção/fidelização. Vale a ressalva: como o dataset cobre uma janela de tempo limitada, esse número reflete recompra *dentro do período observado*, não necessariamente o comportamento vitalício do cliente — clientes marcados como "únicos" podem ter comprado novamente fora da janela de dados disponível.

---

## 🎯 Objetivo

Responder perguntas de negócio sobre um marketplace de e-commerce usando apenas SQL: quais categorias geram mais receita, como os clientes se comportam ao longo do tempo, e o quanto a logística de entrega impacta o negócio.

## 🗂️ Estrutura do banco

O dataset é composto por múltiplas tabelas relacionadas por `order_id` / `customer_id` / `product_id`:

| Tabela | Conteúdo |
|---|---|
| `olist_orders_dataset` | Pedidos, status e datas (compra, aprovação, entrega) |
| `olist_order_items_dataset` | Itens do pedido — preço e frete |
| `olist_order_payments_dataset` | Tipo de pagamento, parcelas e valor |
| `olist_order_reviews_dataset` | Avaliações da loja |
| `olist_products_dataset` | Categoria e medidas do produto |
| `olist_customers_dataset` | Localização (cidade/estado) do cliente |
| `olist_sellers_dataset` | Localização dos vendedores |
| `olist_geolocation_dataset` | Dados de geolocalização |
| `product_category_name_translation` | Tradução dos nomes de categoria |

Antes de qualquer análise, o modelo não tinha chaves primárias/estrangeiras definidas — isso foi o primeiro passo (`Analise_inicial.sql`), criando a PK em `olist_order_reviews_dataset` e as FKs de `order_payments` e `order_items` para `orders`, garantindo integridade referencial para os joins seguintes.

## 🔑 Desafio técnico: `customer_id` x `customer_unique_id`

Um ponto que passa despercebido em uma primeira olhada no dataset: **cada pedido gera um `customer_id` novo**, mesmo que seja o mesmo cliente comprando de novo. Analisar por `customer_id` faz **todo cliente parecer que comprou uma única vez** — o que quebra qualquer análise de recorrência, LTV ou ticket médio por cliente.

A solução foi identificar o `customer_unique_id` (que identifica a pessoa de fato, não o pedido) e usar ele como chave de agrupamento nas análises de comportamento do cliente:

```sql
select
t3.customer_unique_id
,count(t2.order_id) as qtd_pedidos
,sum(t1.price) as faturamento
,round(sum(t1.price) / count(distinct t2.order_id),0) as ticket_medio
from olist_order_items_dataset as t1
inner join olist_orders_dataset as t2 on t2.order_id = t1.order_id
inner join olist_customers_dataset as t3 on t3.customer_id = t2.customer_id
group by t3.customer_unique_id
order by faturamento desc
```

## 📈 Análises realizadas

### Vendas e receita
- Categoria que mais gera receita
- Ticket médio geral e por categoria
- Estado e cidade com maior volume de vendas

### Comportamento do cliente
- Pedidos, faturamento e ticket médio por cliente (via `customer_unique_id`)
- Clientes que compraram apenas uma vez
- Intervalo médio entre compras, usando `LAG()` particionado por cliente
- Tempo desde a última compra de cada cliente

### Logística e entrega
- Tempo médio de entrega por estado
- Atraso médio de entrega por estado (entrega real x estimada)
- Categorias com maior tempo médio de entrega
- Relação entre valor do frete e tempo de entrega
- Percentual de pedidos entregues com atraso, por categoria (`CASE WHEN`)

### Séries temporais
- Faturamento mensal
- Crescimento percentual mês a mês (`LAG()`)
- Média móvel de 3 meses (`SUM()`/`AVG()` com `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW`)
- Ranking dos melhores meses (`DENSE_RANK()`)
- Faturamento por trimestre e ranking trimestral

## 🧠 Destaques técnicos

- **Window functions**: `LAG()` para comparar valores entre períodos/pedidos consecutivos, `DENSE_RANK()` para ranqueamento, médias móveis com frames customizados (`ROWS BETWEEN`)
- **CTEs encadeadas**: quebrar cálculos de crescimento mês a mês e por categoria em etapas legíveis, em vez de subqueries aninhadas
- **Agregações condicionais**: `CASE WHEN` dentro de `SUM()` para calcular percentual de atrasos sem subquery extra
- **Correção de modelagem**: identificação e tratamento do problema `customer_id` x `customer_unique_id`, comum em datasets de e-commerce

## 📁 Arquivos

| Arquivo | Conteúdo |
|---|---|
| `Analise_inicial.sql` | Mapeamento das tabelas e definição de chaves primárias/estrangeiras |
| `praticando1.sql` | Receita por categoria, ticket médio, vendas por estado/cidade |
| `praticando2.sql` | Comportamento de clientes, recorrência, frete e crescimento por categoria |
| `praticando3.sql` | Análises de tempo de entrega e atraso logístico |
| `praticando4.sql` | Séries temporais: faturamento mensal, média móvel, ranking e trimestres |

## 🛠️ Tecnologias

- SQL Server (T-SQL)
- Dataset público: [Brazilian E-Commerce Public Dataset by Olist (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

---

<sub>Este projeto faz parte do meu portfólio de transição para Análise de Dados. A camada de visualização (Power BI) está disponível em prints/documentação neste mesmo repositório.</sub>
