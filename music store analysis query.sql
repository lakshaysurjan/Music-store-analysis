--Q1 Find all details of the oldest employee.
SELECT*FROM employee
WHERE birthdate = (SELECT MIN(birthdate)
				  FROM employee);
				  
--Q2 Who is the senior most employee based on job title
SELECT*FROM employee
Order by levels desc
LIMIT 1;

--Q3 Which countries have the most invoice 
SELECT billing_country,COUNT(*) AS c
FROM invoice
GROUP BY billing_country
ORDER BY c desc;

--Q4 What are top 3 values of total invoice 
SELECT total 
FROM invoice
ORDER BY total desc
LIMIT 3;

--Q5 Which city has the best customers? We would like to throw a promotional music festival in the city we made the most money.
--Write a query that returns one city that has the highest sum of invoice totals.Return both city name and sum of all invoice totals.
SELECT billing_city,SUM(total) AS invoice_total
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total desc
LIMIT 1;

--Q6 Who is the best customer? The customer who has spent the most money will be declred the best customer. Write a query that returns 
--the person who has spent the most money.
SELECT customer.customer_id,customer.first_name, customer.last_name, SUM(invoice.total) AS total
FROM customer
JOIN invoice
ON customer.customer_id=invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total desc
LIMIT 1;

--Q7 Write a query to return the email,first_name,last_name and genre of all Rock Music listeners. Return your list ordered alphabetically 
--by email starting with A.
SELECT customer.email,customer.first_name,customer.last_name,genre.name
FROM customer 
JOIN invoice ON customer.customer_id=invoice.customer_id
JOIN invoice_line ON invoice.invoice_id=invoice_line.invoice_id
JOIN track ON invoice_line.track_id=track.track_id
JOIN genre ON track.genre_id=genre.genre_id
WHERE genre.name='Rock'
ORDER BY customer.email;

--Q8 Lets invite the artists who have written the most rock music in our dataset. Write a query that returns the artist name and total
--track count of the top 10 rock bands.
SELECT artist.name, COUNT(*) AS a
FROM artist
JOIN album ON artist.artist_id=album.artist_id
JOIN track ON album.album_id=track.album_id
WHERE track.genre_id=(SELECT genre.genre_id
					 FROM genre
					 WHERE genre.name='Rock')
GROUP BY artist.name
ORDER BY a DESC
LIMIT 10;

--Q9 Return all the track names that have a song length longer than the average song length. Return name and miliseconds for each track.
--Order by the song length with the longest songs listed first
SELECT name,milliseconds 
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds)
					  FROM track)
ORDER BY milliseconds DESC;	

--Q10 Find how much amount spent by each customer on artists? Write a query to return customer name,artist name and total spent.
SELECT customer.first_name,customer.last_name,artist.name, SUM(invoice.total)
FROM customer 
JOIN invoice ON customer.customer_id=invoice.customer_id
JOIN invoice_line ON invoice.invoice_id=invoice_line.invoice_id
JOIN track ON invoice_line.track_id=track.track_id
JOIN album ON track.album_id=album.album_id
JOIN artist ON album.artist_id=artist.artist_id
GROUP BY customer.first_name,customer.last_name,artist.name;

--Q11 We want to find out the most popular music genre for each country. We determine the most popular genre as the genre with the 
--highest amount of purchases. Write a query that returns each country along with top genre. For countries where the maximum number of
--purchases is shared return all genres.
WITH popular_genre AS
(
SELECT COUNT(invoice_line.quantity) AS purchases,customer.country,genre.name,genre.genre_id,ROW_NUMBER() OVER(PARTITION BY customer.country 
ORDER BY COUNT(invoice_line.quantity)DESC )AS RowNo
FROM invoice_line
	JOIN invoice ON invoice.invoice_id=invoice_line.invoice_id
	JOIN customer ON customer.customer_id=invoice.customer_id
	JOIN track ON track.track_id=invoice_line.track_id
	JOIN genre ON genre.genre_id=track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
	)
	SELECT*FROM popular_genre WHERE RowNo <=1
