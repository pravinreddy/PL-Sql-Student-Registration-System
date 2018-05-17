create or replace type dept_code_array as varray(50) of varchar2(4);
/

create or replace type course_no_array as varray(50) of number(3);
/

DECLARE 
   dep dept_code_array;
   cou course_no_array;
   i INT;
BEGIN  
  get_prereq('CS',532 , dep, cou);

FOR i IN dep.first .. dep.count
   LOOP
      DBMS_OUTPUT.put_line (dep(i) || ' '|| cou(i));
   END LOOP; 
END; 
/
