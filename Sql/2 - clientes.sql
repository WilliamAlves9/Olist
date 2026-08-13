
select * from olist_products_dataset

select * from olist_order_items_dataset

select * from olist_orders_dataset

select * from olist_order_payments_dataset

select * from olist_customers_dataset

--quantos pedidos cada cliente fez, faturamento e ticket medio
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

--quantos clientes fizeram apenas um pedido
select
t2.customer_unique_id
,count( t1.order_id) as qtd_pedidos

from olist_orders_dataset as t1
inner join olist_customers_dataset as t2 on t2.customer_id = t1.customer_id
group by t2.customer_unique_id
--order by qtd_pedidos desc
having count( t1.order_id) = 1

--media entre compras de cada cliente

select
customer_id
,avg(dias_desde_ultima_compra) as media

from(
	select
	order_approved_at
	,customer_id
	,lag(order_approved_at) over(partition by customer_id order by order_approved_at) as compra_anterior
	,datediff(day,lag(order_approved_at) over(partition by customer_id order by order_approved_at),order_approved_at) as dias_desde_ultima_compra
	from olist_orders_dataset 
	where order_approved_at is not null
)as t
--where dias_desde_ultima_compra is not null
group by customer_id

--tempo desde a ultima compra
select
customer_id
,max(order_approved_at) as data_ultima_compra
,datediff(year,max(order_approved_at), getdate()) as ultima_compra
from olist_orders_dataset
where order_approved_at is not null
group by customer_id
order by ultima_compra desc

--maior crescimneto de vendas de cada cliente, nao ficou bom, muitos clientes só tem uma venda nesse database
with faturamentoPedido as(
	select
	t2.customer_unique_id
	,t1.order_id
	,t1.order_approved_at
	,sum(t3.price) as faturamento
	from olist_orders_dataset as t1
	join olist_customers_dataset as t2 on t2.customer_id = t1.customer_id
	join olist_order_items_dataset as t3 on t3.order_id = t1.order_id
	group by t2.customer_unique_id, t1.order_id, t1.order_approved_at
),
calculo as
(
	select
	customer_unique_id
	,order_approved_at
	,faturamento
	,lag(faturamento) over(partition by customer_unique_id order by order_approved_at desc) as venda_anterior
	from faturamentoPedido
)
select
customer_unique_id
,order_approved_at
,faturamento
,venda_anterior
, faturamento - venda_anterior as crescimento
from calculo
where venda_anterior is not null
order by faturamento desc


select
t2.product_category_name
,t1.freight_value
,avg(t1.freight_value) as frete_medio
from olist_order_items_dataset as t1
join olist_products_dataset as t2 on t1.product_id = t2.product_id
group by t2.product_category_name, t1.freight_value
order by t1.freight_value desc

--media de frete de cada categoria
select top 1
product_category_name
,media_frete
from
(
	select
	t2.product_category_name
	,round(avg(t1.freight_value),2) as media_frete
	from olist_order_items_dataset as t1
	join olist_products_dataset as t2 on t1.product_id = t2.product_id
	group by t2.product_category_name
)as t
group by product_category_name, media_frete
order by media_frete desc

--media de preco de cada categoria
select top 1
product_category_name
,media_valor
from
(
	select
	t2.product_category_name
	,round(avg(t1.price),2) as media_valor
	from olist_order_items_dataset as t1
	join olist_products_dataset as t2 on t1.product_id = t2.product_id
	group by t2.product_category_name
)as t
group by product_category_name, media_valor
order by media_valor desc


--maior quantidade de pedidos
select top 1
t2.product_category_name
,count(distinct t1.order_id) as qtd_pedidos
from olist_order_items_dataset as t1
join olist_products_dataset as t2 on t1.product_id = t2.product_id
group by t2.product_category_name
order by qtd_pedidos desc


--maior crescimento mensal por categoria
with analise_mensal as
(
	select
	t2.product_category_name
	,year(t3.order_approved_at) as ano
	,month(t3.order_approved_at) as mes
	,sum(t1.price) as faturamento
	from olist_order_items_dataset as t1
	join olist_products_dataset as t2 on t1.product_id = t2.product_id
	join olist_orders_dataset as t3 on t3.order_id = t1.order_id
	group by t2.product_category_name, year(t3.order_approved_at), month(t3.order_approved_at)
),
crescimento_mes as
(
	select
	product_category_name
	,ano
	,mes
	,faturamento
	,faturamento - lag(faturamento) over(partition by product_category_name order by ano,mes asc) as crescimento
	from analise_mensal
)
select
product_category_name
,ano
,mes
,faturamento
,crescimento
from crescimento_mes
where crescimento is not null
order by ano, mes asc


--menor crescimento mensal por categoria
with faturamento_mensal as
(
	select
	t2.product_category_name
	,year(t3.order_approved_at) as ano
	,month(t3.order_approved_at) as mes
	,sum(t1.price) as faturamento_atual
	from olist_order_items_dataset as t1
	join olist_products_dataset as t2 on t1.product_id = t2.product_id
	join olist_orders_dataset as t3 on t3.order_id = t1.order_id
	group by t2.product_category_name, year(t3.order_approved_at),month(t3.order_approved_at)
),
comparativo_mes_anterior as
(
	select
	product_category_name
	,ano
	,mes
	,faturamento_atual
	,faturamento_atual - lag(faturamento_atual) over(partition by product_category_name order by ano,mes asc) as diferenca
	from faturamento_mensal
)
select 
product_category_name
,ano
,mes
,diferenca
from comparativo_mes_anterior
where diferenca is not null
order by diferenca asc


