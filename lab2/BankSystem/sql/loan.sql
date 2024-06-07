use banksystem;

DELIMITER //

CREATE FUNCTION get_remaining_loan_amount(loan_id VARCHAR(32))
RETURNS FLOAT
DETERMINISTIC
BEGIN
    DECLARE total_loan FLOAT;
    DECLARE total_paid FLOAT;
    DECLARE remaining_amount FLOAT;

    -- 获取贷款总金额
    SELECT loan_money INTO total_loan
    FROM loan
    WHERE loan.loan_id = loan_id;

    -- 获取已支付的总金额
    SELECT IFNULL(SUM(pay_money), 0) INTO total_paid
    FROM pay_loan
    WHERE pay_loan.loan_id = loan_id;

    -- 计算剩余金额
    SET remaining_amount = total_loan - total_paid;

    RETURN remaining_amount;
END//

DELIMITER ;

-- 一键查询贷款账户存储过程
DROP PROCEDURE IF EXISTS get_all_loans;
DELIMITER //

CREATE PROCEDURE get_all_loans()
BEGIN
    SELECT 
        loan_id, 
        client_id, 
        bank_name,
        get_remaining_loan_amount(loan_id) AS remaining_amount
    FROM loan;
END //

DELIMITER ;

-- 创建贷款账户存储过程
drop procedure if exists add_loan;
delimiter //
create procedure add_loan(
    in p_loan_id char(18),
    in p_client_id char(18),
    in p_bank_name varchar(30),
    in p_loan_money float,
    in p_loan_rate float,
    in p_loan_date date
)
begin
    -- 检查银行是否存在
    if not exists (select * from bank where bank_name = p_bank_name) then
        signal sqlstate '45000'
            set message_text = 'Bank does not exist';
    else
        -- 插入贷款账户
        insert into loan(loan_id, client_id, bank_name, loan_money, loan_rate, loan_date)
        values (p_loan_id, p_client_id, p_bank_name, p_loan_money, p_loan_rate, p_loan_date);
    end if;
end //
delimiter ;

-- 根据贷款账户ID查询贷款账户存储过程
drop procedure if exists get_loan_by_id;
delimiter //
create procedure get_loan_by_id(
    in p_loan_id char(18)
)
begin
    
    select loan_id, loan.client_id, bank_name, loan_money, loan_rate, loan_date, c.name, get_remaining_loan_amount(loan_id) AS remaining_amount
        from loan
        join client c on loan.client_id = c.client_id
        where loan.loan_id = p_loan_id;

end //
delimiter ;

-- 根据贷款ID更新贷款账户存储过程
drop procedure if exists update_loan;
delimiter //
create procedure update_loan(
    in p_loan_id char(18),
    in p_client_id char(18),
    in p_bank_name varchar(30),
    in p_loan_money float,
    in p_loan_rate float
)
begin
    -- 检查银行是否存在
    if not exists (select * from bank where bank_name = p_bank_name) then
        signal sqlstate '45000'
            set message_text = 'Bank does not exist';
    else
        -- 更新贷款账户
        update loan
        set bank_name = p_bank_name, loan_money = p_loan_money, loan_rate = p_loan_rate
        where loan_id = p_loan_id;
    end if;
end //
delimiter ;

-- 根据贷款ID删除贷款账户存储过程
drop procedure if exists delete_loan;
delimiter //
create procedure delete_loan(
    in p_loan_id char(18)
)
begin
    -- 删除贷款账户
    -- set foreign_key_checks = 0;
    delete from loan
    where loan_id = p_loan_id;
    -- set foreign_key_checks = 1;
end //
delimiter ;


-- 根据load_id, client_id, name, bank_name查询贷款存储过程
drop procedure if exists search_loan;
delimiter //
create procedure search_loan(
    in p_loan_id char(18),
    in p_client_id char(18),
    in p_bank_name varchar(30),
    in p_name varchar(30)
)
begin
    select 
        l.loan_id,
        l.bank_name,
        l.client_id
    from loan l
    join client c on l.client_id = c.client_id
    where
        (p_loan_id is null or l.loan_id like concat('%', p_loan_id, '%'))
        and (p_client_id is null or l.client_id like concat('%', p_client_id, '%'))
        and (p_bank_name is null or l.bank_name like concat('%', p_bank_name, '%'))
        and (p_name is null or c.name like concat('%', p_name, '%'));
end //
delimiter ;

-- 根据load_id还款过程
drop procedure if exists add_loan_payment;
delimiter //
create procedure add_loan_payment(
    in p_pay_id int,
    in p_payment float,
    in p_payment_date date,
    in p_loan_id char(18)
)
begin
    -- 检查贷款账户是否存在
    if not exists (select * from loan where loan_id = p_loan_id) then
        signal sqlstate '45000'
            set message_text = 'Loan does not exist';
    else
        -- 插入还款记录
        insert into pay_loan(pay_id, pay_money, pay_date, loan_id)
        values (p_pay_id, p_payment, p_payment_date, p_loan_id);
    end if;
end //
delimiter ;

-- 根据贷款账户ID查询还款记录存储过程
drop procedure if exists get_loan_payment;
delimiter //
create procedure get_loan_payment(
    in p_loan_id char(18)
)
begin
    select pay_id, pay_money, pay_date
        from pay_loan
        where loan_id = p_loan_id;
end //
delimiter ;