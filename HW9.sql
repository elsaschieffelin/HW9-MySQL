USE sakila; 
-- (1) --
	-- Display the first and last names of all actors from the table actor.
SELECT first_name,last_name FROM actor; 
	--  Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
ALTER TABLE `sakila`.`actor` 
	ADD COLUMN `Actor_Name` VARCHAR(100) NULL AFTER `actor_id`;
SELECT CONCAT (first_name, ' ', last_name) AS Actor_Name FROM actor; 
UPDATE actor SET Actor_Name = CONCAT(first_name, ' ', last_name); 
SELECT Actor_Name FROM actor; 
-- (2) --
	-- You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT * FROM actor; 
SELECT actor_id, first_name, last_name FROM actor 
	WHERE first_name = 'Joe';
	-- Find all actors whose last name contain the letters GEN
SELECT * FROM actor
	WHERE last_name LIKE '%gen%'; 
	--  Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name FROM actor
		WHERE last_name LIKE '%li%';
	-- Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country
	WHERE country IN ('Afghanistan', 'Bangladesh', 'China'); 
-- (3) --
	-- You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB
ALTER TABLE `sakila`.`actor` 
ADD COLUMN `description` BLOB NULL AFTER `last_update`;
	-- Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
	DROP COLUMN description; 
-- (4) --
	-- List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) FROM actor
	GROUP BY last_name; 
	-- List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS count 
	FROM actor
	GROUP BY last_name
    HAVING count > 1; 
    -- The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
SELECT actor_id, Actor_Name FROM actor
	WHERE Actor_Name = 'GROUCHO WILLIAMS'; 
UPDATE actor SET first_name = 'HARPO', Actor_Name = 'HARPO WILLIAMS'
	WHERE actor_id = 172; 
	-- Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor 
	SET first_name = 'GROUCHO',
    Actor_Name = CONCAT('GROUCHO ', last_name)
    WHERE first_name = 'HARPO'; 
-- (5) --
	-- You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;
-- (6) --
	-- Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address
	FROM staff
		JOIN address
			ON address.address_id = staff.address_id; 
	-- Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT * FROM payment;
SELECT staff.staff_id, staff.first_name, staff.last_name, SUM(payment.amount)
	FROM payment
		JOIN staff 
			ON staff.staff_id = payment.staff_id
    WHERE payment.payment_date LIKE '2005-08-%'
    GROUP BY staff_id; 
	-- List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT COUNT(film_actor.actor_id), film_actor.film_id, film.title
	FROM film
		INNER JOIN film_actor
			ON film_actor.film_id = film.film_id
	GROUP BY film_id;
    -- How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(*) FROM inventory
	WHERE film_id = (
		SELECT film_id
			FROM film
            WHERE title = 'Hunchback Impossible'
            );
	-- Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.customer_id, customer.first_name, customer.last_name, SUM(payment.amount)
	FROM customer
		JOIN payment
        ON customer.customer_id = payment.customer_id
	GROUP BY customer_id
    ORDER BY customer.last_name;
-- (7) --
	-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title FROM film
	WHERE 
    title LIKE 'K%' OR title LIKE 'Q%'
	AND 
    language_id = 
		(
			SELECT language_id FROM language
				WHERE name = 'English'
		);
	-- Use subqueries to display all actors who appear in the film Alone Trip.
SELECT Actor_Name FROM actor
	WHERE actor_id IN 
		(
			SELECT actor_id FROM film_actor
				WHERE  film_id = 
					(
						SELECT film_id FROM film 
							WHERE title = 'Alone Trip'
					)
		);
	--  You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT email FROM customer
	WHERE address_id IN
		(
			SELECT address_id FROM address
				WHERE city_id IN
				(
					SELECT city_id FROM city 
						WHERE country_id = 
						(
							SELECT country_id from country
								WHERE country = 'Canada'
						)
				)
		);
	-- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title FROM film 
	WHERE film_id IN
	(
		SELECT film_id FROM film_category
			WHERE category_id = 
			(
				SELECT category_id FROM category
					WHERE name = 'Family'
			)
	); 
	 -- Display the most frequently rented movies in descending order.
SELECT film.title, COUNT(rental.inventory_id) AS count
	FROM film, inventory, rental
	WHERE inventory.film_id = film.film_id AND inventory.inventory_id = rental.inventory_id
    GROUP BY title
    ORDER BY count DESC;
    --  Write a query to display how much business, in dollars, each store brought in.
SELECT SUM(payment.amount), staff.store_id 
	FROM payment
		JOIN staff
			ON payment.staff_id = staff.staff_id
	GROUP BY store_id; 
	-- Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country
	FROM store, address, city, country
    WHERE store.address_id = address.address_id 
		AND address.city_id = city.city_id
        AND city.country_id = country.country_id;
	-- List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name, SUM(p.amount) AS sum
	FROM category c, film_category fc, inventory i, payment p, rental r
    WHERE c.category_id = fc.category_id
		AND fc.film_id = i.film_id
        AND i.inventory_id = r.inventory_id
        AND p.rental_id = r.rental_id
	GROUP BY c.name
    ORDER BY sum DESC; 
-- (8) -- 
	-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS
	SELECT c.name, SUM(p.amount) AS sum
		FROM category c, film_category fc, inventory i, payment p, rental r
		WHERE c.category_id = fc.category_id
			AND fc.film_id = i.film_id
			AND i.inventory_id = r.inventory_id
			AND p.rental_id = r.rental_id
	GROUP BY c.name
    ORDER BY sum DESC
    LIMIT 5; 
    -- How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;
	-- You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;
    
    
    