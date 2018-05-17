
/*
This is a trigger when a student is enrolled in a class then this trigger increments the class size by 1 
when a student is enrolled
*/
create or replace trigger trigger_enroll AFTER insert on enrollments
for each row
DECLARE
i int;
BEGIN

i:=1;

update classes SET class_size = class_size+i where classid = :new.classid;
END;
/
show errors;


/*
This is a trigger when a student is dropped the class then this trigger decrement the class size by 1 
when a student is dropped
*/
create or replace trigger trigger_drop AFTER delete on enrollments
for each row
DECLARE
i int;
BEGIN

i:=1;

update classes SET class_size = class_size-i where classid = :old.classid;
END;
/
show errors;

/*
This is a trigger when a student is deleted form  the student then it deletes all the enrollments 
of that particular student
*/
CREATE OR REPLACE TRIGGER trigger_delete BEFORE DELETE on students
FOR EACH ROW

BEGIN

delete from enrollments where sid = :old.sid;
 
END;
/
show errors;

/*
This trigger enters the values into the logs table when the deletion of a student happens
*/

create or replace trigger delete_student_trigger after delete on students
for each row
declare
begin
  insert into logs values(log_seq.nextval,'pravin',sysdate,'students','Delete',:old.sid);
  end;
/ 
show errors;

/*
This trigger enters the values into the logs table when the insertion of a new student happens
*/
create or replace trigger insert_student_trigger after insert on students
for each row
declare
begin
  insert into logs values(log_seq.nextval,'pravin',sysdate,'students','Insert',:new.sid);
  end;
/ 
show errors;

/*
This trigger enters the values into the logs table when the student is enrolled in the class
*/

create or replace trigger insert_enroll_trigger after insert on enrollments
for each row
declare
begin
  insert into logs values(log_seq.nextval,'pravin',sysdate,'Enrollments','Insert',:new.sid);
  end;
/ 
show errors;

/*
This trigger enters the values into the logs table when the student is dropped the class
*/

create or replace trigger delete_enroll_trigger after delete on enrollments
for each row
declare
begin
  insert into logs values(log_seq.nextval,'pravin',sysdate,'enrollments','Delete',:old.sid);
  end;
/ 
show errors;