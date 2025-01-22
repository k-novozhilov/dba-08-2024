# Домашняя работа №16 "Анализ и профилирование запроса"

Предположим, нам нужно получить список сотрудников (`employees`), которые работают над проектами (`projects`), и информацию об их ролях (`roles`) и разрешениях (`permissions`). Также добавим подзапрос для фильтрации сотрудников, у которых есть определенные разрешения.

```sql
SELECT 
    e.name, 
    e.surname, 
    p.name AS project_name, 
    r.name AS role_name, 
    pm.name AS permission_name
FROM 
    employees e
INNER JOIN 
    employees_projects ep ON e.id = ep.employee_id
INNER JOIN 
    projects p ON ep.project_id = p.id
INNER JOIN 
    model_has_roles mhr ON e.id = mhr.model_id AND mhr.model_type = 'Employee'
INNER JOIN 
    roles r ON mhr.role_id = r.id
INNER JOIN 
    role_has_permissions rhp ON r.id = rhp.role_id
INNER JOIN 
    permissions pm ON rhp.permission_id = pm.id
WHERE 
    e.id IN (
        SELECT 
            e.id 
        FROM 
            employees e
        INNER JOIN 
            model_has_roles mhr ON e.id = mhr.model_id
        INNER JOIN 
            role_has_permissions rhp ON mhr.role_id = rhp.role_id
        WHERE 
            rhp.permission_id = (SELECT id FROM permissions WHERE name = 'edit_project')
    );
```

### 1. `EXPLAIN` в трех форматах

#### Формат 1: Обычный `EXPLAIN`

```sql
EXPLAIN
SELECT 
    e.name, 
    e.surname, 
    p.name AS project_name, 
    r.name AS role_name, 
    pm.name AS permission_name
FROM 
    employees e
INNER JOIN 
    employees_projects ep ON e.id = ep.employee_id
INNER JOIN 
    projects p ON ep.project_id = p.id
INNER JOIN 
    model_has_roles mhr ON e.id = mhr.model_id AND mhr.model_type = 'Employee'
INNER JOIN 
    roles r ON mhr.role_id = r.id
INNER JOIN 
    role_has_permissions rhp ON r.id = rhp.role_id
INNER JOIN 
    permissions pm ON rhp.permission_id = pm.id
WHERE 
    e.id IN (
        SELECT 
            e.id 
        FROM 
            employees e
        INNER JOIN 
            model_has_roles mhr ON e.id = mhr.model_id
        INNER JOIN 
            role_has_permissions rhp ON mhr.role_id = rhp.role_id
        WHERE 
            rhp.permission_id = (SELECT id FROM permissions WHERE name = 'edit_project')
    );
```

#### Формат 2: `EXPLAIN FORMAT=JSON`

```sql
EXPLAIN FORMAT=JSON
SELECT 
    e.name, 
    e.surname, 
    p.name AS project_name, 
    r.name AS role_name, 
    pm.name AS permission_name
FROM 
    employees e
INNER JOIN 
    employees_projects ep ON e.id = ep.employee_id
INNER JOIN 
    projects p ON ep.project_id = p.id
INNER JOIN 
    model_has_roles mhr ON e.id = mhr.model_id AND mhr.model_type = 'Employee'
INNER JOIN 
    roles r ON mhr.role_id = r.id
INNER JOIN 
    role_has_permissions rhp ON r.id = rhp.role_id
INNER JOIN 
    permissions pm ON rhp.permission_id = pm.id
WHERE 
    e.id IN (
        SELECT 
            e.id 
        FROM 
            employees e
        INNER JOIN 
            model_has_roles mhr ON e.id = mhr.model_id
        INNER JOIN 
            role_has_permissions rhp ON mhr.role_id = rhp.role_id
        WHERE 
            rhp.permission_id = (SELECT id FROM permissions WHERE name = 'edit_project')
    );
```

#### Формат 3: `EXPLAIN ANALYZE`

