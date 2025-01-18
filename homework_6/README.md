# Домашняя работа №6
## Создать индекс к какой-либо из таблиц вашей БД

```postgresql
CREATE INDEX idx_employees_email ON employees(email);
```

## Прислать текстом результат команды EXPLAIN, в которой используется данный индекс

```
QUERY PLAN
Index Scan using idx_employees_email on employees (cost=0.28..8.30 rows=1 width=107)
Index Cond: ((email)::text = 'akov03@example.org'::text)
```

## Реализовать индекс для полнотекстового поиска

```postgresql
CREATE INDEX idx_employees_name_gin ON employees USING gin (to_tsvector('russian', name));
```

## Реализовать индекс на часть таблицы или индекс на поле с функцией

```postgresql
CREATE INDEX idx_employees_division_it ON employees(email) WHERE division = 'incidunt';
```

## Создать индекс на несколько полей

```postgresql
CREATE INDEX idx_employees_name_surname ON employees(name, surname);
```

## Написать комментарии к каждому из индексов

```postgresql
COMMENT ON INDEX idx_employees_email IS 'Индекс для ускорения поиска по email в таблице employees';
COMMENT ON INDEX idx_employees_name_gin IS 'GIN индекс для полнотекстового поиска по полю name в таблице employees';
COMMENT ON INDEX idx_employees_division_it IS 'Частичный индекс для email, где division равен incidunt';
COMMENT ON INDEX idx_employees_name_surname IS 'Составной индекс для ускорения поиска по name и surname в таблице employees';
```
## Описать что и как делали и с какими проблемами столкнулись



В целом всё прошло гладко, за исключением пары моментов.

- Для полнотекстового поиска нужно было выбрать между GIN и GiST. GIN обычно быстрее для поиска, но медленнее для вставки. 
- Нужно было правильно определить порядок полей в индексе, чтобы он был эффективен для запросов. 