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
  total_stock INT NOT NULL DEFAULT 0,
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
	cost DECIMAL(10, 2) NOT NULL DEFAULT 0,
  unit_cost DECIMAL(10, 2), -- cost per unit = cost / quantity
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

-- EVENT 1: check for low stock quantities
DELIMITER //
CREATE EVENT check_low_stock
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
  INSERT INTO low_stock_log (part_id, part_name, total_stock, supplier_name)
  SELECT 
    p.id, 
    p.part_name, 
    p.total_stock, 
    s.supplier_name
  FROM part AS p
  JOIN supplier AS s ON p.supplier_id = s.id
  WHERE p.total_stock <= p.low_stock_alert;
END //
DELIMITER ;

SET GLOBAL event_scheduler = ON;

-- FUNCTION 1: calculate cost of making a product
DELIMITER //
CREATE FUNCTION calculate_product_cost(product_id VARCHAR(15))
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
  DECLARE total_cost DECIMAL(10, 2) DEFAULT 0;
  -- calculate the total cost for the product by adding the cost of each part used
  SELECT SUM(pp.quantity * pb.unit_cost) INTO total_cost
  FROM product_part AS pp
  JOIN part_batch AS pb ON pp.part_id = pb.part_id
  WHERE pp.product_id = product_id
    AND pb.id = (
      SELECT MIN(id)
      FROM part_batch
      WHERE part_batch.part_id = pb.part_id
    );
  RETURN total_cost;
END //
DELIMITER ;

-- PROCEDURE 1: check for low stock quantities
DELIMITER //
CREATE PROCEDURE GetLowStockParts()
BEGIN
  SELECT 
    p.id AS part_id, 
    p.part_name, 
    p.total_stock,
    p.low_stock_alert, 
    s.supplier_name
  FROM part AS p
  JOIN supplier AS s ON p.supplier_id = s.id
  WHERE p.total_stock <= p.low_stock_alert;
END //
DELIMITER ;

-- TRIGGER 1: insert before on part_batch to calculate part_batch.unit_cost
DELIMITER //
CREATE TRIGGER update_unit_cost_before_insert
BEFORE INSERT ON part_batch
FOR EACH ROW
BEGIN
  -- calculate the unit_cost for each batch as cost / quantity
  SET NEW.unit_cost = NEW.cost / NEW.quantity;
END //
DELIMITER ;

-- TRIGGER 2: insert after on part_batch to update part.total_stock values
DELIMITER //
CREATE TRIGGER update_total_stock_after_insert
AFTER INSERT ON part_batch
FOR EACH ROW
BEGIN
  -- update part.total_stock based on the sum of part_batch.remaining_quantity
  UPDATE part
  SET total_stock = (
    -- if no rows found for a part, set to 0
    SELECT IFNULL(SUM(remaining_quantity), 0)
    FROM part_batch
    WHERE part_id = NEW.part_id
  )
  WHERE id = NEW.part_id;
END //
DELIMITER ;

-- TRIGGER 3: update after part_batch to update part.total_stock values
DELIMITER //
CREATE TRIGGER update_total_stock_after_update
AFTER UPDATE ON part_batch
FOR EACH ROW
BEGIN
  -- update part.total_stock based on the sum of part_batch.remaining_quantity
  UPDATE part
  SET total_stock = (
    -- if no rows found for a part, set to 0
    SELECT IFNULL(SUM(remaining_quantity), 0)
    FROM part_batch
    WHERE part_id = NEW.part_id
  )
  WHERE id = NEW.part_id;
END //
DELIMITER ;

INSERT INTO supplier (supplier_name)
VALUES
  ('Crystal Gems Co.'),
  ('Silver Sparkles Ltd'),
  ('Bee Charmed');

INSERT INTO part (part_name, supplier_part_id, supplier_id, low_stock_alert)
VALUES
  ('Sterling silver chain', 'SSC-1', 2, 5),
  ('Sterling silver clasp, 9mm', 'SSCl-5', 2, 10),
  ('Sterling silver heart charm', 'SSC-1', 3, 1),
  ('October crystal bead, 6mm', 'CB/10', 1, 4),
  ('Sterling silver jump rings 4mm', 'SSJR-4', 2, 20);

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

-- show part.total_stock all initially 0
SELECT * FROM part;

