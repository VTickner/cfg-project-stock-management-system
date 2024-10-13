-- FUNCTION 1: calculate cost of making a product
DELIMITER //
CREATE FUNCTION calculate_product_cost(product_id VARCHAR(15))
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
  DECLARE total_cost DECIMAL(10, 2) DEFAULT 0;
  -- calculate the total cost for the product by adding the cost of each part used
  SELECT SUM(product_part.quantity * pb.unit_cost) INTO total_cost
  FROM product_part
  JOIN part_batch pb ON product_part.part_id = pb.part_id
  WHERE product_part.product_id = product_id
    AND pb.id = (
      SELECT MIN(id)
      FROM part_batch
      WHERE part_batch.part_id = pb.part_id
    );
  RETURN total_cost;
END //
DELIMITER ;