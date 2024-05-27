use library;

-- 设计触发器，实现
-- A. 当一本书被预约时, 自动将图书表Book 中相应图书的bstatus 修改为2，并增加 reserve_Times
drop trigger if exists reserve_book;
delimiter //
create trigger reserve_book
	after insert on Reserve
    for each row
begin
	update Book set bstatus = if(Book.bstatus=1, 1, 2), reserve_Times = reserve_Times + 1 
		where Book.bid = new.book_ID;
end //
delimiter ;

drop trigger if exists cancal_or_borrow;
delimiter //
create trigger cancel_or_borrow
	after delete on Reserve 
    for each row
begin
	update Book set reserve_Times = reserve_Times - 1 where Book.bid = old.book_ID;
    update Book set bstatus = if(bstatus = 2 and reserve_Times = 0, 0, bstatus) 
		where Book.bid = old.book_ID;
end //
delimiter ;

select reserve_Times, bstatus
from Book
where bid = 'B012';

insert into Reserve (book_ID, reader_ID, take_Date)
values ('B012', 'R001', '2024-06-08');

select reserve_Times, bstatus
from Book
where bid = 'B012';

delete from Reserve where book_ID = 'B012' and reader_ID = 'R001';

select reserve_Times, bstatus
from Book
where bid = 'B012';
