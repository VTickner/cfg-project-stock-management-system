CREATE DATABASE stock_management;
USE stock_management;

CREATE TABLE supplier (
  id SERIAL,
	supplier_name VARCHAR(50) NOT NULL,
	PRIMARY KEY (id)
);

CREATE TABLE part (
	id SERIAL,
	part_name VARCHAR(75) NOT NULL,
	supplier_part_id VARCHAR(15), -- id used by supplier (can't guarantee it will be unique)
  supplier_id BIGINT UNSIGNED,
	total_stock INT NOT NULL,
  low_stock_alert INT,
  PRIMARY KEY (id),
  FOREIGN KEY (supplier_id) REFERENCES supplier(id),
  -- ensure a part's ID from a supplier is unique
  CONSTRAINT unique_supplier_part_id UNIQUE (supplier_id, supplier_part_id)
);

CREATE TABLE part_batch (
	id SERIAL,
	part_id BIGINT UNSIGNED,
	supplier_id BIGINT UNSIGNED,
	quantity INT NOT NULL,
	unit_cost DECIMAL(10, 2) NOT NULL, -- cost per unit
	remaining_quantity INT NOT NULL,
  PRIMARY KEY (id),
	FOREIGN KEY (part_id) REFERENCES part(id), -- 1 to many relationship
	FOREIGN KEY (supplier_id) REFERENCES supplier(id) -- 1 to many relationship
);

CREATE TABLE product (
	id VARCHAR(15),
	product_name VARCHAR(75) NOT NULL,
	price DECIMAL(10, 2) NOT NULL,
	product_type VARCHAR(10) NOT NULL,
	PRIMARY KEY (id)
);

CREATE TABLE product_part (
	id SERIAL,
	product_id VARCHAR(15),
	part_id BIGINT UNSIGNED,
	quantity INT NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (product_id) REFERENCES product(id),
	FOREIGN KEY (part_id) REFERENCES part(id)
);

CREATE TABLE `order` (
	id SERIAL,
  PRIMARY KEY (id)
);

CREATE TABLE order_item (
	id SERIAL,
	order_id BIGINT UNSIGNED,
	product_id VARCHAR(15),
	quantity INT NOT NULL,
  PRIMARY KEY (id),
	FOREIGN KEY (order_id) REFERENCES `order`(id),
	FOREIGN KEY (product_id) REFERENCES product(id)
);