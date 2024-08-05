-- Museums with the Most Diverse Collection of Styles
SELECT m.name AS museum_name, COUNT(DISTINCT w.style) AS style_count
FROM museums m
JOIN works w ON m.museum_id = w.museum_id
GROUP BY m.name
ORDER BY style_count DESC
LIMIT 10;

-- Number of paintings over decades
SELECT FLOOR((birth + death) / 2 / 10) * 10 AS decade, COUNT(*) AS painting_count
FROM works w
JOIN artists a ON w.artist_id = a.artist_id
GROUP BY decade
ORDER BY decade;

-- Top 5 Museums with the Oldest Collections
SELECT m.name AS museum_name, AVG(YEAR(CURDATE()) - a.birth) AS average_age
FROM works w
JOIN artists a ON w.artist_id = a.artist_id
JOIN museums m ON w.museum_id = m.museum_id
GROUP BY m.name
ORDER BY average_age DESC
LIMIT 5;

-- Total Number of Paintings by Each Artist
SELECT a.full_name, COUNT(w.work_id) AS total_paintings
FROM artists a
JOIN works w ON a.artist_id = w.artist_id
GROUP BY a.full_name
ORDER BY total_paintings DESC;

-- Top 10 Most Expensive Paintings (Based on Sale Price)
SELECT w.name AS painting_name, a.full_name AS artist_name, p.sale_price
FROM works w
JOIN artists a ON w.artist_id = a.artist_id
JOIN prices p ON w.work_id = p.work_id
ORDER BY p.sale_price DESC
LIMIT 10;

-- Top 5 Most Popular Museums
WITH MuseumPaintings AS (
    SELECT museum_id, COUNT(work_id) AS no_of_paintings_in_museum
    FROM works
    GROUP BY museum_id
)
SELECT m.name AS museum_name, mp.no_of_paintings_in_museum
FROM museums m
JOIN MuseumPaintings mp ON m.museum_id = mp.museum_id
ORDER BY mp.no_of_paintings_in_museum DESC
LIMIT 5;

-- Identify the Artist and the Museum Where the Most Expensive and Least Expensive Painting is Placed
WITH PriceRank AS (
    SELECT w.artist_id, w.museum_id, p.sale_price,
           RANK() OVER (ORDER BY p.sale_price DESC) AS rnk
    FROM works w
    JOIN prices p ON w.work_id = p.work_id
)
SELECT DISTINCT a.full_name AS artist_name, m.name AS museum_name, pr.sale_price
FROM PriceRank pr
JOIN artists a ON pr.artist_id = a.artist_id
JOIN museums m ON pr.museum_id = m.museum_id
WHERE pr.rnk = 1 OR pr.rnk = (SELECT MAX(rnk) FROM PriceRank);

 -- Which Museum Has the Most Number of the Most Popular Painting Style?
WITH query1 AS(SELECT style,
COUNT(work_id) OVER(PARTITION BY style) as no_of_work
FROM works
ORDER BY no_of_work desc
LIMIT 1),

query2 AS (SELECT work_id,museums.museum_id,museums.name
FROM works JOIN museums ON works.museum_id = museums.museum_id
INNER JOIN query1 ON query1.style = works.style)

SELECT name , COUNT(work_id) as no_of_painting
FROM query2
GROUP BY name
ORDER BY no_of_painting desc
LIMIT 1;

