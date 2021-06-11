/* ********************************************************

    Testing of RIGHTS

******************************************************** */
--delete UR_USER_FUNCTION_ACCESSES;
--delete UR_ACCESS;
--delete UR_FUNCTION_AXIS;
--delete UR_USER_AXIS;

--------------------------------------------------------------------------------------

insert into UR_ACCESS values ( 'S'    , 'See'       , null  );
insert into UR_ACCESS values ( 'E'    , 'Edit'      , null  );
insert into UR_ACCESS values ( 'A'    , 'All/Admin' , null  );


--------------------------------------------------------------------------------------
-- Hierarchy of Users and User Groups
--------------------------------------------------------------------------------------
/*

ADMINS
   |
   +-- SA
   |
   +-- FERI
   
   
READERS   
   |
   +-- JOHN
   |
   +-- HR
   |    |
   |    +-- MARY
   |
   +-- IT   
        |
        +-- FRANK
        
HENRY

*/ 

insert into UR_USER_AXIS values ( 'ADMINS'        , null          );
insert into UR_USER_AXIS values ( 'SA'            , 'ADMINS'      );
insert into UR_USER_AXIS values ( 'FERI'          , 'ADMINS'      );

insert into UR_USER_AXIS values ( 'READERS'       , null          );
insert into UR_USER_AXIS values ( 'JOHN'          , 'READERS'     );
insert into UR_USER_AXIS values ( 'HR'            , 'READERS'     );
insert into UR_USER_AXIS values ( 'MARY'          , 'HR'          );
insert into UR_USER_AXIS values ( 'IT'            , 'READERS'     );
insert into UR_USER_AXIS values ( 'FRANK'         , 'IT'          );

insert into UR_USER_AXIS values ( 'HENRY'         , null          );


--------------------------------------------------------------------------------------
-- Hierarchy of Functions, Menus, Modules...
--------------------------------------------------------------------------------------

/*

APPL 1
   |
   +-- HR MODUL
   |    |
   |    +-- HR MENU 1
   |    |       |
   |    |       +-- HR FUNC 1
   |    |
   |    +-- HR MENU 2
   |            |
   |            +-- HR FUNC 2
   |
   +-- IT MODUL
   |    |
   |    +-- IT MENU 1
   |    |       |
   |    |       +-- IT FUNC 1
   |    |
   |    +-- IT MENU 2
   |            |
   |            +-- IT FUNC 2
   |
   +-- ZZ MODUL
   |    |
   |    +-- ZZ MENU 1
   |    |       |
   |    |       +-- ZZ FUNC 1
   |    |
   |    +-- ZZ MENU 2
   |            |
   |            +-- ZZ FUNC 2
   |
   +-- FUNC 00

*/

insert into UR_FUNCTION_AXIS values ( 'APPL 1'    , null          );

insert into UR_FUNCTION_AXIS values ( 'HR MODUL'  , 'APPL 1'      );
insert into UR_FUNCTION_AXIS values ( 'IT MODUL'  , 'APPL 1'      );
insert into UR_FUNCTION_AXIS values ( 'ZZ MODUL'  , 'APPL 1'      );

insert into UR_FUNCTION_AXIS values ( 'HR MENU 1' , 'HR MODUL'    );
insert into UR_FUNCTION_AXIS values ( 'HR MENU 2' , 'HR MODUL'    );

insert into UR_FUNCTION_AXIS values ( 'IT MENU 1' , 'IT MODUL'    );
insert into UR_FUNCTION_AXIS values ( 'IT MENU 2' , 'IT MODUL'    );

insert into UR_FUNCTION_AXIS values ( 'ZZ MENU 1' , 'ZZ MODUL'    );
insert into UR_FUNCTION_AXIS values ( 'ZZ MENU 2' , 'ZZ MODUL'    );

insert into UR_FUNCTION_AXIS values ( 'FUNC 00'   , 'APPL 1'      );

insert into UR_FUNCTION_AXIS values ( 'HR FUNC 1' , 'HR MENU 1'   );
insert into UR_FUNCTION_AXIS values ( 'HR FUNC 2' , 'HR MENU 2'   );

