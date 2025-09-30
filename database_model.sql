-- ===============================================
-- MODELO DE BANCO DE DADOS RELACIONAL
-- Descrição: Modelo de comércio com tabelas Produtos e Pedidos
-- ===============================================

-- Criar schema se não existir
CREATE SCHEMA IF NOT EXISTS ecommerce;

-- Usar o schema
SET search_path TO ecommerce, public;

-- ===============================================
-- CRIAÇÃO DAS TABELAS (DDL)
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
-- INSERÇÃO DE DADOS (DML)
-- ===============================================

-- Inserir dados na tabela Produtos
INSERT INTO products (name, description, price, category, stock_quantity) VALUES
('Smartphone Samsung Galaxy S23', 'Smartphone Android com 256GB, câmera de 50MP, tela de 6.1 polegadas', 2499.99, 'Eletrônicos', 25),
('Notebook Dell Inspiron 15', 'Notebook com Intel Core i7, 16GB RAM, SSD 512GB, tela Full HD 15.6 polegadas', 3299.99, 'Informática', 15),
('Fones de Ouvido Sony WH-1000XM4', 'Fones wireless com cancelamento de ruído ativo, bateria de 30 horas', 899.99, 'Áudio', 40),
('Smartwatch Apple Watch Series 8', 'Relógio inteligente com GPS, monitoramento de saúde e fitness', 1899.99, 'Wearables', 20),
('Tablet iPad Air 10.9', 'Tablet Apple com chip M1, 64GB, Wi-Fi, tela Liquid Retina', 2199.99, 'Tablets', 30);

-- Inserir dados na tabela Pedidos
INSERT INTO orders (product_id, customer_name, customer_email, quantity, total_amount, status) VALUES
(1, 'Maria Silva', 'maria.silva@email.com', 2, 4999.98, 'completed'),
(3, 'João Santos', 'joao.santos@email.com', 1, 899.99, 'pending'),
(2, 'Ana Costa', 'ana.costa@email.com', 1, 3299.99, 'shipped'),
(4, 'Pedro Oliveira', 'pedro.oliveira@email.com', 1, 1899.99, 'processing'),
(5, 'Carla Ferreira', 'carla.ferreira@email.com', 3, 6599.97, 'completed'),
(1, 'Roberto Lima', 'roberto.lima@email.com', 1, 2499.99, 'pending');

-- ===============================================
-- CONSULTAS DE VERIFICAÇÃO
-- ===============================================

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

-- ===============================================
-- COMENTÁRIOS SOBRE O MODELO
-- ===============================================

/*
ESTRUTURA DO BANCO DE DADOS:

1. TABELA PRODUCTS:
   - Armazena informações dos produtos disponíveis
   - Chave primária: id (SERIAL)
   - Campos obrigatórios: name, price, category
   - Restrições: price >= 0, stock_quantity >= 0
   - Inclui timestamps para auditoria

2. TABELA ORDERS:
   - Armazena pedidos realizados pelos clientes
   - Chave primária: id (SERIAL)
   - Chave estrangeira: product_id (referencia products.id)
   - Restrições: quantity > 0, total_amount >= 0
   - Status para controle do ciclo de vida do pedido

3. RELACIONAMENTOS:
   - Um produto pode estar em vários pedidos (1:N)
   - Cada pedido está relacionado a um produto específico
   - Integridade referencial mantida via FK com restrições

4. ÍNDICES:
   - Criados para otimizar consultas frequentes
   - Melhoram performance em buscas por categoria, preço, etc.

5. DADOS DE EXEMPLO:
   - 5 produtos em diferentes categorias
   - 6 pedidos com diferentes status
   - Valores realistas para demonstração
*/