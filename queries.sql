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