set serveroutput on

create or replace type dept_code_array as varray(50) of varchar2(4);
/

create or replace type course_no_array as varray(50) of number(3);
/

create or replace function check_list(
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
		
/


CREATE OR REPLACE PROCEDURE get_prereq(
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
/
show errors
