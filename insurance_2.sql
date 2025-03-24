-- 1. Find the total number of people who owned cars that were involved in accidents in 2021.
SELECT COUNT(DISTINCT O.driver_id#) AS total_owners
FROM OWNS O
JOIN PARTICIPATED P ON O.regno = P.regno
JOIN ACCIDENT A ON P.report_number = A.report_number
WHERE YEAR(A.acc_date) = 2021;

-- 2. Find the number of accidents in which the cars belonging to “Smith” were involved.
SELECT COUNT(DISTINCT P.report_number) AS accident_count
FROM PERSON Pe
JOIN OWNS O ON Pe.driver_id# = O.driver_id#
JOIN PARTICIPATED P ON O.regno = P.regno
WHERE Pe.name = 'Smith';

-- 3. Add a new accident to the database; assume any values for required attributes.
INSERT INTO ACCIDENT (report_number, acc_date, location)
VALUES (1001, '2025-03-24', 'New York');

-- 4. Delete the Mazda belonging to “Smith”.
DELETE FROM OWNS 
WHERE regno IN (
    SELECT O.regno 
    FROM OWNS O
    JOIN PERSON P ON O.driver_id# = P.driver_id#
    JOIN CAR C ON O.regno = C.regno
    WHERE P.name = 'Smith' AND C.model = 'Mazda'
);

DELETE FROM CAR 
WHERE regno IN (
    SELECT O.regno 
    FROM OWNS O
    JOIN PERSON P ON O.driver_id# = P.driver_id#
    JOIN CAR C ON O.regno = C.regno
    WHERE P.name = 'Smith' AND C.model = 'Mazda'
);

-- 5. Update the damage amount for the car with license number “KA09MA1234” in the accident with report.
UPDATE PARTICIPATED 
SET damage_amount = 5000  -- Assume new damage amount
WHERE regno = 'KA09MA1234';

-- 6. A view that shows models and year of cars that are involved in accidents.
CREATE VIEW AccidentCars AS
SELECT DISTINCT C.model, C.year
FROM CAR C
JOIN PARTICIPATED P ON C.regno = P.regno;

-- 7. A trigger that prevents a driver from participating in more than 3 accidents in a given year.
DELIMITER //
CREATE TRIGGER Prevent_More_Than_3_Accidents
BEFORE INSERT ON PARTICIPATED
FOR EACH ROW
BEGIN
    DECLARE accident_count INT;
    SELECT COUNT(*) INTO accident_count 
    FROM PARTICIPATED P
    JOIN ACCIDENT A ON P.report_number = A.report_number
    WHERE P.driver_id# = NEW.driver_id# AND YEAR(A.acc_date) = YEAR(CURDATE());

    IF accident_count >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A driver cannot participate in more than 3 accidents in a year';
    END IF;
END;
//
DELIMITER ;
