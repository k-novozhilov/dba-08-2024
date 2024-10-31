-- Напишите запрос по своей базе с регулярным выражением, добавьте пояснение, что вы хотите найти.
select substring(email from '@(.*)$') as domain, count(*)
from public.employees
group by domain;
/* В данном запросе я хочу получить список почтовых доменов и кол-во сотрудников, использующих каждый домен */


-- Напишите запрос по своей базе с использованием LEFT JOIN и INNER JOIN, как порядок соединений в FROM влияет на результат? Почему?
select p.name, p.slug, e.name as employee
from public.projects p
left join public.employees_projects ep on p.id = ep.project_id
left join public.employees e on e.id = ep.employee_id
where "type" = 'Frontend';
-- результат здесь https://github.com/k-novozhilov/dba-08-2024/blob/main/2024-11-01_00-27-13.png

select p.name, p.slug, e.name as employee
from public.projects p
inner join public.employees_projects ep on p.id = ep.project_id
inner join public.employees e on e.id = ep.employee_id
where "type" = 'Frontend';
-- результат здесь https://github.com/k-novozhilov/dba-08-2024/blob/main/2024-11-01_00-27-26.png

/* для INNER JOIN порядок не имеет значения, а для LEFT JOIN — имеет, так как он определяет, какие данные будут включены в результат. 
Для строк с совпадениями будет отображаться вся информация из обеих таблиц, 
а для строк без совпадений соответствующие столбцы правой таблицы будут заполнены значениями NULL. */


-- Напишите запрос на добавление данных с выводом информации о добавленных строках.
insert into public.accounts (id, name, login, password, deleted_at, created_at, updated_at, password_api) 
values (DEFAULT, 'beget', 'beget_user', 'sd5wsdfdg55hhgg', null, null, null, 'retrewtRfcxd55-sdfsvFsa')
returning public.accounts.id, public.accounts.name;


-- Напишите запрос с обновлением данные используя UPDATE FROM
update public.servers s
set name = 'my favorite server' 
from public.projects p
where p.slug = 'nulla-project' and s.project_id = p.id;


-- Напишите запрос для удаления данных с оператором DELETE используя join с другой таблицей с помощью using.
delete from public.servers s
using public.projects p
where p.slug = 'nulla-project' and s.project_id = p.id;


-- Задание со *: Приведите пример использования утилиты COPY
COPY public.employees
TO '/var/tmp/employees.csv' 
WITH (FORMAT CSV, HEADER, DELIMITER ';');
