# Домашняя работа №14 "Индексы"

### Создание таблицы `products` (имитируем, т.к. в нашей БД такой таблицы нет)

```sql
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    properties JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Добавление полнотекстового индекса

Предположим, что в JSON-поле properties хранятся данные в формате:

```json
{
  "color": "red",
  "size": "large",
  "material": "cotton"
}
```

Создадим отдельные сгенерированные столбцы для каждого поля и добавим их в полнотекстовый индекс. Например:

```sql

ALTER TABLE products
    ADD COLUMN properties_color VARCHAR(255)
        GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(properties, '$.color'))) STORED;

ALTER TABLE products
    ADD COLUMN properties_size VARCHAR(255)
        GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(properties, '$.size'))) STORED;

ALTER TABLE products
    ADD COLUMN properties_material VARCHAR(255)
        GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(properties, '$.material'))) STORED;

ALTER TABLE products ADD FULLTEXT INDEX ft_search (name, description, properties_color, properties_size, properties_material);
```

### Проверка работы индекса

#### Выборка без индекса

Перед добавлением индекса выполним запрос для поиска по ключевым словам:

```sql
EXPLAIN SELECT * FROM products WHERE name LIKE '%red%' OR description LIKE '%red%' OR properties LIKE '%red%';
```

```
+----+-------------+----------+------------+------+---------------+------+---------+------+------+----------+-------------+
| id | select_type | table    | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
+----+-------------+----------+------------+------+---------------+------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | products | NULL       | ALL  | NULL          | NULL | NULL    | NULL |   50 |    29.76 | Using where |
+----+-------------+----------+------------+------+---------------+------+---------+------+------+----------+-------------+
```

Результат `EXPLAIN` показывает, что MySQL будет выполнять полное сканирование таблицы (type: ALL), что может быть медленно для больших таблиц.

#### Выборка с индексом

После добавления индекса выполним аналогичный запрос с использованием полнотекстового поиска:

```sql
EXPLAIN SELECT * FROM products WHERE MATCH(name, description, properties_color, properties_size, properties_material) AGAINST('red');
```

```
+----+-------------+----------+------------+----------+---------------+-----------+---------+-------+------+----------+-------------------------------+
| id | select_type | table    | partitions | type     | possible_keys | key       | key_len | ref   | rows | filtered | Extra                         |
+----+-------------+----------+------------+----------+---------------+-----------+---------+-------+------+----------+-------------------------------+
|  1 | SIMPLE      | products | NULL       | fulltext | ft_search     | ft_search | 0       | const |    1 |   100.00 | Using where; Ft_hints: sorted |
+----+-------------+----------+------------+----------+---------------+-----------+---------+-------+------+----------+-------------------------------+
```

Результат `EXPLAIN` показывает, что MySQL использует полнотекстовый индекс (type: fulltext), что значительно ускорит выполнение запроса.
