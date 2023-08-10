/***
--> Digital Music Store - Data Analysis
Data Analysis project to help Chinook Digital Music Store to help how they can
optimize their business opportunities and to help answering business related questions.
***/

select * from Album; -- 347
select * from Artist; -- 275
select * from Customer; -- 59
select * from Employee; -- 8
select * from Genre; -- 25
select * from Invoice; -- 412
select * from InvoiceLine; -- 2240
select * from MediaType; -- 5
select * from Playlist; -- 18
select * from PlaylistTrack; -- 8715
select * from Track; -- 3503



-- Using SQL solve the following problems using the chinook database.
1) Find the artist who has contributed with the maximum no of albums. Display the artist name and the no of albums.

select name, num_albums
from(
select ar.name, count(*) as num_albums,
rank() over (order by count(*) desc)
from artist ar
join album ab on ar.artistid= ab.artistid
group by ar.name)q
where rank =1


2) Display the name, email id, country of all listeners who love Jazz, Rock and Pop music.

select concat(c.firstname,' ',c.lastname),c.email,c.country
from customer c
join invoice i on c.customerid=i.customerid
join invoiceline il on il.invoiceid = i.invoiceid
join track t on t.trackid=il.trackid
join genre g on g.genreid=t.genreid
where g.name in ('Pop','Jazz','Rock')


3) Find the employee who has supported the most no of customers. Display the employee name and designation

select name,desig from(
select (e.firstname||' '|| e.lastname) as name,e.title as desig, count(*),
rank() over( order by count(*) desc)
from employee e 
join customer c on c.supportrepid= e.employeeid
group by name,desig)p
where rank=1

 
4) Which city corresponds to the best customers?
select city from(
select c.city,sum(i.total),
rank() over (order by sum(i.total) desc)
from customer c
join invoice i on c.customerid=i.customerid
group by c.city)p
where rank =1

5) The highest number of invoices belongs to which country?
select p.billingcountry from(
select billingcountry,count(*),
rank() over (order by count(*) desc)
from invoice 
group by billingcountry
	)p where p.rank =1

6) Name the best customer (customer who spent the most money).

select name from (
select concat(c.firstname,' ',c.lastname) as name, sum(i.total),
rank() over (order by sum(i.total) desc)
from customer c
join invoice i on c.customerid=i.customerid
group by name)p
where p.rank =1

7) Suppose you want to host a rock concert in a city and want to know which location should host it.
select city from(
select c.city,count(t.trackid),
rank() over( order by count(t.trackid) desc)
from customer c
join invoice i on c.customerid=i.customerid
join invoiceline il on il.invoiceid = i.invoiceid
join track t on t.trackid=il.trackid
join genre g on g.genreid=t.genreid
where g.name in ('Rock')
group by c.city)p
where p.rank =1

8) Identify all the albums who have less then 5 track under them.
    Display the album name, artist name and the no of tracks in the respective album.
	
	select ab.title,ar.name,count(t.trackid)
	from artist ar
	join album ab on ar.artistid=ab.artistid
	join track t on t.albumid=ab.albumid
	group by ab.title,ar.name
	having count(t.trackid)<5
	order by 3 desc

9) Display the track, album, artist and the genre for all tracks which are not purchased.





select t.name, ab.title,ar.name,g.name from
artist ar
	join album ab on ar.artistid=ab.artistid
	join track t on t.albumid=ab.albumid
	join genre g on g.genreid = t.genreid
	--join invoiceline il on il.trackid= t.trackid
	where not exists (select trackid from invoiceline il
					 where il.trackid= t.trackid)
	
	

10) Find artist who have performed in multiple genres. Diplay the aritst name and the genre.
--count of genres for each artist
select ar.name,count(distinct g.name)
from
artist ar
	join album ab on ar.artistid=ab.artistid
	join track t on t.albumid=ab.albumid
	join genre g on g.genreid = t.genreid
	group by ar.name
	having count(distinct g.name)>1

