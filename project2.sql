
-- Implementation of procedures and funtions for the project2

-- question 1
DROP SEQUENCE log_seq;

-- droping the old sequence and starting a new sequence from 100
CREATE SEQUENCE log_seq
	START WITH 100
	INCREMENT BY 1
NOCYCLE
NOCACHE
/

create or replace type dept_code_array as varray(50) of varchar2(4);
/
-- array for departments

create or replace type course_no_array as varray(50) of number(3);
/
-- array for courses

create or replace type sid_array as varray(50) of char(4);
/
 -- sid array

create or replace type lastname_array as varray(50) of varchar2(15);
/

-- lastname_array


create or replace package project as

-- question 2 procedure call


-- question 3 procedure call

-- insert the student into students table by giving the parameters sid, firstname, lastname, staus..etc
PROCEDURE insert_students(
	 s_id IN students.sid%TYPE,
	 s_firstname IN students.firstname%TYPE,
	 s_lastname IN students.lastname%TYPE,
	 s_status IN students.status%TYPE,
	 s_gpa IN students.gpa%TYPE,
	 s_email IN students.email%TYPE);

-- question 4 procedure call




-- question 5 procedure call

-- in this procedure it takes dept code and course_no as input and gives out a coursor 
PROCEDURE get_prerequisites_coursor(
	   d_dept_code IN prerequisites.dept_code%TYPE,
	   d_course_no IN prerequisites.course_no%TYPE,
		d_dept OUT SYS_REFCURSOR);

-- In this procedure we give the depatment code and course number and we get a deptment array and course array 
PROCEDURE get_prereq(
	   d_dept_code IN prerequisites.dept_code%TYPE,
	   d_course_no IN prerequisites.course_no%TYPE,
		d_dept OUT dept_code_array,
		d_course OUT course_no_array);
		

-- dependent function for the get_prereq procedure
function check_list(
		f_dept_code IN prerequisites.dept_code%TYPE,
	    f_course_no IN prerequisites.course_no%TYPE,
		f_dept dept_code_array,
		f_course course_no_array)
		return boolean;
		
-- question 6 procedure call
-- IN this call it takes the classid and give information about that class
procedure list_classes(
	cid IN classes.classid%type,
	course_title out courses.title%type,
	c_semester out classes.semester%type,
	c_year out classes.year%type,
	c_sid out sid_array,
	c_lastname out lastname_array);
	
-- question 7 procedure call

-- TO enroll a student with variors restrictions
procedure insert_enroll(
	e_sid IN students.sid%type,
	e_cid IN classes.classid%type);


-- dependent function for insert_enroll procedure for checking the prequisites
function check_pre(
		cp_sid IN enrollments.sid%TYPE,
	    cp_cid IN enrollments.classid%TYPE)
		return boolean;


-- question 8 procedure call

-- this function to check the prerequisites are clashing while droping the enrollment in the emrollments table
function check_pre_taken(
		cp_sid IN enrollments.sid%TYPE,
	    cp_cid IN enrollments.classid%TYPE)
		return boolean;

-- to delete a enrollment with varios restrictions		
	
procedure drop_enroll(
	e_sid IN students.sid%type,
	e_cid IN classes.classid%type);

-- question 9 procedure call

-- delete a student from student table

procedure delete_student(
	d_sid IN students.sid%type);
	
end;
	
/
show errors


/*
*********** package body **********
*/

create or replace package body project as

-- question 2





-- question 3 procedure
PROCEDURE insert_students(
	 s_id IN students.sid%TYPE,
	 s_firstname IN students.firstname%TYPE,
	 s_lastname IN students.lastname%TYPE,
	 s_status IN students.status%TYPE,
	 s_gpa IN students.gpa%TYPE,
	 s_email IN students.email%TYPE)
IS
BEGIN

  INSERT INTO students (sid, firstname, lastname, status, gpa, email)
  VALUES (s_id, s_firstname, s_lastname, s_status, s_gpa, s_email);

  COMMIT;

END;


-- question 4 procedure









--question 5 procedure

-- for checking the prerequisites list have repeted elements
function check_list(
		f_dept_code IN prerequisites.dept_code%TYPE,
	    f_course_no IN prerequisites.course_no%TYPE,
		f_dept dept_code_array,
		f_course course_no_array)
		return boolean is
		status boolean;
		
i int;
BEGIN
	i:=1;
	status :=true;
	for i in 1 .. f_dept.count loop
	  if f_dept(i) = f_dept_code and f_course(i) = f_course_no then
		status := false;
	  END if;
	  
	END loop;
	return status;
END check_list ;	

