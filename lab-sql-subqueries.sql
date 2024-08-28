use sakila;

-- Write SQL queries to perform the following tasks using the Sakila database:

-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT COUNT(i.film_id) FROM sakila.inventory as i
WHERE i.film_id = (SELECT f.film_id as id FROM sakila.film as f where f.title = "Hunchback Impossible");

-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.

SELECT f.title as title FROM sakila.film as f
WHERE f.length > (SELECT AVG(f.length) as average FROM sakila.film as f);
-- 3. Use a subquery to display all actors who appear in the film "Alone Trip"

SELECT a.first_name , a.last_name from sakila.actor as a 
WHERE a.actor_id in (
	SELECT fa.actor_id as id from sakila.film_actor as fa
		WHERE fa.film_id = (
			SELECT f.film_id as id FROM sakila.film as f where f.title = "Alone Trip")
);

-- Bonus:
-- 4. Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.


SELECT f.title as title FROM sakila.film as f
WHERE f.film_id in (
	SELECT fc.film_id as id FROM sakila.film_category as fc
		WHERE fc.category_id = (
			SELECT c.category_id as catid FROM sakila.category as c
				WHERE c. name = "family")
);
-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.

SELECT CONCAT(c.first_name , " ",  c.last_name) as name, c.email as email from sakila.customer as c
WHERE c.address_id in(
	SELECT a.address_id FROM sakila.address as a
		WHERE a.city_id in (
			SELECT ci.city_id from sakila.city as ci
				WHERE ci.country_id = (
					SELECT co.country_id from sakila.country as co
						where co.country = "Canada")
));


SELECT CONCAT(c.first_name , " ",  c.last_name) as name, c.email as email from sakila.customer as c
JOIN sakila.address as a
ON c.address_id = a.address_id
JOIN sakila.city as ci
ON a.city_id = ci.city_id
JOIN sakila.country as co
ON ci.country_id = co.country_id 
WHERE co.country = "Canada";


-- 6. Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.

SELECT f.title FROM sakila.film as f
JOIN sakila.film_actor as fa
ON f.film_id = fa.film_id
WHERE fa.actor_id = (
	SELECT fa.actor_id, count(fa.film_id) FROM sakila.film_actor as fa
	GROUP BY fa.actor_id
	ORDER BY fa.actor_id DESC
	LIMIT 1
);

-- 7. Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.

SELECT f.film_id, f.title FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE r.customer_id = (
    SELECT p.customer_id FROM payment as p
    GROUP BY p.customer_id
    ORDER BY SUM(p.amount) DESC
    LIMIT 1
);
-- 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.


SELECT customer_id, total_amount
FROM (
    SELECT p.customer_id, SUM(p.amount) AS total_amount FROM sakila.payment as p
    GROUP BY p.customer_id
) AS client_totals
WHERE total_amount > (
    SELECT AVG(total_amount) FROM (
        SELECT SUM(p.amount) AS total_amount
		FROM sakila.payment as p
        GROUP BY p.customer_id
    ) AS average_total
);