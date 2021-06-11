/************************************************************
    Author  :   TothF  
    Remark  :   User Rights (or any matrix with hierarchical axes )
    Date    :   2015.07.01
************************************************************/

------------------
-- TABLES
------------------
CREATE TABLE UR_USER_AXIS (
    NAME                    VARCHAR2 (  500 ) NOT NULL,
    PARENT_NAME             VARCHAR2 (  500 ),
    CONSTRAINT              PK_UR_USER_AXIS     PRIMARY KEY ( NAME ),
    CONSTRAINT              FK1_UR_USER_AXIS    FOREIGN KEY ( PARENT_NAME ) REFERENCES UR_USER_AXIS  ( NAME )
  );

COMMENT ON TABLE  UR_USER_AXIS                      IS 'Users and/or groups in hierarchy';
COMMENT ON COLUMN UR_USER_AXIS.NAME                 IS 'The name of a user or user group';
COMMENT ON COLUMN UR_USER_AXIS.PARENT_NAME          IS 'The name of a user or user group';

--------------------------------------------------------------------------------------

CREATE TABLE UR_FUNCTION_AXIS (
    NAME                    VARCHAR2 (  500 ) NOT NULL,
    PARENT_NAME             VARCHAR2 (  500 ),
    CONSTRAINT              PK_UR_FUNCTION_AXIS     PRIMARY KEY ( NAME ),
    CONSTRAINT              FK1_UR_FUNCTION_AXIS    FOREIGN KEY ( PARENT_NAME ) REFERENCES UR_FUNCTION_AXIS  ( NAME )
  );

COMMENT ON TABLE  UR_FUNCTION_AXIS                      IS 'Application, modules, functions ... in hierarchy';
COMMENT ON COLUMN UR_FUNCTION_AXIS.NAME                 IS 'The name of a application, module, function';
COMMENT ON COLUMN UR_FUNCTION_AXIS.PARENT_NAME          IS 'The name of a application, module, function';

--------------------------------------------------------------------------------------

CREATE TABLE UR_ACCESS (
    CODE                    VARCHAR2 (   50 ) NOT NULL,
    NAME                    VARCHAR2 (  500 ) NOT NULL,
    REMARK                  VARCHAR2 (  500 ),
    CONSTRAINT              PK_UR_ACCESS     PRIMARY KEY ( CODE ),
    CONSTRAINT              UN1_UR_ACCESS    UNIQUE ( NAME )
  );

COMMENT ON TABLE  UR_ACCESS               IS 'The level/type of access';
COMMENT ON COLUMN UR_ACCESS.CODE          IS 'eg: R, W, E, U, D, I,...';
COMMENT ON COLUMN UR_ACCESS.NAME          IS 'eg: Read, Write, Execute, Update, Delete, Insert, ...';

--------------------------------------------------------------------------------------

CREATE TABLE UR_USER_FUNCTION_ACCESSES (
    USER_NAME               VARCHAR2 (  500 ) NOT NULL,
    FUNCTION_NAME           VARCHAR2 (  500 ) NOT NULL,
    ACCESS_CODE             VARCHAR2 (   50 ) NOT NULL,
    CONSTRAINT              PK_UR_USR_FNC_ACCESS    PRIMARY KEY ( USER_NAME , FUNCTION_NAME , ACCESS_CODE ),
    CONSTRAINT              FK1_UR_USR_FNC_ACCESS   FOREIGN KEY ( USER_NAME     ) REFERENCES UR_USER_AXIS      ( NAME ),
    CONSTRAINT              FK2_UR_USR_FNC_ACCESS   FOREIGN KEY ( FUNCTION_NAME ) REFERENCES UR_FUNCTION_AXIS  ( NAME ),
    CONSTRAINT              FK3_UR_USR_FNC_ACCESS   FOREIGN KEY ( ACCESS_CODE   ) REFERENCES UR_ACCESS         ( CODE )
  );

COMMENT ON TABLE  UR_USER_FUNCTION_ACCESSES        IS 'The cells of the function/user matrix';

--------------------------------------------------------------------------------------

------------------
-- TYPES
------------------

create or replace type UR_T_RESULT_RECORD as object (
      NAME               varchar2( 500 )
    , ACCESS_CODE        varchar2(  50 )
    , INHERITED_FROM     varchar2(  50 )
    );
