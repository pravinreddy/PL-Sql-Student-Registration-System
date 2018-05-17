declare
  l_rc sys_refcursor;
  s1 temp_pretable%rowtype;
begin
  get_prerequisites_coursor('CS',432, l_rc );
  loop
    fetch l_rc
     into s1;
    exit when l_rc%notfound;
    dbms_output.put_line(s1.dept_code,s1.course_no);
  end loop;
  close l_rc;
end;
/
show errors