INSERT INTO part_batch (part_id, supplier_id, quantity, cost, remaining_quantity)
VALUES
  (1, 2, 20, 1, 20),
  (2, 2, 10, 15, 10),
  (3, 3, 2, 8.50, 2),
  (1, 2, 50, 1.50, 50),
  (4, 1, 10, 4, 10),
  (5, 2, 500, 4, 500);

-- show TRIGGER 2: show part.total_stock now updated with part_batch.remaining_quantity
SELECT * FROM part;

-- show TRIGGER 1: show unit_cost automatically calculated from using cost / quantity
SELECT * FROM part_batch;

-- use FUNCTION 1: calculate cost of making 'Sterling silver heart charm necklace'
SELECT 
  p.id AS product_id,
  p.product_name,
  p.price AS product_price,
  p.product_type,
  calculate_product_cost(p.id) AS product_cost
FROM product AS p
WHERE p.id = 'SS-1';

-- VIEW 1: show information about a particular product
CREATE OR REPLACE VIEW product_part_supplier_view AS
SELECT 
  p.id AS product_id, 
  p.product_name, 
  p.price, 
  p.product_type, 
  supplier.supplier_name,
  part.part_name,
  part.total_stock, 
  pp.quantity AS needed_quantity,
  MIN(part_batch.unit_cost) AS unit_cost,
  (pp.quantity * MIN(part_batch.unit_cost)) AS cost_per_part
FROM product AS p
JOIN product_part AS pp ON p.id = pp.product_id
JOIN part ON pp.part_id = part.id
JOIN supplier ON part.supplier_id = supplier.id
JOIN part_batch ON part.id = part_batch.part_id
GROUP BY
  p.id, 
  p.product_name, 
  p.price, 
  p.product_type, 
  supplier.supplier_name,
  part.part_name,
  part.total_stock,
  pp.quantity
ORDER BY p.id;

-- use VIEW 1
SELECT * FROM product_part_supplier_view
WHERE product_id = 'SS-1';

-- use subquery: identify suppliers that may need to be restocked
SELECT 
  p.id AS part_id, 
  p.part_name, 
  p.total_stock, 
  p.low_stock_alert,
  s.supplier_name
FROM supplier AS s
JOIN part AS p ON p.supplier_id = s.id
-- filters so only parts with low stock are shown
WHERE p.id IN (
  -- checks for parts where the total_stock <= low_stock_alert and returning a list of part ids
  SELECT p2.id 
  FROM part AS p2
  WHERE p2.total_stock <= p2.low_stock_alert
)
ORDER BY p.id;

-- use GROUP BY and HAVING: identify suppliers that may need to be restocked
SELECT 
  p.id AS part_id, 
  p.part_name, 
  p.total_stock, 
  p.low_stock_alert,
  s.supplier_name
FROM supplier AS s
JOIN part AS p ON p.supplier_id = s.id
GROUP BY 
  p.id, 
  p.part_name, 
  p.total_stock,
  p.low_stock_alert,
  s.supplier_name
HAVING p.total_stock <= p.low_stock_alert
ORDER BY p.id;

-- use PROCEDURE 1: check for low stock quantities
CALL GetLowStockParts();

-- check whether have enough parts to make 2 of 'Sterling silver heart charm necklace'
SELECT 
  p.product_name,
	pp.quantity AS required_quantity,
	part.part_name,
	part.total_stock,
	part.low_stock_alert,
	(part.total_stock - (pp.quantity * 2)) AS remaining_stock,
	CASE 
		WHEN (part.total_stock - (pp.quantity * 2)) <= 0 THEN 'Out of Stock'
		WHEN (part.total_stock - (pp.quantity * 2)) < part.low_stock_alert THEN 'Low Stock Alert'
		ELSE 'Sufficient Stock'
	END AS stock_status
FROM product AS p
JOIN product_part AS pp ON p.id = pp.product_id
JOIN part ON pp.part_id = part.id
WHERE p.id = 'SS-1';

-- create an order for 2 'Sterling silver heart charm necklace'
INSERT INTO `order` (order_date) VALUES ('2024-10-13');

SET @order_id = LAST_INSERT_ID();  -- Get the created order's ID

INSERT INTO order_item (order_id, product_id, quantity) 
VALUES (@order_id, 'SS-1', 2);

SELECT * FROM `order`;
SELECT * FROM order_item;

-- need to create trigger to update parts used for items ordered