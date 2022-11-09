-- 1. Создайте view dv_ Messages ( важно: даже если по message_id нет данных о продажах или отправках, они все равно должны попасть в итоговую выборку)
-- Набор столбцов в результирующем наборе :
-- Message id- Message name-count of sales–count of users with sales–count of users (CLICKED)-count of users (READ) - count of users (DELIVERED) – Open Rate – Click Rate
create view product.dv_Messages as
SELECT 
      dic_message.id,
      dic_message.name,
      count(distinct db_sales.id) as count_of_sales,
      count(distinct db_sales.contact_id) as users_with_sales,
      count_of_users.CLICKED,
      count_of_users.READM,
      count_of_users.DELIVERED,
      count_of_users.Open_Rate,
      count_of_users.Click_Rate
FROM product.dic_message
left join product.db_sales
on dic_message.id = db_sales.message_id
left join
(
SELECT
      db_emailactivity.message_id,
      count(distinct case when db_emailactivity.status_id = 1 then db_emailactivity.contact_id end) as CLICKED,
      count(distinct case when db_emailactivity.status_id = 3 then db_emailactivity.contact_id end) as READM,
      count(distinct case when db_emailactivity.status_id = 2 then db_emailactivity.contact_id end) as DELIVERED,
      count(distinct case when db_emailactivity.status_id = 3 then db_emailactivity.contact_id end)/
      count(distinct case when db_emailactivity.status_id = 2 then db_emailactivity.contact_id end) as Open_Rate,
      count(distinct case when db_emailactivity.status_id = 1 then db_emailactivity.contact_id end)/
      count(distinct case when db_emailactivity.status_id = 2 then db_emailactivity.contact_id end) as Click_Rate
From product.db_emailactivity
group by db_emailactivity.message_id
) as count_of_users
on db_sales.message_id = count_of_users.message_id 
group by 
      dic_message.id,
      dic_message.name,
      count_of_users.CLICKED,
      count_of_users.READM,
      count_of_users.DELIVERED,
      count_of_users.Open_Rate,
      count_of_users.Click_Rate;


-- 2. Создайте view dv_SourceSales (важно: в итоговую выборку должны попасть все user_source_id, даже если по ним нет пользователей или продаж)

-- Набор столбцов в результирующем наборе : 
-- User_source_id – user_source_name – count of users – count of users with sales – revenue – count of messages with sales 
create view product.dv_SourceSales as
SELECT 
      dic_usersource.id,
      dic_usersource.name,
      count(distinct db_users.id) as count_of_users,
      count(distinct db_sales.contact_id) as users_with_sales,
      sum(db_sales.revenue) as revenue,
      count(distinct db_sales.message_id) as messages_with_sales 
FROM product.dic_usersource
left join product.db_users
on dic_usersource.id = db_users.source_id
left join product.db_contacts
on db_users.id = db_contacts.user_id
left join
product.db_sales
on db_contacts.id = db_sales.contact_id
group by 
         dic_usersource.id,
         dic_usersource.name;
         
-- 3. Найдите процентную долю revenue по каждому письму за все время от общего revenue  в таблице db_Sales.
-- Важно! Для всех писем с dic_Messages
-- Набор столбцов в результирующем наборе :message_id - message_name - revenue - revenue from total 


SELECT 
      dic_message.id,
      dic_message.name,
      sum(revenue),
	  sales.revenue/(SELECT sum(revenue) FROM product.db_sales)*100 as revenue_from_total
      
FROM product.dic_message
left join 
(
SELECT
      message_id,
      sum(db_sales.revenue) as revenue,
      count(db_sales.message_id) as count_mes
From
product.db_sales
group by message_id
) sales
on dic_message.id = sales.message_id
group by 
      dic_message.id,
      dic_message.name;



-- 4.  Найдите разницу в днях между lastvisit и created_at (db_Users).
-- В зависимости от этого показателя найти количество пользователей с такой разбивкой:
-- ‘without login’ - lastvisit is null
-- ‘less 1 day’ -  DATEDIFF = 0
-- ‘1 day’
-- ‘2-5days’
-- ‘more 5 days’
Select 
      count(case when last_createdat < 1 then 'less 1 day' end ),
      count(case when last_createdat = 1 then '1 day' end ),
      count(case when last_createdat between 2 and 5 then '2-5 days' end),
      count(case when last_createdat > 5 then 'more 5 days' end)
From
(
SELECT 
      difference.last_createdat,
	  case when last_createdat < 1 then 'less 1 day'
       when last_createdat = 1 then '1 day'
       when last_createdat between 2 and 5 then '2-5 days'
       when last_createdat > 5 then 'more 5 days'
      else 'without login' end as visits
FROM 
( 
 Select
      convert (db_users.lastvisit, date) as lastvisit,
      convert ( db_users.created_at, date) as created_at,
      datediff(db_users.lastvisit,db_users.created_at) as last_createdat
  FROM product.db_users
  ) as difference
  ) as dif;


Select 
      count(case when last_createdat < 1 then 'less 1 day' end ),
      count(case when last_createdat = 1 then '1 day' end ),
      count(case when last_createdat between 2 and 5 then '2-5 days' end),
      count(case when last_createdat > 5 then 'more 5 days' end)
From
(
SELECT 
      convert (db_users.lastvisit, date) as lastvisit,
      convert ( db_users.created_at, date) as created_at,
      datediff(db_users.lastvisit,db_users.created_at) as last_createdat,
	  case when last_createdat < 1 then 'less 1 day'
       when last_createdat = 1 then '1 day'
       when last_createdat between 2 and 5 then '2-5 days'
       when last_createdat > 5 then 'more 5 days'
      else 'without login' end as visits
  ) as dif;


Select
    case when lastvisit is null then 'without login'
		when datediff(lastvisit, created_at) = 0 then 'less 1 day'
        when datediff(lastvisit, created_at) = 1 then '1 day'
        when datediff(lastvisit, created_at) > 1 AND datediff(lastvisit, created_at) <= 5 then '2-5days'
        when datediff(lastvisit, created_at) > 5 then 'more 5 days'
        else 'Undefined'
        end as type,
	count(*) as count_od_user_id
from product.db_users
group by
case when lastvisit is null then 'without login'
		when datediff(lastvisit, created_at) = 0 then 'less 1 day'
        when datediff(lastvisit, created_at) = 1 then '1 day'
        when datediff(lastvisit, created_at) > 1 AND datediff(lastvisit, created_at) <= 5 then '2-5days'
        when datediff(lastvisit, created_at) > 5 then 'more 5 days'
        else 'Undefined'
        end;












