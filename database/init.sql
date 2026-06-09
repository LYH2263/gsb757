SET NAMES utf8mb4;

CREATE DATABASE IF NOT EXISTS bookstore CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bookstore;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'USER'
);

CREATE TABLE IF NOT EXISTS books (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    author VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    description TEXT,
    image_url VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS cart_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    quantity INT DEFAULT 1,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (book_id) REFERENCES books(id)
);

CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'COMPLETED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    book_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (book_id) REFERENCES books(id)
);

-- 填充种子数据
INSERT INTO users (username, password, role) VALUES ('admin', '123456', 'ADMIN');

INSERT INTO books (title, author, price, description, image_url) VALUES
('了不起的盖茨比', 'F. Scott Fitzgerald', 12.99, '爵士时代最经典的文学作品之一。', 'https://images.unsplash.com/photo-1592496431122-2349e0fbc666?w=400'),
('1984', 'George Orwell', 14.99, '一部极具震撼力的反乌托邦社会寓言。', 'https://images.unsplash.com/photo-1541963463532-d68292c34b19?w=400'),
('杀死一只知更鸟', 'Harper Lee', 10.99, '关于种族歧视、勇气与人性光辉的经典巨著。', 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400'),
('麦田里的守望者', 'J.D. Salinger', 11.99, '一个关于青春叛逆与迷茫的动人故事。', 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400');
