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

   depart dept_code_array;
   courses course_no_array;
   dept_taken dept_code_array;
   courses_taken course_no_array;
   f_dept classes.dept_code%type;
   f_course classes.course_no%type;
   i1 int;
   j1 int;
   k1 int;
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
	
	i1:=0;
	j1:=0;
	k1:=0;

	status := true;

	dept_taken:=dept_code_array();
	courses_taken:=course_no_array();



select dept_code into f_dept from classes where classid=cp_cid;

select course_no into f_course from classes where classid=cp_cid;

FOR rec in (select a.dept_code,a.course_no from (select * from (select * from enrollments where sid = cp_sid and not classid = cp_cid) e join classes c on e.classid=c.classid) a where a.sid=cp_sid)

	loop
		i1 := i1+1;
		dept_taken.extend;
		dept_taken(i1):=rec.dept_code;
		courses_taken.extend;
		courses_taken(i1) :=rec.course_no;
		dbms_output.put_line('i am here 1'|| '   '||dept_taken(i1)||'   '||courses_taken(i1));
    END loop;	

	for j1 IN dept_taken.first .. dept_taken.count
	loop
		for rec in (SELECT * FROM prerequisites WHERE dept_code = dept_taken(j1) AND course_no = courses_taken(j1) )
		loop

			i := i+1;
			dep_array.extend;
			dep_array(i):=rec.pre_dept_code;
			cou_array.extend;
			cou_array(i) :=rec.pre_course_no;
			dbms_output.put_line('i am here 2'|| '   '||dep_array(i)||'   '||cou_array(i));

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
						dbms_output.put_line('i am here 3'|| '   '||dep_array(i)||'   '||cou_array(i));
					END IF;
				END loop;
			END loop;
			count2 := count1;
			count1 := dep_array.count;
			
		END loop;

	End loop;





		
	FOR k1 IN dep_array.first .. dep_array.count
			LOOP
				dbms_output.put_line('i am here 4'|| '   '||dep_array(k1)||'   '||cou_array(k1));
			END LOOP;





/*FOR j IN dept_taken.first .. dept_taken.count
   LOOP		
		dbms_output.put_line('i am here 2'|| '   '||dept_taken(k)||'   '||courses_taken(k));
		get_prereq(dept_taken(j), courses_taken(j), depart, courses);
		FOR k IN depart.first .. depart.count
			LOOP
				if(depart(k)=f_dept) and (courses(k) = f_course) then 
					status := false;
				end if;
				dbms_output.put_line('i am here 3'|| '   '||depart(k)||'   '||courses(k));
			END LOOP;
   END LOOP;   */
   
   
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


/*delete from enrollments where sid= e_sid and classid = e_cid;*/
EXCEPTION
	when check_sid then dbms_output.put_line('The SID is invalid');
	when check_cid then dbms_output.put_line('The CLASSID is invalid');
	when check_enroll then dbms_output.put_line('The student is not enrolled in the class');
	when check_prerequisites then dbms_output.put_line('The drop is not permitted because another class uses it as a prerequisite');
END;
/
show error
