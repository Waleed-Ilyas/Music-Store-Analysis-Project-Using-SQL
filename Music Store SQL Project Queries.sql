-- Q1: Who is the senior most employee based on job title?

Select * from employee
ORDER BY levels desc limit 1

-- Q:2 Which country have the most invoices?

Select COUNT(*) as c, billing_country
from invoice 
group by billing_country
order by c DESC 

-- Q:3 What are the top 3 values of total invoices?

Select total From invoice
order by total DESC
LIMIT 3

-- Q:4 Which City has the best Customers? We Would like to throw a promotional Music Festival in the city we made the most money. Write the Query that returns one city that has the highest sum of invoice totals. Resturn both the city name & sum of all invoice totals.

Select SUM(total) as invoice_total, billing_city
From invoice Group by billing_city
Order By invoice_total DESC

-- Q:5 Who is the best Customer? The Customer who has spent the most money will be declared the best Customer. Write a query that returns the person who has spent the most money.

Select customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) as total
From Customer Join invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id ORDER BY total DESC Limit 1

-- Q:6 Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A

Select Distinct email, first_name, last_name
From customer
Join invoice ON Customer.customer_id = invoice.customer_id
Join invoice_line ON invoice.invoice_id = invoice_line.invoice_id
where track_id IN(
	Select track_id from track
	Join genre ON track.genre_id = genre.genre_id
	Where genre.name Like 'Rock'
) Order By email;


-- Q:7 Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands

Select artist.artist_id, artist.name, Count(artist.artist_id) AS number_of_songs
From Track Join album ON album.album_id = track.album_id
Join artist ON artist.artist_id = album.artist_id
Join genre ON genre.genre_id = track.genre_id
WHERE genre.name like 'Rock'
Group By artist.artist_id Order By number_of_songs DESC Limit 10

-- Q:8 Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

Select name, milliseconds
From track
Where milliseconds > (
	Select AVG(milliseconds) AS avg_track_lenght
	From track
)
Order By milliseconds DESC
Limit 10;

-- Q:9 Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent.

With best_selling_artist AS(
	Select artist.artist_id AS artist_id, artist.name AS artist_name, 
	Sum(invoice_line.unit_price*invoice_line.quantity)
	From invoice_line join track ON track.track_id = invoice_line.track_id
	Join album ON album.album_id = track.album_id
	Join artist on artist.artist_id = album.artist_id
	Group by 1 Order By 3 Desc  Limit 1
)

Select c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
SUM(il.unit_price*il.quantity) AS amount_spent From invoice i
Join customer c ON c.customer_id = i.customer_id
Join invoice_line il ON il.invoice_id = i.invoice_id
Join track t ON t.track_id = il.track_id
Join album alb On alb.album_id = t.album_id
Join best_selling_artist bsa ON bsa.artist_id = alb.artist_id
Group By 1,2,3,4
Order By 5 Desc;

-- Q:10 We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases.

With popular_genre AS 
(
	Select Count(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
	ROW_NUMBER() OVER (PARTITION BY customer.country Order By Count (invoice_line.quantity) DESC) AS RowNo
	From invoice_line
		Join invoice ON invoice.invoice_id = invoice_line.invoice_id
		Join customer ON customer.customer_id = invoice.customer_id
		Join track ON track.track_id = invoice_line.track_id
		Join genre ON genre.genre_id = track.genre_id 
		Group By 2,3,4 Order By 2 ASC, 1 Desc
)
Select * From popular_genre Where RowNo <= 1


-- Q:11 Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount 

With Customer_with_country AS(
	Select customer.customer_id, first_name, last_name, billing_country, SUM(total) AS total_spending,
	ROW_NUMBER() OVER (PARTITION BY billing_country Order By SUM(total) DESC) AS RowNo
	From invoice
	Join customer On customer.customer_id = invoice.customer_id
	Group By 1,2,3,4 Order By 4 ASC, 5 Desc
)
Select * From Customer_with_country where RowNo <=1




















