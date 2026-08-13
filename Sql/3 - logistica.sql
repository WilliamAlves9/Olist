select * from olist_products_dataset

select * from olist_order_items_dataset

select * from olist_orders_dataset

select * from olist_order_payments_dataset

select * from olist_customers_dataset

--tempo médio de entrega por estado
select
t2.customer_state
,avg(datediff(day,t1.order_purchase_timestamp,t1.order_delivered_customer_date)) as media_entrega
from olist_orders_dataset as t1
join olist_customers_dataset as t2 on t2.customer_id = t1.customer_id
group by t2.customer_state
order by media_entrega desc

--atraso medio de entrega por estado
select
t2.customer_state
,avg(datediff(day,t1.order_delivered_customer_date,t1.order_estimated_delivery_date)) as media_entrega
from olist_orders_dataset as t1
join olist_customers_dataset as t2 on t2.customer_id = t1.customer_id
group by t2.customer_state
order by media_entrega desc

--categorias que demoram mais para serem entregues
select
t3.product_category_name
,avg(datediff(day,t1.order_purchase_timestamp,t1.order_delivered_customer_date)) as media_entrega
from olist_orders_dataset as t1
join olist_order_items_dataset as t2 on t2.order_id = t1.order_id
join olist_products_dataset as t3 on t3.product_id = t2.product_id
group by t3.product_category_name
order by media_entrega desc

--relação entre valor do frete e tempo de entrega
select
t3.product_category_name
,round(avg(t2.freight_value),2) as media_frete
,avg(datediff(day,t1.order_purchase_timestamp,t1.order_delivered_customer_date)) as media_entrega
from olist_orders_dataset as t1
join olist_order_items_dataset as t2 on t2.order_id = t1.order_id
join olist_products_dataset as t3 on t3.product_id = t2.product_id
group by t3.product_category_name
order by media_entrega desc, media_frete desc

--categorias que possuem maior percentual de entregas atrasadas
select
t3.product_category_name
,sum(case when t1.order_delivered_customer_date > t1.order_estimated_delivery_date then 1 else 0 end) as qtd_atrasos
,cast(sum(case 
		  when t1.order_delivered_customer_date > t1.order_estimated_delivery_date 
		  then 1.0 else 0.0 end) / count(t1.order_id) * 100 as decimal(5,2)) as percentual_atraso
from olist_orders_dataset as t1
join olist_order_items_dataset as t2 on t2.order_id = t1.order_id
join olist_products_dataset as t3 on t3.product_id = t2.product_id
group by t3.product_category_name
order by percentual_atraso desc