use sakila;
-- 1a. Display the first and last names of all actors from the table actor.

SELECT first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

SELECT UPPER(CONCAT(first_name, ' ',last_name)) as 'Actor'
from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT actor_id, first_name, last_name
from actor 
where first_name like 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:

SELECT first_name, last_name
from actor
where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

SELECT last_name, first_name
from actor
where last_name like '%LI%';

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country
from country 
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

Alter Table actor
add column description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.

Alter Table actor
drop column description;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name,
count(last_name)
from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT last_name,
count(last_name)
from actor
group by last_name having count(*) >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

SET SQL_SAFE_UPDATES = 0;
Update actor 
set first_name = 'Harpo'
where first_name = 'Groucho' and last_name = 'Williams';


-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

SET SQL_SAFE_UPDATES = 0;
Update actor 
set first_name = 'Groucho'
where first_name = 'Harpo' and last_name = 'Williams';


-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

Describe address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

SELECT staff.first_name, staff.last_name, address.address_id
from staff
join address on
staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
select staff.staff_id, staff.first_name, staff.last_name, sum(payment.amount), payment.payment_date
from staff inner join payment on 
staff.staff_id = payment.staff_id and payment_date like '%2005-08%'
group by staff.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT film.film_id, film.title, count(film_actor.actor_id)
from film inner join film_actor on
film.film_id = film_actor.film_id
group by film.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

select title, 
(select count(*) from inventory
where film.film_id = inventory.film_id)
from film
where title = 'Hunchback Impossible';


-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

select customer.last_name, customer.first_name, count(payment.amount)
from customer  join payment on 
customer.customer_id = payment.customer_id
group by customer.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title 
from film  where title 
like 'Q%' or title like 'K%'
and title in
(
	select title
    from film
    where language_id = 1);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

select first_name, last_name
from actor where actor_id in
(
select actor_id
from film_actor 
where film_id in
(
select film_id
from film
where title = 'Alone Trip' ));


-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT customer.customer_id, customer.first_name, customer.last_name, customer.email
from customer  join address on
customer.address_id = address.address_id 
join city
on address.city_id = city.city_id
join country
on country.country_id = city.country_id
where country.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

select film.title
from film join film_category on
film.film_id = film_category.film_id
join category
on category.category_id = film_category.category_id
where category.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.

select film.title, count(rental_id)
from rental join inventory on
rental.inventory_id = inventory.inventory_id 
join film on
film.film_id = inventory.film_id
group by title
order by count(rental_id) desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

select store.store_id, sum(amount)
from payment join rental
on payment.rental_id = rental.rental_id
join inventory on
inventory.inventory_id = rental.inventory_id
join store on
store.store_id = inventory.store_id
group by store_id;


-- 7g. Write a query to display for each store its store ID, city, and country.

select store.store_id, city.city, country.country
from store join address  on 
store.address_id = address.address_id
join city on 
address.city_id = city.city_id
join country on 
country.country_id = city.country_id
group by store_id;


-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
 select category.name, sum(payment.amount)
 from category join film_category on
 category.category_id = film_category.category_id
 join inventory on
 inventory.film_id = film_category.film_id
 join rental on
 rental.inventory_id = inventory.inventory_id
 join payment on 
 payment.rental_id = rental.rental_id
 group by category.name order by  sum(payment.amount) limit 5;
 


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.


-- 8b. How would you display the view that you created in 8a?
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.