with cte as(
select distinct ar.name,g.name as gen
from
artist ar
	join album ab on ar.artistid=ab.artistid
	join track t on t.albumid=ab.albumid
	join genre g on g.genreid = t.genreid
	order by 1
	)
	, temp as (select cte.name as name1 from 
			   cte 
			   group by cte.name
			   having count(1)>1
			  
			  )
select cte.name,cte.gen
from temp
join cte on cte.name=temp.name1


11) Which is the most popular and least popular genre?

genres popularity determined by the no of tracks sold

with cte as(
select g.name, sum(il.quantity),
rank() over (order by sum(il.quantity) desc)
from genre g
join track t on g.genreid= t.genreid
join invoiceline il on il.trackid= t.trackid
group by g.name)

select name ,
case when rank=1 then 'Most popular' else 'least popular' end as pop
from cte
where cte.rank =1 or cte.rank in (select max(rank) from cte)


12) Identify if there are tracks more expensive than others. If there are then
    display the track name along with the album title and artist name for these expensive tracks.
	with cte as(
	select t.name,t.albumid,t.unitprice,
	rank() over (order by t.unitprice desc)
	from 
	track t 
	)
	
	select cte.name, ab.title,ar.name  from
	cte 
	join album ab on ab.albumid=cte.albumid
	join artist ar on ar.artistid=ab.artistid
	where cte.rank =1
	
    
13) Identify the 5 most popular artist for the most popular genre.
    Popularity is defined based on how many songs an artist has performed in for the particular genre.
    Display the artist name along with the no of songs.
    [Reason: Now that we know that our customers love rock music, we can decide which musicians 
	 to invite to play at the concert.
    Lets invite the artists who have written the most rock music in our dataset.]
	
	with pop_genre as(
	select p.genre from(
	select count(q.genre),q.genre,
	rank() over(order by count(q.genre) desc)
	from (
	select ar.name as artistname,g.name as genre,count(*) as num_purchases
	from artist ar
	join album ab on ar.artistid=ab.artistid
	join track t on t.albumid=ab.albumid
	join invoiceline il on il.trackid=t.trackid
	join genre g on g.genreid=t.genreid
	group by ar.name,g.name)q
	group by q.genre)p
	where rank=1)
	
	select ar.name as artistname,count(t.trackid) as num_songs
	from artist ar
	join album ab on ar.artistid=ab.artistid
	join track t on t.albumid=ab.albumid
	join genre g on g.genreid=t.genreid
	where g.name in (select genre from pop_genre)
		group by ar.name
		order by num_songs desc

14) Find the artist who has contributed with the maximum no of songs/tracks. Display the artist name and the no of songs.
select artistname from (

select ar.name as artistname,count(t.trackid) as num_songs,
    rank() over(order by count(1) desc) as rnk

	from artist ar
	join album ab on ar.artistid=ab.artistid
	join track t on t.albumid=ab.albumid
	join genre g on g.genreid=t.genreid
			group by ar.name
					order by num_songs desc
	)x
where x.rnk = 1;


15) Are there any albums owned by multiple artist?

select (ab.albumid),count(ab.artistid)
from album ab
group by ab.albumid
having count(ab.albumid)>1


 
16) Is there any invoice which is issued to a non existing customer?

select *
from invoice i 
left join customer c on c.customerid=i.customerid
where c.customerid is null

select * from Invoice I
where not exists (select 1 from customer c 
                where c.customerid = I.customerid);



17) Is there any invoice line for a non existing invoice?

select *
from invoice i 
left join invoiceline il on il.invoiceid=i.invoiceid
where i.invoiceid is null


18) Are there albums without a title?

select *
from album
where title is null


19) Are there invalid tracks in the playlist?

select *
from playlisttrack 
where trackid not in (select trackid from track)


select * from PlaylistTrack pt -- result is 0 which means that all tracks in the playlist do exist hence all are valid
where not exists (select 1 from Track t 
                 where t.trackid = pt.trackid)

