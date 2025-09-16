INSERT INTO pedidos (numero_pedido, data_emissao, codigo_cliente, valor_total) VALUES
(1, '2025-09-10', 1, 651.50);

INSERT INTO pedidos_produtos (numero_pedido, codigo_produto, quantidade, vlr_unitario, vlr_total) VALUES
(1, 101, 2.000, 150.75, 301.50), 
(1, 102, 1.000, 350.00, 350.00); 

INSERT INTO pedidos (numero_pedido, data_emissao, codigo_cliente, valor_total) VALUES
(2, '2025-09-12', 4, 3380.89);

INSERT INTO pedidos_produtos (numero_pedido, codigo_produto, quantidade, vlr_unitario, vlr_total) VALUES
(2, 108, 1.000, 2500.00, 2500.00),
(2, 109, 1.000, 480.90, 480.90),
(2, 110, 1.000, 399.99, 399.99);

INSERT INTO pedidos (numero_pedido, data_emissao, codigo_cliente, valor_total) VALUES
(3, '2025-09-15', 7, 941.25);

INSERT INTO pedidos_produtos (numero_pedido, codigo_produto, quantidade, vlr_unitario, vlr_total) VALUES
(3, 107, 2.000, 280.50, 561.00),
(3, 119, 1.000, 380.25, 380.25); 