```sql
EXPLAIN ANALYZE
SELECT 
    e.name, 
    e.surname, 
    p.name AS project_name, 
    r.name AS role_name, 
    pm.name AS permission_name
FROM 
    employees e
INNER JOIN 
    employees_projects ep ON e.id = ep.employee_id
INNER JOIN 
    projects p ON ep.project_id = p.id
INNER JOIN 
    model_has_roles mhr ON e.id = mhr.model_id AND mhr.model_type = 'Employee'
INNER JOIN 
    roles r ON mhr.role_id = r.id
INNER JOIN 
    role_has_permissions rhp ON r.id = rhp.role_id
INNER JOIN 
    permissions pm ON rhp.permission_id = pm.id
WHERE 
    e.id IN (
        SELECT 
            e.id 
        FROM 
            employees e
        INNER JOIN 
            model_has_roles mhr ON e.id = mhr.model_id
        INNER JOIN 
            role_has_permissions rhp ON mhr.role_id = rhp.role_id
        WHERE 
            rhp.permission_id = (SELECT id FROM permissions WHERE name = 'edit_project')
    );
```

### 2. Оценка плана выполнения

### Оценка плана запроса

Из плана выполнения запроса (`EXPLAIN`) можно выделить следующие ключевые моменты:

1. **Nested Loop Semi Join**:
   - Основной запрос использует `Nested Loop Semi Join`, что может быть неэффективно для больших объемов данных.

2. **InitPlan 1**:
   - Подзапрос для поиска `permission_id` по имени `edit_project`.
   - Используется индекс `permissions_name_guard_name_unique`, что эффективно.

3. **Nested Loop**:
   - Основной запрос использует несколько вложенных циклов (`Nested Loop`), что может быть медленным для больших таблиц.

4. **Seq Scan on employees_projects**:
   - Используется последовательное сканирование (`Seq Scan`) таблицы `employees_projects`, что может быть медленным для больших таблиц.

5. **Index Only Scan**:
   - Используется индексное сканирование (`Index Only Scan`) для таблиц `model_has_roles`, `employees`, `roles`, `role_has_permissions`, что эффективно.

### Самые тяжелые места

1. **Nested Loop Semi Join**:
   - Вложенные циклы могут быть медленными для больших объемов данных, особенно если данные не помещаются в память.

2. **Seq Scan on employees_projects**:
   - Последовательное сканирование таблицы `employees_projects` может быть медленным, если таблица большая.

3. **Подзапросы**:
   - Подзапросы могут быть неэффективными, особенно если они выполняются для каждой строки основного запроса.

### Оптимизация запроса

#### 1. Добавление индексов

1. **Индекс на `employees_projects.employee_id`**:
   ```sql
   CREATE INDEX idx_employees_projects_employee_id ON employees_projects(employee_id);
   ```

2. **Индекс на `model_has_roles.model_id`**:
   ```sql
   CREATE INDEX idx_model_has_roles_model_id ON model_has_roles(model_id);
   ```

3. **Индекс на `role_has_permissions.role_id`**:
   ```sql
   CREATE INDEX idx_role_has_permissions_role_id ON role_has_permissions(role_id);
   ```

4. **Индекс на `permissions.name`**:
   ```sql
   CREATE INDEX idx_permissions_name ON permissions(name);
   ```

#### 2. Использование хинтов

Можно использовать хинты для указания MySQL, как лучше выполнить запрос. Например, можно указать использование определенного индекса:

```sql
SELECT 
    e.name, 
    e.surname, 
    p.name AS project_name, 
    r.name AS role_name, 
    pm.name AS permission_name
FROM 
    employees e USE INDEX (idx_employees_id)
INNER JOIN 
    employees_projects ep USE INDEX (idx_employees_projects_employee_id) ON e.id = ep.employee_id
INNER JOIN 
    projects p ON ep.project_id = p.id
INNER JOIN 
    model_has_roles mhr USE INDEX (idx_model_has_roles_model_id) ON e.id = mhr.model_id AND mhr.model_type = 'Employee'
INNER JOIN 
    roles r ON mhr.role_id = r.id
INNER JOIN 
    role_has_permissions rhp USE INDEX (idx_role_has_permissions_role_id) ON r.id = rhp.role_id
INNER JOIN 
    permissions pm USE INDEX (idx_permissions_name) ON rhp.permission_id = pm.id
WHERE 
    e.id IN (
        SELECT 
            e.id 
        FROM 
            employees e USE INDEX (idx_employees_id)
        INNER JOIN 
            model_has_roles mhr USE INDEX (idx_model_has_roles_model_id) ON e.id = mhr.model_id
        INNER JOIN 
            role_has_permissions rhp USE INDEX (idx_role_has_permissions_role_id) ON mhr.role_id = rhp.role_id
        WHERE 
            rhp.permission_id = (SELECT id FROM permissions USE INDEX (idx_permissions_name) WHERE name = 'edit_project')
    );
```