-- procedure for the prequisites with dept_code and course_no as the input and deptarment array and course_array
PROCEDURE get_prereq(
	   d_dept_code IN prerequisites.dept_code%TYPE,
	   d_course_no IN prerequisites.course_no%TYPE,
		d_dept OUT dept_code_array,
		d_course OUT course_no_array)
IS

i INT;
j INT;
k INT;
count1 number(2);
count2 number(3);
dep_array dept_code_array;
cou_array course_no_array;

BEGIN

	i:= 0;
	j:= 1;
	k:= 1;
	dep_array:=dept_code_array();
	cou_array:=course_no_array();
	
	for rec in (SELECT * FROM prerequisites WHERE dept_code = d_dept_code AND 
course_no = d_course_no)
	loop
		i := i+1;
		dep_array.extend;
		dep_array(i):=rec.pre_dept_code;
		cou_array.extend;
		cou_array(i) :=rec.pre_course_no;
		d_dept := dep_array;
		d_course:= cou_array;
    END loop;
	
	count1 := dep_array.count;
	count2 := 0;
	
	while count1>count2 loop
		for j IN 1 .. count1 loop
			for  rec1 in (SELECT * FROM prerequisites WHERE dept_code = dep_array(j) AND course_no = cou_array(j))
			loop
			IF check_list(rec1.pre_dept_code, rec1.pre_course_no, dep_array, cou_array ) then
				k:=1;
					i := i+1;
					dep_array.extend;
					dep_array(i):=rec1.pre_dept_code;
					cou_array.extend;
					cou_array(i) :=rec1.pre_course_no;
					d_dept := dep_array;
					d_course:= cou_array;
				END IF;
			END loop;
		END loop;
		count2 := count1;
		count1 := dep_array.count;
		
	END loop;

	
END;



--procedure that takes the department code and course number and gives the output prerequisites courses a in the form of cursor

PROCEDURE get_prerequisites_coursor(
	   d_dept_code IN prerequisites.dept_code%TYPE,
	   d_course_no IN prerequisites.course_no%TYPE,
		d_dept OUT SYS_REFCURSOR)
IS

i INT;
j INT;
k INT;
l int;
count1 number(2);
count2 number(3);
dep_array dept_code_array;
cou_array course_no_array;

BEGIN


	i:= 0;
	j:= 1;
	k:= 1;
	l:= 1;
	dep_array:=dept_code_array();
	cou_array:=course_no_array();
	
	for rec in (SELECT * FROM prerequisites WHERE dept_code = d_dept_code AND 
course_no = d_course_no)
	loop
		i := i+1;
		dep_array.extend;
		dep_array(i):=rec.pre_dept_code;
		cou_array.extend;
		cou_array(i) :=rec.pre_course_no;
    END loop;
	
	count1 := dep_array.count;
	count2 := 0;
	
	while count1>count2 loop
		for j IN 1 .. count1 loop
			for  rec1 in (SELECT * FROM prerequisites WHERE dept_code = dep_array(j) AND course_no = cou_array(j))
			loop
			IF check_list(rec1.pre_dept_code, rec1.pre_course_no, dep_array, cou_array ) then
				k:=1;
					i := i+1;
					dep_array.extend;
					dep_array(i):=rec1.pre_dept_code;
					cou_array.extend;
					cou_array(i) :=rec1.pre_course_no;
				END IF;
			END loop;
		END loop;
		count2 := count1;
		count1 := dep_array.count;
		
	END loop;
	
for l in 1 .. dep_array.count 
loop
	insert into temp_pretable values(d_dept_code,d_course_no,dep_array(l),cou_array(l));
end loop;

open d_dept for select distinct pre_dept_code, pre_course_no from temp_pretable where dept_code = d_dept_code and course_no = d_course_no;

	
END;

-- question 6 procedure

-- procedure shows the list of classes to show the particular class information as output with classid as input 
procedure list_classes(
	cid IN classes.classid%type,
	course_title out courses.title%type,
	c_semester out classes.semester%type,
	c_year out classes.year%type,
	c_sid out sid_array,
	c_lastname out lastname_array)
IS

i int;
j int;
dept classes.dept_code%type;
course classes.course_no%type;
count_cid int;
count_sid int;
check_cid EXCEPTION;


BEGIN

i:=0;
j:=0;
count_cid:=0;
count_sid:=0;
c_sid:=sid_array();
c_lastname:=lastname_array();


select count(classid) into count_cid from classes where classes.classid =cid;

if (count_cid = 0) then
 raise check_cid;
end if;	

select count(sid) into count_sid from enrollments where classid =cid;

