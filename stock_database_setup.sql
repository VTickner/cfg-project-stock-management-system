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
  order_date DATE NOT NULL,
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

INSERT INTO supplier (supplier_name)
VALUES
  ('Crystal Gems Co.'),
  ('Silver Sparkles Ltd'),
  ('Bee Charmed');

INSERT INTO part (part_name, supplier_part_id, supplier_id, total_stock, low_stock_alert)
VALUES
	('Sterling silver chain', 'SSC-1', 2, 50, 5),
  ('Sterling silver clasp, 9mm', 'SSCl-5', 2, 30, 10),
  ('Sterling silver heart charm', 'SSC-1', 3, 5, 1),
  ('October crystal bead, 6mm', 'CB/10', 1, 10, 4),
  ('Sterling silver jump rings 4mm', 'SSJR-4', 2, 200, 20);

INSERT INTO part_batch (part_id, supplier_id, quantity, unit_cost, remaining_quantity)
VALUES
	(1, 2, 20, 0.05, 20),
  (2, 2, 10, 1.50, 10),
  (3, 3, 2, 4.25, 2),
  (3, 1, 50, 0.03, 45);

INSERT INTO product (id, product_name, price, product_type)
VALUES
	('SS-1','Sterling silver heart charm necklace', 21.50, 'necklace'),
  ('SS-2', 'Sterling silver dainty chain necklace', 17.00, 'necklace'),
  ('SS-3', 'Sterling silver dainty chain bracelet', 15.50, 'bracelet'),
  ('Supp-1', 'October crystal beads, 6mm', 2.25, 'supply');

INSERT INTO product_part (product_id, part_id, quantity)
VALUES
	('SS-1', 1, 40),
  ('SS-1', 2, 1),
  ('SS-1', 3, 1),
  ('SS-1', 5, 3),
  ('SS-2', 1, 40),
  ('SS-2', 2, 1),
  ('SS-2', 5, 2),
  ('SS-3', 1, 16),
  ('SS-3', 2, 1),
  ('SS-3', 5, 2);