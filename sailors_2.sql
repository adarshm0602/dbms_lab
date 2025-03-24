-- 1. Find the colors of boats reserved by Albert.
SELECT DISTINCT B.color
FROM BOAT B
JOIN RSERVERS R ON B.bid = R.bid
JOIN SAILORS S ON R.sid = S.sid
WHERE S.sname = 'Albert';

-- 2. Find all sailor IDs of sailors who have a rating of at least 8 or reserved boat 103.
SELECT DISTINCT S.sid
FROM SAILORS S
LEFT JOIN RSERVERS R ON S.sid = R.sid
WHERE S.rating >= 8 OR R.bid = 103;

-- 3. Find the names of sailors who have not reserved a boat whose name contains the string “storm”. 
-- Order the names in ascending order.
SELECT DISTINCT S.sname
FROM SAILORS S
WHERE S.sid NOT IN (
    SELECT DISTINCT R.sid
    FROM RSERVERS R
    JOIN BOAT B ON R.bid = B.bid
    WHERE B.bname LIKE '%storm%'
)
ORDER BY S.sname ASC;

-- 4. Find the names of sailors who have reserved all boats.
SELECT S.sname
FROM SAILORS S
JOIN RSERVERS R ON S.sid = R.sid
GROUP BY S.sid, S.sname
HAVING COUNT(DISTINCT R.bid) = (SELECT COUNT(*) FROM BOAT);

-- 5. Find the name and age of the oldest sailor.
SELECT S.sname, S.age
FROM SAILORS S
WHERE S.age = (SELECT MAX(age) FROM SAILORS);

-- 6. For each boat which was reserved by at least 5 sailors with age >= 40, find the boat ID and the average age of such sailors.
SELECT R.bid, AVG(S.age) AS avg_age
FROM RSERVERS R
JOIN SAILORS S ON R.sid = S.sid
WHERE S.age >= 40
GROUP BY R.bid
HAVING COUNT(DISTINCT S.sid) >= 5;

-- 7. Create a view that shows the names and colors of all the boats that have been reserved by a sailor with a specific rating.
CREATE VIEW Reserved_Boats AS
SELECT DISTINCT B.bname, B.color, S.rating
FROM BOAT B
JOIN RSERVERS R ON B.bid = R.bid
JOIN SAILORS S ON R.sid = S.sid;

-- 8. A trigger that prevents boats from being deleted if they have active reservations.
CREATE TRIGGER Prevent_Boat_Deletion
BEFORE DELETE ON BOAT
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM RSERVERS WHERE bid = OLD.bid) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete boat as it has active reservations';
    END IF;
END;
