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