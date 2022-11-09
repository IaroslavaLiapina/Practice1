-- 1. Найти 10 записей с product.db_Actions по action_id = 2 и created_at отсортированному по возрастанию
SELECT *
FROM product.db_actions
Where action_id = 2
Order by created_at asc
Limit 10;    

-- 2. Для каждого action_id в product.db_Actions вывести минимальную и максимальную дату совершения события. Данные отсортировать по возрастанию минимальной даты. 
SELECT 
    action_id,
    min(created_at) as min_date,
    max(created_at) as max_date
FROM product.db_actions
group by action_id
order by min_date desc;

-- 3. Найти message_id с наибольшим количеством уникальных contact_id (db_Sales) 
SELECT 
    message_id,
    count(distinct contact_id) as uniq_contact_id
FROM product.db_sales
group by message_id
order by uniq_contact_id desc;

-- 4. Найти 3 дня с максимальным количеством уникальных contact_id (db_Sales)
SELECT
     created_at,
     count(distinct contact_id) as uniq_cont_id
FROM product.db_sales
group by created_at
order by uniq_cont_id desc 
limit 3;

-- 5. Найти количество уникальных email с верификацией и количеством визитов = 1 
SELECT 
    count(distinct email) as uniq_email
FROM product.db_users
Where verified = 1 and numvisits = 1;

-- 6. Найти дату создания контакта с максимальным количеством визитов  
SELECT 
    created_at
FROM product.db_users
order by numvisits desc
limit 1;

SELECT 
   created_at, 
   sum(numvisits) as numvisits
FROM product.db_Users  
group by created_at  
order by numvisits desc 
limit 1; 

-- . Найти топ 5 дней с наибольшим количеством уникальных contact_id со статусом = 2 (db_EmailActivity)  

SELECT
    status_id, 
    cast(created_at as date) as new_date,
    count(distinct contact_id) as uniq_contact_id
FROM product.db_emailactivity
Where status_id = 2
group by new_date
order by  uniq_contact_id desc
limit 5;

SELECT 
   cast(created_at as date) as date, 
   count(distinct contact_id) as contacts  
FROM product.db_EmailActivity  
where status_id = 2  
group by 1  
order by 2 desc limit 5; 

-- 8. Найти количество событий action_id = 22 с разбивкой на названия источников пользователя 

SELECT 
   dic_UserSource.name, 
   COUNT(db_Actions.id) AS events   
from product.db_actions
 JOIN 
      product.db_Users  
      ON db_Actions.user_id = db_Users.id  
   JOIN 
      product.dic_UserSource  
      ON db_Users.source_id = dic_UserSource.id  
WHERE 
   db_Actions.action_id = 22  
GROUP BY 
   dic_UserSource.name  
ORDER BY 
   2 DESC  ;


-- 9. Найти количество уникальных прочитанных писем только по пользователям с источником - Google account 



SELECT 
      count(distinct db_EmailActivity.message_id) as read_messages  
   FROM 
      product.db_EmailActivity  
      join 
         product.db_Contacts  
         on db_EmailActivity.contact_id = db_Contacts.id  
      join 
         product.db_Users  
         on db_Contacts.user_id = db_Users.id  
   where 
      db_Users.source_id = 1  
      and db_EmailActivity.status_id = 3;

-- 10. Найти количество уникальных отправленных писем удаленным пользователям 

SELECT 
      count(distinct db_emailactivity.message_id) as uniq
FROM product.db_emailactivity
left join product.db_contacts
on db_emailactivity.contact_id = db_contacts.id
left join  product.db_users
on db_contacts.user_id = db_users.id
Where db_users.is_deleted = 1
and db_EmailActivity.status_id = 2;


-- 11. Найти сумму revenue, которое сделали только верифицированные пользователи 

SELECT sum(db_sales.revenue) as revenue

FROM product.db_sales
left join product.db_contacts
on db_sales.contact_id = db_contacts.id
left join product.db_users
on db_contacts.user_id = db_users.id
where db_users.verified = 1

-- 12. Найти сумму revenue, которое сделали пользователи, которым было отправлено более 3 писем (не обязательно уникальных) в разбивке на столбец is_deleted. 

SELECT 
      sum( db_sales.revenue) as suma,
      db_users.is_deleted
FROM product.db_sales

left join product.db_contacts
on db_sales.contact_id = db_contacts.id
 join 
            product.db_Users  
            on db_Contacts.user_id = db_Users.id 
where  db_Sales.contact_id in
(
Select contact_id
From product.db_emailactivity
Where status_id = 2
group by contact_id
having count(message_id) > 3  
 ) 
group by db_users.is_deleted;

 --  13. Найти сумму revenue с разбивкой на названия писем, письмо выводить, только если его прочитали хотя бы 50 уникальных пользователей. 
 -- Вывести только топ 3 по сумме revenue. 
 
 SELECT sum(db_sales.revenue),
		dic_message.name 
 FROM product.db_sales
        left join product.dic_message
         on db_sales.message_id = dic_message.id
                left join 
 ( SELECT 
            message_id  
         FROM 
            product.db_EmailActivity  
         where 
            status_id = 3  
         group by 
            message_id  
         having 
            count(distinct contact_id) >= 50  ) as uniq_mail
  on db_sales.message_id = uniq_mail.message_id
 group by dic_message.name
 order by 1 desc
 limit 3;
 

 
 
 
 
 