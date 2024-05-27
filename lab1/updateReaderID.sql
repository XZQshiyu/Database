use library;
-- 设计一个存储过程 updateReaderID 实现对读者表的ID的修改
drop procedure if exists updateReaderID;
delimiter //
create procedure updateReaderID(in old_rid char(8), in new_rid char(8))
begin
	-- 检查old_new是否在原先的Redaer表中
    select count(*) into @cnt from Reader where rid = old_rid;
    if @cnt = 0 then
		signal sqlstate '45000'
			set message_text = 'The old reader_id is not in the Reader table';
	end if;
	-- 检查new_rid是否在原先的Reader表中
    select count(*) into @cnt from Reader where rid = new_rid;
    if @cnt > 0 then
		signal sqlstate '45000'
			set message_text = 'The new reader_id is already in the Reader table';
	end if;
	-- 开始事务
    -- 禁用外键约束
    set foreign_key_checks = 0;
    update Reader set rid = new_rid where rid = old_rid;
    update Borrow set Reader_ID = new_rid where Reader_ID = old_rid;
    update Reserve set Reader_ID = new_rid where Reader_ID = old_rid;
    set foreign_key_checks = 1;
end //
delimiter ;

-- 使用存储过程: 将读者ID中的 ‘R006' 改为 'R999'
call updateReaderID('R006', 'R999');
select rid 
from Reader;
call updateReaderID('R999', 'R006');
select rid 
from Reader;