CREATE DATABASE college_admission;
USE college_admission;

CREATE TABLE College(
cName VARCHAR(50),
state VARCHAR(50),
enrollment INT PRIMARY key);

CREATE TABLE Student(
sID INT PRIMARY KEY,
sName VARCHAR(50),
GPA FLOAT,
sizeHS INT);

CREATE TABLE Apply(
sID INT,
cName VARCHAR(50),
major VARCHAR(50),
decision CHAR(1) NOT NULL
CHECK (decision IN ('Y','N')));

INSERT INTO College (cName,state,enrollment) VALUES
("Stanford","CA",15000),
("Berkeley","CA",36000),
("MIT","MA",10000),
("Cornell","NY",21000);

INSERT INTO Student (sID,sName,GPA,sizeHS) VALUES
(123,"Amy",3.9,1000),
(234,"Bob",3.6,1500),
(345,"Craig",3.5,500),
(456,"Doris",3.9,1000),
(567,"Edward",2.9,2000),
(678,"Fay",3.8,200),
(789,"Gary",3.5,800),
(987,"Helen",3.7,800),
(876,"Irene",3.9,400),
(765,"Jay",2.9,1500),
(654,"Amy",3.9,1000),
(543,"Craig",3.4,2000);

INSERT INTO Apply (sID,cName,major,decision) VALUES
(123,"Stanford","CS","Y"),
(123,"Stanford","EE","N"),
(123,"Berkeley","CS","Y"),
(123,"Cornell","EE","Y"),
(234,"Berkeley","biology","Y"),
(345,"MIT","bioengineering","Y"),
(345,"Cornell","bioengineering","N"),
(345,"Cornell","CS","Y"),
(345,"Cornell","EE","N"),
(678,"Stanford","history","Y"),
(987,"Stanford","CS","Y"),
(987,"Berkeley","CS","Y"),
(876,"Stanford","CS","N"),
(876,"MIT","biology","Y"),
(876,"MIT","marine biology","N"),
(765,"Stanford","history","Y"),
(765,"Cornell","history","N"),
(765,"Cornell","pychology","Y"),
(543,"MIT","CS","N");

/* This query is going to find
the ID, name, and GPA of
students whose GPA is greater than 3.6.*/

SELECT sID, sName, GPA
FROM Student
WHERE GPA > 3.6;

/* In this query, we're going to
find the names of the students
and the majors for which they've applied.*/

SELECT distinct sName, major
FROM Student S
JOIN Apply A
ON A.sID = S.sID;
/* Another solution*/
SELECT distinct sName, major
FROM Student S, Apply A
WHERE A.sID = S.sID;

/* Our next query is going to be a little more complicated; it's going to find the names
and GPAs of students whose size high school is less than a thousand, they've applied to CS at Stanford, and we're going
to get the decision associated with that.*/
SELECT sName, GPA, decision
FROM Student S
JOIN Apply A
ON A.sID = S.sID AND sizeHS < 1000 AND major = "CS" AND cName = "Stanford";

/* Our next query is again a join of two relations.
This time we're going to find all large
campuses that have someone applying to that campus in CS.*/

SELECT C.cName, sID
FROM Apply A 
JOIN College C ON A.cName = C.cName AND major = "CS" AND enrollment > 20000
ORDER BY C.cName desc; 

/* we wanted to find all students who were applying for a major that had to do with bio.*/
SELECT sID, major
FROM Apply
WHERE major like '%bio%';

/* we'll take the pairs where the student had the same GPA and will return the ID,
name, and GPA for each of the two students.*/

SELECT S1.sID, S1.sName, S1.GPA,  S2.sID, S2.sName, S2.GPA
FROM Student S1, Student S2
WHERE S1.GPA = S2.GPA AND S1.sID < S2.sID;

/* generate a list that includes names
of colleges together with names of students.*/

SELECT cName as name FROM college
UNION ALL
SELECT sName as name FROM Student
ORDER BY name;

/* Find the students who have applied in both CS and EE */
SELECT DISTINCT A1.sID
FROM Apply A1
JOIN Apply A2
ON A1.sID = A2.sID AND  A1.major = "CS" AND A2.major = "EE";

/* let's find students
who applied to CS but did not apply to EE.*/

SELECT DISTINCT A1.sID
FROM Apply A1
JOIN Apply A2 ON A1.sID = A2.sID AND A1.major = "CS" AND A2.major != ANY (SELECT DISTINCT sID FROM APPLY WHERE major = "EE");

/* What this query finds is the ID's and names of all students who have applied to major in CS to some college.*/
SELECT sID, sName
FROM Student
WHERE sID in (SELECT sID from Apply Where major = "CS");


/* Average GPA's of students who choose to apply for CS.*/
SELECT AVG(GPA)
FROM Student 
where sID IN (SELECT sID FROM Apply WHERE major = "CS");

/* find students
who have applied to major in
CS, but have not applied to major in EE.*/
SELECT sID, sName
FROM Student
WHERE sID IN (SELECT sID FROM Apply WHERE major = "CS") 
AND sID NOT IN (SELECT sID FROM Apply WHERE major = "EE");

/* The query is going to find all colleges, such that there's
some other college that is in the same state.*/
SELECT cName, state
FROM College C1
WHERE EXISTS (SELECT * FROM College C2 WHERE C1.state = C2. state AND C1.cName <> C2.cName);

/* finding the college that has the largest enrollment.*/ 
SELECT cName
FROM college C1
WHERE NOT EXISTS (SELECT * FROM College C2 WHERE C1.enrollment < C2.enrollment);
/*ALTERNATE*/
SELECT cName
FROM college
WHERE enrollment >= ALL (SELECT enrollment FROM College);
/*ALTERNATE8*/
SELECT cName
From College C1
WHERE enrollment > ALL (SELECT enrollment FROM College C2 WHERE C1.cName <> C2.cName);


/* look for the student with the highest GPA.*/
SELECT GPA, sName
FROM Student S1
WHERE NOT EXISTS (SELECT * FROM Student S2 WHERE S1.GPA < S2.GPA);
/* ALTERNATE*/
SELECT GPA, sName
FROM Student 
WHERE GPA >= ALL (SELECT GPA FROM Student);

/*This query finds all students who are not from the smallest high school in the database.*/
SELECT sID, sName, sizeHS
FROM Student S1
WHERE sizeHS > ANY (SELECT sizeHS FROM Student S2);
