/* All sales */
SELECT * FROM Sales;

/* All sales by Jehu Rudeforth */
SELECT * FROM Sales
WHERE sales_person_id =
	(SELECT id FROM Sales_Persons
		WHERE name = 'Jehu Rudeforth');

/* All sales by Jehu Rudeforth in 'UK' */
SELECT s.* 
FROM Sales s
JOIN Sales_Persons sp ON s.sales_person_id = sp.id
JOIN Countries c ON s.country_id = c.id
WHERE sp.name = 'Jehu Rudeforth'
AND c.country_name = 'UK';

/* Salespeople with total sales over $50.000 */
SELECT sp.name, SUM(s.amount) AS total_sales
FROM Sales s
JOIN Sales_Persons sp ON s.sales_person_id = sp.id
GROUP BY sp.name
HAVING SUM(s.amount) > 50000
ORDER BY total_sales DESC;
 
/* Sales by country */
SELECT s.*, c.country_name
FROM Sales s
JOIN Countries c ON s.country_id = c.id
WHERE c.country_name = 'UK';

/* Categorization of sales based on amount */
SELECT s.id, s.amount,
	CASE
		WHEN s.amount > 10000 THEN 'High Sale'
		WHEN s.amount BETWEEN 5000 AND 10000 THEN 'Medium Sale'
		ELSE 'Low Sale'
	END AS sale_category
FROM Sales s;

/* Sales over $10,000 in May 2022 */
SELECT *
FROM Sales
WHERE amount > 10000
AND EXTRACT(YEAR FROM date) = 2022
AND EXTRACT(MONTH FROM date) = 5;

/* Top-5 sellers by total sales amount */
SELECT sp.name, SUM(s.amount) AS total_sales
FROM Sales s
JOIN Sales_Persons sp ON s.sales_person_id =sp.id
GROUP BY sp.name
ORDER BY total_sales DESC
LIMIT 5;

/*Top-3 best-selling products */
SELECT p.product_name, SUM(s.boxes_shipped) AS total_boxes
FROM Sales s
JOIN Products p ON s.product_id = p.id
GROUP BY p.product_name
ORDER BY total_boxes DESC
LIMIT 3;

/* Number of sales per salesperson */
SELECT sp.name, COUNT(s.id) AS total_sales
FROM Sales s
JOIN Sales_Persons sp ON s.sales_person_id = sp.id
GROUP BY sp.name
ORDER BY total_sales DESC;

/* Total revenue per country */
SELECT c.country_name, SUM(s.amount) AS total_revenue
FROM Sales s
JOIN Countries c ON s.country_id = c.id
GROUP BY c.country_name
ORDER BY total_revenue DESC;

/* Average number of boxes shipped per country */
SELECT c.country_name, ROUND(AVG(s.boxes_shipped), 2) AS avg_boxes
FROM Sales s
JOIN Countries c ON s.country_id = c.id
GROUP BY c.country_name
ORDER BY avg_boxes DESC;

/* All sales for the first half of the year containing "Choco" */
SELECT s.*, p.product_name
FROM Sales s
JOIN Products p ON s.product_id = p.id
WHERE s.date BETWEEN '2022-01-01' AND '2022-06-30'
AND p.product_name ILIKE '%Choco%';

/* Top seller for each month */
SELECT sp.name, 
       TO_CHAR(DATE_TRUNC('month', s.date), 'YYYY-MM') AS month, 
       SUM(s.amount) AS total_sales,
       RANK() OVER (PARTITION BY DATE_TRUNC('month', s.date) ORDER BY SUM(s.amount) DESC) AS rank
FROM Sales s
JOIN Sales_Persons sp ON s.sales_person_id = sp.id
GROUP BY sp.name, DATE_TRUNC('month', s.date)
ORDER BY month, rank;

/* Sales dynamic per month */
SELECT TO_CHAR(DATE_TRUNC('month', CAST(date AS DATE)), 'YYYY-MM') AS month, 
		SUM(amount) AS total_sales
FROM Sales
GROUP BY DATE_TRUNC('month', date)
ORDER BY month; 

/* Cumulative sales per country */
SELECT c.country_name, SUM(s.amount) AS number_of_sales, 
		SUM(SUM(amount)) OVER (ORDER BY SUM(s.amount)) AS cumulative_sales
FROM Sales s
JOIN Countries c ON s.country_id = c.id
GROUP BY c.country_name
ORDER BY number_of_sales DESC;

/* Percentage of each salesperson's contribution on total sales */
SELECT sp.name, SUM(s.amount) AS total_sales,
		ROUND(SUM(s.amount) * 100.0 / (SELECT SUM(amount)
										FROM Sales), 2) AS percent_of_total
FROM Sales s
JOIN Sales_Persons sp ON s.sales_person_id = sp.id
GROUP BY sp.name
ORDER BY total_sales DESC;

/* Monthly average revenue and comparison with the previous month */
SELECT TO_CHAR(DATE_TRUNC('month', date), 'YYYY-MM') AS month,
		SUM(amount) AS total_sales,
		LAG(SUM(amount)) OVER (ORDER BY TO_CHAR(DATE_TRUNC('month', date), 'YYYY-MM')) AS previous_month_sales,
		SUM(amount) - LAG(SUM(amount)) OVER (ORDER BY TO_CHAR(DATE_TRUNC('month', date), 'YYYY-MM')) AS sales_difference
FROM Sales
GROUP BY month
ORDER BY month;

/* Most popular product in each country */
SELECT c.country_name, p.product_name, total_sales
FROM (
	SELECT s.country_id, s.product_id,
			SUM(s.boxes_shipped) AS total_sales,
			RANK() OVER (PARTITION BY s.country_id ORDER BY SUM(s.boxes_shipped) DESC) AS rank
	FROM Sales s
	GROUP BY s.country_id, s.product_id
) ranked
JOIN Countries c ON ranked.country_id = c.id
JOIN Products p ON ranked.product_id = p.id
WHERE ranked.rank = 1;