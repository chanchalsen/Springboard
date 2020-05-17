/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT 
fal.name,
fal.membercost
FROM Facilities fal
WHERE fal.membercost > 0;

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(fal.name)
FROM Facilities fal
WHERE fal.membercost = 0;

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT 
fal.facid,
fal.name,
fal.membercost,
fal.monthlymaintenance
FROM Facilities fal
WHERE (fal.membercost / fal.monthlymaintenance) < 0.2;

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
FROM Facilities fal
WHERE fal.facid IN ('1', '5');

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT 
fal.name,
fal.monthlymaintenance,
CASE 
	WHEN fal.monthlymaintenance > 100 THEN 'expensive'
	ELSE 'cheap' 
END AS "Cost Bracket"
FROM Facilities fal;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT 
mem.firstname,
mem.surname,
mem.joindate
FROM Members mem
WHERE mem.joindate = (SELECT MAX(joindate) FROM Members);

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT 
DISTINCT 
CONCAT(mem.firstname, ' ', mem.surname) AS fulll_name,
fal.facid,
fal.name
FROM Members mem
LEFT JOIN Bookings book ON mem.memid = book.memid
LEFT JOIN Facilities fal ON book.facid = fal.facid
WHERE fal.facid IN ('0', '1')
ORDER BY full_name, fal.name;


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT tbl.* from 
(
SELECT fal.name,
CONCAT(mem.firstname, ' ', mem.surname) AS full_name,
CASE 
	WHEN mem.memid = 0 THEN book.slots * fal.guestcost
	ELSE book.slots * fal.membercost 
END AS cost,
book.starttime
FROM Members mem
LEFT JOIN Bookings book ON mem.memid = book.memid
LEFT JOIN Facilities fal ON book.facid = fal.facid) as tbl
WHERE tbl.cost > 30
AND tbl.starttime LIKE '2012-09-14%'
ORDER BY tbl.cost DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT 
fal.name,
CONCAT(mem.firstname, ' ', mem.surname) AS full_name,
CASE WHEN mem.memid = 0 THEN book.slots * fac.guestcost
ELSE book.slots * fac.membercost END AS cost
FROM Members mem
LEFT JOIN Bookings book ON mem.memid = book.memid
LEFT JOIN Facilities fal ON book.facid = fal.facid
WHERE (SELECT CASE WHEN mem.memid = 0 THEN book.slots * fac.guestcost ELSE book.slots * fac.membercost END) > 30
AND book.starttime LIKE '2012-09-14%'
ORDER BY cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT 
fal.name,
SUM(CASE WHEN book.memid = 0 THEN book.slots * fal.guestcost
ELSE book.slots * fal.membercost END) AS revenue
FROM Bookings book
JOIN Facilities fal
ON book.facid = fac.facid
GROUP BY fac.facid
HAVING revenue < 1000
ORDER BY revenue DESC;
