use banksystem;
-- 获取所有银行信息的存储过程
drop procedure if exists GetAllBanks;
delimiter //
CREATE PROCEDURE GetAllBanks()
BEGIN
    SELECT bank_name, location, asset FROM Bank;
END //
delimiter ;

-- 添加银行信息的存储过程
drop procedure if exists AddBank;
delimiter //
CREATE PROCEDURE AddBank(
    IN p_bank_name VARCHAR(30),
    IN p_location VARCHAR(30),
    IN p_asset FLOAT
)
BEGIN
    INSERT INTO Bank (bank_name, location, asset) VALUES (p_bank_name, p_location, p_asset);
END //
delimiter ;

-- 修改银行信息的存储过程
drop procedure if exists UpdateBank;
DELIMITER //
CREATE PROCEDURE UpdateBank(
    IN p_bank_name VARCHAR(30),
    IN p_location VARCHAR(30),
    IN p_asset FLOAT
)
BEGIN
    UPDATE Bank 
    SET location = p_location, asset = p_asset 
    WHERE bank_name = p_bank_name;
END //
DELIMITER ;

-- 删除银行信息的存储过程
drop procedure if exists DeleteBank;
DELIMITER //
CREATE PROCEDURE DeleteBank(
    IN p_bank_name VARCHAR(30)
)
BEGIN
    DELETE FROM Bank 
    WHERE bank_name = p_bank_name;
END //
DELIMITER ;

-- 查找银行信息的存储过程
drop procedure if exists GetBankByName;
DELIMITER //
CREATE PROCEDURE GetBankByName(
    IN p_bank_name VARCHAR(30)
)
BEGIN
    SELECT bank_name, location, asset 
    FROM Bank 
    WHERE bank_name = p_bank_name;
END //
DELIMITER ;

-- 查找银行信息的存储过程
DROP PROCEDURE IF EXISTS search_bank;
DELIMITER //
CREATE PROCEDURE search_bank(
    IN p_bank_name VARCHAR(30),
    IN p_location VARCHAR(30)
)
BEGIN
    SELECT bank_name, location, asset
    FROM Bank
    WHERE (p_bank_name IS NULL OR bank_name LIKE CONCAT('%', p_bank_name, '%'))
    AND (p_location IS NULL OR location LIKE CONCAT('%', p_location, '%'));
END //
DELIMITER ;

-- 获取所有部门信息的存储过程
DROP PROCEDURE IF EXISTS get_departments_by_bank;

DELIMITER //

CREATE PROCEDURE get_departments_by_bank (
    IN p_bank_name VARCHAR(30)
)
BEGIN
    SELECT * FROM department
    WHERE bank_name = p_bank_name;
END //

DELIMITER ;