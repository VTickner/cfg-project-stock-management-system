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