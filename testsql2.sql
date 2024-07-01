#### Schemas

```sql
CREATE TABLE artists (
    artist_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    birth_year INT NOT NULL
);

CREATE TABLE artworks (
    artwork_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    artist_id INT NOT NULL,
    genre VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    artwork_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artwork_id) REFERENCES artworks(artwork_id)
);

INSERT INTO artists (artist_id, name, country, birth_year) VALUES
(1, 'Vincent van Gogh', 'Netherlands', 1853),
(2, 'Pablo Picasso', 'Spain', 1881),
(3, 'Leonardo da Vinci', 'Italy', 1452),
(4, 'Claude Monet', 'France', 1840),
(5, 'Salvador Dalí', 'Spain', 1904);

INSERT INTO artworks (artwork_id, title, artist_id, genre, price) VALUES
(1, 'Starry Night', 1, 'Post-Impressionism', 1000000.00),
(2, 'Guernica', 2, 'Cubism', 2000000.00),
(3, 'Mona Lisa', 3, 'Renaissance', 3000000.00),
(4, 'Water Lilies', 4, 'Impressionism', 500000.00),
(5, 'The Persistence of Memory', 5, 'Surrealism', 1500000.00);

INSERT INTO sales (sale_id, artwork_id, sale_date, quantity, total_amount) VALUES
(1, 1, '2024-01-15', 1, 1000000.00),
(2, 2, '2024-02-10', 1, 2000000.00),
(3, 3, '2024-03-05', 1, 3000000.00),
(4, 4, '2024-04-20', 2, 1000000.00);

select * from artists
select * from artworks
select * from sales

--### Section 1: 1 mark each

--1. Write a query to display the artist names in uppercase.
select upper(name) as artistNames from artists


--2. Write a query to find the total amount of sales for the artwork 'Mona Lisa'.
select sum(total_amount) as totalSales from sales 
where artwork_id in(select artwork_id from artworks where title='Mona Lisa')

--3. Write a query to calculate the price of 'Starry Night' plus 10% tax.
select (110*price)/100 as price from artworks where title ='Starry Night'

--4. Write a query to extract the year from the sale date of 'Guernica'.
select year(sale_date) as saleyear from sales 
where artwork_id in (select artwork_id from artworks where title='Guernica')


--### Section 2: 2 marks each
select * from artists
select * from artworks
select * from sales

--5. Write a query to display artists who have artworks in multiple genres.
select name from artists
where artist_id in 
(select o.artist_id from artworks o 
join artworks i 
on i.artist_id=o.artist_id and 
i.genre<>o.genre)

--6. Write a query to find the artworks that have the highest sale total for each genre.
with cte_salerank
as
(select  a.artwork_id,a.title,sum(s.total_amount) as saleTotal, a.genre,
rank()over(partition by genre order by sum(s.total_amount) desc) as ranks from artworks a
inner join sales s
on s.artwork_id=a.artwork_id
group by  a.artwork_id,a.title,a.genre)
select * from cte_salerank where ranks=1;




--7. Write a query to find the average price of artworks for each artist.
select a.artist_id,a.name,avg(b.price) as avgPrice from artists a 
left join artworks b
on a.artist_id=b.artist_id
group by a.artist_id,a.name


--8. Write a query to find the top 2 highest-priced artworks and the total quantity sold for each.
select top(2) a.artwork_id,a.title,a.price ,sum(s.quantity) as totalQty from artworks a
inner join sales s
on s.artwork_id=a.artwork_id
group by a.artwork_id,a.title,a.price
order by a.price desc

--9. Write a query to find the artists who have sold more artworks than the average number of artworks sold per artist.

select a.artist_id,sum(s.quantity) from artworks a 
inner join sales s
on s.artwork_id=a.artwork_id
group by a.artist_id 
having sum(s.quantity)> (select avg(quantity) from sales)


--10. Write a query to display artists whose birth year is earlier than the average birth year of artists from their country.
select o.artist_id, o.name from artists o 
where o.birth_year<(select avg(i.birth_year) from artists i where o.country=i.country)


--11. Write a query to find the artists who have created artworks in both 'Cubism' and 'Surrealism' genres.
select artist_id ,name from artists where artist_id in
(select artist_id from artworks where genre ='Cubism'
intersect 
select artist_id from artworks where genre ='Surrealism')
--12. Write a query to find the artworks that have been sold in both January and February 2024.

select artwork_id, title from artworks where artwork_id in 
(select artwork_id from sales 
where  format(sale_date,'MM-yyyy')='01-2024'
intersect 
select artwork_id from sales 
where  format(sale_date,'MM-yyyy')='02-2024')


--13. Write a query to display the artists whose average artwork price is higher than every artwork price in the 'Renaissance' genre.
select artist_id,avg(price ) as avgprice  from artworks 
group by artist_id having avg(price)> all(select price from artworks where genre ='Renaissance')


--14. Write a query to rank artists by their total sales amount and display the top 3 artists.
select top (3) a.artist_id,a.name, sum(s.total_amount) as totalSales from artists a
inner join artworks w
on w.artist_id=a.artist_id
inner join sales s
on s.artwork_id=w.artwork_id
group by a.artist_id,a.name
order by sum(s.total_amount) desc 
--15. Write a query to create a non-clustered index on the `sales` table to improve query performance for queries filtering by `artwork_id`.
create nonclustered index ix_artwork on sales([artwork_id]);
--### Section 3: 3 Marks Questions
select * from artists
select * from artworks
select * from sales
--16.  Write a query to find the average price of artworks for each artist 
--and only include artists whose average artwork price is higher than the overall average artwork price.
select a.artist_id,avg(a.price) as avgPrice from artworks a group by a.artist_id
having avg(a.price)>(select avg(b.price) from  artworks b ) 

--17.  Write a query to create a view that shows artists who have created artworks in multiple genres.
create view vw_artistsMultiGenre
as
select name from artists
where artist_id in 
(select o.artist_id from artworks o 
join artworks i 
on i.artist_id=o.artist_id and 
i.genre<>o.genre)
select * from vw_artistsMultiGenre

--18.  Write a query to find artworks that have a higher price than the average price of artworks by the same artist.
select a.artwork_id,a.title from artworks a 
where a.price >(select avg(b.price) from artworks b where b.artist_id=b.artist_id)
 
--### Section 4: 4 Marks Questions

select * from artists
select * from artworks
select * from sales
--19.  Write a query to convert the artists and their artworks into JSON format.
select a.artist_id,a.name ,a.country,a.birth_year ,
(select b.artwork_id,b.title,b.genre,b.price from artworks b where b.artist_id=a.artist_id
for json PATH
)as artworks
from artists a for json PATH, root('artists')

--20.  Write a query to export the artists and their artworks into XML format.
select a.artist_id,a.name ,a.country,a.birth_year ,
(select b.artwork_id,b.title,b.genre,b.price from artworks b where b.artist_id=a.artist_id
for XML PATH('artist'), type
)as artworks
from artists a for XML PATH('artist'), root('artists')

--#### Section 5: 5 Marks Questions

select * from artists
select * from artworks
select * from sales
--21. Create a stored procedure to add a new sale and update the total sales for the artwork.
--Ensure the quantity is positive, and use transactions to maintain data integrity.
alter procedure sp_insertsale
@sale_id int, @artwork_id int,@sale_date date,@quantity int, @total_amount decimal(10,2)
as
begin 
begin transaction
begin try
if (@quantity<=0)
throw 50000,'quantity should be positive ',1;
insert into sales values
(@sale_id , @artwork_id ,@sale_date ,@quantity , @total_amount);
select sum(s.total_amount) as totalSale from sales s 
inner join artworks a
on s.artwork_id=a.artwork_id
where s.artwork_id=@artwork_id
commit transaction
end try
begin catch
print concat('error number: ',error_number());
print concat('error msg: ',error_message());
rollback transaction
end catch
end
exec sp_insertsale @sale_id=7, @artwork_id =1,@sale_date='2024-03-21',@quantity=0, @total_amount=2100000.00
delete from sales where sale_id=6

--22. Create a multi-statement table-valued function (MTVF) 
--to return the total quantity sold for each genre and use it in a query to display the results.
create function dbo.qtygenre(@genre varchar(max))
returns @temp table (genre varchar(max),qty int)
as
begin 
insert into @temp 
select a.genre, sum(s.quantity) as totalQty from artworks a
inner join sales s
on s.artwork_id=a.artwork_id
group by a.genre
having  a.genre=@genre;
return;
end;
select * from dbo.qtygenre('Cubism')


--23. Create a scalar function to calculate the average sales amount for artworks in a given genre
--and write a query to use this function for 'Impressionism'.
create function dbo.avgSales(@genre varchar(max))
returns int
as
begin
declare @avgtotal int 
set @avgtotal=(select avg(total_amount) from sales where artwork_id in 
(select artwork_id from artworks where genre =@genre))
return @avgtotal;
end 
select  dbo.avgSales('Impressionism')

select * from artists
select * from artworks
select * from sales
--24. Create a trigger to log changes to the `artworks` table into an `artworks_log` table,
--capturing the `artwork_id`, `title`, and a change description.
create table artworks_log(
log_id int identity(1,1) primary key,
artwork_id int,
title varchar(max),
description varchar(max))

create trigger trg_logchanges
on artworks 
after update 
as
begin
if(update(price))
insert into artworks_log values
((select artwork_id from inserted),(select title from inserted),'price updated');
end
update artworks 
set price =100.00
where artwork_id=4
select * from artworks_log

--25. Write a query to create an NTILE distribution of artists based on their total sales, divided into 4 tiles.


--### Normalization (5 Marks)

--26. **Question:**
--    Given the denormalized table `ecommerce_data` with sample data:

--| id  | customer_name | customer_email      | product_name | product_category | product_price | order_date | order_quantity | order_total_amount |
--| --- | ------------- | ------------------- | ------------ | ---------------- | ------------- | ---------- | -------------- | ------------------ |
--| 1   | Alice Johnson | alice@example.com   | Laptop       | Electronics      | 1200.00       | 2023-01-10 | 1              | 1200.00            |
--| 2   | Bob Smith     | bob@example.com     | Smartphone   | Electronics      | 800.00        | 2023-01-15 | 2              | 1600.00            |
--| 3   | Alice Johnson | alice@example.com   | Headphones   | Accessories      | 150.00        | 2023-01-20 | 2              | 300.00             |
--| 4   | Charlie Brown | charlie@example.com | Desk Chair   | Furniture        | 200.00        | 2023-02-10 | 1              | 200.00             |

--Normalize this table into 3NF (Third Normal Form). Specify all primary keys, foreign key constraints, unique constraints, not null constraints, and check constraints.
create table customers (
id int primary key,
customer_name varchar(max) not null,
customer_email varchar(max));

create table products (
product_id int primary key,
product_name varchar(max) not null,
product_category varchar(max),
product_price decimal(6,2));
 
 create table orders (
 order_id int primary key,
 order_date date not null,
  order_quantity int check(order_quantity<1),
  order_total_amount decimal(7,2));

  create table info(
id int foreign key references customers(id),
product_id int foreign key references products(product_id),
 order_id int foreign key references orders(order_id));


--### ER Diagram (5 Marks)

--27. Using the normalized tables from Question 27, create an ER diagram. Include the entities, relationships, primary keys, foreign keys, unique constraints, not null constraints, and check constraints. Indicate the associations using proper ER diagram notation.



