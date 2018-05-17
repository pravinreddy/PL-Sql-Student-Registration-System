set serveroutput on

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