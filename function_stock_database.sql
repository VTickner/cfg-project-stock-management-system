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