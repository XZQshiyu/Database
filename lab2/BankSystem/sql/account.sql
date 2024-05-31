use banksystem;
-- 创建储蓄账户存储过程
drop procedure if exists create_saving_account;
delimiter //
CREATE PROCEDURE create_saving_account(
    IN p_account_id CHAR(18),
    IN p_bank_name VARCHAR(30),
    IN p_balance FLOAT,
    IN p_open_date DATE,
    IN p_rate FLOAT,
    IN p_client_id VARCHAR(18)
)
BEGIN
    -- 检查银行是否存在
    IF (SELECT COUNT(*) FROM Bank WHERE bank_name = p_bank_name) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bank does not exist';
    ELSE
        -- 插入储蓄账户
        INSERT INTO saving_account(account_id, bank_name, balance, open_date, rate)
        VALUES (p_account_id, p_bank_name, p_balance, p_open_date, p_rate);
        
        -- 插入客户与账户的关联
        INSERT INTO client_saving_account(client_id, account_id)
        VALUES (p_client_id, p_account_id);
    END IF;
END //
delimiter ;

-- 创建信用账户存储过程
drop procedure if exists create_credit_account;
delimiter //
CREATE PROCEDURE create_credit_account(
    IN p_account_id CHAR(18),
    IN p_bank_name VARCHAR(30),
    IN p_balance FLOAT,
    IN p_open_date DATE,
    IN p_overdraft FLOAT,
    IN p_client_id VARCHAR(18)
)
BEGIN
    -- 检查银行是否存在
    IF (SELECT COUNT(*) FROM Bank WHERE bank_name = p_bank_name) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bank does not exist';
    ELSE
        -- 插入信用账户
        INSERT INTO credit_account(account_id, bank_name, balance, open_date, overdraft)
        VALUES (p_account_id, p_bank_name, p_balance, p_open_date, p_overdraft);
        
        -- 插入客户与账户的关联
        INSERT INTO client_credit_account(client_id, account_id)
        VALUES (p_client_id, p_account_id);
    END IF;
END //
delimiter ;

-- 一键查询储蓄账户存储过程
drop procedure if exists get_saving_account_by_all;
delimiter //
create procedure get_saving_account_by_all()
begin 
    SELECT sa.account_id, sa.bank_name, 'saving' AS account_type, c.client_id
        FROM saving_account sa
        JOIN client_saving_account csa ON sa.account_id = csa.account_id
        JOIN client c ON csa.client_id = c.client_id;
end //
delimiter ;

-- 一键查询信用账户存储过程
drop procedure if exists get_credit_account_by_all;
delimiter //
create procedure get_credit_account_by_all()
begin 
    SELECT ca.account_id, ca.bank_name, 'credit' AS account_type, c.client_id
        FROM credit_account ca
        JOIN client_credit_account cca ON ca.account_id = cca.account_id
        JOIN client c ON cca.client_id = c.client_id;
end //
delimiter ;

-- 根据account_id查询储蓄账户存储过程
drop procedure if exists get_saving_account_by_id;
delimiter //
create procedure get_saving_account_by_id(
    IN p_account_id CHAR(18)
)
begin 
    SELECT sa.account_id, sa.bank_name, sa.balance, sa.open_date, 'saving' AS account_type, sa.rate, c.client_id, c.name
        FROM saving_account sa
        JOIN client_saving_account csa ON sa.account_id = csa.account_id
        JOIN client c ON csa.client_id = c.client_id
        WHERE sa.account_id = p_account_id;
end //
delimiter ;

-- 根据account_id查询信用账户存储过程
drop procedure if exists get_credit_account_by_id;
delimiter //
create procedure get_credit_account_by_id(
    IN p_account_id CHAR(18)
)
begin 
    SELECT ca.account_id, ca.bank_name, ca.balance, ca.open_date, 'credit' AS account_type, ca.overdraft, c.client_id, c.name
        FROM credit_account ca
        JOIN client_credit_account cca ON ca.account_id = cca.account_id
        JOIN client c ON cca.client_id = c.client_id
        WHERE ca.account_id = p_account_id;
end //
delimiter ;

-- 根据account_id修改储蓄账户存储过程
drop procedure if exists update_saving_account_by_account_id;
delimiter //
create procedure update_saving_account_by_account_id(
    IN p_account_id CHAR(18),
    IN p_bank_name VARCHAR(30),
    IN p_balance FLOAT,
    IN p_rate FLOAT
)
begin 
    -- 检查银行是否存在
    IF (SELECT COUNT(*) FROM Bank WHERE bank_name = p_bank_name) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bank does not exist';
    ELSE
        -- 更新储蓄账户
        UPDATE saving_account
        SET bank_name = p_bank_name, balance = p_balance, rate = p_rate
        WHERE account_id = p_account_id;
    END IF;
