-- Набор столбцов в результирующем наборе : Message id - Message name -  count of sales – count of unique contact_id with sales – count of unique  contact_id
    SELECT  
          dic_message.id as message_id,
          dic_message.name as message_name,
          count(distinct db_sales.id) as count_of_sales,
          count(distinct db_sales.contact_id) as unique_contact_id_with_sales,
          count(distinct db_contacts.id) as unique_contact_id
    
    FROM product.dic_message 
    left join product.db_sales
    on dic_message.id = db_sales.message_id
    left join product.db_contacts
    on db_sales.contact_id = db_contacts.id
    group by dic_message.id,
          dic_message.name;
    
   
      SELECT 
  dic_message.id as message_id,
  dic_message.name as message_name,
  count(distinct db_sales.id) as sales,
  count(distinct db_sales.contact_id) as unique_sales,
  count(distinct db_emailactivity.contact_id) as unique_id
FROM 
  product.dic_message
left join 
  product.db_sales
on dic_message.id = db_sales.message_id
left join 
 product.db_contacts
on db_sales.contact_id = db_contacts.id
left join 
 product.db_emailactivity
on db_contacts.id = db_emailactivity.contact_id
  group by
   dic_message.id,
   dic_message.name;

--  Важно! В результирующем наборе должны быть все пользователи User id – email – source. Проверяйте дубликаты при соединении таблиц, используйте подзапросы и join уже к ним. Обращайте внимание на revenue! 

-- Набор столбцов в результирующем наборе : User id – email – source – count of clicked unique message_id -count of read unique message_id - count of delivered unique message_id– revenue

SELECT 
      db_users.id as User_id,
      db_users.email as Email,
      dic_usersource.name as Sourceq,
      EmailActivity.READw,
      EmailActivity.DELIVERED,
      EmailActivity.clicked,	
      sum(db_Sales.revenue) as revenue

FROM product.db_users
Left join product.dic_usersource
on db_users.source_id = dic_usersource.id
left join 
( Select id, user_id From product.db_contacts) as CONTACTS
on db_users.id = CONTACTS.user_id
left join
( Select db_emailactivity.contact_id, 
        count(distinct CASE When db_emailactivity.status_id = 3 Then db_emailactivity.message_id end) as READw,
        count(distinct CASE When db_emailactivity.status_id = 2 Then db_emailactivity.message_id end) as DELIVERED,
        count(distinct case when db_emailactivity.status_id = 1 then db_emailactivity.message_id end) as clicked
 From product.db_emailactivity
 group by db_emailactivity.contact_id) as EmailActivity
on CONTACTS.id = EmailActivity.contact_id
left join product.db_sales
on CONTACTS.id = db_sales.contact_id      
group by 
      db_users.id ,
      db_users.email ,
      dic_usersource.name ;  

SELECT 
db_users.id as user_id,
db_users.email as email,
db_users.source_id as sources,
emailactivity.unique_clicked,
emailactivity.unique_readm,
emailactivity.unique_delivered,
sum(db_Sales.revenue) as revenue
FROM 
	product.db_users
left join
	product.db_contacts
on db_users.id = db_contacts.user_id
left join
(select db_emailactivity.contact_id,
count(distinct case when db_emailactivity.status_id = 1 then db_emailactivity.message_id end) as unique_clicked,
count(distinct case when db_emailactivity.status_id = 3 then db_emailactivity.message_id end) as unique_readm,
count(distinct case when db_emailactivity.status_id = 2 then db_emailactivity.message_id end) as unique_delivered
from product.db_emailactivity
group by db_emailactivity.contact_id
) as
emailactivity
on db_contacts.id = emailactivity.contact_id
left join
product.db_sales
on db_contacts.id = db_sales.contact_id
group by
db_users.id,
db_users.email,
db_users.source_id;

-- Пользователи, которые не получили ни одного письма за все время (не важно, с каким статусом).

SELECT
   db_Users.id as user_id,
   db_users.email as email
FROM
   product.db_Users 
   LEFT join
      product.db_Contacts 
      on db_Users.id = db_Contacts.user_id 
   LEFT join
	product.db_emailactivity 
    on db_Contacts.id = db_emailactivity.contact_id
	where db_emailactivity.status_id is null



