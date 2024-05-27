use library;

-- 设计一个存储过程 borrowBook，当读者借书时调用该存储过程完成借书处理
drop procedure if exists borrowBook;
delimiter //
create procedure borrowBook(in readerID char(8), in bookID char(8), in borrowDate date)
begin
	-- 检查reader和 book是否存在，不存在则不允许借书
    select count(*) into @reader from Reader where rid = readerID;
    if @reader = 0 then 
		signal sqlstate '45000' 
			set message_text = 'The reader is not exist in the Reader table';
	end if;
    select count(*) into @book from Book where bid = bookID;
    if @book = 0 then
		signal sqlstate '45000'
			set message_text = 'The book is not exist in the Book table';
	end if;
    
    -- 如果该图书已经被借阅或者 由其他人预定，则不允许借阅(这个逻辑可以在C,D实现)
    select count(*) into @is_borrow from Borrow where book_ID = bookID and return_Date is null;
    if @is_borrow > 0 then
		signal sqlstate '45000'
			set message_text = 'The book is already been borrowed!';
	end if;
    
    -- A. 一个读者最多只能借阅3本书, 意味着如果读者已经借阅了三本图书并且未归还则不允许再借书
    select count(*) into @cnt from Borrow where reader_ID = readerID and return_Date is null;
    if @cnt >= 3 then
		signal sqlstate '45000'
			set message_text = 'The reader has already borrowed 3 books!';
	end if;
    
    -- B. 同一天不允许同一个读者重复借阅同一本图书
    select count(*) into @cnt from Borrow where book_ID = bookID and reader_ID = readerID and borrow_Date = borrowDate;
    if @cnt > 0 then
		signal sqlstate '45000'
			set message_text = 'The reader has already borrowed this book today!';
	end if;
    
    -- C. 如果该图书存在预约记录，而当前借阅者没有预约，则不允许借阅
    -- D. 如果借阅者已经预约了该图书，则允许借阅，但要求借阅完成后删除借阅者对该图书的预约记录
    select count(*) into @cnt from Reserve where book_ID = bookID and reader_ID = readerID and take_Date > borrowDate;
    if @cnt = 0 then
		select count(*) into @cnt_other from Reserve where book_ID = bookID and take_Date > borrowDate;
        if @cnt_other > 0 then
			signal sqlstate '45000' 
				set message_text = 'The book has already been reserved by other people';
		end if;
	end if;
    
    -- E. 借阅成功后图书表中的 times + 1， 修改 bstatus， 并在borrow表中插入相应借阅信息
    insert into Borrow(reader_ID, book_ID, borrow_Date) values (readerID, bookID, borrowDate);
    
    update Book set borrow_Times = Book.borrow_Times + 1, bstatus = 1 where bid = bookID;
    
    delete from Reserve where book_ID = bookID and reader_ID = readerID;
    
     -- 借阅成功
    select 'successfully borrow the book!';
end //
delimiter ;
select *
from Borrow;
select *
from Reserve;
call borrowBook('R001', 'B008', '2024-05-9');
select borrow_Times, bstatus 
from Book
where bid = 'B001';
call borrowBook('R001', 'B001', '2024-05-9');
select *
from Reserve;
select borrow_Times, bstatus 
from Book
where bid = 'B001';

call borrowBook('R001', 'B001', '2024-05-9');
call borrowBook('R005', 'B008', '2024-05-9');
