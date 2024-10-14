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
  part_batch.unit_cost,
  (pp.quantity * part_batch.unit_cost) AS cost_per_part
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
  part.total_stock
ORDER BY p.id;

-- use VIEW 1
SELECT * FROM product_part_supplier_view
WHERE product_id = 'SS-1';

-- use subquery: identify suppliers that may need to be restocked
SELECT 
  p.id AS part_id, 
  p.part_name, 
  p.total_stock, 
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
  s.supplier_name
FROM supplier AS s
JOIN part AS p ON p.supplier_id = s.id
GROUP BY 
  p.id, 
  p.part_name, 
  p.total_stock, 
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
		WHEN (part.total_stock - (pp.quantity * 2)) < 0 THEN 'Out of Stock'
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

-- need to create trigger to update parts used for items ordered