# Домашняя работа №11 "SQL выборка"

## 1. Запрос с `INNER JOIN`

У нас есть таблицы `employees` и `projects`, и мы хотим получить список сотрудников, которые работают над проектами:

```postgresql
SELECT e.name, e.surname, p.name
FROM employees e
INNER JOIN employees_projects ep ON e.id = ep.employee_id
INNER JOIN projects p ON ep.project_id = p.id;
```
Этот запрос возвращает имена и фамилии сотрудников, а также названия проектов, над которыми они работают. INNER JOIN используется для того, чтобы получить только те записи, где есть соответствие в обеих таблицах.

## 2. Запрос с LEFT JOIN
Получим список всех сотрудников и проекты, над которыми они работают (если такие есть):

```postgresql
SELECT e.name, e.surname, p.name
FROM employees e
LEFT JOIN employees_projects ep ON e.id = ep.employee_id
LEFT JOIN projects p ON ep.project_id = p.id;
```

Этот запрос возвращает всех сотрудников, даже если они не работают над какими-либо проектами. LEFT JOIN используется для того, чтобы включить все записи из таблицы employees, даже если нет соответствующих записей в таблице projects.

## 3. Запросы с `WHERE` и разными операторами

```postgresql
SELECT name, surname, division
FROM employees
WHERE division = 'IT';
```

Этот запрос возвращает всех сотрудников, работающих в подразделении IT. Это полезно для фильтрации сотрудников по отделам.

```postgresql
SELECT name, surname, email
FROM employees
WHERE email_verified_at IS NOT NULL;
```

Этот запрос возвращает сотрудников, у которых подтвержден email. Это полезно для отправки важных уведомлений только подтвержденным пользователям.

```postgresql
SELECT name, surname
FROM employees
WHERE additional_info->'skills' @> '["Java"]';
```

Этот запрос возвращает сотрудников, у которых в списке навыков есть Java. Это полезно для поиска сотрудников с определенными навыками.

```postgresql
SELECT name, surname, created_at
FROM employees
WHERE created_at > '2023-01-01';
```

Этот запрос возвращает сотрудников, которые были добавлены после 1 января 2023 года. Это полезно для анализа новых сотрудников.

```postgresql
SELECT name, surname, email
FROM employees
WHERE email LIKE '%@example.com';
```

Описание: Этот запрос возвращает сотрудников, у которых email заканчивается на @example.com. Это полезно для фильтрации по домену email.