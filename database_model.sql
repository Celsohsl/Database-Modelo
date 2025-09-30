-- ===============================================
-- MODELO DE BANCO DE DADOS RELACIONAL
-- Descrição: Modelo de comércio com tabelas Produtos e Pedidos
-- ===============================================

-- Criar schema se não existir
CREATE SCHEMA IF NOT EXISTS ecommerce;

-- Usar o schema
SET search_path TO ecommerce, public;

-- ===============================================

-- Tabela de Produtos
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    category VARCHAR(100) NOT NULL,
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Pedidos
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL,
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    status VARCHAR(50) DEFAULT 'pending',
    
    -- Chave estrangeira para relacionar com produtos
    CONSTRAINT fk_product 
        FOREIGN KEY (product_id) 
        REFERENCES products(id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE
);

-- Índices para melhorar performance
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_products_price ON products(price);
CREATE INDEX IF NOT EXISTS idx_orders_product_id ON orders(product_id);
CREATE INDEX IF NOT EXISTS idx_orders_date ON orders(order_date);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);

-- ===============================================

-- Inserir dados na tabela Produtos
INSERT INTO products (name, description, price, category, stock_quantity) VALUES
('Expresso Tradicional', 'Café expresso encorpado com notas de chocolate amargo', R$ 5.00, 'Bebida', 15),
('Cappuccino Caramelo', 'Cappuccino tradicional com calda de caramelo artesanal e chantilly', R$ 8.50, 'Bebida', 10),
('Cookie Duplo Chocolate', 'Cookie caseiro com gotas de chocolate meio amargo e chocolate branco', R$ 4.00, 'Doce', 20),
('Cheesecake do Dia', 'Fatia generosa de cheesecake cremoso', R$ 8.50, 'doce', 10),
('Sanduíche de Frango', 'Pão artesanal com peito de frango grelhado, alface, tomate e maionese especial', R$ 12.00, 'Salgado', 8);

-- Inserir dados na tabela Pedidos
INSERT INTO orders (product_id, customer_name, customer_email, quantity, total_amount, status) VALUES
(1, 'Maria Silva', 'maria.silva@email.com', 2, 4999.98, 'completed'),
(3, 'João Santos', 'joao.santos@email.com', 1, 899.99, 'pending'),
(2, 'Ana Costa', 'ana.costa@email.com', 1, 3299.99, 'shipped'),
(4, 'Pedro Oliveira', 'pedro.oliveira@email.com', 1, 1899.99, 'processing'),
(5, 'Carla Ferreira', 'carla.ferreira@email.com', 3, 6599.97, 'completed'),
(1, 'Roberto Lima', 'roberto.lima@email.com', 1, 2499.99, 'pending');

-- Verificar dados inseridos
SELECT 'PRODUTOS CADASTRADOS:' as info;
SELECT id, name, price, category, stock_quantity FROM products ORDER BY id;

SELECT 'PEDIDOS REALIZADOS:' as info;
SELECT 
    o.id,
    p.name as produto,
    o.customer_name,
    o.quantity,
    o.total_amount,
    o.status,
    o.order_date
FROM orders o 
JOIN products p ON o.product_id = p.id 
ORDER BY o.order_date DESC;

-- Relatório de vendas por categoria
SELECT 'VENDAS POR CATEGORIA:' as info;
SELECT 
    p.category,
    COUNT(o.id) as total_pedidos,
    SUM(o.quantity) as total_itens_vendidos,
    SUM(o.total_amount) as receita_total
FROM products p
LEFT JOIN orders o ON p.id = o.product_id
GROUP BY p.category
ORDER BY receita_total DESC;