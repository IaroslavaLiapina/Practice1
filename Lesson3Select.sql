#     		Таблица db_Users
# Узнать, сколько в базе пользователей с верификацией и сколько без нее
SET sql_mode = 'ONLY_FULL_GROUP_BY';
Select verified, 
       count(id)
From product.db_users
group by verified;

#	Найти распределение пользователей по источникам ( source_id)   
SELECT
source_id,
count(id)
FROM product.db_users
GROUP BY source_id;

#	Узнать, сколько в базе удаленных пользователей.
SELECT
count(id)
FROM product.db_users
WHERE is_deleted = 1;

 #	Найти 10 удаленных пользователей с максимальным количеством визитов.  
 
SELECT *
FROM product.db_users
WHERE is_deleted = 1
Order by numvisits desc 
Limit 14;
#    Отсортировать пользователей по убыванию даты последнего логина. Учитывать только пользователей, что пришли в сентябре.
 
SELECT *
FROM product.db_users
     WHERE created_at between '2020-09-01 00:00:00' and '2020-09-30 23:59:59'
	 Order by lastvisit desc;
#				db_EmailActivity
#   Найти только те message_id, у которых больше 100 событий.

SELECT 
    message_id, 
    count(*) as events
FROM product.db_emailactivity
group by message_id
having count(*) > 100
order by events desc;

#	Найти 3 contact_id, у которых больше всего писем.    
SELECT 
    contact_id, 
    count(distinct message_id) as u_message,
	count(message_id) as message
  FROM product.db_emailactivity
  group by contact_id
  order by u_message desc
  limit 3
  
  #			db_Sales
#   Найти message_id, который больше всего принес дохода.

SELECT 
    message_id,
    sum(revenue) as revenue
FROM product.db_sales
Group by message_id
Order by revenue desc;

# 	Сколько писем принесло больше $100?
SELECT 
    message_id,
    sum(revenue) as rev
FROM product.db_sales
Group by message_id
Having sum(revenue) > 100
Order by rev desc;

SELECT 
	distinct message_id
FROM product.db_Sales
	group by message_id
    having sum(revenue) > 100;
    
    #    Найти для каждого message_id средний доход от одного пользователя.
SELECT 
    message_id,
    sum(revenue),
    count(distinct contact_id),
    sum(revenue)/count(distinct contact_id) as rev_per_user
FROM product.db_sales
Group by message_id
having count(distinct contact_id) > 10
order by rev_per_user desc;
