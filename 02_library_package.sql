-- PL/SQL business logic for issue, return, and late fine.
CREATE OR REPLACE PACKAGE lms_library AS
  PROCEDURE add_book(
    p_title IN VARCHAR2, p_author IN VARCHAR2, p_category IN VARCHAR2,
    p_isbn IN VARCHAR2, p_total_copies IN NUMBER
  );
  PROCEDURE add_member(
    p_full_name IN VARCHAR2, p_email IN VARCHAR2, p_phone IN VARCHAR2
  );
  PROCEDURE issue_book(
    p_member_id IN NUMBER, p_book_id IN NUMBER, p_due_date IN DATE
  );
  PROCEDURE return_book(
    p_issue_id IN NUMBER, p_return_date IN DATE DEFAULT SYSDATE
  );
END lms_library;
/

CREATE OR REPLACE PACKAGE BODY lms_library AS
  PROCEDURE add_book(
    p_title IN VARCHAR2, p_author IN VARCHAR2, p_category IN VARCHAR2,
    p_isbn IN VARCHAR2, p_total_copies IN NUMBER
  ) IS
  BEGIN
    INSERT INTO lms_books(title, author, category, isbn, total_copies, available_copies)
    VALUES (p_title, p_author, p_category, p_isbn, p_total_copies, p_total_copies);
  END add_book;

  PROCEDURE add_member(
    p_full_name IN VARCHAR2, p_email IN VARCHAR2, p_phone IN VARCHAR2
  ) IS
  BEGIN
    INSERT INTO lms_members(full_name, email, phone)
    VALUES (p_full_name, p_email, p_phone);
  END add_member;

  PROCEDURE issue_book(
    p_member_id IN NUMBER, p_book_id IN NUMBER, p_due_date IN DATE
  ) IS
    v_available NUMBER;
  BEGIN
    IF p_due_date IS NULL OR p_due_date < TRUNC(SYSDATE) THEN
      RAISE_APPLICATION_ERROR(-20001, 'Due date must be today or a future date.');
    END IF;

    SELECT available_copies INTO v_available
    FROM lms_books
    WHERE book_id = p_book_id
    FOR UPDATE;

    IF v_available < 1 THEN
      RAISE_APPLICATION_ERROR(-20002, 'No copies are currently available.');
    END IF;

    INSERT INTO lms_issues(book_id, member_id, issue_date, due_date, status)
    VALUES (p_book_id, p_member_id, SYSDATE, p_due_date, 'ISSUED');

    UPDATE lms_books
    SET available_copies = available_copies - 1
    WHERE book_id = p_book_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20003, 'Book or member was not found.');
  END issue_book;

  PROCEDURE return_book(
    p_issue_id IN NUMBER, p_return_date IN DATE DEFAULT SYSDATE
  ) IS
    v_book_id NUMBER;
    v_due_date DATE;
    v_status VARCHAR2(10);
    v_fine NUMBER(10,2);
  BEGIN
    SELECT book_id, due_date, status
    INTO v_book_id, v_due_date, v_status
    FROM lms_issues
    WHERE issue_id = p_issue_id
    FOR UPDATE;

    IF v_status = 'RETURNED' THEN
      RAISE_APPLICATION_ERROR(-20004, 'This book has already been returned.');
    END IF;

    v_fine := GREATEST(TRUNC(p_return_date) - TRUNC(v_due_date), 0) * 5;

    UPDATE lms_issues
    SET return_date = p_return_date,
        fine_amount = v_fine,
        status = 'RETURNED'
    WHERE issue_id = p_issue_id;

    UPDATE lms_books
    SET available_copies = available_copies + 1
    WHERE book_id = v_book_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20005, 'Issue record was not found.');
  END return_book;
END lms_library;
/
