LIBRARY MANAGEMENT SYSTEM — Oracle APEX + SQL + PL/SQL

Is project mein:
1. index.html — screenshot jaisa dashboard UI demo (browser mein open karein)
2. 01_schema_and_sample_data.sql — tables aur sample data
3. 02_library_package.sql — PL/SQL package: book/member add, issue, return, fine
4. 03_apex_setup_hindi.txt — Oracle APEX mein isse working application banane ke steps

IMPORTANT:
- HTML file demo/design preview hai. Real database operations ke liye Oracle APEX ko Oracle Database se connect karke SQL scripts run karein.
- Fine rule: Rs. 5 per late day.
- Demo dashboard counts HTML mein sample values hain; live counts APEX pages ko database queries se connect karne ke baad dikhte hain.

Oracle APEX steps:
1. APEX Workspace login karein.
2. SQL Workshop > SQL Scripts > Upload, phir 01_schema_and_sample_data.sql upload/run karein.
3. Isi tarah 02_library_package.sql upload/run karein.
4. App Builder > Create > New Application.
5. Pages add karein: Dashboard, Books (Interactive Report/Form), Members (Interactive Report/Form), Issue/Return (Form).
6. Dashboard region ke SQL source mein:
   SELECT (SELECT COUNT(*) FROM lms_books) total_books,
          (SELECT NVL(SUM(total_copies),0) FROM lms_books) total_copies,
          (SELECT COUNT(*) FROM lms_members) total_members
   FROM dual;
7. Issue process ke liye PL/SQL process mein:
   BEGIN
     lms_library.issue_book(
       p_member_id => :PXX_MEMBER_ID,
       p_book_id   => :PXX_BOOK_ID,
       p_due_date  => :PXX_DUE_DATE
     );
   END;
   PXX item names ko apne page item names se replace karein.
8. Return process ke liye:
   BEGIN
     lms_library.return_book(
       p_issue_id => :PXX_ISSUE_ID,
       p_return_date => SYSDATE
     );
   END;
   PXX item names ko apne page item names se replace karein.

Agar aap Oracle APEX mein pehli baar app bana rahe hain, pehle SQL scripts run karein aur phir Create Application karein.
