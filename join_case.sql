#  		JOINS
# 	client_id – count of sales -  count of emails
SELECT db_actions.client_id,
       count(distinct db_sales.id) as sales,
       count(distinct db_emailactivity.message_id) as message
FROM product.db_actions
left join product.db_contacts
on db_actions.user_id = db_contacts.user_id
left join product.db_sales
on db_contacts.id = db_sales.contact_id
left join product.db_emailactivity
on db_contacts.id = db_emailactivity.contact_id
group by db_actions.client_id;


SELECT
   db_Actions. client_id,
   count(distinct db_Sales.id) as sales,
   count(distinct db_EmailActivity.message_id) as messages 
FROM
   product.db_Actions 
   LEFT join
      product.db_Contacts 
      on db_Actions.user_id = db_Contacts.user_id 
   LEFT join
      product.db_Sales 
      on db_Contacts.id = db_Sales.contact_id 
   LEFT join
      product.db_EmailActivity 
      on db_Contacts.id = db_EmailActivity.contact_id 
group by
   db_Actions. client_id ;

#	message_id – message_name-  revenue

SELECT
   db_Sales.message_id,
   dic_Message.name as message_name,
   sum(db_Sales.revenue) as revenue 
FROM
   product.db_Sales 
   join
      product.dic_Message 
      on db_Sales.message_id = dic_Message.id 
group by
   db_Sales.message_id,
   dic_Message.name 
order by
   3 desc;


#		message_id – message_name - status – count of users – count of ids

SELECT  
      dic_message.id as message_id,
      dic_message.name as message_name,
      dic_emailstatus.name as status,
      count(distinct db_emailactivity.contact_id) as users,
      count(distinct db_emailactivity.id)

FROM product.dic_message
left join product.db_emailactivity
on dic_message.id = db_emailactivity.message_id
left join product.dic_emailstatus
on db_emailactivity.status_id = dic_emailstatus.id
group by 
	  dic_message.id,
      dic_message.name,
      dic_emailstatus.name;

SELECT
   dic_Message.id as message_id,
   dic_Message.name as message_name,
   dic_EmailStatus.name as status,
   count(distinct db_EmailActivity.contact_id) as users,
   count(distinct db_EmailActivity.id) as events 
FROM
   product.dic_Message 
   LEFT join
      db_EmailActivity 
      on dic_Message.id = db_EmailActivity.message_id 
   LEFT JOIN
      dic_EmailStatus 
      on db_EmailActivity.status_id = dic_EmailStatus.id 
group by
   dic_Message.id,
   dic_Message.name,
   dic_EmailStatus.name;
        
 # 		User_id – contact_id – client_id - source – is_deleted – verified – count of messages with clicks 
     SELECT 
           db_Users.id as user_id,
   db_Contacts.id as contact_id,
   ClientIDs.client_id,
   dic_UserSource.name as source,
   db_Users.is_deleted,
   db_Users.verified,
   count(distinct db_EmailActivity.message_id) as clicked_messages 
     FROM product.db_users
     left join product.db_contacts
     on db_users.id = db_contacts.user_id
     left join  (
         Select distinct
            user_id,
            client_id 
         from
            product.db_Actions 
            where client_id is not null
      )
      ClientIDs 
      on db_Users.id = ClientIDs.user_id 
      LEFT join
      product.dic_UserSource 
      on db_Users.source_id = dic_UserSource.id 
   LEFT join
      product.db_EmailActivity 
      on db_Contacts.id = db_EmailActivity.contact_id 
      and db_EmailActivity.status_id = 1 
group by
   db_Users.id,
   db_Contacts.id,
   ClientIDs.client_id,
   dic_UserSource.name,
   db_Users.is_deleted,
   db_Users.verified;
   
     
     
SELECT
   db_Users.id as user_id,
   db_Contacts.id as contact_id,
   ClientIDs.client_id,
   dic_UserSource.name as source,
   db_Users.is_deleted,
   db_Users.verified,
   count(distinct db_EmailActivity.message_id) as clicked_messages 
  -- count(distinct case when db_EmailActivity.status_id = 1  then db_EmailActivity.message_id end )
FROM
   product.db_Users 
   LEFT join
      product.db_Contacts 
      on db_Users.id = db_Contacts.user_id 
   LEFT join
      (
         Select distinct
            user_id,
            client_id 
         from
            product.db_Actions 
            where client_id is not null
      )
      ClientIDs 
      on db_Users.id = ClientIDs.user_id 
   LEFT join
      product.dic_UserSource 
      on db_Users.source_id = dic_UserSource.id 
   LEFT join
      product.db_EmailActivity 
      on db_Contacts.id = db_EmailActivity.contact_id 
      and db_EmailActivity.status_id = 1 
group by
   db_Users.id,
   db_Contacts.id,
   ClientIDs.client_id,
   dic_UserSource.name,
   db_Users.is_deleted,
   db_Users.verified
   
   
   
   
 -- Пример дублирования данных
   
   SELECT
   db_Users.id as user_id,
   db_Contacts.id as contact_id,
   db_Sales.id as sales_id,
   db_Sales.revenue as sales_revenue,
   db_EmailActivity.id as activity_id 
FROM
   product.db_Users 
   join
      product.db_Contacts 
      on db_Users.id = db_Contacts.user_id 
   join
      product.db_Sales 
      on db_Contacts.id = db_Sales.contact_id 
   join
      product.db_EmailActivity 
      on db_EmailActivity.contact_id = db_Contacts.id 
where
   db_Contacts.id = 841309588