# Домашняя работа №15 "Добавляем в базу хранимые процедуры и триггеры"

## Создание пользователей

Создадим пользователей `client` и `manager`:
    
```sql
CREATE USER 'client'@'localhost' IDENTIFIED BY 'client_password';
CREATE USER 'manager'@'localhost' IDENTIFIED BY 'manager_password';
```

## Создание процедуры для выборки товаров

Создадим процедуру `get_products`, которая будет принимать параметры для фильтрации, сортировки и постраничной выдачи.

#### Предположим, что у нас есть таблица `products` с полями (в моей БД её нет, придумываем):

- `id` (INT)
- `name` (VARCHAR)
- `category` (VARCHAR)
- `price` (DECIMAL)
- `manufacturer` (VARCHAR)
- `created_at` (TIMESTAMP)

```sql
DELIMITER //

CREATE PROCEDURE get_products(
    IN p_category VARCHAR(255),
    IN p_price_min DECIMAL(10, 2),
    IN p_price_max DECIMAL(10, 2),
    IN p_manufacturer VARCHAR(255),
    IN p_sort_by VARCHAR(255),
    IN p_sort_order VARCHAR(4),
    IN p_limit INT,
    IN p_offset INT
)
BEGIN
    SET @query = CONCAT(
        'SELECT * FROM products WHERE 1=1 ',
        IF(p_category IS NOT NULL, CONCAT('AND category = "', p_category, '" '), ''),
        IF(p_price_min IS NOT NULL, CONCAT('AND price >= ', p_price_min, ' '), ''),
        IF(p_price_max IS NOT NULL, CONCAT('AND price <= ', p_price_max, ' '), ''),
        IF(p_manufacturer IS NOT NULL, CONCAT('AND manufacturer = "', p_manufacturer, '" '), ''),
        'ORDER BY ', p_sort_by, ' ', p_sort_order, ' ',
        'LIMIT ', p_limit, ' OFFSET ', p_offset
    );

    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DELIMITER ;
```

### Пример вызова процедуры:

```sql
CALL get_products('Electronics', 100.00, 500.00, 'Samsung', 'price', 'ASC', 10, 0);
```

## Назначение прав пользователю `client`

Дадим пользователю `client` права на выполнение процедуры `get_products`:

```sql
GRANT EXECUTE ON PROCEDURE your_database.get_products TO 'client'@'localhost';
FLUSH PRIVILEGES;
```


## Создание процедуры `get_orders`

Создадим процедуру `get_orders`, которая будет формировать отчёт по продажам за определённый период с различными уровнями группировки.

### Предположим, что у нас есть таблица `orders` с полями:
- `id` (INT)
- `product_id` (INT)
- `quantity` (INT)
- `price` (DECIMAL)
- `order_date` (TIMESTAMP)

```sql
DELIMITER //

CREATE PROCEDURE get_orders(
    IN p_period VARCHAR(10), -- 'hour', 'day', 'week'
    IN p_group_by VARCHAR(50) -- 'product', 'category', 'manufacturer'
)
BEGIN
    SET @query = CONCAT(
        'SELECT ',
        CASE p_group_by
            WHEN 'product' THEN 'p.name'
            WHEN 'category' THEN 'p.category'
            WHEN 'manufacturer' THEN 'p.manufacturer'
        END,
        ', SUM(o.quantity) AS total_quantity, SUM(o.quantity * o.price) AS total_revenue ',
        'FROM orders o ',
        'JOIN products p ON o.product_id = p.id ',
        'WHERE o.order_date >= ',
        CASE p_period
            WHEN 'hour' THEN 'NOW() - INTERVAL 1 HOUR'
            WHEN 'day' THEN 'NOW() - INTERVAL 1 DAY'
            WHEN 'week' THEN 'NOW() - INTERVAL 1 WEEK'
        END,
        ' GROUP BY ',
        CASE p_group_by
            WHEN 'product' THEN 'p.name'
            WHEN 'category' THEN 'p.category'
            WHEN 'manufacturer' THEN 'p.manufacturer'
        END
    );

    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DELIMITER ;
```

#### Пример вызова процедуры:

```sql
CALL get_orders('day', 'product');
```

## Назначение прав пользователю `manager`

Дадим пользователю `manager` права на выполнение процедуры `get_orders`:

```sql
GRANT EXECUTE ON PROCEDURE your_database.get_orders TO 'manager'@'localhost';
FLUSH PRIVILEGES;
```
