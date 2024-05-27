use library;

-- 1. 查询读者Rose 结过的书（包括已还和未还）的图书号、书名和借期
SELECT 
    book_ID, bname, borrow_Date
FROM
    Book,
    Borrow
WHERE
    Book.bid = Borrow.book_ID
        AND Borrow.reader_ID IN (SELECT 
            rid
        FROM
            Reader
        WHERE
            rname = 'Rose');
                        
-- 2. 查询从没有借过图书也从没有预约过图书的读者号和读者姓名
select rid, rname
from Reader
where rid not in (
	select reader_ID
    from Borrow
    union
    select  reader_ID
    from Reserve
);
-- 3. 查询被借阅次数最多的作者 方法B更好
select author 
from Book
group by author
having sum(borrow_Times) > 0
order by sum(borrow_Times) DESC
limit 1;

select b.author, count(*) as borrow_cnt
from Borrow br
join Book b
on br.book_ID = b.bid
group by b.author
order by borrow_cnt desc
limit 1;

-- 4. 查询目前借阅未还的书名中包含"MySQL"的图书号和书名
select bid, bname
from Book
where bname like "%MySQL%"
	and bid in (select book_ID
				from Borrow
				where return_Date is NULL);

-- 5. 查询借阅图书数目超过3本的的读者姓名
select rname 
from Reader
where rid in (select reader_ID
				from Borrow
                group by reader_ID
                having count(*) > 3);
                
-- 6. 查询没有借阅过任何一本 J.K. Rowling 所著的图书的读者号和姓名
select rid, rname
from Reader
where rid not in (
	select reader_ID
	from Borrow
    where book_ID in (
		select bid 
        from Book
        where author = 'J.K. Rowling')
	);

-- 7. 查询2024 年借阅图书数目排名前3名的读者号、姓名以及借阅图书数
select r.rid, r.rname, count(*) as borrow_num
from Reader r
	join Borrow w on w.reader_ID = r.rid
where w.borrow_Date like '2024%'
group by r.rid
order by borrow_num desc
limit 3;

-- 8. 创建了一个读者借书信息的视图，该视图包含读者号、姓名、所借图书号、图书名和借期
-- 	  并使用该视图查询2024年所有读者的读者号以及所借阅的不同图书数
drop view if exists reader_borrow_view;

create view reader_borrow_view as
select r.rid, r.rname, b.bid, b.bname, bo.borrow_Date
from Reader r
	join Borrow bo on r.rid = bo.reader_ID
    join Book b on b.bid = bo.book_ID;

select rid, count(distinct bid) as borrow_book_num
from reader_borrow_view
where year(borrow_Date) = 2024
group by rid;