-- comp9311 22T1 Project 1
--
-- MyMyUNSW Solutions


-- Q1:
create or replace view Q1(subject_name)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT Subjects.name
FROM Subjects
WHERE Subjects._prereq LIKE '%COMP%COMP3%' OR Subjects._prereq LIKE '%COMP3%COMP%'
GROUP BY Subjects.name
;


-- Q2:
create or replace view Q2(course_id)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT Courses.id
FROM Courses, Classes, Rooms, Class_types
WHERE Courses.id = Classes.course 
AND Classes.ctype = Class_types.id 
AND Classes.room = Rooms.id
AND Class_types.name = 'Studio'
GROUP BY Courses.id
HAVING COUNT(DISTINCT Rooms.building) >= 3
;


-- Q3:
create or replace view Q3(course_id, use_rate)
as 
--... SQL statements, possibly using other views/functions defined by you ...
SELECT Courses.id, COUNT(Classes.id)
FROM Courses, Classes, Rooms, Buildings
WHERE Courses.id = Classes.course 
AND Classes.room = Rooms.id
AND Rooms.building = Buildings.id
AND Buildings.name = 'Central Lecture Block'
AND classes.startdate >= '2008-01-01'
AND classes.startdate <= '2008-12-31'
GROUP BY Courses.id
HAVING COUNT(Classes.id) >= 9
;


-- Q4:
create or replace view Q4(facility)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT DISTINCT Facilities.description
FROM Facilities
EXCEPT
SELECT DISTINCT Facilities.description
FROM Room_facilities, Rooms, Facilities, Buildings
WHERE Room_facilities.facility = Facilities.iD
AND Rooms.id = Room_facilities.room
AND Rooms.building = Buildings.id
AND Buildings.gridref LIKE 'C%'
;


--Q5:
create or replace view Q5(unsw_id, student_name)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT DISTINCT People.unswid, People.name
FROM People, Countries, Students
WHERE People.id = Students.id
AND Students.stype = 'local'
EXCEPT
SELECT DISTINCT People.unswid, People.name
FROM People, Course_enrolments
WHERE People.id = Course_enrolments.student
AND Course_enrolments.grade != 'HD'
;


-- Q6:
create or replace view Q6_MoreThan10(subject_name, num)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT Subjects.name, COUNT(*)
FROM Subjects, Courses, Semesters, Course_enrolments
WHERE Subjects.id = Courses.subject
AND Courses.semester = Semesters.id
AND Semesters.name = 'Sem1 2006'
AND Courses.id = Course_enrolments.course
AND Course_enrolments.mark is null
GROUP BY Subjects.name
HAVING COUNT(*) > 10
;

create or replace view Q6_WithOneValid(subject_name, num)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT Subjects.name, COUNT(*)
FROM Subjects, Courses, Semesters, Course_enrolments
WHERE Subjects.id = Courses.subject
AND Courses.semester = Semesters.id
AND Semesters.name = 'Sem1 2006'
AND Courses.id = Course_enrolments.course
AND Course_enrolments.mark > 0
GROUP BY Subjects.name
HAVING COUNT(*) > 10
;


create or replace view Q6(subject_name, non_null_mark_count, null_mark_count)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT Q6_MoreThan10.subject_name, Q6_WithOneValid.num, Q6_MoreThan10.num
FROM Q6_MoreThan10, Q6_WithOneValid
WHERE Q6_MoreThan10.subject_name = Q6_WithOneValid.subject_name
;



-- Q7:
create or replace view Q7(school_name, stream_count)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT Orgunits.longname, COUNT(*)
FROM Orgunits, Streams, OrgUnit_types
WHERE Orgunits.id = Streams.offeredBy
AND Orgunits.utype = OrgUnit_types.id
AND OrgUnit_types.name = 'School'
GROUP BY Orgunits.id
HAVING COUNT(*) > (SELECT COUNT(*) FROM Orgunits, Streams WHERE Orgunits.id = Streams.offeredBy AND Orgunits.longname = 'School of Computer Science and Engineering' GROUP BY Orgunits.id 
)
;



-- Q8: 

