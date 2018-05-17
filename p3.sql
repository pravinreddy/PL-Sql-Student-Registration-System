set serveroutput on

CREATE OR REPLACE PROCEDURE insert_students(
	 s_id IN students.sid%TYPE,
	 s_firstname IN students.firstname%TYPE,
	 s_lastname IN students.lastname%TYPE,
	 s_status IN students.status%TYPE,
	 s_gpa IN students.gpa%TYPE,
	 s_email IN students.email%TYPE)
IS
BEGIN

  INSERT INTO students (sid, firstname, lastname, status, gpa, email)
  VALUES (s_id, s_firstname, s_lastname, s_status, s_gpa, s_email);

  COMMIT;

END;

/
show errors

