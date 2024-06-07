use banksystem;
-- 获取所有银行信息的存储过程
drop procedure if exists GetAllBanks;
delimiter //
CREATE PROCEDURE GetAllBanks()
BEGIN
    SELECT bank_name, location, asset, image FROM Bank;
END //
delimiter ;

-- 添加银行信息的存储过程
drop procedure if exists AddBank;
delimiter //
CREATE PROCEDURE AddBank(
    IN p_bank_name VARCHAR(30),
    IN p_location VARCHAR(30),
    IN p_asset FLOAT,
    IN p_image VARCHAR(255)
)
BEGIN
    DECLARE asset_limit_reached BOOLEAN DEFAULT FALSE;

    if p_asset < 0 THEN
        set asset_limit_reached = TRUE;
    end if;

    if asset_limit_reached THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Bank asset cannot be negative';
    else
        INSERT INTO Bank (bank_name, location, asset, image) VALUES (p_bank_name, p_location, p_asset, p_image);
    end if;
END //
delimiter ;

-- 修改银行信息的存储过程
drop procedure if exists UpdateBank;
DELIMITER //
CREATE PROCEDURE UpdateBank(
    IN p_bank_name VARCHAR(30),
    IN p_location VARCHAR(30),
    IN p_asset FLOAT,
    IN p_image VARCHAR(255)
)
BEGIN
    UPDATE Bank 
    SET location = p_location, asset = p_asset, image = p_image
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
    SELECT bank_name, location, asset, image
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
    SELECT bank_name, location, asset, image
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