create or replace view Q8_LOCAL(name, wam)
as
SELECT DISTINCT People.name, Course_enrolments.mark
FROM People, Program_enrolments, Course_enrolments, Semesters, Subjects, Students, Courses
WHERE People.id = Program_enrolments.student
AND Course_enrolments.student = People.id
AND Course_enrolments.course = Courses.id
AND Courses.subject = Subjects.id
AND Subjects.name = 'Engineering Design'
AND Courses.semester = Semesters.id
AND Course_enrolments.mark > 98
AND Semesters.name = 'Sem1 2012'
AND People.id = Students.id
AND Students.stype = 'local'
;


create or replace view Q8_INTER(name, wam)
as
SELECT DISTINCT People.name, Course_enrolments.mark
FROM People, Program_enrolments, Course_enrolments, Semesters, Subjects, Students, Courses
WHERE People.id = Program_enrolments.student
AND Course_enrolments.student = People.id
AND Course_enrolments.course = Courses.id
AND Courses.subject = Subjects.id
AND Subjects.name = 'Engineering Design'
AND Courses.semester = Semesters.id
AND Course_enrolments.mark > 98
AND Semesters.name = 'Sem1 2012'
AND People.id = Students.id
AND Students.stype = 'intl'
;


create or replace view Q8(student_name_local, student_name_intl)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT Q8_LOCAL.name, Q8_INTER.name
FROM Q8_LOCAL, Q8_INTER
WHERE Q8_LOCAL.wam = Q8_INTER.wam
;


-- Q9:
create or replace view Q9(ranking, course_id, subject_name, student_diversity_score)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT *
FROM
(
SELECT RANK() OVER (ORDER BY COUNT(DISTINCT People.origin) DESC) as rk, Courses.id, Subjects.name, COUNT(DISTINCT People.origin)
FROM Courses, Subjects, People, Course_enrolments
WHERE Courses.subject = Subjects.id
AND Course_enrolments.course = Courses.id
AND Course_enrolments.student = People.id
GROUP BY Courses.id, Subjects.id
) as dt
WHERE rk <= 6
;



-- Q10:
create or replace view Q10(subject_code, avg_mark)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT Subjects.code, AVG(COALESCE(Course_enrolments.mark, 0))::numeric(4,2)
FROM Subjects, Courses, Semesters, Course_enrolments, OrgUnits
WHERE Subjects.id = Courses.subject
AND Subjects.offeredBy = OrgUnits.id
AND Subjects.career = 'PG'
AND OrgUnits.longname = 'School of Computer Science and Engineering'
AND Courses.semester = Semesters.id
AND Semesters.name = 'Sem1 2010'
AND Course_enrolments.course = Courses.id
GROUP BY Subjects.id, Courses.id
HAVING COUNT(Course_enrolments.mark) > 10
;




-- Q11:

create or replace view Q11_SEM1(subject_code, avg)
as
SELECT DISTINCT Subjects.code, AVG(Course_enrolments.mark)
FROM Subjects, Courses, Semesters, Course_enrolments, OrgUnits
WHERE Subjects.id = Courses.subject
AND Subjects.offeredBy = OrgUnits.id
AND (OrgUnits.longname = 'School of Chemistry' OR OrgUnits.longname = 'School of Accounting')
AND Courses.semester = Semesters.id
AND Semesters.name = 'Sem1 2008'
AND Course_enrolments.mark > 0
AND Course_enrolments.course = Courses.id
GROUP BY Subjects.id, Courses.id
;


create or replace view Q11_SEM2(subject_code, avg)
as
SELECT DISTINCT Subjects.code, AVG(Course_enrolments.mark)
FROM Subjects, Courses, Semesters, Course_enrolments, OrgUnits
WHERE Subjects.id = Courses.subject
AND Subjects.offeredBy = OrgUnits.id
AND (OrgUnits.longname = 'School of Chemistry' OR OrgUnits.longname = 'School of Accounting')
AND Courses.semester = Semesters.id
AND Semesters.name = 'Sem2 2008'
AND Course_enrolments.mark > 0
AND Course_enrolments.course = Courses.id
GROUP BY Subjects.id, Courses.id
;



