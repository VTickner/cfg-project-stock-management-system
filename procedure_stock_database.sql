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