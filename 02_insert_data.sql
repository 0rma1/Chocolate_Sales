CREATE TEMP TABLE temp_sales (
sales_person TEXT,
country TEXT,
product TEXT,
date DATE,
amount NUMERIC,
boxes_shipped INTEGER
);

COPY temp_sales FROM 'D:\Desktop\Chocolate Sales.csv'
DELIMITER ';' CSV HEADER; 

INSERT INTO Sales_Persons(name)
SELECT DISTINCT sales_person FROM temp_sales
ON CONFLICT (name) DO NOTHING;

INSERT INTO Countries (country_name)
SELECT DISTINCT country FROM temp_sales
ON CONFLICT (country_name) DO NOTHING;

INSERT INTO Products (product_name)
SELECT DISTINCT product FROM temp_sales
ON CONFLICT (product_name) DO NOTHING;

INSERT INTO Sales (sales_person_id, country_id, product_id, date, amount, boxes_shipped )
SELECT
	sp.id, c.id, p.id,
	t.date,
	t.amount,
	t.boxes_shipped
FROM temp_sales t
JOIN Sales_Persons sp ON t.sales_person = sp.name
JOIN Countries c ON t.country = c.country_name
JOIN Products p ON t.product = p.product_name;

DROP TABLE temp_sales;