end //
delimiter ;

-- 根据account_id修改信用账户存储过程
drop procedure if exists update_credit_account_by_account_id;
delimiter //
create procedure update_credit_account_by_account_id(
    IN p_account_id CHAR(18),
    IN p_bank_name VARCHAR(30),
    IN p_balance FLOAT,
    IN p_overdraft FLOAT
)
begin 
    -- 检查银行是否存在
    IF (SELECT COUNT(*) FROM Bank WHERE bank_name = p_bank_name) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bank does not exist';
    ELSE
        -- 更新信用账户
        UPDATE credit_account
        SET bank_name = p_bank_name, balance = p_balance, overdraft = p_overdraft
        WHERE account_id = p_account_id;
    END IF;
end //
delimiter ;


-- 根据account_id删除储蓄账户存储过程
drop procedure if exists delete_saving_account_by_account_id;
delimiter //
create procedure delete_saving_account_by_account_id(
    IN p_account_id CHAR(18)
)
begin 
    SET FOREIGN_KEY_CHECKS = 0;
    DELETE FROM saving_account
    WHERE account_id = p_account_id;
    delete from client_saving_account
    where account_id = p_account_id;
    SET FOREIGN_KEY_CHECKS = 1;
end //
delimiter ;

-- 根据account_id删除信用账户存储过程
drop procedure if exists delete_credit_account_by_account_id;
delimiter //
create procedure delete_credit_account_by_account_id(
    IN p_account_id CHAR(18)
)
begin 
    SET FOREIGN_KEY_CHECKS = 0;
    DELETE FROM credit_account
    WHERE account_id = p_account_id;
    delete from client_credit_account
    where account_id = p_account_id;
    SET FOREIGN_KEY_CHECKS = 1;
end //
delimiter ;

-- 根据client_id, account_id, bank_name查询储蓄账户存储过程
DROP PROCEDURE IF EXISTS search_saving_account;
DELIMITER //

CREATE PROCEDURE search_saving_account(
    IN p_client_id VARCHAR(18),
    IN p_account_id CHAR(18),
    IN p_bank_name VARCHAR(30),
    IN p_name VARCHAR(30)
)
BEGIN
    SELECT 
        sa.account_id, 
        sa.bank_name, 
        'saving' AS account_type, 
        c.client_id
    FROM 
        saving_account sa
    JOIN 
        client_saving_account csa ON sa.account_id = csa.account_id
    JOIN 
        client c ON csa.client_id = c.client_id
    WHERE 
        (p_client_id IS NULL OR c.client_id LIKE CONCAT('%', p_client_id, '%'))
        AND (p_account_id IS NULL OR sa.account_id LIKE CONCAT('%', p_account_id, '%'))
        AND (p_bank_name IS NULL OR sa.bank_name LIKE CONCAT('%', p_bank_name, '%'))
        AND (p_name IS NULL OR c.name LIKE CONCAT('%', p_name, '%'));
END //

DELIMITER ;

-- 根据client_id, account_id, bank_name查询信用账户存储过程
DROP PROCEDURE IF EXISTS search_credit_account;
DELIMITER //

CREATE PROCEDURE search_credit_account(
    IN p_client_id VARCHAR(18),
    IN p_account_id CHAR(18),
    IN p_bank_name VARCHAR(30),
    IN p_name VARCHAR(30)
)
BEGIN
    SELECT 
        ca.account_id, 
        ca.bank_name, 
        'credit' AS account_type, 
        c.client_id
    FROM 
        credit_account ca
    JOIN 
        client_credit_account cca ON ca.account_id = cca.account_id
    JOIN 
        client c ON cca.client_id = c.client_id
    WHERE 
        (p_client_id IS NULL OR c.client_id LIKE CONCAT('%', p_client_id, '%'))  
        AND (p_account_id IS NULL OR ca.account_id LIKE CONCAT('%', p_account_id, '%'))
        AND (p_bank_name IS NULL OR ca.bank_name LIKE CONCAT('%', p_bank_name, '%'))
        AND (p_name IS NULL OR c.name LIKE CONCAT('%', p_name, '%'));
END //

DELIMITER ;