create or replace view Q11(subject_code, inc_rate)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT DISTINCT Q11_SEM1.subject_code, ((Q11_SEM2.avg - Q11_SEM1.avg) / Q11_SEM1.avg)::numeric(5,4) as rate
FROM Q11_SEM1, Q11_SEM2
WHERE Q11_SEM1.avg < Q11_SEM2.avg
AND Q11_SEM1.subject_code = Q11_SEM2.subject_code
ORDER BY rate DESC
LIMIT 1
;




-- Q12:

create or replace view Q12(cid, syear, sterm, dur)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT People.name, Subjects.code, Semesters.year, Semesters.term, SUM(Classes.endTime-Classes.startTime)
FROM Classes, Class_types, Courses, Semesters, Subjects, Course_staff, People, Staff_roles
WHERE Classes.ctype = Class_types.id
AND Class_types.unswid = 'LAB'
AND Classes.course = Courses.id
AND Courses.semester = Semesters.id
AND Subjects.code LIKE 'COMP%'
AND Subjects.id = Courses.subject
AND Course_staff.course = Courses.id
AND Course_staff.role = Staff_roles.id
AND Staff_roles.name like '%Lecturer%'
AND Course_staff.staff = People.id
AND People.title = 'Dr'
GROUP BY People.name, Subjects.code, Semesters.year, Semesters.term
;


-- Q13:

create or replace view Q13_MORETHAN150_ALL(subject_code, year, term, num)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT Subjects.code, Semesters.year, Semesters.term, COUNT(*)
FROM Courses, Semesters, Subjects, Course_enrolments
WHERE Courses.semester = Semesters.id
AND Subjects.id = Courses.subject
AND Subjects.code LIKE 'COMP%'
AND Course_enrolments.course = Courses.id
GROUP BY Subjects.code, Semesters.year, Semesters.term
HAVING COUNT(*) > 150
;

create or replace view Q13_MAX(subject_code, year, term, num)
as
SELECT Q13_MORETHAN150_ALL.subject_code, Q13_MORETHAN150_ALL.year, Q13_MORETHAN150_ALL.term, Q13_MORETHAN150_ALL.num
FROM Q13_MORETHAN150_ALL
WHERE Q13_MORETHAN150_ALL.num = (
	SELECT max(temp.num)
	FROM Q13_MORETHAN150_ALL as temp
	WHERE Q13_MORETHAN150_ALL.subject_code = temp.subject_code
)
;

create or replace view Q13_FAIL(subject_code, year, term, num)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT Subjects.code, Semesters.year, Semesters.term, COUNT(*)
FROM Courses, Semesters, Subjects, Course_enrolments, Q13_MAX
WHERE Courses.semester = Semesters.id
AND Subjects.id = Courses.subject
AND Subjects.code LIKE 'COMP%'
AND Course_enrolments.course = Courses.id
AND Course_enrolments.mark < 50
AND Subjects.code = Q13_MAX.subject_code
AND Semesters.year = Q13_MAX.year
AND Semesters.term = Q13_MAX.term
GROUP BY Subjects.code, Semesters.year, Semesters.term
;


create or replace view Q13_ALL(subject_code, year, term, num)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT Subjects.code, Semesters.year, Semesters.term, COUNT(*)
FROM Courses, Semesters, Subjects, Course_enrolments, Q13_MAX
WHERE Courses.semester = Semesters.id
AND Subjects.id = Courses.subject
AND Subjects.code LIKE 'COMP%'
AND Course_enrolments.course = Courses.id
AND Course_enrolments.mark > 0
AND Subjects.code = Q13_MAX.subject_code
AND Semesters.year = Q13_MAX.year
AND Semesters.term = Q13_MAX.term
GROUP BY Subjects.code, Semesters.year, Semesters.term
;


create or replace view Q13(subject_code, year, term, fail_rate)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT Q13_ALL.subject_code, Q13_ALL.year, Q13_ALL.term, round(Q13_FAIL.num::numeric/Q13_ALL.num::numeric,4)
FROM Q13_ALL, Q13_FAIL
WHERE Q13_ALL.subject_code = Q13_FAIL.subject_code
AND Q13_ALL.year = Q13_FAIL.year
AND Q13_ALL.term = Q13_FAIL.term
;