select dept_code into dept from classes where classes.classid =cid;

select course_no into course from classes where classes.classid =cid;

select title into course_title from courses where courses.dept_code = dept and courses.course_no = course;

select year into c_year from classes where classes.classid = cid;

select semester into c_semester from classes where classes.classid = cid;



DBMS_OUTPUT.put_line (cid||' '||course_title||' '|| c_semester || ' '|| c_year);


if(count_sid < 1)then
DBMS_OUTPUT.put_line ('No student is enrolled in the class');
end if;

for rec in (select sid from enrollments where classid=cid)
	loop
	i:=i+1;
	c_sid.extend;
	c_sid(i):=rec.sid;
	c_lastname.extend;
	select lastname into c_lastname(i) from students where sid=rec.sid;
	DBMS_OUTPUT.put_line (rec.sid || ' '|| c_lastname(i));
	END loop;
	

EXCEPTION
	when check_cid then dbms_output.put_line('The CLASSID is invalid');
END;

-- question 7 procedure

-- dependent function for the enroll_student procedure 
function check_pre(
		cp_sid IN enrollments.sid%TYPE,
	    cp_cid IN enrollments.classid%TYPE)
		return boolean is
		status boolean;

   depart dept_code_array;
   courses course_no_array;
   dept_taken dept_code_array;
   courses_taken course_no_array;
   f_dept classes.dept_code%type;
   f_course classes.course_no%type;
   i int;
   j int;
   k int;
   l int;
		
BEGIN

i:=0;

status := false;

dept_taken:=dept_code_array();
courses_taken:=course_no_array();

select dept_code into f_dept from classes where classid=cp_cid;

select course_no into f_course from classes where classid=cp_cid;

FOR rec in (select a.dept_code,a.course_no from (select * from enrollments e join classes c on e.classid=c.classid) a where a.lgrade is not null and a.lgrade != 'D' and a.lgrade !='E' and a.lgrade !='F' and a.sid=cp_sid)

	loop
		i := i+1;
		dept_taken.extend;
		dept_taken(i):=rec.dept_code;
		courses_taken.extend;
		courses_taken(i) :=rec.course_no;
    END loop;
	

get_prereq(f_dept,f_course , depart, courses);

l:=depart.count;


FOR j IN dept_taken.first .. dept_taken.count
   LOOP
		FOR k IN depart.first .. depart.count
			LOOP
				if(depart(k)=dept_taken(j)) and (courses_taken(j) = courses(k)) then
				l:=l-1;
				end if;
			END LOOP;
   END LOOP;
   
   
   if (l=0) then
	status :=true;
   end if;
   
   return status;

end check_pre;


-- procedure for enrolling the student with sid and classid ass input 

procedure insert_enroll(
	e_sid IN students.sid%type,
	e_cid IN classes.classid%type)
IS

count_sid int;
count_cid int;
count_taken int;
count_classes int;
count_size classes.class_size%type;
c_cid classes.classid%type;
c_year classes.year%type;
c_semester classes.semester%type;

count_limit number(3);
check_sid EXCEPTION;
check_cid EXCEPTION;
check_size EXCEPTION;
check_enroll EXCEPTION;
check_overload EXCEPTION;
check_grades EXCEPTION;

BEGIN

count_classes :=0;
count_taken :=0;
select count(sid) into count_sid from students where students.sid = e_sid;

if(count_sid != 1) then
 raise check_sid;
end if;

select count(classid) into count_cid from classes where classes.classid = e_cid;

if (count_cid != 1) then
 raise check_cid;
end if;	

select class_size into count_size from classes where classes.classid =e_cid;

select limit into count_limit from classes where classes.classid =e_cid;

select count(classid) into count_taken from enrollments where enrollments.sid = e_sid and enrollments.classid = e_cid;

select year into c_year from classes where classes.classid = e_cid;

select semester into c_semester from classes where classes.classid = e_cid;

select count(a.classid) into count_classes from (select e.sid,e.classid,year,semester from enrollments e join classes c on e.classid = c.classid) a where a.sid=e_sid and a.year=c_year and a.semester=c_semester;



if (count_size >= count_limit) then
 raise check_size;
end if;
if (count_taken > 0) then
 raise check_enroll;
end if;
if (count_classes > 2) then
 raise check_overload;
end if;
if (count_classes = 2) then
 dbms_output.put_line('you are overloaded');
end if;
if (check_pre(e_sid,e_cid) = false) then
 raise check_grades;
end if;


