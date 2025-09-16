CREATE TABLE clientes (
    codigo INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    cidade VARCHAR(100),
    uf CHAR(2),
    PRIMARY KEY (codigo)
);

CREATE TABLE produtos (
    codigo INT NOT NULL,
    descricao VARCHAR(150) NOT NULL,
    preco_venda DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (codigo)
);

CREATE TABLE pedidos (
    numero_pedido INT NOT NULL AUTO_INCREMENT,
    data_emissao DATE NOT NULL,
    codigo_cliente INT NOT NULL,
    valor_total DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (numero_pedido), 
    CONSTRAINT FK_pedidos_cliente FOREIGN KEY (codigo_cliente) REFERENCES clientes(codigo)
);

CREATE INDEX idx_codigo_cliente ON pedidos(codigo_cliente);

CREATE TABLE pedidos_produtos (
    autoincrem INT NOT NULL AUTO_INCREMENT,
    numero_pedido INT NOT NULL,
    codigo_produto INT NOT NULL,
    quantidade DECIMAL(10, 3) NOT NULL,
    vlr_unitario DECIMAL(10, 2) NOT NULL,
    vlr_total DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (autoincrem), 
    CONSTRAINT FK_pedidos_produtos_pedido FOREIGN KEY (numero_pedido) REFERENCES pedidos(numero_pedido),
    CONSTRAINT FK_pedidos_produtos_produto FOREIGN KEY (codigo_produto) REFERENCES produtos(codigo)
);

CREATE INDEX idx_numero_pedido ON pedidos_produtos(numero_pedido);
CREATE INDEX idx_codigo_produto ON pedidos_produtos(codigo_produto);