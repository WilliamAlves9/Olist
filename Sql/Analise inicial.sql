--order_payments_dataset e order_items_dataset sem chave    
--olist_geolocation_dataset dados de localização
--olist_order_items_dataset, data limite de entrega preço e frete
--olist_order_payments_dataset tipo de pagamento, parcelas e valor
--olist_order_reviews_dataset, avaliação sobre a loja
--olist_orders_dataset pedidos, status, e datas
--olist_products_dataset nome da categoria, e medidas (iremos trabalhar com nome de categoria e não de produto em si)
--olist_sellers_dataset dados de localização dos vendedores
--product_category_name_translation tradução das categorias
--olist_customers_dataset nome da cidade e estado dos clientes


--adicionando chaves primarias e secundarias
alter table olist_order_reviews_dataset
add constraint PK_olist_order_reviews_dataset primary key (review_id)

alter table olist_order_payments_dataset
add constraint FK_order_payments_dataset foreign key(order_id) references olist_orders_dataset(order_id)

alter table olist_order_items_dataset
add constraint FK_order_items_dataset foreign key(order_id) references olist_orders_dataset(order_id)

