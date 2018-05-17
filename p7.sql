set serveroutput on


create or replace type dept_code_array as varray(50) of varchar2(4);
/

create or replace type course_no_array as varray(50) of number(3);
/


create or replace function check_pre(
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
   j int;
   k int;
   l int;
		
BEGIN

i:=0;
j:=0;
k:=0;
l:=0;

status := false;


select dept_code into f_dept from classes where classid=cp_cid;

select course_no into f_course from classes where classid=cp_cid;

open l_rc for select a.dept_code,a.course_no from (select * from enrollments e join classes c on e.classid=c.classid) a where a.lgrade is not null and a.lgrade != 'D' and a.lgrade !='E' and a.lgrade !='F' and a.sid=cp_sid;

select count(a.course_no) into k from (select * from enrollments e join classes c on e.classid=c.classid) a where a.lgrade is not null and a.lgrade != 'D' and a.lgrade !='E' and a.lgrade !='F' and a.sid=cp_sid;

select count(pre_course_no) into j from prerequisites where dept_code= f_dept and course_no =f_course; 

open l_rc2 for select pre_dept_code,pre_course_no from prerequisites where dept_code= f_dept and course_no =f_course; 


if(k>=j and j!=0) then
loop
    fetch l_rc2
     into s1,s2;
    exit when l_rc2%notfound;
	loop
		fetch l_rc into s3,s4;
		exit when l_rc%notfound;
		if(s1=s3 and s2=s4) then
			j:=j-1;
		end if;
	end loop;
	close l_rc;
  end loop;
  close l_rc2;
 end if;
   
   
   if (j=0) then
	status :=true;
   end if;
   
   return status;

end check_pre;
/
show errors

create or replace procedure insert_enroll(
	e_sid IN students.sid%type,
	e_cid IN classes.classid%type)
IS

count_sid int;
count_cid int;
count_taken int;
count_classes int;
count_pre int;
count_size classes.class_size%type;
c_cid classes.classid%type;
c_year classes.year%type;
c_semester classes.semester%type;

   f_dept1 classes.dept_code%type;
   f_course1 classes.course_no%type;

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
count_pre:=0;
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

select dept_code into f_dept1 from classes where classid=e_cid;

select course_no into f_course1 from classes where classid=e_cid;



if (count_size >= count_limit) then
 raise check_size;
end if;
if (count_taken > 0) then
 raise check_enroll;
end if;
if (count_classes > 2) then
 raise check_overload;
end if;
if(check_pre(e_sid,e_cid) = false) then
 raise check_grades;
end if;

if (count_classes = 2) then
 dbms_output.put_line('you are overloaded');
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
/
show error
