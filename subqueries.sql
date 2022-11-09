# 		Подзапросы
# 	Найти Email Activity только по тем письмам, которые в своем названии содержат ’Promo’
# 	Совет1: если в вашем запросе больше 1 таблицы, вызывайте столбцы с приставкой названия таблицы, например db_EmailActivity.message_id
# 	Совет2: старайтесь избегать * в запросах, выбирайте только нужные столбцы

SELECT 
	* ,
    (Select name from product.dic_Message where db_EmailActivity.message_id = dic_Message.id) as message_name # коррелирующий подзапрос
FROM product.db_EmailActivity
	where message_id in 
		( SELECT id FROM product.dic_Message where name like 'Promo%' ); # некоррелирующий запрос

#	Найти количество пользователей, которые прочитали больше 2ух уникальных писем.
# Совет3: при сложных запросах начинайте с вложенных запросов и наращивайте их. 

Select 
	count(contact_id) as contacts
from (
		SELECT 
			contact_id,
			count( distinct message_id) as counts
		FROM product.db_EmailActivity
			where status_id = 3
			group by contact_id
			having count( distinct message_id) > 2 ) ActiveContacts;

 #		Найти user_id пользователей, у которых больше трех покупок (db_Sales) 
 
SELECT 
	user_id 
FROM product.db_Contacts
	where id in (
			SELECT 
				contact_id
			FROM product.db_Sales
				group by contact_id
				having count(id)  > 3 ) ;


#	Необходимо найти активный сегмент:  
#	список user_id, которые купили больше чем на $20 или совершили больше 5 неуникальных ивентов. 
#	Учитывать только не удаленные и верифицированные контакты.


Select   
	user_id 	
from 
	(              
		SELECT 
			user_id 
		FROM product.db_Contacts
			where id in (
				SELECT 
					contact_id
				FROM product.db_Sales
					group by contact_id
					having sum(revenue)  > 20 )    
		union 
        
		SELECT 
			user_id
		FROM product.db_Actions
			group by user_id
			having count(id) > 2 
	) ActiveSEgment
where user_id in 
(SELECT user_id FROM product.db_Users where is_deleted = 0 and verified = 1);
