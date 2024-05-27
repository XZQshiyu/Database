use library;

-- 设计一个存存储过程returnBook, 当读者还书时调用该存储过程完成还书处理

drop procedure if exists returnBook;
delimiter //
create procedure returnBook(in readerID char(8), in bookID char(8), in returnDate date)
begin
	-- 检查该书和读者是否存在
    select count(*) into @reader from Reader where readerID = rid;
    if @reader = 0 then
		signal sqlstate '45000'
			set message_text = 'The reader does not exist in the Reader table';
	end if;
    select count(*) into @book from Book where bookID = bid;
    if @book = 0 then
		signal sqlstate '45000'
			set message_text = 'The book does not exist in the Book table';
	end if;
    
    -- 检查书是否在borrow表中且是否由该reader借的
    select count(*) into @is_borrow from Borrow where bookID = book_ID and readerID = reader_ID and return_Date is null;
    if @is_borrow != 1 then
		signal sqlstate '45000'
			set message_text = 'The book is not borrowed by this raeder';
	end if;
    
    -- 更新borrow表
    
    update Borrow set return_Date = returnDate where bookID = book_ID and readerID = reader_ID and return_Date is null;
    
    -- 更新Book 表
    
    select count(*) into @reserve_cnt from Reserve where book_ID = bookID;
    if @reserve_cnt != 0 then
		update Book set bstatus = 2 where bookID = bid;
	else 
		update Book set bstatus = 0 where bookID = bid;
	end if;
    
    select 'Successfully return the book';
end //
delimiter ;

call returnBook('R001', 'B008', '2024-05-10');
select bstatus
from Book
where bid = 'B001';
select return_Date
from Borrow
where reader_ID = 'R001' and book_ID = 'B001';
call returnBook('R001', 'B001', '2024-05-10');
select bstatus
from Book
where bid = 'B001';
select return_Date
from Borrow
where reader_ID = 'R001' and book_ID = 'B001';
