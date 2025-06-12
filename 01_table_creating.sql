CREATE TABLE Sales_Persons ( 
id SERIAL PRIMARY KEY,
name TEXT UNIQUE NOT NULL
);

CREATE TABLE Countries (
id SERIAL PRIMARY KEY,
country_name TEXT UNIQUE NOT NULL
);

CREATE TABLE Products (
id SERIAL PRIMARY KEY,
product_name TEXT UNIQUE NOT NULL
);

CREATE TABLE Sales (
id SERIAL PRIMARY KEY,
sales_person_id INTEGER REFERENCES Sales_persons(id),
country_id INTEGER REFERENCES Countries(id),
product_id INTEGER REFERENCES Products(id),
date DATE NOT NULL,
amount NUMERIC NOT NULL,
boxes_shipped INTEGER NOT NULL
)