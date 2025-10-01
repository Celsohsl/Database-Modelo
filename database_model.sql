
-- MODELO DE BANCO DE DADOS - CAFETERIA
-- PostgreSQL

-- Armazena informações sobre os produtos disponíveis na cafeteria
CREATE TABLE produtos (
    id_produto SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    categoria VARCHAR(50) NOT NULL,
    preco NUMERIC(10, 2) NOT NULL,
    estoque INT NOT NULL DEFAULT 0,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Armazena informações dos clientes
CREATE TABLE clientes (
    id_cliente SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefone VARCHAR(20),
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Armazena os pedidos realizados pelos clientes
CREATE TABLE pedidos (
    id_pedido SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL,
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'pendente',
    valor_total NUMERIC(10, 2) NOT NULL,
    observacoes TEXT,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

-- Relaciona produtos aos pedidos (tabela intermediária)
CREATE TABLE itens_pedido (
    id_item SERIAL PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario NUMERIC(10, 2) NOT NULL,
    subtotal NUMERIC(10, 2) NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
);

-- Inserindo produtos
INSERT INTO produtos (nome, descricao, categoria, preco, estoque) VALUES
('Cappuccino', 'Café expresso com leite vaporizado e espuma cremosa', 'Bebidas Quentes', 8.50, 50),
('Croissant', 'Croissant francês artesanal com manteiga', 'Panificação', 6.00, 30),
('Cheesecake', 'Torta de queijo cremosa com calda de frutas vermelhas', 'Sobremesas', 12.00, 15),
('Café Expresso', 'Café expresso tradicional italiano', 'Bebidas Quentes', 5.00, 100),
('Suco Natural Laranja', 'Suco de laranja natural sem açúcar', 'Bebidas Frias', 7.00, 40);

-- Inserindo clientes
INSERT INTO clientes (nome, email, telefone) VALUES
('Maria Silva', 'maria.silva@email.com', '(11) 98765-4321'),
('João Santos', 'joao.santos@email.com', '(11) 91234-5678'),
('Ana Costa', 'ana.costa@email.com', '(11) 99876-5432'),
('Pedro Oliveira', 'pedro.oliveira@email.com', '(11) 97654-3210');

-- Inserindo pedidos
INSERT INTO pedidos (id_cliente, status, valor_total, observacoes) VALUES
(1, 'concluído', 20.50, 'Sem açúcar no cappuccino'),
(2, 'em preparo', 18.00, NULL),
(3, 'concluído', 25.00, 'Para viagem');

-- Inserindo itens dos pedidos
INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario, subtotal) VALUES
-- Pedido 1 (Maria Silva)
(1, 1, 2, 8.50, 17.00),
(1, 4, 1, 5.00, 5.00),
-- Pedido 2 (João Santos)
(2, 2, 2, 6.00, 12.00),
(2, 5, 1, 7.00, 7.00),
-- Pedido 3 (Ana Costa)
(3, 1, 1, 8.50, 8.50),
(3, 3, 1, 12.00, 12.00),
(3, 2, 1, 6.00, 6.00);


-- Listar todos os produtos disponíveis
SELECT * FROM produtos ORDER BY categoria, nome;

-- Listar pedidos com informações do cliente
SELECT 
    p.id_pedido,
    c.nome AS cliente,
    p.data_pedido,
    p.status,
    p.valor_total
FROM pedidos p
INNER JOIN clientes c ON p.id_cliente = c.id_cliente
ORDER BY p.data_pedido DESC;

-- Detalhar itens de um pedido específico
SELECT 
    ip.id_pedido,
    pr.nome AS produto,
    ip.quantidade,
    ip.preco_unitario,
    ip.subtotal
FROM itens_pedido ip
INNER JOIN produtos pr ON ip.id_produto = pr.id_produto
WHERE ip.id_pedido = 1;

-- Relatório completo de pedidos
SELECT 
    p.id_pedido,
    c.nome AS cliente,
    pr.nome AS produto,
    ip.quantidade,
    ip.subtotal,
    p.valor_total,
    p.status
FROM pedidos p
INNER JOIN clientes c ON p.id_cliente = c.id_cliente
INNER JOIN itens_pedido ip ON p.id_pedido = ip.id_pedido
INNER JOIN produtos pr ON ip.id_produto = pr.id_produto
ORDER BY p.id_pedido;