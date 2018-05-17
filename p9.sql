create or replace procedure delete_student(
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
/
show errors
