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

-- show part.total_stock now updated with part_batch.remaining_quantity
SELECT * FROM part;

-- show unit_cost automatically calculated from using cost / quantity
SELECT * FROM part_batch;

-- calculate cost of making 'Sterling silver heart charm necklace'
SELECT 
  p.id AS product_id,
  p.product_name,
  p.price AS product_price,
  p.product_type,
  calculate_product_cost(p.id) AS product_cost
FROM product p
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
FROM product p
JOIN product_part AS pp ON p.id = pp.product_id
JOIN part ON pp.part_id = part.id
JOIN supplier ON part.supplier_id = supplier.id
JOIN part_batch ON part.id = part_batch.part_id
ORDER BY p.id;

SELECT * FROM product_part_supplier_view
WHERE product_id = 'SS-1';