insert into UR_FUNCTION_AXIS values ( 'IT FUNC 1' , 'IT MENU 1'   );
insert into UR_FUNCTION_AXIS values ( 'IT FUNC 2' , 'IT MENU 2'   );

insert into UR_FUNCTION_AXIS values ( 'ZZ FUNC 1' , 'ZZ MENU 1'   );
insert into UR_FUNCTION_AXIS values ( 'ZZ FUNC 2' , 'ZZ MENU 2'   );


--------------------------------------------------------------------------------------
-- user - function access matrix
--------------------------------------------------------------------------------------

insert into UR_USER_FUNCTION_ACCESSES values ( 'ADMINS' , 'APPL 1'     , 'A' );
insert into UR_USER_FUNCTION_ACCESSES values ( 'HR'     , 'HR MODUL'   , 'E' );
insert into UR_USER_FUNCTION_ACCESSES values ( 'IT'     , 'IT MODUL'   , 'E' );
insert into UR_USER_FUNCTION_ACCESSES values ( 'HENRY'  , 'FUNC 00'    , 'E' );
insert into UR_USER_FUNCTION_ACCESSES values ( 'HENRY'  , 'IT FUNC 1'  , 'E' );

--------------------------------------------------------------------------------------
commit;
--------------------------------------------------------------------------------------



-- what XY user can access and how?
select distinct name, access_code, inherited_from from table( UR_GET_USER_FUNCTIONS ( 'FERI'  ) ) order by 1;
select distinct name, access_code, inherited_from from table( UR_GET_USER_FUNCTIONS ( 'JOHN'  ) ) order by 1;
select distinct name, access_code, inherited_from from table( UR_GET_USER_FUNCTIONS ( 'MARY'  ) ) order by 1;
select distinct name, access_code, inherited_from from table( UR_GET_USER_FUNCTIONS ( 'FRANK' ) ) order by 1;
select distinct name, access_code, inherited_from from table( UR_GET_USER_FUNCTIONS ( 'HENRY' ) ) order by 1;

-- who can access XY function and how?
select distinct name, access_code, inherited_from from table( UR_GET_FUNCTION_USERS ( 'FUNC 00'   ) ) order by 1;
select distinct name, access_code, inherited_from from table( UR_GET_FUNCTION_USERS ( 'HR FUNC 1' ) ) order by 1;
select distinct name, access_code, inherited_from from table( UR_GET_FUNCTION_USERS ( 'IT FUNC 2' ) ) order by 1;
select distinct name, access_code, inherited_from from table( UR_GET_FUNCTION_USERS ( 'ZZ FUNC 1' ) ) order by 1;
select distinct name, access_code, inherited_from from table( UR_GET_FUNCTION_USERS ( 'IT MODUL'  ) ) order by 1;

-- can MARY access XY function and how?
select distinct access_code, inherited_from from table( UR_GET_USER_FUNCTIONS ( 'MARY' ) ) where name = 'HR FUNC 2' order by 2,1;
select distinct access_code, inherited_from from table( UR_GET_USER_FUNCTIONS ( 'MARY' ) ) where name = 'IT FUNC 2' order by 2,1;
select distinct access_code, inherited_from from table( UR_GET_USER_FUNCTIONS ( 'MARY' ) ) where name = 'ZZ FUNC 1' order by 2,1;
select distinct access_code, inherited_from from table( UR_GET_USER_FUNCTIONS ( 'MARY' ) ) where name = 'FUNC 00'   order by 2,1;

-- it shows the same
select distinct access_code, inherited_from from table( UR_GET_FUNCTION_USERS ( 'HR FUNC 2' ) ) where name = 'MARY' order by 2,1;
select distinct access_code, inherited_from from table( UR_GET_FUNCTION_USERS ( 'IT FUNC 2' ) ) where name = 'MARY' order by 2,1;
select distinct access_code, inherited_from from table( UR_GET_FUNCTION_USERS ( 'ZZ FUNC 1' ) ) where name = 'MARY' order by 2,1;
select distinct access_code, inherited_from from table( UR_GET_FUNCTION_USERS ( 'FUNC 00'   ) ) where name = 'MARY' order by 2,1;



