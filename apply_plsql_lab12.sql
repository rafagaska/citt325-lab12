/*
||  Name:          Rafael Gasca Diaz
||  Date:          21 March 2023
||  Purpose:       Complete 325 Chapter 13 lab.
*/

--@/home/student/Data/cit325/oracle/lib/cleanup_oracle.sql

-- Open log file.
SPOOL apply_plsql_lab12.txt


 -- DROP TABLES AND TYPES.
DROP TYPE item_obj FORCE;
DROP TYPE item_tab;
DROP FUNCTION item_list;

-- Create item-obj, item_tab collection object type, and item_list.
CREATE OR REPLACE
  TYPE item_obj IS OBJECT
        ( title         VARCHAR2(60)
        , subtitle      VARCHAR2(60)
        , rating        VARCHAR2(8) 
        , release_date  DATE );
/
-- Display item_obj and object types.
DESC item_obj

-- CREATE item_obj object collection type:
CREATE OR REPLACE
  TYPE item_tab IS TABLE of item_obj;
/

-- Create the item_tab object type
DESC item_tab


CREATE OR REPLACE
  FUNCTION item_list
  ( pv_start_date DATE
  , pv_end_date   DATE DEFAULT (TRUNC(SYSDATE) + 1) ) RETURN item_tab IS 
 
    
    TYPE item_rec IS RECORD
    ( title        VARCHAR2(60)
    , subtitle     VARCHAR2(60)
    , rating       VARCHAR2(8)
    , release_date DATE);
 
  
    item_cursor   SYS_REFCURSOR;
 
   
    item_row   ITEM_REC;
    item_set   ITEM_TAB := item_tab();
 
   
    stmt  VARCHAR2(2000);
  
  BEGIN
    /* Create a dynamic statement. */
    stmt := 'SELECT     i.item_title AS title'||CHR(10)
         || ',          i.item_subtitle AS subtitle'||CHR(10)
         || ',          i.item_rating AS rating'||CHR(10)
         || ',          i.item_release_date AS release_date'||CHR(10)
         || 'FROM       item i'||CHR(10)
         || 'WHERE      i.item_rating_agency = ''MPAA'''||CHR(10)
         || 'AND        i.item_release_date BETWEEN :start_date AND :end_date';
 
    dbms_output.put_line(stmt);
    

   
    OPEN item_cursor FOR stmt USING pv_start_date, pv_end_date;
    LOOP
     
      FETCH item_cursor INTO item_row;
      EXIT WHEN item_cursor%NOTFOUND;
 
           
      item_set.EXTEND;
      item_set(item_set.COUNT) :=
        item_obj( title         => item_row.title
                , subtitle      => item_row.subtitle
                , rating        => item_row.rating
                , release_date  => item_row.release_date );
    END LOOP;
 
      RETURN item_set;
  END item_list;
/

DESC item_list

SET PAGESIZE 9999
COL title   FORMAT A60
COL rating  FORMAT A6
SELECT   il.title
,        il.rating
FROM     TABLE(item_list(TO_DATE('01-JAN-2000'))) il;


-- Close log file.
SPOOL OFF

