#			Views
#		Представление dv_Correlation
#	Date – count of delivered emails – count of sales


Create view product.dv_Correlation as
select DATES,
       sum(UNIONS.EMAILS) as emails,
       sum(UNIONS. SALES) as sales
from 
(
SELECT 
      convert(created_at, date) as DATES,
      count(id) as EMAILS,
      0 as SALES
FROM product.db_emailactivity
Where status_id = 2
group by 1
Union all
SELECT 
       convert(created_at, date) as DATES,
       0 as EMAILS,
       count(id) as SALES
FROM product.db_sales
group by 1
) as  UNIONS
group by 1;



# 			Представление dv_ProductFunnel

#	date - Client_id – count of sales - revenue- count of emails
SELECT distinct
       db_actions.client_id,
       db_contacts.id as contact_id
FROM product.db_actions
left join product.db_contacts
on db_actions.user_id = db_contacts.user_id;


-- example
Select
   UnionTable.Date,
   db_Actions.client_id,
   max(UnionTable.Sales) as Sales,
   max(UnionTable.Revenue) as Revenue,
   max(UnionTable.Messages) as Messages 
from
   (
      Select
         convert(created_at, date) as Date,
         contact_id,
         count(id) as Sales,
         sum(revenue) as Revenue,
         0 as Messages 
      from
         product.db_Sales 
      group by
         convert(created_at, date),
         contact_id 
      union all
      Select
         convert(created_at, date) as Date,
         contact_id,
         0,
         0,
         count(distinct message_id) as Messages 
      from
         product.db_EmailActivity 
      group by
         convert(created_at, date),
         contact_id 
   )
   UnionTable 
   join
      product.db_Contacts 
      on UnionTable.contact_id = db_Contacts.id 
   join
      product.db_Actions 
      on db_Contacts.user_id = db_Actions.user_id 
   where  db_Actions.client_id is not null
group by 1, 2 ;





# 			Представление dv_ProductFunnel

#	date - Client_id – count of sales - revenue- count of emails



create view product.dv_ProductFunnel as
SELECT
      Dates,
      client_id,
      max(sales) as sales,
      max(revenue) as revenue,
      max(messages)as messages
FROM 
(
-- date - Client_id – count of sales - revenue
SELECT
      convert(db_sales.created_at, date) as Dates,
      dic_contacts.client_id,
      count(distinct db_sales.id) as sales,
      sum(db_sales.revenue) as revenue,
      0 as messages
FROM
(
SELECT 
       distinct
       db_actions.client_id,
       db_contacts.id as contact_id
FROM product.db_actions
left join product.db_contacts
on db_actions.user_id = db_contacts.user_id 
) dic_contacts
inner join product.db_sales
on dic_contacts.contact_id = db_sales.contact_id
group by 
       convert(db_sales.created_at, date),
       dic_contacts.contact_id
       
union all  
     
-- date - Client_id - count of emails
SELECT
      convert(db_emailactivity.created_at, date) as Dates,
      dic_contacts.client_id,
      0 as sales,
      0 as revenue,
      count(db_emailactivity.id) as messages
From
( 
SELECT
       distinct
       db_actions.client_id,
       db_contacts.id as contact_id
FROM product.db_actions
left join product.db_contacts
on db_actions.user_id = db_contacts.user_id
) dic_contacts
inner join product.db_emailactivity
on dic_contacts.contact_id = db_emailactivity.contact_id
group by 
      convert(db_emailactivity.created_at, date),
      dic_contacts.client_id
) Unions
group by 
       Dates,
       client_id;






