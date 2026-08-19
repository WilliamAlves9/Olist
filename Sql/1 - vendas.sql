select
    t1.order_id
    ,t1.payment_value
    ,t2.price
from olist_order_payments_dataset as t1
inner join olist_order_items_dataset as t2 on t1.order_id = t2.order_id
where t1.order_id = '04f92792b1960e9302825742e0751a5c'

select
*
from olist_order_items_dataset
where order_id = '04f92792b1960e9302825742e0751a5c'

--qual categoria gerou mais receita?
select top 10
    t2.product_category_name
    ,sum(t1.price) as valor_total
from olist_order_items_dataset as t1
inner join olist_products_dataset as t2 on t2.product_id = t1.product_id
group by product_category_name
order by valor_total desc

--ticket medio
select
    round(sum(price) / count(distinct order_id),2) as ticket_medio
from olist_order_items_dataset 
order by ticket_medio desc

--estado que mais compra
select
    t3.customer_state
    ,sum(t1.price) as total_vendido
from olist_order_items_dataset as t1
inner join olist_orders_dataset as t2 on t2.order_id = t1.order_id
inner join olist_customers_dataset as t3 on t3.customer_id = t2.customer_id
group by t3.customer_state
order by total_vendido desc

--cidade que mais compra
select
    t3.customer_city
    ,sum(t1.price) as total_vendido
from olist_order_items_dataset as t1
inner join olist_orders_dataset as t2 on t2.order_id = t1.order_id
inner join olist_customers_dataset as t3 on t3.customer_id = t2.customer_id
group by t3.customer_city
order by total_vendido desc


--categoria com maior ticket medio
select
    t2.product_category_name
    ,round(sum(t1.price) / count(distinct order_id),2) as ticket_medio
from olist_order_items_dataset as t1
inner join olist_products_dataset as t2 on t2.product_id = t1.product_id
group by product_category_name
order by ticket_medio desc


--classe abc de produtos
with faturamento_produto as
(
    select
    t1.product_id
    ,sum(t1.price) as faturamento
from olist_order_items_dataset as t1
inner join olist_products_dataset as t2 on t2.product_id = t1.product_id
group by t1.product_id
),
percentual_produto as
(
    select
    product_id
        ,faturamento
        ,sum(faturamento) over (order by faturamento desc) as faturamento_acumulado
        ,sum(faturamento) over (order by faturamento desc) / sum(faturamento) over() as pct_acumulado
    from faturamento_produto
)

select 
    product_id
    ,faturamento
    ,pct_acumulado * 100 as calculo_percentual
    ,case when pct_acumulado <= 0.80 then 'A'
          when pct_acumulado <= 0.95 then 'B' 
          else 'C'                            
          end as Classe_ABC
from percentual_produto
order by faturamento desc;

--contagem e percentual de quantos produtos então em cada classe basta trocar com a consulta acima
select
    classe_abc
    ,count(*) as quantidade_produtos
    ,count(*) * 100 / sum(count(*)) over() as percentual_produtos
from(
    select
        product_id
        ,faturamento
        ,pct_acumulado * 100 as calculo_percentual
        ,case when pct_acumulado <= 0.80 then 'A'
              when pct_acumulado <= 0.95 then 'B'
              else 'C'
              end as classe_abc
from percentual_produto
)as t
group by classe_abc