/


create or replace TYPE UR_T_RESULT_LIST AS TABLE OF UR_T_RESULT_RECORD;
/

------------------
-- FUNCTIONS
------------------

create or replace function UR_GET_USER_FUNCTIONS ( I_USER_NAME in varchar2 ) return UR_T_RESULT_LIST pipelined is
    V_RESULT_RECORD         UR_T_RESULT_RECORD := UR_T_RESULT_RECORD( null, null, null );
begin

    for L_U in ( select FUNCTION_NAME, ACCESS_CODE 
                   from UR_USER_FUNCTION_ACCESSES 
                  where USER_NAME in ( select NAME from UR_USER_AXIS start with NAME = I_USER_NAME connect by prior PARENT_NAME = NAME ) 
               )
    loop

        V_RESULT_RECORD.ACCESS_CODE    := L_U.ACCESS_CODE;

        V_RESULT_RECORD.INHERITED_FROM := 'DIRECT';
        V_RESULT_RECORD.NAME           := L_U.FUNCTION_NAME;
        PIPE ROW( V_RESULT_RECORD ); 

        V_RESULT_RECORD.INHERITED_FROM := 'CHILD';
        for L_F in ( select NAME, PARENT_NAME 
                       from UR_FUNCTION_AXIS 
                      start with NAME = L_U.FUNCTION_NAME
                connect by prior PARENT_NAME = NAME )
        loop
            if L_U.FUNCTION_NAME != L_F.NAME then
                V_RESULT_RECORD.NAME := L_F.NAME;
                PIPE ROW( V_RESULT_RECORD ); 
            end if;
        end loop;

        V_RESULT_RECORD.INHERITED_FROM := 'PARENT';
        for L_F in ( select NAME, PARENT_NAME 
                       from UR_FUNCTION_AXIS 
                      start with NAME = L_U.FUNCTION_NAME 
                    connect by prior NAME = PARENT_NAME )
        loop
            if L_U.FUNCTION_NAME != L_F.NAME then
                V_RESULT_RECORD.NAME := L_F.NAME;
                PIPE ROW( V_RESULT_RECORD ); 
            end if;
        end loop;

    end loop;

    return;

end;
/

/**********************************************************************************************************/

create or replace function UR_GET_FUNCTION_USERS ( I_FUNCTION_NAME in varchar2 ) return UR_T_RESULT_LIST pipelined is
    V_RESULT_RECORD         UR_T_RESULT_RECORD := UR_T_RESULT_RECORD( null, null, null );
begin

    for L_U in ( select USER_NAME, ACCESS_CODE 
                   from UR_USER_FUNCTION_ACCESSES 
                  where FUNCTION_NAME in ( select NAME from UR_FUNCTION_AXIS start with NAME = I_FUNCTION_NAME connect by prior PARENT_NAME = NAME ) 
               )
    loop

        V_RESULT_RECORD.ACCESS_CODE    := L_U.ACCESS_CODE;

        V_RESULT_RECORD.INHERITED_FROM := 'DIRECT';
        V_RESULT_RECORD.NAME           := L_U.USER_NAME;
        PIPE ROW( V_RESULT_RECORD ); 

        V_RESULT_RECORD.INHERITED_FROM := 'CHILD';
        for L_F in ( select NAME, PARENT_NAME 
                       from UR_USER_AXIS 
                      start with NAME = L_U.USER_NAME
                connect by prior PARENT_NAME = NAME )
        loop
            if L_U.USER_NAME != L_F.NAME then
                V_RESULT_RECORD.NAME := L_F.NAME;
                PIPE ROW( V_RESULT_RECORD ); 
            end if;
        end loop;

        V_RESULT_RECORD.INHERITED_FROM := 'PARENT';
        for L_F in ( select NAME, PARENT_NAME 
                       from UR_USER_AXIS 
                      start with NAME = L_U.USER_NAME 
                    connect by prior NAME = PARENT_NAME )
        loop
            if L_U.USER_NAME != L_F.NAME then
                V_RESULT_RECORD.NAME := L_F.NAME;
                PIPE ROW( V_RESULT_RECORD ); 
            end if;
        end loop;
 
    end loop;

    return;

end;
/

/**********************************************************************************************************/
