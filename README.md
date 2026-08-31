# 📊 Análise de Dados de E-commerce - Dataset Olist

Projeto de prática com análise de dados de um marketplace de e-commerce brasileiro (dataset público da Olist), cobrindo tratamento e exploração dos dados em **SQL Server** e visualização em **Power BI**. O objetivo foi treinar habilidades de análise de dados a partir do comportamento de clientes, vendas e logística de entrega.

![SQL Server](https://img.shields.io/badge/SQL_Server-CC2927?style=flat-square&logo=microsoftsqlserver&logoColor=white)
![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=flat-square&logo=powerbi&logoColor=black)
![Power Query](https://img.shields.io/badge/Power_Query-217346?style=flat-square&logo=microsoftexcel&logoColor=white)

## 🗂️ Estrutura do repositório

```
olist/
├── README.md      ← você está aqui
└── sql/
    ├── README.md              ← documentação técnica da camada SQL
    ├── Analise_inicial.sql
    ├── 1 - vendas.sql
    ├── 2 - clientes.sql
    ├── 3 - logistica.sql
    └── 4 - analise temporal.sql
```

> 🔗 O tratamento e a modelagem dos dados em SQL (incluindo a resolução do `customer_id` x `customer_unique_id`) estão documentados em [`sql/README.md`](./sql/README.md).

---

## 🖥️ Dashboard (Power BI)

Dashboard interativo construído a partir dos dados já tratados na camada SQL, dividido em três páginas.

### 1. Visão Geral

![Visão Geral](./assets/dashboard-visao-geral.png)

KPIs principais do negócio: faturamento (R$ 1,36 Bi), quantidade de pedidos (99 mil), ticket médio (R$ 13,67 mil) e média de atraso na entrega (0,70 dias). Complementado por evolução mensal de faturamento x quantidade de pedidos, mapa de concentração geográfica das vendas na América do Sul, faturamento por categoria de produto, faturamento por estado (treemap) e tipo de pagamento mais utilizado.

**Leitura rápida:** pagamento por crédito domina disparado sobre boleto, voucher e débito, e há uma queda evidente de faturamento em setembro, que vale investigar como possível sazonalidade ou problema de coleta de dados.

### 2. Clientes

![Dashboard Clientes](./assets/dashboard-clientes.png)

Página dedicada ao comportamento do cliente: faturamento e ticket médio por cliente, total de clientes (96 mil), média de pedidos por cliente (1,03), média de review (4,09) e **taxa de recorrência (3,12%)**. Também traz distribuição de clientes por estado, percentual de clientes e de faturamento por classe ABC, quantidade de avaliações por nota e o sentimento predominante dos comentários (positivo/neutro/negativo).

**Leitura rápida:** a Classe A representa 44,5% dos clientes, mas concentra **79,47% do faturamento**, um Pareto bem definido que reforça a importância de priorizar retenção desse grupo.

### 3. Logística

![Dashboard Logística](./assets/dashboard-logistica.png)

Foco no impacto da entrega na experiência do cliente: média de atraso por nota de avaliação, quantidade de vendedores por estado, atraso médio e quantidade de pedidos por cidade, status geral dos pedidos e média de frete por estado.

**Leitura rápida:** o gráfico "Média de atraso por avaliação" mostra uma relação praticamente inversa entre atraso e nota: pedidos com nota 1 têm em média ~4 dias de atraso, enquanto pedidos com nota 5 têm atraso próximo de zero. Isso sugere que o tempo de entrega é um fator relevante na satisfação do cliente. Algumas cidades específicas aparecem com atraso médio bem elevado no ranking por cidade, mas como o volume de pedidos nessas cidades é baixo, essa média pode estar distorcida por poucos casos isolados, e não necessariamente representa um padrão logístico consistente.

---

## 🧱 Modelagem de dados

A classificação ABC de clientes **não foi construída dentro do Power BI**: ela vem da camada SQL, onde os clientes já foram classificados por faixa de faturamento. No modelo do Power BI, essa informação entra como uma tabela separada (contendo `customer_unique_id`, percentual e classe) e é relacionada à tabela de dados dos clientes através do `customer_unique_id`, o mesmo identificador usado para resolver a duplicidade de `customer_id` por pedido, mantendo consistência entre a camada SQL e a camada de BI.

## 🔎 Principais insights

- **Recorrência baixa**: apenas 3,12% dos clientes fizeram mais de uma compra no período, consistente com o achado já identificado na análise SQL (2.997 de 96.096 clientes).
- **Concentração de receita (Pareto)**: 44,5% dos clientes (Classe A) geram quase 80% do faturamento total.
- **Atraso impacta satisfação**: quanto maior o atraso na entrega, menor a nota média da avaliação.
- **Concentração geográfica**: São Paulo lidera isoladamente em faturamento, quantidade de clientes e de vendedores, o Sudeste domina o volume do marketplace.
- **Atrasos pontuais por cidade**: algumas cidades de baixo volume aparecem com média de atraso alta, um sinal a validar antes de virar conclusão, já que poucos pedidos podem distorcer a média.
- **Meio de pagamento**: cartão de crédito é o método amplamente predominante entre os clientes.

## 🛠️ Tecnologias

- SQL Server (T-SQL)
- Power BI Desktop + DAX
- Power Query
- Dataset público: [Brazilian E-Commerce Public Dataset by Olist (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

---

<sub>Projeto de prática feito durante minha transição para Análise de Dados. Documentação técnica completa da camada SQL disponível em <a href="./sql/README.md">sql/README.md</a>.</sub>
