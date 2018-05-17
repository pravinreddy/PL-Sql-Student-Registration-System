CREATE OR REPLACE TRIGGER trigger_delete BEFORE DELETE on students
FOR EACH ROW

BEGIN

delete from enrollments where sid = :old.sid;
 
END;
/
show errors;