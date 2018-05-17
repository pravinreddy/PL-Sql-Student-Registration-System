set serveroutput on


create or replace type dept_code_array as varray(50) of varchar2(4);
/

create or replace type course_no_array as varray(50) of number(3);
/


create or replace function check_pre_taken(
		cp_sid IN enrollments.sid%TYPE,
	    cp_cid IN enrollments.classid%TYPE)
		return boolean is
		status boolean;

   l_rc sys_refcursor;
   l_rc2 sys_refcursor;
   s1 classes.dept_code%type;
   s2 classes.course_no%type;
   s3 classes.dept_code%type;
   s4 classes.course_no%type;
   f_dept classes.dept_code%type;
   f_course classes.course_no%type;
   i int;
 

		
BEGIN
	
	i:=0;

	status := true;

select dept_code into f_dept from classes where classid=cp_cid;

select course_no into f_course from classes where classid=cp_cid;


open l_rc for select a.dept_code,a.course_no from (select * from (select * from enrollments where sid = cp_sid and not classid = cp_cid) e join classes c on e.classid=c.classid) a where a.sid=cp_sid;

open l_rc2 for select dept_code,course_no from prerequisites where pre_dept_code= f_dept and pre_course_no =f_course; 


loop
    fetch l_rc2 into s1,s2;
	exit when l_rc2%notfound;
	loop
		fetch l_rc into s3,s4;
		exit when l_rc%notfound;
			if(s1 = s3 and s2 = s4) then 
				status := false;
			end if;
	end loop;
	close l_rc;
END LOOP;
close l_rc2;
   
return status;

end check_pre_taken;
/
show errors


create or replace procedure drop_enroll(
	e_sid IN students.sid%type,
	e_cid IN classes.classid%type)
IS

count_sid int;
count_cid int;
count_taken int;
count_last int;
count_last_class int;
count_pre int;
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

count_pre:=0;
select count(sid) into count_pre from enrollments where sid=e_sid;


if(count_pre>1) then
if (check_pre_taken(e_sid,e_cid) = false) then
 raise check_prerequisites;
end if;
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
/
show error
