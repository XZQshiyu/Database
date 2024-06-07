use banksystem;

-- 当添加一个新的储蓄账户时，更新银行的资产
delimiter //
create trigger after_saving_account_insert
after insert on saving_account
for each row
begin
    update Bank
    set asset = asset + new.balance
    where bank_name = new.bank_name;
end ;
//

delimiter ;

-- 当添加一个新的信用账户时时，更新银行的资产
delimiter //
create trigger after_credit_account_insert
after insert on credit_account
for each row
begin
    update Bank
    set asset = asset - new.balance
    where bank_name = new.bank_name;
end ;
//
delimiter ;

-- 当添加信用账户时，银行资产减少相应的金额，且资产不能减为0
delimiter //
CREATE TRIGGER before_credit_account_insert
BEFORE INSERT ON credit_account
FOR EACH ROW
BEGIN
    DECLARE current_asset FLOAT;
    SET current_asset = (SELECT asset FROM Bank WHERE bank_name = NEW.bank_name);
    IF current_asset - NEW.balance <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Bank asset cannot be zero or negative after adding credit account';
    END IF;
END;
//
delimiter ;

-- 当删除一个储蓄账户时，更新银行的资产
delimiter //
create trigger after_saving_account_delete
after delete on saving_account
for each row
begin
    update Bank
    set asset = asset - old.balance
    where bank_name = old.bank_name;
end ;
//
delimiter ;

-- 当删除一个信用账户时，更新银行的资产
delimiter //
create trigger after_credit_account_delete
after delete on credit_account
for each row
begin
    update Bank
    set asset = asset + old.balance
    where bank_name = old.bank_name;
end ;
//
delimiter ;

-- 当修改一个储蓄账户时，更新银行的资产
delimiter //
create trigger after_saving_account_update
after update on saving_account
for each row
begin
    update Bank
    set asset = asset - old.balance + new.balance
    where bank_name = new.bank_name;
end ;
//
delimiter ;

-- 当修改一个信用账户时，更新银行的资产
delimiter //
create trigger after_credit_account_update
after update on credit_account
for each row
begin
    update Bank
    set asset = asset + old.balance - new.balance
    where bank_name = new.bank_name;
end ;
//
delimiter ;

-- 申请贷款时，更新银行的资产
delimiter //
create trigger after_loan_insert
after insert on loan
for each row
begin
    update Bank
    set asset = asset - new.loan_money
    where bank_name = new.bank_name;
end ;
//
delimiter ;

-- 申请贷款时，银行资产减少相应的金额，且资产不能减为0
delimiter //
CREATE TRIGGER before_loan_insert
BEFORE INSERT ON loan
FOR EACH ROW
BEGIN
    DECLARE current_asset FLOAT;
    SET current_asset = (SELECT asset FROM Bank WHERE bank_name = NEW.bank_name);
    IF current_asset - NEW.loan_money <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Bank asset cannot be zero or negative after loan application';
    END IF;
END;
//
delimiter ;

-- 还贷时，更新银行的资产
delimiter //
create trigger after_pay_loan_insert
after insert on pay_loan
for each row
begin
    update Bank
    set asset = asset + new.pay_money
    where bank_name = (select bank_name from loan where loan_id = new.loan_id);
end ;
//
delimiter ;


-- 当删除一个贷款时，更新银行的资产
delimiter //
create trigger after_loan_delete
after delete on loan
for each row
begin
    update Bank
    set asset = asset + old.loan_money
    where bank_name = old.bank_name;
end ;
//
delimiter ;