insert into enrollments values(e_sid, e_cid, NULL);
EXCEPTION
	when check_sid then dbms_output.put_line('The SID is invalid');
	when check_cid then dbms_output.put_line('The CLASSID is invalid');
	when check_size then dbms_output.put_line('The CLASS is closed');
	when check_enroll then dbms_output.put_line('The student is already in the class');	
	when check_overload then dbms_output.put_line('Students cannot be enrolled in more than three classes in the same semester');
	when check_grades then dbms_output.put_line('Prerequisite courses have not been completed');
END;
	
	
	
-- question 8 procedure

-- body of the function to check the prequisites of the course

function check_pre_taken(
		cp_sid IN enrollments.sid%TYPE,
	    cp_cid IN enrollments.classid%TYPE)
		return boolean is
		status boolean;

   dept_taken dept_code_array;
   courses_taken course_no_array;
   f_dept classes.dept_code%type;
   f_course classes.course_no%type;
   i int;
   j int;
   k int;
	count1 number(2);
	count2 number(3);
	dep_array dept_code_array;
	cou_array course_no_array;
	pre_cur sys_refcursor;
	s1 prerequisites.dept_code%TYPE;
	s2 prerequisites.course_no%TYPE;

		
BEGIN

	dep_array:=dept_code_array();
	cou_array:=course_no_array();
	
	i:=0;
	j:=0;
	k:=0;

	status := true;

	dept_taken:=dept_code_array();
	courses_taken:=course_no_array();



select dept_code into f_dept from classes where classid=cp_cid;

select course_no into f_course from classes where classid=cp_cid;

FOR rec in (select a.dept_code,a.course_no from (select * from (select * from enrollments where sid = cp_sid and not classid = cp_cid) e join classes c on e.classid=c.classid) a where a.sid=cp_sid)

	loop
		i := i+1;
		dept_taken.extend;
		dept_taken(i):=rec.dept_code;
		courses_taken.extend;
		courses_taken(i) :=rec.course_no;
    END loop;	

FOR j IN dept_taken.first .. dept_taken.count
   LOOP		
		get_prerequisites_coursor(dept_taken(j), courses_taken(j), pre_cur);
		loop
		fetch pre_cur into s1,s2;
		exit when pre_cur%notfound;
				if(s1=f_dept) and (s2 = f_course) then 
					status := false;
				end if;
		end loop;
		close pre_cur;
   END LOOP;
   
   
   return status;

end check_pre_taken;


-- body of the procedure to drop the course by the student
procedure drop_enroll(
	e_sid IN students.sid%type,
	e_cid IN classes.classid%type)
IS

count_sid int;
count_cid int;
count_taken int;
count_last int;
count_last_class int;
c_cid classes.classid%type;
c_year classes.year%type;
c_semester classes.semester%type;

count_limit number(3);
check_sid EXCEPTION;
check_cid EXCEPTION;
check_enroll EXCEPTION;
check_prerequisites EXCEPTION;

BEGIN

count_taken :=0;
select count(sid) into count_sid from students where students.sid = e_sid;

if(count_sid != 1) then
 raise check_sid;
end if;

select count(classid) into count_cid from classes where classes.classid = e_cid;

if (count_cid != 1) then
 raise check_cid;
end if;	

select count(sid) into count_taken from enrollments where sid= e_sid and classid = e_cid;

if (count_taken = 0) then
 raise check_enroll;
end if;

if (check_pre_taken(e_sid,e_cid) = false) then
 raise check_prerequisites;
end if;

select count(sid) into count_last from enrollments where sid=e_sid;

if (count_last =1) then
 dbms_output.put_line('This student is not enrolled in any classes');
end if;

select count(classid) into count_last_class from enrollments where classid=e_cid;

if (count_last_class =1) then
 dbms_output.put_line('The class now has no students.');
end if;


delete from enrollments where sid= e_sid and classid = e_cid;
EXCEPTION
	when check_sid then dbms_output.put_line('The SID is invalid');
	when check_cid then dbms_output.put_line('The CLASSID is invalid');
	when check_enroll then dbms_output.put_line('The student is not enrolled in the class');
	when check_prerequisites then dbms_output.put_line('The drop is not permitted because another class uses it as a prerequisite');
END;


	
	
-- question 9 procedure

-- procedure for deleting the student form the table 
	
procedure delete_student(
	d_sid IN students.sid%type)
IS
count_stu int;
check_stu EXCEPTION;

BEGIN

count_stu :=0;

select count(sid) into count_stu from students where students.sid = d_sid;

if(count_stu != 1) then
 raise check_stu;
end if;

delete from students where students.sid = d_sid;

EXCEPTION

	when check_stu then dbms_output.put_line('The SID is invalid');

END;
end;
/
show errors
	
	
	
	
