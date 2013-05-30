SELECT u.screen_name, COUNT(*) FROM "user" u LEFT JOIN status s ON s.user_id = u.id GROUP BY u.screen_name ORDER BY COUNT(*) DESC LIMIT 30;

SELECT u.screen_name, u.id, COUNT(*) FROM "user" u LEFT JOIN status s ON s.user_id = u.id GROUP BY u.screen_name, u.id ORDER BY COUNT(*) DESC LIMIT 30;

SELECT u.screen_name, u.id, COUNT(*) FROM "user" u LEFT JOIN status s ON s.user_id = u.id GROUP BY u.screen_name, u.id HAVING COUNT(*) > 10 ORDER BY COUNT(*) DESC;


SELECT DISTINCT ()
SELECT m.screen_name AS name, m.id AS id, COUNT(*) FROM "user_mention" m LEFT JOIN status s ON m.status_id = s.id GROUP BY m.screen_name, m.id HAVING COUNT(*) > 5
UNION SELECT u.screen_name AS name, u.id AS id, COUNT(*) FROM "user" u LEFT JOIN status s ON s.user_id = u.id GROUP BY u.screen_name, u.id HAVING COUNT(*) > 5;



SELECT DISTINCT d.name AS name, d.id AS id FROM (
    SELECT m.screen_name AS name, m.id AS id
        FROM "user_mention" m LEFT JOIN status s ON m.status_id = s.id
        GROUP BY m.screen_name, m.id HAVING COUNT(*) > 5
    UNION SELECT u.screen_name AS name, u.id AS id
        FROM "user" u LEFT JOIN status s ON s.user_id = u.id
        GROUP BY u.screen_name, u.id HAVING COUNT(*) > 5
    ) AS d;




SELECT d.tag, d.state, d.cnt, (d.cnt/s.total)*100 AS pct FROM 
    (SELECT t.tag AS tag, l.state AS state, COUNT(DISTINCT s.id)::float AS cnt FROM status s
        LEFT JOIN tag t ON t.status_id = s.id
        LEFT JOIN "user" u ON u.id = s.user_id
        LEFT JOIN locations l ON l.location = u.location
        WHERE l.country_code = 'de' AND t.category = 'Parteien'
        AND l.state IS NOT NULL
        GROUP BY t.tag, l.state) AS d
    LEFT JOIN (SELECT ls.state AS state, COUNT(*)::float as total FROM locations ls WHERE ls.country_code = 'de' GROUP BY ls.state) as s
        ON d.state = s.state
    ORDER BY pct DESC;




SELECT state, COUNT(*) FROM locations WHERE country_code = 'de' GROUP BY state ORDER BY COUNT(*) DESC;
SELECT city, COUNT(*) FROM locations WHERE country_code = 'de' GROUP BY city ORDER BY COUNT(*) DESC;


      SELECT t.tag, to_char(s.created_at, 'YYYY-MM-DD') AS day, COUNT(s.id)
        FROM status s LEFT JOIN tag t ON t.status_id = s.id
        WHERE t.category = 'Personen'
        GROUP BY t.tag, day ORDER BY day, t.tag;




SELECT l.screen_name, l.user_id, COUNT(DISTINCT s.id) as tweets, COUNT(r.id) AS retweeted
    FROM lists l
    LEFT JOIN status s ON s.user_id = l.user_id
    LEFT JOIN status r ON r.retweeted_status_id = s.id
    WHERE l.list_name = 'bundestagsabgeordnete'
    GROUP BY l.screen_name, l.user_id
    ORDER BY COUNT(r.id) DESC;

SELECT COUNT(s.id), SUM(s.retweet_count), SUM(s.favorite_count)
    FROM lists l LEFT JOIN status s ON s.user_id = l.user_id
    WHERE l.list_name = 'Politikertreppe';


SELECT t.screen_name, s.user_id, COUNT(DISTINCT s.id), COUNT(r.id) AS retweets
    FROM status s
    LEFT JOIN "user" t ON t.id = s.user_id
    LEFT JOIN status r ON r.retweeted_status_id = s.id
    GROUP BY s.user_id, t.screen_name
    ORDER BY COUNT(r.id) DESC LIMIT 10;