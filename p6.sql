set serveroutput on


create or replace type sid_array as varray(50) of char(4);
/

create or replace type lastname_array as varray(50) of varchar2(15);
/


create or replace procedure list_classes(
	cid IN classes.classid%type,
	course_title out courses.title%type,
	c_semester out classes.semester%type,
	c_year out classes.year%type,
	c_cur out SYS_REFCURSOR)
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

open c_cur for select a.sid,a.lastname from students a join (select sid from enrollments where classid=cid) e on a.sid = e.sid;
	

EXCEPTION
	when check_cid then dbms_output.put_line('The CLASSID is invalid');
END;
/
show error
