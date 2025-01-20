# Домашняя работа №12 "Транзакции"

# Пример транзакции и загрузки данных в базу данных

## 1. Пример транзакции с изменением данных в нескольких таблицах

Предположим, у нас есть задача: при добавлении нового сотрудника в таблицу `employees`, мы также хотим добавить его в проект с ID 1 в таблицу `employees_projects`. Это должно быть выполнено как атомарная операция, чтобы обеспечить целостность данных.

### Хранимая процедура для выполнения транзакции

```sql
CREATE OR REPLACE PROCEDURE add_employee_to_project(
    p_name VARCHAR(255),
    p_surname VARCHAR(255),
    p_email VARCHAR(255),
    p_division VARCHAR(255)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_employee_id BIGINT;
BEGIN
    -- Начало транзакции
    BEGIN
        -- Вставляем нового сотрудника в таблицу employees
        INSERT INTO employees (name, surname, email, division, created_at, updated_at)
        VALUES (p_name, p_surname, p_email, p_division, NOW(), NOW())
        RETURNING id INTO v_employee_id;

        -- Вставляем запись в таблицу employees_projects
        INSERT INTO employees_projects (employee_id, project_id)
        VALUES (v_employee_id, 1);

        -- Если все операции успешны, фиксируем транзакцию
        COMMIT;
    EXCEPTION
        -- Если произошла ошибка, откатываем транзакцию
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Ошибка при добавлении сотрудника и проекта: %', SQLERRM;
    END;
END;
$$;
```

## 2. Загрузка данных из CSV

### Использование `LOAD DATA`

У нас есть CSV-файл employees.csv с данными о сотрудниках. Мы можем загрузить эти данные в таблицу employees с помощью команды LOAD DATA.

```postgresql
LOAD DATA INFILE '/path/to/employees.csv'
INTO TABLE employees
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(name, surname, email, division, created_at, updated_at);
```

### Использование `mysqlimport`

```bash
mysqlimport --ignore-lines=1 --fields-terminated-by=, --columns='name,surname,email,division,created_at,updated_at' --local -u username -p database_name /path/to/employees.csv
```

Эта команда загружает данные из CSV-файла в таблицу employees. Параметр --ignore-lines=1 пропускает первую строку файла, --fields-terminated-by=, указывает, что поля разделены запятыми, а --columns задает порядок столбцов.
