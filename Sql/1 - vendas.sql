--qual categoria gerou mais receita?
--olist_products_dataset nome da categoria, e medidas

select * from olist_products_dataset

select * from olist_order_items_dataset

select * from olist_orders_dataset

select * from olist_order_payments_dataset

select * from olist_customers_dataset

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


