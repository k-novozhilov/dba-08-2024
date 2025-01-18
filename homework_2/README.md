# Домашняя работа №2 "Оптимизация и улучшение базы данных для таблицы `employees`"

## 1. Анализ возможных запросов, отчетов и поиска данных

Предположим, что в системе будут выполняться следующие типы запросов:
- Поиск сотрудников по email.
- Поиск сотрудников по имени и фамилии.
- Фильтрация сотрудников по подразделению (`division`).
- Поиск сотрудников, у которых email подтвержден (`email_verified_at IS NOT NULL`).
- Отчеты по сотрудникам, сгруппированные по подразделениям.
- Поиск сотрудников по части имени или фамилии (полнотекстовый поиск).

## 2. Предполагаемая кардинальность полей

- **email**: Высокая кардинальность, так как email уникален для каждого сотрудника.
- **name** и **surname**: Средняя кардинальность, так как имена и фамилии могут повторяться.
- **division**: Низкая кардинальность, так как количество подразделений ограничено.
- **email_verified_at**: Низкая кардинальность, так как это бинарное состояние (подтвержден или нет).

## 3. Создание дополнительных индексов

### Простые индексы
1. **Индекс на поле `division`**:
   ```postgresql
   CREATE INDEX idx_employees_division ON employees(division);
   ```

Ускоряет фильтрацию сотрудников по подразделению.

2. **Индекс на поле `email_verified_at`**:
```postgresql
CREATE INDEX idx_employees_email_verified ON employees(email_verified_at);
```
Ускоряет поиск сотрудников с подтвержденным email.

### Композитные индексы
3. **Индекс на поля `name` и `surname`:**
```postgresql
CREATE INDEX idx_employees_name_surname ON employees(name, surname);
```
Ускоряет поиск сотрудников по имени и фамилии.

4. **Индекс на поля `division` и `email_verified_at`:**

```postgresql
CREATE INDEX idx_employees_division_email_verified ON employees(division, email_verified_at);
```

Ускоряет фильтрацию сотрудников по подразделению и статусу подтверждения email.

## 4. Логические ограничения в БД

### Уникальные поля

Поле `email` должно быть уникальным:

```postgresql
ALTER TABLE employees ADD CONSTRAINT unique_employee_email UNIQUE (email);
```

### Условия на поля

Поле `email_verified_at` должно быть либо NULL, либо содержать корректную дату:

```postgresql
ALTER TABLE employees ADD CONSTRAINT chk_email_verified_at CHECK (email_verified_at IS NULL OR email_verified_at > '2015-01-01');
```

Поле `division` не должно быть пустым:

```postgresql
ALTER TABLE employees ADD CONSTRAINT chk_division_not_empty CHECK (division <> '');
```

## 5. Создание ограничений по выбранным полям

1. Уникальность email
```postgresql
ALTER TABLE employees ADD CONSTRAINT unique_employee_email UNIQUE (email);
```
2. Проверка даты подтверждения email
```postgresql
ALTER TABLE employees ADD CONSTRAINT chk_email_verified_at CHECK (email_verified_at IS NULL OR email_verified_at > '2015-01-01');
```
3. Проверка, что подразделение не пустое
```postgresql
ALTER TABLE employees ADD CONSTRAINT chk_division_not_empty CHECK (division <> '');
```