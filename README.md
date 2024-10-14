# Code First Girls - Introduction To Data & SQL Course & Project

Introduction to Data & SQL was an online course run by [Code First Girls](https://codefirstgirls.com/) to give an introduction into data analysis and SQL. Also as part of the course there was a project to create and give a presentation about it.

## Table of contents

- [Project Overview](#project-overview)
  - [Project Objectives](#project-objectives)
- [Database: Stock Management for Handmade Business](#database-stock-management-for-handmade-business)
  - [Database design and schema](#database-deign-and-schema)
  - [Database data](#database-data)
- [Project Process](#project-process)
  - [Project learning outcomes](#project-learning-outcomes)
  - [Useful resources](#useful-resources)
- [Author](#author)

## Project Overview

This was an individual project, and my aim was to not just meet the specified number of requirements (see below) but to try to complete all the project advanced requirements, in order maximise my learning from completing the project.

### Project objectives

- Project was to create a database
- Project core requirements:
  - ❎ Create relational DB with minimum 5 tables
  - ❎ Set Primary and Foreign Key constraints to create relations between the tables
  - ❎ Using any type of joins, create a view that combines multiple tables in a logical way
  - ❎ In the DB, create a stored function that can be applied to a query in the DB
  - ❎ Prepare an example query with a subquery to demonstrate how to extract data from the DB for analysis
  - ❎ Create DB diagram where all table relations are shown
- Project advanced requirements (include 2-3 minimum):
  - ❎ In the DB, create a stored procedure and demonstrate how it runs
  - ❎ In the DB, create a trigger and demonstrate how it runs
  - ❎ In the DB, create an event and demonstrate how it runs
  - ❎ Create a view that uses at least 3-4 base tables; prepare and demonstrate a query that uses the view to produce a logically arranged result set for analysis
  - ❎ Prepare an example query with group by and having to demonstrate how to extract data from the DB for analysis
- ❎ Present a 3 minute presentation to the group explaining the idea behind the DB (use DB diagram), what it is for and how it is expected to be used. Run sample queries to demonstrate how the functions, stored procedures etc work. Show snippets of data stored in the tables.

## Database: Stock Management for Handmade Business

I run a handmade business and keep track of stock and costs associated with creating products via spreadsheets. So my project idea was to make a database that does the same thing: tracks parts used in products, adjusts stock and costs based on usage of parts from different purchases, updates stock levels after orders are processed, and shows when stock is low.

### Database deign and schema

My focus for the tables in the database was around stock management. Therefore only limited information regarding orders that is applicable for stock management (order id, order date, items ordered) is used in this instance.

The IDs that suppliers use for their parts may not be unique in the database (as some suppliers might end up using the exact same ID for different items). However, the ID supplier's use will be unique within their own items, therefore, I needed to add a constraint so that a part's ID from a supplier is unique.

```sql
  CONSTRAINT unique_supplier_part_id UNIQUE (supplier_id, supplier_part_id)
```

I designed the following schema for the database (I've included the [DBML database markup language file](./stock_management.dbml)):

![Database schema](./schema.png)

### Database data

The full SQL for this project can be found in [stock_management.sql](./stock_database.sql). However, I have created separate SQL files to make it simpler to find the various different parts that make up the database project:

- [Tables](./tables_stock_database.sql)
- [Event](./event_stock_database.sql)
- [Function](./function_stock_database.sql)
- [Procedure](./procedure_stock_database.sql)
- [Triggers](./triggers_stock_database.sql)
- [Data & Views](./data_stock_database.sql)

## Project Process

After [designing the schema](#database-deign-and-schema) for the database, I created the tables and then added some sample data to put into the tables. Having sample data in the tables, made it easier to test and visualise what data queries, triggers etc would be useful to be able to extract and apply to the tables.

I wanted to be able to show that there is more than one way to accomplish the same end result. So I used the example query of checking for low stock quantities, and carried this out via:

- Using a subquery within a query.
- Using a query with `GROUP BY` and `HAVING`.
- Using a stored procedure.

### Project learning outcomes

- Use `` around reserved keywords in SQL e.g.:
  ```sql
  CREATE TABLE `order` (
  	id SERIAL,
    PRIMARY KEY (id)
  );
  ```
- `SERIAL` is an alias for `BIGINT UNSIGNED NOT NULL AUTO_INCREMENT` therefore id referencing as a foreign key the data type needs to be `BIGINT UNSIGNED`.

  ```sql
  CREATE TABLE part (
    id SERIAL,
    ...
    PRIMARY KEY (id)
  );

  CREATE TABLE part_batch (
    id SERIAL,
    part_id BIGINT UNSIGNED,
    ...
    PRIMARY KEY (id),
    FOREIGN KEY (part_id) REFERENCES part(id), -- 1 to many relationship
    ...
  );
  ```

- To enable scheduled events:
  ```sql
  SET GLOBAL event_scheduler = ON;
  ```

### Potential Improvements

- Add trigger when `INSERT INTO order_item ...` to update `part_batch.remaining_quantity` so that remaining stock part batch quantities are automatically updated when items are ordered (and therefore created). N.B. This will cause another trigger to execute (labelled TRIGGER 3) which will also update `part.total_stock` so that the total stock of each part is also automatically updated.

### Useful resources

- [dbdiagram.io](https://dbdiagram.io/home)

## Author

V. Tickner
