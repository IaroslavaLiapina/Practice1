# Recursive CTE 

WITH RECURSIVE dates_range (d) AS
(
  SELECT CURDATE() - INTERVAL 124 DAY
  UNION ALL
  SELECT d + INTERVAL 1 DAY FROM dates_range WHERE d + INTERVAL 1 day <= CURDATE()
)
Select * from dates_range ;


#	Переделаем последний запрос с 6 лекции на новый с использованием CTE
# 		Найти количество пользователей в разрезе на статусы и revenue по группам писем групп :Discount, Promo, Sale.  
# 	Было:

Select 
		Message_type,
        CLICKED,
        DELIVERED,
        READM,
        SPAM,
        SUBSCRIPTION_CHANGED
		UNDELIVERED,
        UNSUBSCRIBED,
        MessageRevenue.Revenue,
        MessageRevenue.Revenue/DELIVERED as revenue_per_user
 from ( 
 
 SELECT 
		case when dic_Message.name like '%discount%' then 'Discount' else
        case when dic_Message.name like 'Promo%' then 'Promo' else
		case when dic_Message.name like 'Sale%' then 'Sale' else 'Other' end end end as Message_type,
        
        count(distinct Case when db_EmailActivity.status_id = 1 then db_EmailActivity.message_id end ) as CLICKED,
        count(distinct Case when db_EmailActivity.status_id = 2 then db_EmailActivity.message_id end ) as DELIVERED,
        count(distinct Case when db_EmailActivity.status_id = 3 then db_EmailActivity.message_id end ) as READM,
        count(distinct Case when db_EmailActivity.status_id = 4 then db_EmailActivity.message_id end ) as SPAM,
		count(distinct Case when db_EmailActivity.status_id = 5 then db_EmailActivity.message_id end ) as SUBSCRIPTION_CHANGED,       
 		count(distinct Case when db_EmailActivity.status_id = 6 then db_EmailActivity.message_id end ) as UNDELIVERED,
 		count(distinct Case when db_EmailActivity.status_id = 7 then db_EmailActivity.message_id end ) as UNSUBSCRIBED 
        
 FROM product.db_EmailActivity
 join product.dic_Message
 on db_EmailActivity.message_id = dic_Message.id
  group by 1 
  ) MessageStatus
 left join 
		( select
				case when dic_Message.name like '%discount%' then 'Discount' else
				case when dic_Message.name like 'Promo%' then 'Promo' else
				case when dic_Message.name like 'Sale%' then 'Sale' else 'Other' end end end as MessageType,
                sum(Revenue) as Revenue
        from product.db_Sales
        join product.dic_Message
		on db_Sales.message_id = dic_Message.id
        group by 1
        ) MessageRevenue
        on MessageStatus.Message_type = MessageRevenue.MessageType ;

# 	Стало 

With Messages as 
(
   select
		id as mess_id,
		case when dic_Message.name like '%discount%' then 'Discount' else
        case when dic_Message.name like 'Promo%' then 'Promo' else
		case when dic_Message.name like 'Sale%' then 'Sale' else 'Other' end end end as Mess_type
        from
      product.dic_Message 
)
, MessageRevenue as 
(
   select
      mess_type,
      sum(Revenue) as Revenue 
   from
      product.db_Sales 
      join
         Messages 
         on db_Sales.message_id = Messages.mess_id 
   group by
      mess_type 
)
,
MessagesStatus as 
(
   SELECT
		Messages.mess_type,
        count(distinct Case when db_EmailActivity.status_id = 1 then db_EmailActivity.message_id end ) as CLICKED,
        count(distinct Case when db_EmailActivity.status_id = 2 then db_EmailActivity.message_id end ) as DELIVERED,
        count(distinct Case when db_EmailActivity.status_id = 3 then db_EmailActivity.message_id end ) as READM,
        count(distinct Case when db_EmailActivity.status_id = 4 then db_EmailActivity.message_id end ) as SPAM,
		count(distinct Case when db_EmailActivity.status_id = 5 then db_EmailActivity.message_id end ) as SUBSCRIPTION_CHANGED,       
 		count(distinct Case when db_EmailActivity.status_id = 6 then db_EmailActivity.message_id end ) as UNDELIVERED,
 		count(distinct Case when db_EmailActivity.status_id = 7 then db_EmailActivity.message_id end ) as UNSUBSCRIBED 
        
   FROM
      product.db_EmailActivity 
      join
         Messages 
         on db_EmailActivity.message_id = Messages.mess_id 
   group by
      mess_type 
)

Select
   MessagesStatus.Mess_type,
   CLICKED,
   DELIVERED,
   READM,
   SPAM,
   SUBSCRIPTION_CHANGED UNDELIVERED,
   UNSUBSCRIBED,
   MessageRevenue.Revenue,
   MessageRevenue.Revenue / DELIVERED as revenue_per_user 
from
   MessagesStatus 
   left join
      MessageRevenue 
      on MessagesStatus.Mess_type = MessageRevenue.Mess_type ;

#			Создать dv_Sales 
#	Date – revenue – count of created users - count of users with sales
#	Необходимо сделать разбивку по дням, 
#	даже если в этот день не было создано пользователей или не было покупок
#	Примечание: В запросе на создание view так же может быть CTE
#	Date range – 2020/6/1 – 2020/11/1 
    
      
    Create view product.dv_Sales as  
      WITH RECURSIVE dates_range (d) AS 
(
   SELECT
      '2020-06-01' 
   UNION ALL
   SELECT
      d + INTERVAL 1 DAY 
   FROM
      dates_range 
   WHERE
      d + INTERVAL 1 day <= '2020-11-01' 
)
,
Revenues as 
(
   Select
      date(created_at) as date,
      sum(revenue) as revenue,
      count(distinct contact_id) as users_sales 
   from
      product.db_Sales 
   group by
      1 
)
,
Users as 
(
   SELECT
      date(created_at) as date,
      count(id) as users 
   FROM
      product.db_Users 
   group by
      1 
)
Select
   d as date,
   Revenues.revenue,
   Revenues.users_sales,
   Users.users 
from
   dates_range 
   left join
      Revenues 
      on dates_range.d = Revenues.date 
   left join
      Users 
      on dates_range.d = Users.date ;
      

# 	 Сделать для аналогичного диапазона дат запрос:
#	 Date-user source – count of created users
#	 Важно чтобы в результате для каждого источника была дата,
#	 даже если пользователей в этот день не было создано  
WITH RECURSIVE dates_range (d) AS 
(
   SELECT
      '2020-06-01' 
   UNION ALL
   SELECT
      d + INTERVAL 1 DAY 
   FROM
      dates_range 
   WHERE
      d + INTERVAL 1 day <= '2020-11-01' 
)
,
Users as 
(
SELECT
      date(db_Users.created_at) as date,
      dic_UserSource.name as user_source,
      count(db_Users.id) as users 
   FROM
      product.db_Users 
      join
         product.dic_UserSource 
         on db_Users.source_id = dic_UserSource.id 
   group by
      date(db_Users.created_at),
      dic_UserSource.name 
)
Select
   d as date,
   dic_UserSource.name as source,
   Users.users 
from
   dates_range 
   cross join
      product.dic_UserSource 
   left join
      Users 
      on dates_range.d = Users.date 
      and dic_UserSource.name = Users.user_source;


