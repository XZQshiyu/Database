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