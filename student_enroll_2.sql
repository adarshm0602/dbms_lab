-- 1. Add a new text book and adopt it for a course in a department
INSERT INTO TEXT (book-ISBN, book-title, publisher, author)
VALUES (1234567890, 'Introduction to AI', 'Pearson', 'Stuart Russell');

INSERT INTO BOOK_ADOPTION (course#, sem, book-ISBN)
VALUES (101, 1, 1234567890); -- Assuming course# 101 belongs to the department

-- 2. List textbooks for CS department courses with more than two books
SELECT BA.course#, BA.book-ISBN, T.book-title 
FROM BOOK_ADOPTION BA
JOIN COURSE C ON BA.course# = C.course#
JOIN TEXT T ON BA.book-ISBN = T.book-ISBN
WHERE C.dept = 'CS'
GROUP BY BA.course#, BA.book-ISBN, T.book-title
HAVING COUNT(BA.book-ISBN) > 2
ORDER BY T.book-title ASC;

-- 3. List departments where all adopted books are published by a specific publisher
SELECT C.dept 
FROM COURSE C
JOIN BOOK_ADOPTION BA ON C.course# = BA.course#
JOIN TEXT T ON BA.book-ISBN = T.book-ISBN
GROUP BY C.dept
HAVING COUNT(DISTINCT T.publisher) = 1;

-- 4. List students with maximum marks in 'DBMS' course
SELECT S.regno, S.name, E.marks
FROM STUDENT S
JOIN ENROLL E ON S.regno = E.regno
JOIN COURSE C ON E.course# = C.course#
WHERE C.cname = 'DBMS' AND E.marks = (SELECT MAX(marks) FROM ENROLL WHERE course# = C.course#);

-- 5. Create a view for courses opted by a student with marks obtained
CREATE VIEW Student_Course_Marks AS
SELECT S.regno, S.name, E.course#, C.cname, E.marks
FROM STUDENT S
JOIN ENROLL E ON S.regno = E.regno
JOIN COURSE C ON E.course# = C.course#;

-- 6. Create a trigger to prevent enrollment if marks prerequisite is less than 40
CREATE TRIGGER Prevent_Low_Marks_Enrollment
BEFORE INSERT ON ENROLL
FOR EACH ROW
BEGIN
    IF NEW.marks < 40 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot enroll, marks prerequisite is less than 40';
    END IF;
END;
