SELECT * FROM example.df_orders;

#find top 10 highest revenue generating products

use example;
select product_id,sum(sales_price) as total  
	from df_orders 
    group by product_id 
    order by total desc
    limit 11;

#find top 5 selling products  in each region
with main as (
	select region,product_id,sum(sales_price) as total
	from df_orders
	group by region,product_id
	)
    select * from (
		select *,
        row_number() over(partition by region order by total desc) as rn
		from main) A
    where rn<=5; 
    
#find month over month growth comparision for 2022 and 2023 sales eg : jan 2022 vs jan 2023
with main as(
	select year(order_date) as order_year,
			month(order_date) as order_month,
			sum(sales_price) as total
			from df_orders
			group by year(order_date),month(order_date))
	select order_month,
		sum(case when order_year=2022 then total else 0 end) as sales_2022,
        sum(case when order_year=2023 then total else 0 end) as sales_2023
        from main
        group by order_month
        order by order_month;
        
	#for each category which month had highest sales
    with main as(
		select category,
			date_format(order_date,'%Y%m') as yearmonth,
			sum(sales_price) as total
			from df_orders
			group by category,
			date_format(order_date,'%Y%m') )
	select * from 
	(select *,
		row_number() over(partition by category order by total desc) as rn
        from main) A
    where rn=1;
	
    
#which sub category has the highest growth by profit in 2023 comapre to 2022
with main as(
	select sub_category,year(order_date) as order_year,
			
			sum(sales_price) as total
			from df_orders
			group by sub_category,year(order_date)),
	 main2 as(
		select sub_category,
			sum(case when order_year=2022 then total else 0 end) as sales_2022,
			sum(case when order_year=2023 then total else 0 end) as sales_2023
			from main
			group by sub_category)
        select *,((sales_2023-sales_2022)*100/sales_2022)  as growthpercentage
			from main2
            order by growthpercentage desc limit 1;