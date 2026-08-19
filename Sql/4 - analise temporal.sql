
--faturamento por mês
select
    datefromparts(year(t2.order_approved_at), month(t2.order_approved_at),1) as ano_mes
    ,sum(t1.price) as faturamento
from olist_order_items_dataset as t1
join olist_orders_dataset as t2 on t2.order_id = t1.order_id
group by year(t2.order_approved_at), month(t2.order_approved_at)
order by ano_mes asc

--crescimento mes a mes
with crescimento_mes as
(
    select
        datefromparts(year(t2.order_approved_at), month(t2.order_approved_at),1) as ano_mes
        ,sum(t1.price) as faturamento
    from olist_order_items_dataset as t1
    join olist_orders_dataset as t2 on t2.order_id = t1.order_id
    group by year(t2.order_approved_at), month(t2.order_approved_at)
),
percentual_mes as
(
    select
    ano_mes
    ,faturamento
    ,lag(faturamento) over(order by ano_mes asc) as crescimentoMes
    from crescimento_mes
)
select
    ano_mes
    ,faturamento
    ,round(sum(faturamento - crescimentoMes) / sum(crescimentoMes) * 100,2) as percentual
from percentual_mes
group by ano_mes, faturamento
order by ano_mes asc

with faturamentoMensal as (
    select 
        datefromparts(year(order_approved_at), month(order_approved_at), 1) as mes_ano,
        sum(price) as faturamento_mes
    from olist_orders_dataset as t1
    inner join olist_order_items_dataset as t2 on t2.order_id = t1.order_id
    where order_approved_at is not null
    group by year(order_approved_at), month(order_approved_at)
)
select 
    mes_ano,
    faturamento_mes,
    cast(avg(faturamento_mes) over (order by mes_ano asc rows between 2 preceding and current row) 
    as decimal(10,2)) as media_movel_3_meses

from FaturamentoMensal
order by mes_ano;

--ranking dos melhores meses
with faturamentoMensal as
(
    select
        datefromparts(year(t2.order_approved_at), month(t2.order_approved_at),1) as ano_mes
        ,sum(t1.price) as faturamento
    from olist_order_items_dataset as t1
    join olist_orders_dataset as t2 on t2.order_id = t1.order_id
    group by year(t2.order_approved_at), month(t2.order_approved_at)
)
select
    ano_mes
    ,faturamento
    ,dense_rank() over(order by faturamento desc) as rank_faturamento
from faturamentoMensal


--melhor trimestre
with faturamentoMensal as
(
    select
        datefromparts(year(t2.order_approved_at), month(t2.order_approved_at),1) as ano_mes
        ,sum(t1.price) as faturamento
    from olist_order_items_dataset as t1
    join olist_orders_dataset as t2 on t2.order_id = t1.order_id
    group by year(t2.order_approved_at), month(t2.order_approved_at)
),
trimestre as
(
    select
        ano_mes
        ,faturamento
        ,sum(faturamento) over(order by ano_mes rows between 2 preceding and current row) as faturamento_trimestre
    from faturamentoMensal
)
select
    ano_mes
    ,faturamento_trimestre
    ,dense_rank() over(order by faturamento_trimestre desc)
from trimestre