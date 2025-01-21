# Домашняя работа №13 "Создаем отчетную выборку"

Работаем с БД из файла script.md

### 1. Группировка с использованием `CASE`, `HAVING`, `ROLLUP`, `GROUPING()`:
Этот запрос покажет максимальную и минимальную цену, а также количество предложений в каждой категории.

```sql
SELECT
    category,
    MAX(price) AS max_price,
    MIN(price) AS min_price,
    COUNT(*) AS total_products,
    SUM(CASE WHEN status = 'В наличии' THEN 1 ELSE 0 END) AS in_stock
FROM products
GROUP BY category
WITH ROLLUP;
```

### 2. Выборка, показывающая самый дорогой и самый дешевый товар в каждой категории:
Этот запрос вернет название самого дорогого и самого дешевого товара в каждой категории.

```sql
SELECT
    category,
    MAX(title) KEEP (DENSE_RANK FIRST ORDER BY price DESC) AS most_expensive,
    MAX(title) KEEP (DENSE_RANK FIRST ORDER BY price ASC) AS cheapest
FROM products
GROUP BY category;
```

### 3. Rollup с количеством товаров по категориям:
Этот запрос покажет количество товаров в каждой категории, а также общее количество товаров.

```sql
SELECT
    IF(GROUPING(category), 'ИТОГО', category) AS category,
    COUNT(*) AS total_products
FROM products
GROUP BY category
WITH ROLLUP;
```

### 4. Использование `HAVING` для фильтрации групп:
Этот запрос покажет только те категории, где минимальный рейтинг товаров больше или равен 4.

```sql
SELECT
    category,
    MIN(rating) AS min_rating
FROM products
GROUP BY category
HAVING min_rating >= 4;
```

### 5. Использование `GROUPING()` для идентификации итоговых строк:
Этот запрос покажет общую сумму цен по категориям и общую сумму всех товаров.

```sql
SELECT
    IF(GROUPING(category), 'ИТОГО', category) AS category,
    SUM(price) AS total_price
FROM products
GROUP BY category
WITH ROLLUP;
```
