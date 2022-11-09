-- 1. Для message_id in ( ‘2122670’, ‘2133758’ , ’2126244)
-- для каждого дня августа 2020 года выведите следующий набор:
-- Набор столбцов в результирующем наборе :date - message_id - message_name - count of unic delivered contact_id_ids - Revenue

WITH RECURSIVE dates_range (d) AS 
(
   SELECT
      '2020-08-01' 
   UNION ALL
   SELECT
      d + INTERVAL 1 DAY 
   FROM
      dates_range 
   WHERE
      d + INTERVAL 1 day <= '2020-08-31' 
),
Message_idm as
(
SELECT 
   id as message_id,
   name as message_name
FROM product.dic_message
WHERE id in ( 2122670, 2133758 , 2126244) 
),
Revenues as 
(
SELECT
   date(created_at) as datem,
   message_id as message_idm,
   sum(revenue) as revenuem
FROM
   product.db_Sales 
GROUP BY
   date(created_at),
   message_id
),
Delivered as
(
SELECT 
   date(created_at) as dateemail,
   message_id as mes_id_mail,
   count(distinct Case when db_EmailActivity.status_id = 2 then db_EmailActivity.contact_id end ) as count_of_unic_delivered_contact_id_ids
FROM product.db_emailactivity
GROUP BY
   date(created_at),
   message_id
)
SELECT 
   dates_range.d as Mdate,
   Message_idm.message_id,
   Message_idm.message_name,
   Delivered.count_of_unic_delivered_contact_id_ids,
   Revenues.revenuem
FROM dates_range
CROSS JOIN Message_idm
LEFT JOIN Delivered
  ON dates_range.d = Delivered.dateemail and Message_idm.message_id = Delivered.mes_id_mail
LEFT JOIN Revenues
  ON dates_range.d = Revenues.datem and Message_idm.message_id = Revenues.message_idm;

-- 2. Для каждого дня в сентябре выведите данные о количестве пользователей с db_EmailActivity по каждому статусу.
-- Набор столбцов в результирующем наборе: date - status_name - count of uniq contact_ids


WITH RECURSIVE dates_range (d) AS 
(
   SELECT
      '2020-09-01' 
   UNION ALL
   SELECT
      d + INTERVAL 1 DAY 
   FROM
      dates_range 
   WHERE
      d + INTERVAL 1 day <= '2020-09-30' 
),
EmailActivity as
(
SELECT 
  status_id,
  dic_emailstatus.id as emailstatusid,
  date(created_at) as date_create,
  count(distinct contact_id) as count_of_uniq_contact_ids
FROM product.db_emailactivity
left join product.dic_emailstatus
on db_emailactivity.status_id = dic_emailstatus.id
group by 
  status_id,
  dic_emailstatus.id,
  date(created_at)
)
select 
   d as Mdate,
   dic_emailstatus.name as status_name,
   EmailActivity.count_of_uniq_contact_ids
from dates_range
cross join product.dic_emailstatus
left join EmailActivity
  on dates_range.d = EmailActivity.date_create and dic_emailstatus.id = EmailActivity.emailstatusid
;

WITH RECURSIVE dates_range (d) AS 
(
    SELECT
      '2020-09-01' 
   UNION ALL
   SELECT
      d + INTERVAL 1 DAY 
   FROM
      dates_range 
   WHERE
      d + INTERVAL 1 day <= '2020-09-30'
),
EmailActivity as
(
SELECT 
  status_id,
  dic_emailstatus.id as emailstatusid,
  date(created_at) as date_create,
  count(distinct contact_id) as count_of_uniq_contact_ids
FROM product.db_emailactivity
left join product.dic_emailstatus
on db_emailactivity.status_id = dic_emailstatus.id
group by 
  status_id,
  dic_emailstatus.id,
  date(created_at)
)
select 
   d as Mdate,
   dic_emailstatus.name as status_name,
   EmailActivity.count_of_uniq_contact_ids
from dates_range
cross join product.dic_emailstatus
left join EmailActivity
  on dates_range.d = EmailActivity.date_create and dic_emailstatus.id = EmailActivity.emailstatusid
;


