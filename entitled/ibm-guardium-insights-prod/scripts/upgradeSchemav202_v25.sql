-- **************************************************************
--
-- IBM Confidential
--
-- OCO Source Materials
--
-- 5737-L66
--
-- (C) Copyright IBM Corp. 2020
--
-- The source code for this program is not published or otherwise
-- divested of its trade secrets, irrespective of what has been
-- deposited with the U.S. Copyright Office.
--
-- **************************************************************


-- *************************************************************
-- Synchronization script for Guardium Insights v2.0.2 to v2.5 
-- This script upgrades the DB schema from v2.0.2 to v2.5. It should be run only
-- once per tenant on a db2 database that has been restore using a v2.0.2 backup. 
-- To Run:  db2 -td@ -f upgradeSchemav202_v25.sql
-- ************************************************************



ALTER TABLE "MY_TENANT_SCHEMA"."GROUP_GDP_SYNC" DROP CONSTRAINT GROUP_GDP_SYNC_FK@
ALTER TABLE "MY_TENANT_SCHEMA"."GROUP_MEMBER" DROP CONSTRAINT GROUP_MEMBER_FK@
ALTER TABLE "MY_TENANT_SCHEMA"."GROUP_TUPLE_PARAMETERS" DROP CONSTRAINT TUPLE_PARAM_FK@
ALTER TABLE "MY_TENANT_SCHEMA"."NESTED_GROUP_MEMBER" DROP CONSTRAINT NESTED_GROUP_MEMBER_FK_1@
ALTER TABLE "MY_TENANT_SCHEMA"."NESTED_GROUP_MEMBER" DROP CONSTRAINT NESTED_GROUP_MEMBER_FK_2@


DROP VIEW "MY_TENANT_SCHEMA"."POLICY_VIOLATION_DATA"@
DROP VIEW "MY_TENANT_SCHEMA"."EXCEPTION_DATA"@
DROP VIEW "MY_TENANT_SCHEMA"."ACTIVITY_DATA"@

INSERT INTO "MY_TENANT_SCHEMA"."GROUP_DESC"("GROUP_ID", "NAME", "GROUP_TYPE_ID", "NESTED") VALUES
	(11, 'Admin users - default', 16, 0),
	(12, 'Administration objects - default', 7, 0)@

INSERT INTO "MY_TENANT_SCHEMA"."NESTED_GROUP_MEMBER"("MEMBER_ID", "GROUP_ID", "GROUP_MEMBER") VALUES (1, 9, 12), (2, 10, 11)@

INSERT INTO "MY_TENANT_SCHEMA"."GROUP_MEMBER"("MEMBER_ID", "GROUP_ID", "GROUP_MEMBER") VALUES
	(385, 11, 'SA'),
	(386, 11, 'SYSIBM'),
	(387, 11, 'SYS'),
	(388, 11, 'SYSTEM'),
	(389, 11, 'ADMIN'),
	(390, 11, 'ADMINISTRATOR'),
	(391, 11, 'APPLSYS'),
	(392, 11, 'APPLSYSPUB'),
	(393, 11, 'APPS'),
	(394, 11, 'CTXSYS'),
	(395, 11, 'DB1AS'),
	(396, 11, 'DB2ADMIN'),
	(397, 11, 'DB2FENC1'),
	(398, 11, 'DB2INST2'),
	(399, 11, 'DBA'),
	(400, 11, 'DISTRIBUTOR_ADMIN'),
	(401, 11, 'INTERNAL'),
	(402, 11, 'MDSYS'),
	(403, 11, 'PROBE'),
	(404, 12, 'dba_db_links'),
	(405, 12, 'dba_objects'),
	(406, 12, 'dba_privileges'),
	(407, 12, 'dba_roles'),
	(408, 12, 'dba_tablespaces'),
	(409, 12, 'dba_users'),
	(410, 12, 'sp_createdb'),
	(411, 12, 'sp_grant'),
	(412, 12, 'sysdatabases'),
	(413, 12, 'syslogins'),
	(414, 12, 'sysmembers'),
	(415, 12, 'sysobjects'),
	(416, 12, 'sysusers'),
	(417, 12, 'userpermissions'),
	(418, 12, 'SYSCOLUMNS'),
	(419, 12, 'SYSCOMMENTS')@

INSERT INTO "MY_TENANT_SCHEMA"."GROUP_MEMBER"("GROUP_ID", "GROUP_MEMBER") VALUES
	(9, 'dba_db_links'),
	(9, 'dba_objects'),
	(9, 'dba_privileges'),
	(9, 'dba_roles'),
	(9, 'dba_tablespaces'),
	(9, 'dba_users'),
	(9, 'sp_createdb'),
	(9, 'sp_grant'),
	(9, 'sysdatabases'),
	(9, 'syslogins'),
	(9, 'sysmembers'),
	(9, 'sysobjects'),
	(9, 'sysusers'),
	(9, 'userpermissions'),
	(9, 'SYSCOLUMNS'),
	(9, 'SYSCOMMENTS'),
	(10, 'SA'),
	(10, 'SYSIBM'),
	(10, 'SYS'),
	(10, 'SYSTEM'),
	(10, 'ADMIN'),
	(10, 'ADMINISTRATOR'),
	(10, 'APPLSYS'),
	(10, 'APPLSYSPUB'),
	(10, 'APPS'),
	(10, 'CTXSYS'),
	(10, 'DB1AS'),
	(10, 'DB2ADMIN'),
	(10, 'DB2FENC1'),
	(10, 'DB2INST2'),
	(10, 'DBA'),
	(10, 'DISTRIBUTOR_ADMIN'),
	(10, 'INTERNAL'),
	(10, 'MDSYS'),
	(10, 'PROBE')@

CREATE TABLE "MY_TENANT_SCHEMA"."CLASSIFICATION" (
                             "MessageType"           VARCHAR(25) DEFAULT 'CLASSIFICATION',
                             "UTCOffset"             DOUBLE,
                             "DataSourceID"          DECIMAL(20,0) NOT NULL,
                             "DataSourceName"        VARCHAR(255),
                             "DataSourceType"        VARCHAR(50),
                             "DataSourceIP"          VARCHAR(50),
                             "DataSourceHostName"    VARCHAR(255),
                             "ServiceName"           VARCHAR(255) DEFAULT NULL,
                             "DBName"                VARCHAR(255) DEFAULT NULL,
                             "Port"                  DECIMAL(11,0) DEFAULT 0,
                             "ProcessDescription"    VARCHAR(255) DEFAULT NULL,
                             "Catalog"               VARCHAR(255) DEFAULT NULL,
                             "Schema"                VARCHAR(255) DEFAULT NULL,
                             "TableName"             VARCHAR(255) DEFAULT NULL,
                             "ColumnName"            VARCHAR(255) DEFAULT NULL,
                             "RuleDescription"       VARCHAR(255) DEFAULT NULL,
                             "Comments"              VARCHAR(32000) DEFAULT NULL,
                             "ClassificationName"    VARCHAR(255) DEFAULT NULL,
                             "Category"              VARCHAR(255) DEFAULT NULL,
                             "DataSourceDescription" VARCHAR(255) DEFAULT NULL,
                             "StartDateTime"         TIMESTAMP DEFAULT '0001-01-01-00.00.00.000000',
                             "StartDateTimeUTC"      TIMESTAMP DEFAULT '0001-01-01-00.00.00.000000',
                             "ConfigID"              VARCHAR(50) NOT NULL WITH DEFAULT '',
                             "GlobalID"              VARCHAR(50) NOT NULL WITH DEFAULT '',
                             "TenantID"              VARCHAR(50),
                             "IngestTimestamp"       TIMESTAMP DEFAULT CURRENT TIMESTAMP,
                             PRIMARY KEY ("DataSourceID","ConfigID","GlobalID") )
                             IN "USERSPACE1"@


GRANT CONTROL ON "MY_TENANT_SCHEMA"."CLASSIFICATION" TO USER DB2INST1@
GRANT SELECT ON "MY_TENANT_SCHEMA"."CLASSIFICATION" TO USER DB2INST1 WITH GRANT OPTION@
GRANT UPDATE ON "MY_TENANT_SCHEMA"."CLASSIFICATION" TO USER DB2INST1 WITH GRANT OPTION@
GRANT INSERT ON "MY_TENANT_SCHEMA"."CLASSIFICATION" TO USER DB2INST1 WITH GRANT OPTION@
GRANT DELETE ON "MY_TENANT_SCHEMA"."CLASSIFICATION" TO USER DB2INST1 WITH GRANT OPTION@
GRANT REFERENCES ON "MY_TENANT_SCHEMA"."CLASSIFICATION" TO USER DB2INST1 WITH GRANT OPTION@
GRANT ALTER ON "MY_TENANT_SCHEMA"."CLASSIFICATION" TO USER DB2INST1 WITH GRANT OPTION@
GRANT INDEX ON "MY_TENANT_SCHEMA"."CLASSIFICATION" TO USER DB2INST1 WITH GRANT OPTION@



ALTER TABLE "MY_TENANT_SCHEMA"."EXCEPTION" ALTER COLUMN "SQLStatement" SET DATA TYPE VARCHAR(32000)@
ALTER TABLE "MY_TENANT_SCHEMA"."EXCEPTION" ALTER COLUMN "ErrorCause" SET DATA TYPE VARCHAR(32000)@


CREATE TABLE "MY_TENANT_SCHEMA"."TMP_EXCEPTION"  (
                  "MessageType" VARCHAR(25 OCTETS) WITH DEFAULT 'EXCEPTION' ,
                  "ID" VARCHAR(100 OCTETS) ,
                  "ExceptionTypeID" VARCHAR(64 OCTETS) ,
                  "ExceptionID" DECIMAL(20,0) NOT NULL ,
                  "UserName" VARCHAR(255 OCTETS) ,
                  "SourceAddress" VARCHAR(255 OCTETS) ,
                  "DestinationAddress" VARCHAR(255 OCTETS) ,
                  "DBProtocol" VARCHAR(20 OCTETS) WITH DEFAULT NULL ,
                  "AppUserName" VARCHAR(240 OCTETS) ,
                  "ExceptionDescription" VARCHAR(255 OCTETS) ,
                  "SQLStatement" VARCHAR(32000 OCTETS) ,
                  "ErrorCause" VARCHAR(32000 OCTETS) WITH DEFAULT NULL ,
                  "ErrorCode" VARCHAR(100 OCTETS) ,
                  "Timestamp" TIMESTAMP ,
                  "TimestampUTC" TIMESTAMP ,
                  "SessionID" DECIMAL(20,0) ,
                  "InformationLink" VARCHAR(255 OCTETS) ,
                  "UTCOffset" DOUBLE ,
                  "Count" DECIMAL(11,0) ,
                  "SourceID" VARCHAR(50 OCTETS) WITH DEFAULT NULL ,
                  "ConfigID" VARCHAR(50 OCTETS) NOT NULL ,
                  "GlobalID" VARCHAR(50 OCTETS) NOT NULL ,
                  "TenantID" VARCHAR(50 OCTETS) ,
                  "IngestTimestamp" TIMESTAMP WITH DEFAULT CURRENT TIMESTAMP,
                  PRIMARY KEY ("ExceptionID","ConfigID","GlobalID") ENFORCED )
                 DISTRIBUTE BY HASH("ExceptionID")
                   IN "USERSPACE1"
                 ORGANIZE BY COLUMN@

INSERT INTO "MY_TENANT_SCHEMA"."TMP_EXCEPTION"  (
                        "MessageType",
                        "ID",
                        "ExceptionTypeID",
                        "ExceptionID",
                        "UserName",
                        "SourceAddress" ,
                        "DestinationAddress" ,
                        "DBProtocol" ,
                        "AppUserName" ,
                        "ExceptionDescription",
                        "SQLStatement" ,
                        "ErrorCause" ,
                        "ErrorCode" ,
                        "Timestamp",
                        "SessionID" ,
                        "InformationLink" ,
                        "UTCOffset",
                        "Count",
                        "SourceID" ,
                        "ConfigID" ,
                        "GlobalID" ,
                        "TenantID",
                        "IngestTimestamp" )
SELECT  "MessageType",
        "ID",
        "ExceptionTypeID",
        "ExceptionID",
        "UserName",
        "SourceAddress" ,
        "DestinationAddress" ,
        "DBProtocol" ,
        "AppUserName",
        "ExceptionDescription",
        "SQLStatement" ,
        "ErrorCause" ,
        "ErrorCode" ,
        "Timestamp",
        "SessionID" ,
        "InformationLink" ,
        "UTCOffset",
        "Count",
        "SourceID" ,
        "ConfigID" ,
        "GlobalID" ,
        "TenantID",
        "IngestTimestamp"
FROM "MY_TENANT_SCHEMA"."EXCEPTION"@

SET SCHEMA "MY_TENANT_SCHEMA"@

RENAME TABLE "EXCEPTION" TO "OLD_EXCEPTION"@

RENAME TABLE "TMP_EXCEPTION" TO "EXCEPTION"@

RUNSTATS ON TABLE "MY_TENANT_SCHEMA"."EXCEPTION"@

ECHO RECREATED EXCEPTION TABLE (COUNTS SHOULD MATCH)@

ECHO COUNTS FOR EXCEPTION TABLE@
SELECT COUNT(*) from "MY_TENANT_SCHEMA"."EXCEPTION"@

ECHO COUNTS FOR ORIGINAL EXCEPTION TABLE@
SELECT COUNT(*) from "MY_TENANT_SCHEMA"."OLD_EXCEPTION"@



ALTER TABLE "MY_TENANT_SCHEMA"."FULL_SQL"
 ADD "TimestampUTC" TIMESTAMP@
ALTER TABLE "MY_TENANT_SCHEMA"."FULL_SQL" ALTER COLUMN "FullStatement" SET DATA TYPE VARCHAR(32000)@


ALTER TABLE "MY_TENANT_SCHEMA"."GROUP_TUPLE_PARAMETERS" ADD CONSTRAINT TUPLE_PARAM_UNIQUE UNIQUE ("GROUP_ID")@


ALTER TABLE "MY_TENANT_SCHEMA"."INSTANCE"
 ADD "PeriodStartUTC" TIMESTAMP DEFAULT '0001-01-01-00.00.00.000000'@
ALTER TABLE "MY_TENANT_SCHEMA"."INSTANCE"
 ADD "PeriodEndUTC" TIMESTAMP DEFAULT '0001-01-01-00.00.00.000000'@
ALTER TABLE "MY_TENANT_SCHEMA"."INSTANCE"
 ADD "ApplicationEventDateUTC" TIMESTAMP DEFAULT NULL@
ALTER TABLE "MY_TENANT_SCHEMA"."INSTANCE" ALTER COLUMN "OriginalSQL" SET DATA TYPE VARCHAR(32000)@
ALTER TABLE "MY_TENANT_SCHEMA"."INSTANCE"
 ADD "TimestampUTC" TIMESTAMP DEFAULT CURRENT TIMESTAMP@
ALTER TABLE "MY_TENANT_SCHEMA"."INSTANCE"
 ADD "TotalCount" DECIMAL(20,0)@
ALTER TABLE "MY_TENANT_SCHEMA"."INSTANCE" ADD CONSTRAINT INSTANCE_CHECK_CONSTRAINT CHECK ("TotalCount" =  (ISNULL("SuccessfulSqls", 0) + ISNULL("FailedSqls", 0)))@


ALTER TABLE "MY_TENANT_SCHEMA"."OBJECT"
 ADD "UTCOffset" DOUBLE@
ALTER TABLE "MY_TENANT_SCHEMA"."OBJECT"
 ADD "TimestampUTC" TIMESTAMP@
ALTER TABLE "MY_TENANT_SCHEMA"."OBJECT"
 ADD "ConfigID" VARCHAR(50) NOT NULL WITH DEFAULT ''@
ALTER TABLE "MY_TENANT_SCHEMA"."OBJECT"
 ADD "GlobalID" VARCHAR(50) NOT NULL WITH DEFAULT ''@
ALTER TABLE "MY_TENANT_SCHEMA"."OBJECT"
 ADD "TenantID" VARCHAR(50)@

ALTER TABLE "MY_TENANT_SCHEMA"."OBJECT" DROP PRIMARY KEY@
ALTER TABLE "MY_TENANT_SCHEMA"."OBJECT" ADD CONSTRAINT OBJECT_PK_1 PRIMARY KEY ("ObjectID","SentenceID","ConstructID","ConfigID","GlobalID")@

CREATE TABLE "MY_TENANT_SCHEMA"."OVERFLOW_FIELDS" ("TableName"       VARCHAR(25) DEFAULT '' NOT NULL,
                              "ID"              DECIMAL(20,0) NOT NULL,
                              "ColumnName"      VARCHAR(25) DEFAULT '' NOT NULL,
                              "Value"           CLOB DEFAULT NULL,
                              "ConfigID"        VARCHAR(50) NOT NULL WITH DEFAULT '',
                              "GlobalID"        VARCHAR(50) NOT NULL WITH DEFAULT '',
                              "IngestTimestamp" TIMESTAMP DEFAULT CURRENT TIMESTAMP,
                              PRIMARY KEY ("TableName","ID","ColumnName","ConfigID","GlobalID"))
                              IN "USERSPACE1"@

GRANT CONTROL ON "MY_TENANT_SCHEMA"."OVERFLOW_FIELDS" TO USER DB2INST1@
GRANT SELECT ON "MY_TENANT_SCHEMA"."OVERFLOW_FIELDS" TO USER DB2INST1 WITH GRANT OPTION@
GRANT UPDATE ON "MY_TENANT_SCHEMA"."OVERFLOW_FIELDS" TO USER DB2INST1 WITH GRANT OPTION@
GRANT INSERT ON "MY_TENANT_SCHEMA"."OVERFLOW_FIELDS" TO USER DB2INST1 WITH GRANT OPTION@
GRANT DELETE ON "MY_TENANT_SCHEMA"."OVERFLOW_FIELDS" TO USER DB2INST1 WITH GRANT OPTION@
GRANT REFERENCES ON "MY_TENANT_SCHEMA"."OVERFLOW_FIELDS" TO USER DB2INST1 WITH GRANT OPTION@
GRANT ALTER ON "MY_TENANT_SCHEMA"."OVERFLOW_FIELDS" TO USER DB2INST1 WITH GRANT OPTION@
GRANT INDEX ON "MY_TENANT_SCHEMA"."OVERFLOW_FIELDS" TO USER DB2INST1 WITH GRANT OPTION@


ALTER TABLE "MY_TENANT_SCHEMA"."POLICY_VIOLATION" ALTER COLUMN "FullSQL" SET DATA TYPE VARCHAR(32000)@
ALTER TABLE "MY_TENANT_SCHEMA"."POLICY_VIOLATION"
 ADD "TimestampUTC" TIMESTAMP@

ALTER TABLE "MY_TENANT_SCHEMA"."SENTENCE"
 ADD "UTCOffset" DOUBLE@
ALTER TABLE "MY_TENANT_SCHEMA"."SENTENCE"
 ADD "TimestampUTC" TIMESTAMP@
ALTER TABLE "MY_TENANT_SCHEMA"."SENTENCE"
 ADD "ConfigID" VARCHAR(50) NOT NULL WITH DEFAULT ''@
ALTER TABLE "MY_TENANT_SCHEMA"."SENTENCE"
 ADD "GlobalID" VARCHAR(50) NOT NULL WITH DEFAULT ''@
ALTER TABLE "MY_TENANT_SCHEMA"."SENTENCE"
 ADD "TenantID" VARCHAR(50)@

ALTER TABLE "MY_TENANT_SCHEMA"."SENTENCE" DROP PRIMARY KEY@
ALTER TABLE "MY_TENANT_SCHEMA"."SENTENCE" ADD CONSTRAINT SENTENCE_PK_1 PRIMARY KEY ("SentenceID","ConstructID","ConfigID","GlobalID")@


ALTER TABLE "MY_TENANT_SCHEMA"."SESSION"
 ADD "SessionStartUTC" TIMESTAMP DEFAULT '0001-01-01-00.00.00.000000'@
ALTER TABLE "MY_TENANT_SCHEMA"."SESSION"
 ADD "SessionEndUTC" TIMESTAMP DEFAULT NULL@
ALTER TABLE "MY_TENANT_SCHEMA"."SESSION"
 ADD "IgnoreSinceUTC" TIMESTAMP DEFAULT NULL@
ALTER TABLE "MY_TENANT_SCHEMA"."SESSION"
 ADD "FailoverTimestampUTC" TIMESTAMP DEFAULT NULL@

CREATE TABLE "MY_TENANT_SCHEMA"."VULNERABILITY_ASSESSMENT" (
                                       "MessageType"           VARCHAR(25) DEFAULT 'VULNERABILITY_ASSESSMENT',
                                       "UTCOffset"             DOUBLE,
                                       "TestResultID"          DECIMAL(20,0) NOT NULL,
                                       "DataSourceName"        VARCHAR(255),
                                       "DataSourceType"        VARCHAR(50),
                                       "DBName"                VARCHAR(255) DEFAULT NULL,
                                       "VersionLevel"          VARCHAR(255),
                                       "PatchLevel"            VARCHAR(255) DEFAULT NULL,
                                       "FullVersionInfo"       VARCHAR(32000) DEFAULT NULL,
                                       "Description"           VARCHAR(255) DEFAULT NULL,
                                       "Host"                  VARCHAR(255),
                                       "TestDescription"       VARCHAR(150),
                                       "TestScore"             DECIMAL(11,0) DEFAULT -1,
                                       "ScoreDescription"      VARCHAR(255),
                                       "ResultText"            VARCHAR(32000) DEFAULT NULL,
                                       "Recommendation"        VARCHAR(32000) DEFAULT NULL,
                                       "Severity"              VARCHAR(60) NOT NULL,
                                       "Category"              VARCHAR(60) DEFAULT NULL,
                                       "ExecutionDate"         TIMESTAMP DEFAULT '0001-01-01-00.00.00.000000',
                                       "ExecutionDateUTC"      TIMESTAMP DEFAULT '0001-01-01-00.00.00.000000',
                                       "AssessmentDescription" VARCHAR(150),
                                       "ServiceName"           VARCHAR(255) DEFAULT NULL,
                                       "Port"                  DECIMAL(11,0) DEFAULT 0,
                                       "DataSourceID"          DECIMAL(11,0) DEFAULT 0,
                                       "ResultDetails"         VARCHAR(32000) DEFAULT NULL,
                                       "ConfigID"              VARCHAR(50) NOT NULL WITH DEFAULT '',
                                       "GlobalID"              VARCHAR(50) NOT NULL WITH DEFAULT '',
                                       "IngestTimestamp"       TIMESTAMP DEFAULT CURRENT TIMESTAMP,
                                       PRIMARY KEY ("TestResultID","ConfigID","GlobalID"))
                                       IN "USERSPACE1"@

GRANT CONTROL ON "MY_TENANT_SCHEMA"."VULNERABILITY_ASSESSMENT" TO USER DB2INST1@
GRANT SELECT ON "MY_TENANT_SCHEMA"."VULNERABILITY_ASSESSMENT" TO USER DB2INST1 WITH GRANT OPTION@
GRANT UPDATE ON "MY_TENANT_SCHEMA"."VULNERABILITY_ASSESSMENT" TO USER DB2INST1 WITH GRANT OPTION@
GRANT INSERT ON "MY_TENANT_SCHEMA"."VULNERABILITY_ASSESSMENT" TO USER DB2INST1 WITH GRANT OPTION@
GRANT DELETE ON "MY_TENANT_SCHEMA"."VULNERABILITY_ASSESSMENT" TO USER DB2INST1 WITH GRANT OPTION@
GRANT REFERENCES ON "MY_TENANT_SCHEMA"."VULNERABILITY_ASSESSMENT" TO USER DB2INST1 WITH GRANT OPTION@
GRANT ALTER ON "MY_TENANT_SCHEMA"."VULNERABILITY_ASSESSMENT" TO USER DB2INST1 WITH GRANT OPTION@
GRANT INDEX ON "MY_TENANT_SCHEMA"."VULNERABILITY_ASSESSMENT" TO USER DB2INST1 WITH GRANT OPTION@


CREATE OR REPLACE PROCEDURE "MY_TENANT_SCHEMA"."EXTRACT_SP"(
    IN TNT_ID VARCHAR(1000),
    IN PREV_FULLSQL_TIME VARCHAR(1000),
    IN CURR_FULLSQL_TIME VARCHAR(1000),
    IN PREV_INGEST_TIME VARCHAR(1000),
    IN CURR_INGEST_TIME VARCHAR(1000)
    )
LANGUAGE SQL
DYNAMIC RESULT SETS 1
BEGIN
    -- Declare variables to use
    DECLARE extract_query VARCHAR(5000);
    DECLARE MYCUR CURSOR WITH RETURN TO CLIENT FOR S1;
	SET extract_query =
	'SELECT
       ''BROADCAST'' AS "RecordType",
        "'||TNT_ID||'"."FULL_SQL"."Timestamp" AS "Timestamp",
        "'||TNT_ID||'"."utcmillis"("'||TNT_ID||'"."FULL_SQL"."Timestamp") AS "UnixTimestamp",
        "'||TNT_ID||'"."FULL_SQL"."IngestTimestamp" AS "IngestTimestamp",
        "'||TNT_ID||'"."FULL_SQL"."FullSQLID" AS "FullSQLID",
        "'||TNT_ID||'"."SESSION"."SessionID" AS "SessionID",
        "'||TNT_ID||'"."FULL_SQL"."SQLSequenceInRequest" AS "SQLSequenceInRequest",
        "'||TNT_ID||'"."SESSION"."DBUserName" AS "DBUserName",
        "'||TNT_ID||'"."SESSION"."SourceProgram" AS "SourceProgram",
        "'||TNT_ID||'"."SESSION"."ServerIP" AS "ServerIP",
        "'||TNT_ID||'"."SESSION"."ServiceName" AS "ServiceName",
        "'||TNT_ID||'"."SESSION"."UTCOffset" AS "OriginalTimezone",
        "'||TNT_ID||'"."FULL_SQL"."Succeeded" AS "Status",
        "'||TNT_ID||'"."FULL_SQL"."TotalRecordsAffected" AS "TotalRecordsAffected",
        "'||TNT_ID||'"."FULL_SQL"."ResponseTime" AS "ResponseTime",
        "'||TNT_ID||'"."SESSION"."DatabaseName" AS "DatabaseName",
        "'||TNT_ID||'"."INSTANCE"."ConstructID" AS "ConstructID",
        "'||TNT_ID||'"."SESSION"."ClientID" AS "ClientIP",
        "'||TNT_ID||'"."INSTANCE"."AppUserName" AS "ApplicationUser",
        "'||TNT_ID||'"."INSTANCE"."ObjectsandVerbs" AS "ObjectsAndVerbs",
        "'||TNT_ID||'"."SESSION"."ServerType" AS "DatabaseType",
        "'||TNT_ID||'"."SESSION"."ServerPort" AS "ServerPort",
        "'||TNT_ID||'"."SESSION"."ServerHostName" AS "ServerHostName",
        "'||TNT_ID||'"."SESSION"."OSUser" AS "OSUser",
        '''||TNT_ID||''' AS "TenantID",
        "'||TNT_ID||'"."FULL_SQL"."GlobalID" AS "GlobalID",
        "'||TNT_ID||'"."FULL_SQL"."ConfigID" AS "ConfigID"


    FROM "'||TNT_ID||'"."FULL_SQL" LEFT OUTER JOIN "'||TNT_ID||'"."SESSION" ON "'||TNT_ID||'"."SESSION"."SessionID" = "'||TNT_ID||'"."FULL_SQL"."SessionID" LEFT OUTER JOIN "'||TNT_ID||'"."INSTANCE" ON "'||TNT_ID||'"."SESSION"."SessionID" = "'||TNT_ID||'"."INSTANCE"."SessionID" AND "'||TNT_ID||'"."INSTANCE"."InstanceID" = "'||TNT_ID||'"."FULL_SQL"."InstanceID"
    WHERE "'||TNT_ID||'"."FULL_SQL"."TimestampUTC" >= '''||PREV_FULLSQL_TIME||''' AND  "'||TNT_ID||'"."FULL_SQL"."TimestampUTC" < '''||CURR_FULLSQL_TIME||''' AND "'||TNT_ID||'"."FULL_SQL"."IngestTimestamp" >= '''||PREV_INGEST_TIME||''' AND "'||TNT_ID||'"."FULL_SQL"."IngestTimestamp" < '''||CURR_INGEST_TIME||'''
    ORDER BY "'||TNT_ID||'"."FULL_SQL"."Timestamp",
        "'||TNT_ID||'"."SESSION"."SessionID",
        "'||TNT_ID||'"."FULL_SQL"."SQLSequenceInRequest",
        "'||TNT_ID||'"."FULL_SQL"."FullSQLID" ASC';

    PREPARE S1 FROM extract_query;

    OPEN MYCUR;

END@


GRANT EXECUTE ON PROCEDURE "MY_TENANT_SCHEMA"."EXTRACT_SP" TO USER DB2INST1 WITH GRANT OPTION@


CREATE OR REPLACE PROCEDURE "MY_TENANT_SCHEMA"."INSERT_CLASSIFICATION_v1" (
    IN TNT_ID VARCHAR(1000),
    IN FILENAME VARCHAR(1000),
    IN GLOBALID VARCHAR(1000),
    IN TABLENAME VARCHAR(1000),
    IN DB2MOUNTPOINTPATH VARCHAR(1000)
)
LANGUAGE SQL
S1:BEGIN
	-- GLOBAL TABLE NAME PARAMETERS
	DECLARE FILEPATH VARCHAR(1000);
	DECLARE CREATE_STMT VARCHAR(5000);
	DECLARE INSERT_STMT VARCHAR(5000);

    SET FILEPATH = (CONCAT(CONCAT(CONCAT(DB2MOUNTPOINTPATH,TNT_ID),'/'),FILENAME));

    -- CREATE AN EXTERNAL TABLE FOR THE CSV
    SET CREATE_STMT = '
	CREATE EXTERNAL TABLE '||TNT_ID||'.'||TABLENAME||' (
    UTCOffset FLOAT,
    DataSourceID DECIMAL(20),
    DataSourceName VARCHAR(255),
    DataSourceType VARCHAR(50),
    DataSourceIP VARCHAR(50),
    DataSourceHostName VARCHAR(255),
    ServiceName VARCHAR(255),
    DBName VARCHAR(255),
    Port DECIMAL(11),
    ProcessDescription VARCHAR(255),
    Catalog VARCHAR(255),
    Schema VARCHAR(255),
    TableName VARCHAR(255),
    ColumnName VARCHAR(255),
    RuleDescription VARCHAR(255),
    Comments VARCHAR(32000),
    ClassificationName VARCHAR(255),
    Category VARCHAR(255),
    DataSourceDescription VARCHAR(255),
    StartDateTime TIMESTAMP,
    StartDateTimeUTC TIMESTAMP)
    USING (DATAOBJECT '''||FILEPATH||''' ENCODING UTF8 QUOTEDVALUE DOUBLE RequireQuotes TRUE DELIMITER ''~'' NULLVALUE ''\N'' escapeChar ''\'' TRUNCSTRING TRUE CtrlChars TRUE CRinString TRUE SKIPROWS 1)';
    PREPARE STMT_1 FROM CREATE_STMT;
    EXECUTE STMT_1;


    SET INSERT_STMT = '
    INSERT INTO  "'||TNT_ID||'"."CLASSIFICATION" ("MessageType", "UTCOffset", "DataSourceID", "DataSourceName", "DataSourceType", "DataSourceIP", "DataSourceHostName", "ServiceName", "DBName", "Port", "ProcessDescription", "Catalog", "Schema", "TableName", "ColumnName", "RuleDescription", "Comments", "ClassificationName", "Category", "DataSourceDescription", "StartDateTime", "StartDateTimeUTC", "ConfigID", "GlobalID")

	SELECT
        ''CLASSIFICATION'',
        UTCOffset,
        DataSourceID,
        DataSourceName,
        DataSourceType,
        DataSourceIP,
        DataSourceHostName,
        ServiceName,
        DBName,
        Port,
        ProcessDescription,
        Catalog,
        Schema,
        TableName,
        ColumnName,
        RuleDescription,
        Comments,
        ClassificationName,
        Category,
        DataSourceDescription,
        StartDateTime,
        StartDateTimeUTC,
        ''0'',
        '''||GLOBALID||'''
    FROM
        "'||TNT_ID||'"."'||TABLENAME||'";';
    PREPARE STMT_2 FROM INSERT_STMT;
    EXECUTE STMT_2;
    END S1@


GRANT EXECUTE ON PROCEDURE "MY_TENANT_SCHEMA"."INSERT_CLASSIFICATION_v1" TO USER DB2INST1 WITH GRANT OPTION@



DROP PROCEDURE "MY_TENANT_SCHEMA"."INSERT_EXCEPTION"@
-- **************************************************************
--
-- IBM Confidential
--
-- OCO Source Materials
--
-- 5737-L66
--
-- (C) Copyright IBM Corp. 2020
--
-- The source code for this program is not published or otherwise
-- divested of its trade secrets, irrespective of what has been
-- deposited with the U.S. Copyright Office.
--
-- **************************************************************

CREATE OR REPLACE PROCEDURE "MY_TENANT_SCHEMA"."INSERT_EXCEPTION" (
    IN TNT_ID VARCHAR(1000),
    IN FILENAME VARCHAR(1000),
    IN GLOBALID VARCHAR(1000),
    IN TABLENAME VARCHAR(1000),
    IN DB2MOUNTPOINTPATH VARCHAR(1000)
  )
LANGUAGE SQL
  S1:BEGIN
	-- GLOBAL TABLE NAME PARAMETERS
	DECLARE FILEPATH VARCHAR(1000);
	DECLARE CREATE_STMT VARCHAR(5000);
	DECLARE INSERT_STMT VARCHAR(5000);

  SET FILEPATH = (
  CONCAT(CONCAT(CONCAT(DB2MOUNTPOINTPATH,TNT_ID),'/'),FILENAME));
  SET CREATE_STMT = '
	CREATE EXTERNAL TABLE '||TNT_ID||'.'||TABLENAME||' (
        UTCOffset                                   DOUBLE
        ,ExceptionID                                VARCHAR(20)
        ,SessionId									VARCHAR(20)
        ,UserName									VARCHAR(255)
        ,SourceAddress								VARCHAR(255)
        ,DestinationAddress							VARCHAR(255)
        ,DatabaseProtocol							VARCHAR(20)
        ,ExceptionTimestamp							VARCHAR(20)
        ,ExceptionDescription						VARCHAR(255)
        ,Linktomoreinformationabouttheexception		VARCHAR(255)
        ,SQLstringthatcausedtheException			VARCHAR(32000)
        ,ExceptionTypeID							VARCHAR(64)
        ,DatabaseErrorText							VARCHAR(32000)
        ,AppUserName								VARCHAR(240)
        ,ErrorCode									VARCHAR(100))
	USING (DATAOBJECT '''||FILEPATH||''' ENCODING UTF8 QUOTEDVALUE DOUBLE RequireQuotes TRUE DELIMITER '','' NULLVALUE ''\N'' escapeChar ''\'' TRUNCSTRING TRUE CtrlChars TRUE CRinString TRUE SKIPROWS 1)';
  PREPARE STMT_1 FROM CREATE_STMT;
  EXECUTE STMT_1;


SET INSERT_STMT = 'INSERT
	  INTO  "'||TNT_ID||'"."EXCEPTION" ("MessageType","ID","ExceptionTypeID","ExceptionID","UserName","SourceAddress","DestinationAddress","DBProtocol","AppUserName","ExceptionDescription","SQLStatement","ErrorCause","ErrorCode","Timestamp","TimestampUTC","SessionID","InformationLink","UTCOffset","Count","SourceID","ConfigID","GlobalID")
	  SELECT ''EXCEPTION'',
NULL,
ExceptionTypeID,
ExceptionID,
UserName,
SourceAddress,
DestinationAddress,
DatabaseProtocol,
AppUserName,
ExceptionDescription,
SQLstringthatcausedtheException,
DatabaseErrorText,
ErrorCode,
CASE WHEN ExceptionTimestamp IS NULL
    THEN NULL
    ELSE TO_TIMESTAMP(REPLACE(REPLACE(ExceptionTimestamp,''T'','' ''),''Z'',''''), ''YYYY-MM-DD HH24:MI:SS'')
END,
CASE WHEN ExceptionTimestamp IS NULL
    THEN NULL
    ELSE ADD_HOURS(TO_TIMESTAMP(REPLACE(REPLACE(ExceptionTimestamp,''T'','' ''),''Z'',''''), ''YYYY-MM-DD HH24:MI:SS''), -(UTCOffset))
END,
SessionId,
Linktomoreinformationabouttheexception,
UTCOffset,
NULL,
NULL,
''0'',
'''||GLOBALID||''' FROM "'||TNT_ID||'"."'||TABLENAME||'";';
  PREPARE STMT_2 FROM INSERT_STMT;
  EXECUTE STMT_2;
  END S1@


GRANT EXECUTE ON PROCEDURE "MY_TENANT_SCHEMA"."INSERT_EXCEPTION" TO USER DB2INST1 WITH GRANT OPTION@



-- **************************************************************
--
-- IBM Confidential
--
-- OCO Source Materials
--
-- 5737-L66
--
-- (C) Copyright IBM Corp. 2020
--
-- The source code for this program is not published or otherwise
-- divested of its trade secrets, irrespective of what has been
-- deposited with the U.S. Copyright Office.
--
-- **************************************************************

CREATE OR REPLACE PROCEDURE "MY_TENANT_SCHEMA"."INSERT_EXCEPTION_v1" (
    IN TNT_ID VARCHAR(1000),
    IN FILENAME VARCHAR(1000),
    IN GLOBALID VARCHAR(1000),
    IN TABLENAME VARCHAR(1000),
    IN DB2MOUNTPOINTPATH VARCHAR(1000)
  )
LANGUAGE SQL
  S1:BEGIN
	-- GLOBAL TABLE NAME PARAMETERS
	DECLARE FILEPATH VARCHAR(1000);
	DECLARE CREATE_STMT VARCHAR(5000);
	DECLARE INSERT_STMT VARCHAR(5000);

  SET FILEPATH = (
  CONCAT(CONCAT(CONCAT(DB2MOUNTPOINTPATH,TNT_ID),'/'),FILENAME));
  SET CREATE_STMT = '
	CREATE EXTERNAL TABLE '||TNT_ID||'.'||TABLENAME||' (
        UTCOffset                                   DOUBLE
        ,ExceptionID                                VARCHAR(20)
        ,SessionId									VARCHAR(20)
        ,UserName									VARCHAR(255)
        ,SourceAddress								VARCHAR(255)
        ,DestinationAddress							VARCHAR(255)
        ,DatabaseProtocol							VARCHAR(20)
        ,ExceptionTimestamp							TIMESTAMP
        ,ExceptionTimestampUTC                      TIMESTAMP
        ,ExceptionDescription						VARCHAR(255)
        ,Linktomoreinformationabouttheexception		VARCHAR(255)
        ,SQLstringthatcausedtheException			VARCHAR(32000)
        ,ExceptionTypeID							VARCHAR(64)
        ,DatabaseErrorText							VARCHAR(32000)
        ,AppUserName								VARCHAR(240)
        ,ErrorCode									VARCHAR(100))
	USING (DATAOBJECT '''||FILEPATH||''' ENCODING UTF8 QUOTEDVALUE DOUBLE RequireQuotes TRUE DELIMITER ''~'' NULLVALUE ''\N'' escapeChar ''\'' TRUNCSTRING TRUE CtrlChars TRUE CRinString TRUE SKIPROWS 1)';
  PREPARE STMT_1 FROM CREATE_STMT;
  EXECUTE STMT_1;


SET INSERT_STMT = 'INSERT
	  INTO  "'||TNT_ID||'"."EXCEPTION" ("MessageType","ID","ExceptionTypeID","ExceptionID","UserName","SourceAddress","DestinationAddress","DBProtocol","AppUserName","ExceptionDescription","SQLStatement","ErrorCause","ErrorCode","Timestamp","TimestampUTC","SessionID","InformationLink","UTCOffset","Count","SourceID","ConfigID","GlobalID")
	  SELECT ''EXCEPTION'',
NULL,
ExceptionTypeID,
ExceptionID,
UserName,
SourceAddress,
DestinationAddress,
DatabaseProtocol,
AppUserName,
ExceptionDescription,
SQLstringthatcausedtheException,
DatabaseErrorText,
ErrorCode,
ExceptionTimestamp,
ExceptionTimestampUTC,
SessionId,
Linktomoreinformationabouttheexception,
UTCOffset,
NULL,
NULL,
''0'',
'''||GLOBALID||''' FROM "'||TNT_ID||'"."'||TABLENAME||'";';
  PREPARE STMT_2 FROM INSERT_STMT;
  EXECUTE STMT_2;
  END S1@


GRANT EXECUTE ON PROCEDURE "MY_TENANT_SCHEMA"."INSERT_EXCEPTION_v1" TO USER DB2INST1 WITH GRANT OPTION@



DROP PROCEDURE "MY_TENANT_SCHEMA"."INSERT_FULL_SQL"@
-- **************************************************************
--
-- IBM Confidential
--
-- OCO Source Materials
--
-- 5737-L66
--
-- (C) Copyright IBM Corp. 2020
--
-- The source code for this program is not published or otherwise
-- divested of its trade secrets, irrespective of what has been
-- deposited with the U.S. Copyright Office.
--
-- **************************************************************

CREATE OR REPLACE PROCEDURE "MY_TENANT_SCHEMA"."INSERT_FULL_SQL" (
    IN TNT_ID VARCHAR(1000),
    IN FILENAME VARCHAR(1000),
    IN GLOBALID VARCHAR(1000),
    IN TABLENAME VARCHAR(1000),
    IN DB2MOUNTPOINTPATH VARCHAR(1000)
  )
LANGUAGE SQL
  S1:BEGIN
	-- GLOBAL TABLE NAME PARAMETERS
	DECLARE FILEPATH VARCHAR(1000);
	DECLARE CREATE_STMT VARCHAR(5000);
	DECLARE INSERT_STMT VARCHAR(5000);

  SET FILEPATH = (
  CONCAT(CONCAT(CONCAT(DB2MOUNTPOINTPATH,TNT_ID),'/'),FILENAME));
  SET CREATE_STMT = '
	CREATE EXTERNAL TABLE '||TNT_ID||'.'||TABLENAME||' (
    UTCOffset   FLOAT,
    AccessRuleDescription	VARCHAR(100),
    FullSql     VARCHAR(32000),
    InstanceID	DECIMAL(20),
    RecordsAffected	  DECIMAL(11),
    ResponseTime	DECIMAL(11),
    SessionId	DECIMAL(20),
    Succeeded	DECIMAL(11),
    Timestamp	VARCHAR (20),
    FullSQLID   VARCHAR(20))
	USING (DATAOBJECT '''||FILEPATH||''' ENCODING UTF8 QUOTEDVALUE DOUBLE RequireQuotes TRUE DELIMITER '','' NULLVALUE ''\N'' escapeChar ''\'' TRUNCSTRING TRUE CtrlChars TRUE CRinString TRUE SKIPROWS 1)';
  PREPARE STMT_1 FROM CREATE_STMT;
  EXECUTE STMT_1;


SET INSERT_STMT = 'INSERT
	  INTO  "'||TNT_ID||'"."FULL_SQL" ("MessageType","ID","FullSQLID","SessionID","Timestamp","TimestampUTC","UTCOffset","InstanceID","AccessRuleDescription","FullStatement","TotalRecordsAffected","Succeeded","Status","ResponseTime","ACKResponseTime","ConfigID","GlobalID")
	  SELECT ''FULL_SQL'',
      NULL,
FullSQLID,
SessionId,
CASE WHEN Timestamp IS NULL
    THEN NULL
    ELSE TO_TIMESTAMP(REPLACE(REPLACE(Timestamp,''T'','' ''),''Z'',''''), ''YYYY-MM-DD HH24:MI:SS'')
END,
CASE WHEN Timestamp IS NULL
    THEN NULL
    ELSE ADD_HOURS(TO_TIMESTAMP(REPLACE(REPLACE(Timestamp,''T'','' ''),''Z'',''''), ''YYYY-MM-DD HH24:MI:SS''), -(UTCOffset))
END,
UTCOffset,
InstanceID,
AccessRuleDescription,
FullSql,
RecordsAffected,
Succeeded,
NULL,
ResponseTime,
NULL,
''0'',
'''||GLOBALID||''' FROM "'||TNT_ID||'"."'||TABLENAME||'";';
  PREPARE STMT_2 FROM INSERT_STMT;
  EXECUTE STMT_2;
  END S1@


GRANT EXECUTE ON PROCEDURE "MY_TENANT_SCHEMA"."INSERT_FULL_SQL" TO USER DB2INST1 WITH GRANT OPTION@



-- **************************************************************
--
-- IBM Confidential
--
-- OCO Source Materials
--
-- 5737-L66
--
-- (C) Copyright IBM Corp. 2020
--
-- The source code for this program is not published or otherwise
-- divested of its trade secrets, irrespective of what has been
-- deposited with the U.S. Copyright Office.
--
-- **************************************************************

CREATE OR REPLACE PROCEDURE "MY_TENANT_SCHEMA"."INSERT_FULL_SQL_v1" (
    IN TNT_ID VARCHAR(1000),
    IN FILENAME VARCHAR(1000),
    IN GLOBALID VARCHAR(1000),
    IN TABLENAME VARCHAR(1000),
    IN DB2MOUNTPOINTPATH VARCHAR(1000)
  )
LANGUAGE SQL
  S1:BEGIN
	-- GLOBAL TABLE NAME PARAMETERS
	DECLARE FILEPATH VARCHAR(1000);
	DECLARE CREATE_STMT VARCHAR(5000);
	DECLARE INSERT_STMT VARCHAR(5000);

  SET FILEPATH = (
  CONCAT(CONCAT(CONCAT(DB2MOUNTPOINTPATH,TNT_ID),'/'),FILENAME));
  SET CREATE_STMT = '
	CREATE EXTERNAL TABLE '||TNT_ID||'.'||TABLENAME||' (
    UTCOffset   FLOAT,
    AccessRuleDescription	VARCHAR(100),
    FullSql     VARCHAR(32000),
    InstanceID	DECIMAL(20),
    RecordsAffected	  DECIMAL(11),
    ResponseTime	DECIMAL(11),
    SessionId	DECIMAL(20),
    Succeeded	DECIMAL(11),
    Timestamp	TIMESTAMP,
    TimestampUTC  TIMESTAMP,
    FullSQLID   VARCHAR(20))
	USING (DATAOBJECT '''||FILEPATH||''' ENCODING UTF8 QUOTEDVALUE DOUBLE RequireQuotes TRUE DELIMITER ''~'' NULLVALUE ''\N'' escapeChar ''\'' TRUNCSTRING TRUE CtrlChars TRUE CRinString TRUE SKIPROWS 1)';
  PREPARE STMT_1 FROM CREATE_STMT;
  EXECUTE STMT_1;


SET INSERT_STMT = 'INSERT
	  INTO  "'||TNT_ID||'"."FULL_SQL" ("MessageType","ID","FullSQLID","SessionID","Timestamp","TimestampUTC","UTCOffset","InstanceID","AccessRuleDescription","FullStatement","TotalRecordsAffected","Succeeded","Status","ResponseTime","ACKResponseTime","ConfigID","GlobalID")
	  SELECT ''FULL_SQL'',
      NULL,
FullSQLID,
SessionId,
Timestamp,
TimestampUTC,
UTCOffset,
InstanceID,
AccessRuleDescription,
FullSql,
RecordsAffected,
Succeeded,
NULL,
ResponseTime,
NULL,
''0'',
'''||GLOBALID||''' FROM "'||TNT_ID||'"."'||TABLENAME||'";';
  PREPARE STMT_2 FROM INSERT_STMT;
  EXECUTE STMT_2;
  END S1@


GRANT EXECUTE ON PROCEDURE "MY_TENANT_SCHEMA"."INSERT_FULL_SQL_v1" TO USER DB2INST1 WITH GRANT OPTION@



-- **************************************************************
--
-- IBM Confidential
--
-- OCO Source Materials
--
-- 5737-L66
--
-- (C) Copyright IBM Corp. 2020
--
-- The source code for this program is not published or otherwise
-- divested of its trade secrets, irrespective of what has been
-- deposited with the U.S. Copyright Office.
--
-- **************************************************************

CREATE OR REPLACE PROCEDURE "MY_TENANT_SCHEMA"."INSERT_INSTANCE_v1"(
    IN TNT_ID VARCHAR(1000),
    IN FILENAME VARCHAR(1000),
    IN GLOBALID VARCHAR(1000),
    IN TABLENAME VARCHAR(1000),
    IN DB2MOUNTPOINTPATH VARCHAR(1000)
)
LANGUAGE SQL
S1:BEGIN
	DECLARE FILEPATH VARCHAR(1000);
	DECLARE CREATE_STMT VARCHAR(5000);
	DECLARE INSERT_STMT VARCHAR(5000);
    DECLARE TEMPTABLENAME VARCHAR(1000);
    DECLARE TEMPTABLECREATE VARCHAR(5000);

    SET FILEPATH = (CONCAT(CONCAT(CONCAT(DB2MOUNTPOINTPATH, TNT_ID), '/'), FILENAME));

	-- create an external table for the csv file
    SET CREATE_STMT = 'CREATE EXTERNAL TABLE ' || TNT_ID || '.' || TABLENAME || ' (UTCOffset FLOAT, InstanceId DECIMAL(20), SessionId DECIMAL(20), SuccessfulSqls  DECIMAL(20),
                      FailedSqls DECIMAL(20), ObjectsandVerbs VARCHAR(1000), ConstructId VARCHAR(40), PeriodStart TIMESTAMP, PeriodStartUTC TIMESTAMP, DBUserName VARCHAR(255), OSUser VARCHAR(255),
                      SourceProgram VARCHAR(255), ServerIP VARCHAR(50), AnalyzedClientIP VARCHAR(50), ServiceName VARCHAR(80), ClientHostName VARCHAR(255), ServerType VARCHAR(30),
                      AppUserName VARCHAR(240), DatabaseName VARCHAR(255), ApplicationEventID DECIMAL(20), EventUserName VARCHAR(240), EventType VARCHAR(30), EventValueStr VARCHAR(1000),
                      EventValueNum VARCHAR(30), EventDate TIMESTAMP, EventDateUTC TIMESTAMP, ServerPort VARCHAR(10), NetworkProtocol VARCHAR(20), TotalRecordsAffected DECIMAL(11), ServerHostName VARCHAR(255),
                      Timestamp TIMESTAMP, TimestampUTC TIMESTAMP, OriginalSQL VARCHAR(32000), AverageExecutionTime DECIMAL(11))
                      USING (DATAOBJECT ''' || FILEPATH || ''' ENCODING UTF8 QUOTEDVALUE DOUBLE RequireQuotes TRUE DELIMITER ''~'' NULLVALUE ''\N'' escapeChar ''\'' TRUNCSTRING TRUE CtrlChars TRUE CRinString
                      TRUE SKIPROWS 1)';
    PREPARE STMT_1 FROM CREATE_STMT;
    EXECUTE STMT_1;

    -- merge the INSTANCE rows from the external table
	SET INSERT_STMT = 'MERGE INTO "' || TNT_ID || '"."INSTANCE" AS "INSTANCE"
                  USING "'|| TNT_ID || '"."' || TABLENAME || '" AS "INSTANCE_MERGE" ("UTCOFFSET", "INSTANCEID", "SESSIONID", "SUCCESSFULSQLS", "FAILEDSQLS", "OBJECTSANDVERBS", "CONSTRUCTID",
                  "PERIODSTART", "PERIODSTARTUTC", "DBUSERNAME", "OSUSER", "SOURCEPROGRAM", "SERVERIP", "ANALYZEDCLIENTIP", "SERVICENAME", "CLIENTHOSTNAME", "SERVERTYPE", "APPUSERNAME", "DATABASENAME",
                  "APPLICATIONEVENTID", "EVENTUSERNAME", "EVENTTYPE", "EVENTVALUESTR", "EVENTVALUENUM", "EVENTDATE", "EVENTDATEUTC", "SERVERPORT", "NETWORKPROTOCOL", "TOTALRECORDSAFFECTED", "SERVERHOSTNAME",
                  "TIMESTAMP", "TIMESTAMPUTC", "ORIGINALSQL", "AVERAGEEXECUTIONTIME")
                  ON("INSTANCE"."InstanceID" = "INSTANCE_MERGE"."INSTANCEID" AND "INSTANCE"."SessionID"  = "INSTANCE_MERGE"."SESSIONID" AND "INSTANCE"."ConfigID"  = ''0''
                  AND "INSTANCE"."GlobalID"  = '''||GLOBALID||''')
                  WHEN MATCHED THEN
                  UPDATE SET
                  "INSTANCE"."SuccessfulSqls"  = "INSTANCE_MERGE"."SUCCESSFULSQLS", "INSTANCE"."FailedSqls"  = "INSTANCE_MERGE"."FAILEDSQLS"
                  WHEN NOT MATCHED THEN
                  INSERT ("MessageType", "ID", "InstanceID", "SessionID", "UTCOffset", "PeriodStart", "PeriodStartUTC", "PeriodEnd", "PeriodEndUTC", "ApplicationEventID", "AppUserName", "ApplicationEventType",
                  "ApplicationEventValueStr", "ApplicationEventValueNum", "ApplicationEventDate", "ApplicationEventDateUTC", "ConstructID", "OriginalSQL", "ObjectsandVerbs", "SuccessfulSqls", "FailedSqls", "DBUserName",
                  "OSUser", "SourceProgram", "ServerIP", "ClientID", "ServiceName", "ClientHostName", "ServerType", "DatabaseName", "EventUserName", "ServerPort", "NetworkProtocol",
                  "TotalRecordsAffected", "ServerHostName", "Timestamp", "TimestampUTC", "AverageExecutionTime", "ConfigID", "GlobalID")
                  VALUES (
                  ''INSTANCE'',
                  NULL,
                  "INSTANCE_MERGE"."INSTANCEID",
                  "INSTANCE_MERGE"."SESSIONID",
                  "INSTANCE_MERGE"."UTCOFFSET",
                  "INSTANCE_MERGE"."PERIODSTART",
                  "INSTANCE_MERGE"."PERIODSTARTUTC",
                  NULL,
                  NULL,
                  "INSTANCE_MERGE"."APPLICATIONEVENTID",
                  "INSTANCE_MERGE"."APPUSERNAME",
                  "INSTANCE_MERGE"."EVENTTYPE",
                  "INSTANCE_MERGE"."EVENTVALUESTR",
                  "INSTANCE_MERGE"."EVENTVALUENUM",
                  "INSTANCE_MERGE"."EVENTDATE",
                  "INSTANCE_MERGE"."EVENTDATEUTC",
                  "INSTANCE_MERGE"."CONSTRUCTID",
                  "INSTANCE_MERGE"."ORIGINALSQL",
                  "INSTANCE_MERGE"."OBJECTSANDVERBS",
                  "INSTANCE_MERGE"."SUCCESSFULSQLS",
                  "INSTANCE_MERGE"."FAILEDSQLS",
                  "INSTANCE_MERGE"."DBUSERNAME",
                  "INSTANCE_MERGE"."OSUSER",
                  "INSTANCE_MERGE"."SOURCEPROGRAM",
                  "INSTANCE_MERGE"."SERVERIP",
                  "INSTANCE_MERGE"."ANALYZEDCLIENTIP",
                  "INSTANCE_MERGE"."SERVICENAME",
                  "INSTANCE_MERGE"."CLIENTHOSTNAME",
                  "INSTANCE_MERGE"."SERVERTYPE",
                  "INSTANCE_MERGE"."DATABASENAME",
                  "INSTANCE_MERGE"."EVENTUSERNAME",
                  "INSTANCE_MERGE"."SERVERPORT",
                  "INSTANCE_MERGE"."NETWORKPROTOCOL",
                  "INSTANCE_MERGE"."TOTALRECORDSAFFECTED",
                  "INSTANCE_MERGE"."SERVERHOSTNAME",
                  "INSTANCE_MERGE"."TIMESTAMP",
                  "INSTANCE_MERGE"."TIMESTAMPUTC",
                  "INSTANCE_MERGE"."AVERAGEEXECUTIONTIME",
                  ''0'', ''' || GLOBALID || ''')';
    PREPARE STMT_2 FROM INSERT_STMT;
    EXECUTE STMT_2;

END S1@


GRANT EXECUTE ON PROCEDURE "MY_TENANT_SCHEMA"."INSERT_INSTANCE_v1" TO USER DB2INST1 WITH GRANT OPTION@



DROP PROCEDURE "MY_TENANT_SCHEMA"."INSERT_OBJ"@
-- **************************************************************
--
-- IBM Confidential
--
-- OCO Source Materials
--
-- 5737-L66
--
-- (C) Copyright IBM Corp. 2020
--
-- The source code for this program is not published or otherwise
-- divested of its trade secrets, irrespective of what has been
-- deposited with the U.S. Copyright Office.
--
-- **************************************************************

CREATE OR REPLACE PROCEDURE "MY_TENANT_SCHEMA"."INSERT_OBJ"(
    IN TNT_ID VARCHAR(1000),
    IN FILENAME VARCHAR(1000),
    IN GLOBALID VARCHAR(1000),
    IN TABLENAME VARCHAR(1000),
    IN DB2MOUNTPOINTPATH VARCHAR(1000)
)
LANGUAGE SQL
S1:BEGIN
	DECLARE FILEPATH VARCHAR(1000);
	DECLARE CREATE_STMT VARCHAR(5000);
	DECLARE INSERT_STMT VARCHAR(5000);
    DECLARE TEMPTABLENAME VARCHAR(1000);
    DECLARE TEMPTABLECREATE VARCHAR(5000);
    DECLARE TEMPOBJS VARCHAR(5000);
    DECLARE SENTENCEMERGE VARCHAR(5000);
	DECLARE OBJECTMERGE VARCHAR(5000);
    DECLARE DROPTEMP VARCHAR(100);

    SET FILEPATH = (CONCAT(CONCAT(CONCAT(DB2MOUNTPOINTPATH, TNT_ID), '/'), FILENAME));

	-- create an external table for the csv file
    SET CREATE_STMT = 'CREATE EXTERNAL TABLE ' || TNT_ID || '.' || TABLENAME || ' (UTCOffset FLOAT, InstanceId DECIMAL(20), SessionId DECIMAL(20), SuccessfulSqls  DECIMAL(20),
                      FailedSqls DECIMAL(20), ObjectsandVerbs VARCHAR(1000), ConstructId VARCHAR(40), PeriodStart VARCHAR (20), DBUserName VARCHAR(255), OSUser VARCHAR(255),
                      SourceProgram VARCHAR(255), ServerIP VARCHAR(50), AnalyzedClientIP VARCHAR(50), ServiceName VARCHAR(80), ClientHostName VARCHAR(255), ServerType VARCHAR(30),
                      AppUserName VARCHAR(240), DatabaseName VARCHAR(255), ApplicationEventID DECIMAL(20), EventUserName VARCHAR(240), EventType VARCHAR(30), EventValueStr VARCHAR(1000),
                      EventValueNum VARCHAR(30), EventDate VARCHAR (20), ServerPort VARCHAR(10), NetworkProtocol VARCHAR(20), TotalRecordsAffected DECIMAL(11), ServerHostName VARCHAR(255),
                      Timestamp VARCHAR (20), OriginalSQL VARCHAR(32000), AverageExecutionTime DECIMAL(11))
                      USING (DATAOBJECT ''' || FILEPATH || ''' ENCODING UTF8 QUOTEDVALUE DOUBLE RequireQuotes TRUE DELIMITER '','' NULLVALUE ''\N'' escapeChar ''\'' TRUNCSTRING TRUE CtrlChars TRUE CRinString
                      TRUE SKIPROWS 1)';
    PREPARE STMT_1 FROM CREATE_STMT;
    EXECUTE STMT_1;

    -- merge the INSTANCE rows from the external table
	SET INSERT_STMT = 'MERGE INTO "' || TNT_ID || '"."INSTANCE" AS "INSTANCE"
                  USING "'|| TNT_ID || '"."' || TABLENAME || '" AS "INSTANCE_MERGE" ("UTCOFFSET", "INSTANCEID", "SESSIONID", "SUCCESSFULSQLS", "FAILEDSQLS", "OBJECTSANDVERBS", "CONSTRUCTID",
                  "PERIODSTART", "DBUSERNAME", "OSUSER", "SOURCEPROGRAM", "SERVERIP", "ANALYZEDCLIENTIP", "SERVICENAME", "CLIENTHOSTNAME", "SERVERTYPE", "APPUSERNAME", "DATABASENAME",
                  "APPLICATIONEVENTID", "EVENTUSERNAME", "EVENTTYPE", "EVENTVALUESTR", "EVENTVALUENUM", "EVENTDATE", "SERVERPORT", "NETWORKPROTOCOL", "TOTALRECORDSAFFECTED", "SERVERHOSTNAME",
                  "TIMESTAMP", "ORIGINALSQL", "AVERAGEEXECUTIONTIME")
                  ON("INSTANCE"."InstanceID" = "INSTANCE_MERGE"."INSTANCEID" AND "INSTANCE"."SessionID"  = "INSTANCE_MERGE"."SESSIONID" AND "INSTANCE"."ConfigID"  = ''0''
                  AND "INSTANCE"."GlobalID"  = '''||GLOBALID||''')
                  WHEN MATCHED THEN
                  UPDATE SET
                  "INSTANCE"."SuccessfulSqls"  = "INSTANCE_MERGE"."SUCCESSFULSQLS", "INSTANCE"."FailedSqls"  = "INSTANCE_MERGE"."FAILEDSQLS"
                  WHEN NOT MATCHED THEN
                  INSERT ("MessageType", "ID", "InstanceID", "SessionID", "UTCOffset", "PeriodStart", "PeriodStartUTC", "PeriodEnd", "PeriodEndUTC", "ApplicationEventID", "AppUserName", "ApplicationEventType",
                  "ApplicationEventValueStr", "ApplicationEventValueNum", "ApplicationEventDate", "ApplicationEventDateUTC", "ConstructID", "OriginalSQL", "ObjectsandVerbs", "SuccessfulSqls", "FailedSqls", "DBUserName",
                  "OSUser", "SourceProgram", "ServerIP", "ClientID", "ServiceName", "ClientHostName", "ServerType", "DatabaseName", "EventUserName", "ServerPort", "NetworkProtocol",
                  "TotalRecordsAffected", "ServerHostName", "Timestamp", "TimestampUTC", "AverageExecutionTime", "ConfigID", "GlobalID")
                  VALUES (
                  ''INSTANCE'',
                  NULL,
                  "INSTANCE_MERGE"."INSTANCEID",
                  "INSTANCE_MERGE"."SESSIONID",
                  "INSTANCE_MERGE"."UTCOFFSET",
                  CASE WHEN "INSTANCE_MERGE"."PERIODSTART" IS NULL THEN NULL
                  ELSE TO_TIMESTAMP(REPLACE(REPLACE("INSTANCE_MERGE"."PERIODSTART",''T'','' ''),''Z'',''''),''YYYY-MM-DD HH24:MI:SS'') END,
                  CASE WHEN "INSTANCE_MERGE"."PERIODSTART" IS NULL THEN NULL
                  ELSE ADD_HOURS(TO_TIMESTAMP(REPLACE(REPLACE("INSTANCE_MERGE"."PERIODSTART",''T'','' ''),''Z'',''''),''YYYY-MM-DD HH24:MI:SS''), -("INSTANCE_MERGE"."UTCOFFSET")) END,
                  NULL,
                  NULL,
                  "INSTANCE_MERGE"."APPLICATIONEVENTID",
                  "INSTANCE_MERGE"."APPUSERNAME",
                  "INSTANCE_MERGE"."EVENTTYPE",
                  "INSTANCE_MERGE"."EVENTVALUESTR",
                  "INSTANCE_MERGE"."EVENTVALUENUM",
                  CASE WHEN "INSTANCE_MERGE"."EVENTDATE" IS NULL THEN NULL
                  ELSE TO_TIMESTAMP(REPLACE(REPLACE("INSTANCE_MERGE"."EVENTDATE",''T'','' ''),''Z'',''''),''YYYY-MM-DD HH24:MI:SS'') END,
                  CASE WHEN "INSTANCE_MERGE"."EVENTDATE" IS NULL THEN NULL
                  ELSE ADD_HOURS(TO_TIMESTAMP(REPLACE(REPLACE("INSTANCE_MERGE"."EVENTDATE",''T'','' ''),''Z'',''''),''YYYY-MM-DD HH24:MI:SS''), -("INSTANCE_MERGE"."UTCOFFSET")) END,
                  "INSTANCE_MERGE"."CONSTRUCTID",
                  "INSTANCE_MERGE"."ORIGINALSQL",
                  "INSTANCE_MERGE"."OBJECTSANDVERBS",
                  "INSTANCE_MERGE"."SUCCESSFULSQLS",
                  "INSTANCE_MERGE"."FAILEDSQLS",
                  "INSTANCE_MERGE"."DBUSERNAME",
                  "INSTANCE_MERGE"."OSUSER",
                  "INSTANCE_MERGE"."SOURCEPROGRAM",
                  "INSTANCE_MERGE"."SERVERIP",
                  "INSTANCE_MERGE"."ANALYZEDCLIENTIP",
                  "INSTANCE_MERGE"."SERVICENAME",
                  "INSTANCE_MERGE"."CLIENTHOSTNAME",
                  "INSTANCE_MERGE"."SERVERTYPE",
                  "INSTANCE_MERGE"."DATABASENAME",
                  "INSTANCE_MERGE"."EVENTUSERNAME",
                  "INSTANCE_MERGE"."SERVERPORT",
                  "INSTANCE_MERGE"."NETWORKPROTOCOL",
                  "INSTANCE_MERGE"."TOTALRECORDSAFFECTED",
                  "INSTANCE_MERGE"."SERVERHOSTNAME",
                  CASE WHEN "INSTANCE_MERGE"."TIMESTAMP" IS NULL THEN NULL
                  ELSE TO_TIMESTAMP(REPLACE(REPLACE("INSTANCE_MERGE"."TIMESTAMP",''T'','' ''),''Z'',''''),''YYYY-MM-DD HH24:MI:SS'') END,
                  CASE WHEN "INSTANCE_MERGE"."TIMESTAMP" IS NULL THEN NULL
                  ELSE ADD_HOURS(TO_TIMESTAMP(REPLACE(REPLACE("INSTANCE_MERGE"."TIMESTAMP",''T'','' ''),''Z'',''''),''YYYY-MM-DD HH24:MI:SS''), -("INSTANCE_MERGE"."UTCOFFSET")) END,
                  "INSTANCE_MERGE"."AVERAGEEXECUTIONTIME",
                  ''0'', '''||GLOBALID||''')';
    PREPARE STMT_2 FROM INSERT_STMT;
    EXECUTE STMT_2;

	-- create a temp table to hold the parsed objects and verbs
	SET TEMPTABLENAME = TRIM(CHAR(HEX(GENERATE_UNIQUE())));
    SET TEMPTABLECREATE = 'DECLARE GLOBAL TEMPORARY TABLE SESSION."' || TEMPTABLENAME || '" (
                          "ConstructID" VARCHAR(40),
                          "SentenceID" VARCHAR(40),
                          "Sentence" VARCHAR(40),
                          "ObjectID" VARCHAR(40),
                          "Object" VARCHAR(255),
                          "Depth" DECIMAL(11),
                          "ParentSentenceID" VARCHAR(40),
                          "Timestamp" TIMESTAMP,
                          "TimestampUTC" TIMESTAMP)';
	PREPARE TEMP FROM TEMPTABLECREATE;
    EXECUTE TEMP;

    -- parse the objects and verbs and insert them into the temp table
	SET TEMPOBJS = 'INSERT INTO SESSION."' || TEMPTABLENAME || '" ("ConstructID", "SentenceID", "Sentence", "ObjectID", "Object", "Depth", "ParentSentenceID", "Timestamp", "TimestampUTC")
                  with data as (
                  select DISTINCT A.ConstructId,
                  B.Index as SentenceOrder,
                  CASE
                  WHEN LOCATE_IN_STRING('','', B.String) >= 1 THEN RIGHT(B.String, LENGTH(B.String) - LOCATE_IN_STRING(B.String, '' '', -1))
                  WHEN C.String LIKE ''_% % %'' THEN TRIM(SUBSTR(C.String, LOCATE_IN_STRING(C.String, '' '')))
                  WHEN D.Index = 1 THEN SUBSTR(C.String, LOCATE('' '', C.String) + 1)
                  WHEN D.Index = 2 THEN TRIM(D.String)
                  END AS Sentence,
                  C.Index as ObjectOrder,
                  CASE
                  WHEN D.String = B.String THEN NULL
                  WHEN C.String LIKE ''_% % %'' THEN SUBSTR(C.String, 1, LOCATE_IN_STRING(C.String, '' '') - 1)
                  WHEN D.Index = 1 THEN TRIM(D.String)
                  WHEN D.Index = 2 THEN TRIM(SUBSTR(TRIM(C.String), 1, LOCATE('' '', TRIM(C.String))))
                  END AS Object
                  from ' || TNT_ID || '.' || TABLENAME || ' as A,
                  TABLE("'||TNT_ID||'"."SPLIT"(A.ObjectsandVerbs, '';'')) as B,
                  TABLE("'||TNT_ID||'"."SPLIT"(Trim(B.String), '','')) as C,
                  TABLE("'||TNT_ID||'"."SPLIT"(Trim(C.String), '' '')) as D
                  order by A.ConstructId, B.Index, C.Index
                  ) select data.ConstructID,
                  HEX(HASH(data.ConstructID || data.Sentence || data.SentenceOrder, 1)) as SentenceID,
                  UPPER(LEFT(data.Sentence, 40)) as Sentence,
                  HEX(HASH(data.ConstructID || data.Sentence || data.SentenceOrder || data.Object || data.ObjectOrder, 1)) as ObjectID,
                  LEFT(data.Object, 255) as Object,
                  0,
                  NULL,
                  NULL,
                  NULL
                  from data';
	PREPARE OBJS FROM TEMPOBJS;
	EXECUTE OBJS;

	-- merge the sentence (verb) rows from the temp table
	SET SENTENCEMERGE = 'MERGE INTO "' || TNT_ID || '".SENTENCE AS SENTENCE
	                    USING (SELECT DISTINCT "ConstructID", "SentenceID", "Sentence", "Depth", "ParentSentenceID", "Timestamp", "TimestampUTC" from SESSION."' || TEMPTABLENAME || '") AS SENTENCE_MERGE
	                    ON SENTENCE."ConstructID" = SENTENCE_MERGE."ConstructID" AND SENTENCE."SentenceID" = SENTENCE_MERGE."SentenceID"
	                    WHEN NOT MATCHED THEN
	                    INSERT ("MessageType", "SentenceID", "ConstructID", "Verb", "Depth", "ParentSentenceID", "Timestamp", "TimestampUTC", "ConfigID", "GlobalID")
	                    VALUES (''SENTENCE'',
	                    SENTENCE_MERGE."SentenceID",
	                    SENTENCE_MERGE."ConstructID",
	                    SENTENCE_MERGE."Sentence",
	                    SENTENCE_MERGE."Depth",
	                    SENTENCE_MERGE."ParentSentenceID",
	                    SENTENCE_MERGE."Timestamp",
                        SENTENCE_MERGE."TimestampUTC",
                        ''0'', '''||GLOBALID||''')';
	PREPARE SMERGE FROM SENTENCEMERGE;
	EXECUTE SMERGE;

	-- merge the object rows from the temp table
	SET OBJECTMERGE = 'MERGE INTO "' || TNT_ID || '".OBJECT AS OBJECT
	                  USING (SELECT "ConstructID", "SentenceID", "ObjectID", "Object", "Timestamp", "TimestampUTC" from SESSION."' || TEMPTABLENAME || '" WHERE "ObjectID" IS NOT NULL) AS OBJECT_MERGE
	                  ON OBJECT."ConstructID" = OBJECT_MERGE."ConstructID" AND OBJECT."SentenceID" = OBJECT_MERGE."SentenceID" AND OBJECT."ObjectID" = OBJECT_MERGE."ObjectID"
	                  WHEN NOT MATCHED THEN
	                  INSERT ("MessageType", "SentenceID", "ConstructID", "ObjectID", "ObjectName", "Timestamp", "TimestampUTC", "ConfigID", "GlobalID")
	                  VALUES (''OBJECT'',
	                  OBJECT_MERGE."SentenceID",
	                  OBJECT_MERGE."ConstructID",
	                  OBJECT_MERGE."ObjectID",
	                  OBJECT_MERGE."Object",
	                  OBJECT_MERGE."Timestamp",
                      OBJECT_MERGE."TimestampUTC",
                      ''0'', '''||GLOBALID||''')';
	PREPARE OMERGE FROM OBJECTMERGE;
	EXECUTE OMERGE;

	-- cleanup the temp table
	SET DROPTEMP = 'DROP TABLE SESSION."' || TEMPTABLENAME || '";';
	PREPARE DROPSTMT FROM DROPTEMP;
	EXECUTE DROPSTMT;
END S1@


GRANT EXECUTE ON PROCEDURE "MY_TENANT_SCHEMA"."INSERT_OBJ" TO USER DB2INST1 WITH GRANT OPTION@



-- **************************************************************
--
-- IBM Confidential
--
-- OCO Source Materials
--
-- 5737-L66
--
-- (C) Copyright IBM Corp. 2020
--
-- The source code for this program is not published or otherwise
-- divested of its trade secrets, irrespective of what has been
-- deposited with the U.S. Copyright Office.
--
-- **************************************************************

CREATE OR REPLACE PROCEDURE "MY_TENANT_SCHEMA"."INSERT_OBJECT_v1" (
    IN TNT_ID VARCHAR(1000),
    IN FILENAME VARCHAR(1000),
    IN GLOBALID VARCHAR(1000),
    IN TABLENAME VARCHAR(1000),
    IN DB2MOUNTPOINTPATH VARCHAR(1000)
  )
LANGUAGE SQL
  S1:BEGIN
	-- GLOBAL TABLE NAME PARAMETERS
	DECLARE FILEPATH VARCHAR(1000);
	DECLARE CREATE_STMT VARCHAR(5000);
	DECLARE OBJECTMERGE VARCHAR(5000);
  SET FILEPATH = (
  CONCAT(CONCAT(CONCAT(DB2MOUNTPOINTPATH,TNT_ID),'/'),FILENAME));
  SET CREATE_STMT = '
	CREATE EXTERNAL TABLE '||TNT_ID||'.'||TABLENAME||' (
        UTCOffset               FLOAT
        ,SentenceId             VARCHAR(40)
        ,ConstructId            VARCHAR(40)
        ,ObjectId               VARCHAR(40)
        ,ObjectName             VARCHAR(255)
        ,Timestamp              TIMESTAMP
        ,TimestampUTC           TIMESTAMP)
	USING (DATAOBJECT '''||FILEPATH||''' ENCODING UTF8 QUOTEDVALUE DOUBLE RequireQuotes TRUE DELIMITER ''~'' NULLVALUE ''\N'' escapeChar ''\'' TRUNCSTRING TRUE CtrlChars TRUE CRinString TRUE SKIPROWS 1)';
  PREPARE STMT_1 FROM CREATE_STMT;
  EXECUTE STMT_1;

	-- merge the object rows from the temp table
	SET OBJECTMERGE = 'MERGE INTO "' || TNT_ID || '"."OBJECT" AS "OBJECT"
	                  USING (SELECT DISTINCT "UTCOFFSET", "CONSTRUCTID", "SENTENCEID", "OBJECTID", "OBJECTNAME", "TIMESTAMP", "TIMESTAMPUTC" from "'||TNT_ID||'"."'||TABLENAME||'" WHERE "OBJECTID" IS NOT NULL) AS "OBJECT_MERGE"
	                  ON "OBJECT"."ConstructID" = "OBJECT_MERGE"."CONSTRUCTID" AND "OBJECT"."SentenceID" = "OBJECT_MERGE"."SENTENCEID" AND "OBJECT"."ObjectID" = "OBJECT_MERGE"."OBJECTID"
	                  WHEN NOT MATCHED THEN
	                  INSERT ("MessageType", "UTCOffset", "SentenceID", "ConstructID", "ObjectID", "ObjectName", "Timestamp", "TimestampUTC", "ConfigID", "GlobalID")
	                  VALUES (''OBJECT'',
                      "OBJECT_MERGE"."UTCOFFSET",
	                  "OBJECT_MERGE"."SENTENCEID",
	                  "OBJECT_MERGE"."CONSTRUCTID",
	                  "OBJECT_MERGE"."OBJECTID",
	                  "OBJECT_MERGE"."OBJECTNAME",
	                  "OBJECT_MERGE"."TIMESTAMP",
                      "OBJECT_MERGE"."TIMESTAMPUTC",
                      ''0'', ''' || GLOBALID || ''')';
	PREPARE OMERGE FROM OBJECTMERGE;
	EXECUTE OMERGE;

  END S1@


GRANT EXECUTE ON PROCEDURE "MY_TENANT_SCHEMA"."INSERT_OBJECT_v1" TO USER DB2INST1 WITH GRANT OPTION@



-- **************************************************************
--
-- IBM Confidential
--
-- OCO Source Materials
--
-- 5737-L66
--
-- (C) Copyright IBM Corp. 2020
--
-- The source code for this program is not published or otherwise
-- divested of its trade secrets, irrespective of what has been
-- deposited with the U.S. Copyright Office.
--
-- **************************************************************

CREATE OR REPLACE PROCEDURE "MY_TENANT_SCHEMA"."INSERT_OVERFLOW_FIELDS_v1" (
    IN TNT_ID VARCHAR(1000),
    IN FILENAME VARCHAR(1000),
    IN GLOBALID VARCHAR(1000),
    IN TABLENAME VARCHAR(1000),
    IN DB2MOUNTPOINTPATH VARCHAR(1000)
  )
LANGUAGE SQL
  S1:BEGIN
	-- GLOBAL TABLE NAME PARAMETERS
	DECLARE FILEPATH VARCHAR(1000);
	DECLARE CREATE_STMT VARCHAR(5000);
	DECLARE INSERT_STMT VARCHAR(5000);

  SET FILEPATH = (
  CONCAT(CONCAT(CONCAT(DB2MOUNTPOINTPATH,TNT_ID),'/'),FILENAME));
  SET CREATE_STMT = '
	CREATE EXTERNAL TABLE '||TNT_ID||'.'||TABLENAME||' (
        TableName      VARCHAR(20),
        Id             DECIMAL(20),
        ColumnName     VARCHAR(20),
        Value          CLOB(63K))
	USING (DATAOBJECT '''||FILEPATH||''' ENCODING UTF8 QUOTEDVALUE DOUBLE RequireQuotes TRUE DELIMITER ''~'' NULLVALUE ''\N'' escapeChar ''\'' TRUNCSTRING TRUE CtrlChars TRUE CRinString TRUE SKIPROWS 1)';
  PREPARE STMT_1 FROM CREATE_STMT;
  EXECUTE STMT_1;


SET INSERT_STMT = 'INSERT
	  INTO  "'||TNT_ID||'"."OVERFLOW_FIELDS" ("TableName","ID","ColumnName","Value","ConfigID","GlobalID")
	  SELECT
        TableName,
        Id,
        ColumnName,
        Value,
        ''0'',
        ''' || GLOBALID || '''
        FROM "'||TNT_ID||'"."'||TABLENAME||'";';
  PREPARE STMT_2 FROM INSERT_STMT;
  EXECUTE STMT_2;
  END S1@


GRANT EXECUTE ON PROCEDURE "MY_TENANT_SCHEMA"."INSERT_OVERFLOW_FIELDS_v1" TO USER DB2INST1 WITH GRANT OPTION@



DROP PROCEDURE "MY_TENANT_SCHEMA"."INSERT_POLICY_VIOLATIONS"@
-- **************************************************************
--
-- IBM Confidential
--
-- OCO Source Materials
--
-- 5737-L66
--
-- (C) Copyright IBM Corp. 2020
--
-- The source code for this program is not published or otherwise
-- divested of its trade secrets, irrespective of what has been
-- deposited with the U.S. Copyright Office.
--
-- **************************************************************

CREATE OR REPLACE PROCEDURE "MY_TENANT_SCHEMA"."INSERT_POLICY_VIOLATIONS" (
    IN TNT_ID VARCHAR(1000),
    IN FILENAME VARCHAR(1000),
    IN GLOBALID VARCHAR(1000),
    IN TABLENAME VARCHAR(1000),
    IN DB2MOUNTPOINTPATH VARCHAR(1000)
  )
LANGUAGE SQL
  S1:BEGIN
	-- GLOBAL TABLE NAME PARAMETERS
	DECLARE FILEPATH VARCHAR(1000);
	DECLARE CREATE_STMT VARCHAR(5000);
	DECLARE INSERT_STMT VARCHAR(5000);
  SET FILEPATH = (
  CONCAT(CONCAT(CONCAT(DB2MOUNTPOINTPATH,TNT_ID),'/'),FILENAME));
  SET CREATE_STMT = '
	CREATE EXTERNAL TABLE '||TNT_ID||'.'||TABLENAME||' (
        UTCOffset              FLOAT
        ,OSUser                VARCHAR(255)
        ,DBUserName            VARCHAR(255)
        ,AnalyzedClientIP      VARCHAR(50)
        ,ClientHostName        VARCHAR(255)
        ,SourceProgram         VARCHAR(255)
        ,ServerIP              VARCHAR(50)
        ,ServerType            VARCHAR(30)
        ,Timestamp             VARCHAR(20)
        ,ServiceName           VARCHAR(80)
        ,Severity              DECIMAL(20)
        ,FullSQLString         VARCHAR(32000)
        ,AccessRuleDescription VARCHAR(100)
        ,ViolationLogId        DECIMAL(20)
        ,ObjectsandVerbs       VARCHAR(1000)
        ,ServerHostName        VARCHAR(255))
	USING (DATAOBJECT '''||FILEPATH||''' ENCODING UTF8 QUOTEDVALUE DOUBLE RequireQuotes TRUE DELIMITER '','' NULLVALUE ''\N'' escapeChar ''\'' TRUNCSTRING TRUE CtrlChars TRUE CRinString TRUE SKIPROWS 1)';
  PREPARE STMT_1 FROM CREATE_STMT;
  EXECUTE STMT_1;


SET INSERT_STMT = 'INSERT
	  INTO  "'||TNT_ID||'"."POLICY_VIOLATION" ("MessageType","ID","ViolationID","SessionID","UTCOffset","OSUser","DBUserName","ClientID","ClientHostName","SourceProgram","ServerIP","ServerType","ServiceName","ConstructID","ObjectsandVerbs","AppUserName","AccessRuleID","AccessRuleDescription","Verdict","FullSQL","SendMessage","CurrentCounter","KeyString","CategoryName","ClassificationName","Severity","PolicyDescription","Timestamp","TimestampUTC","ServerHostName","ConfigID","GlobalID")
	  SELECT ''POLICY_VIOLATION'',
      NULL,
      ViolationLogId,
      NULL,
      UTCOffset,
      OSUser,
      DBUserName,
      AnalyzedClientIP,
      ClientHostName,
      SourceProgram,
      ServerIP,
      ServerType,
      ServiceName,
      NULL,
      ObjectsandVerbs,
      NULL,
      NULL,
      AccessRuleDescription,
      NULL,
      FullSQLString,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      Severity,
      NULL,
      CASE WHEN TIMESTAMP IS NULL THEN NULL
          ELSE TO_TIMESTAMP(REPLACE(REPLACE(TIMESTAMP,''T'','' ''),''Z'',''''), ''YYYY-MM-DD HH24:MI:SS'')
      END,
      CASE WHEN TIMESTAMP IS NULL THEN NULL
          ELSE ADD_HOURS(TO_TIMESTAMP(REPLACE(REPLACE(TIMESTAMP,''T'','' ''),''Z'',''''), ''YYYY-MM-DD HH24:MI:SS''), -(UTCOffset))
      END,
      ServerHostName,
      ''0'',
      '''||GLOBALID||'''
   FROM "'||TNT_ID||'"."'||TABLENAME||'";';
  PREPARE STMT_2 FROM INSERT_STMT;
  EXECUTE STMT_2;
  END S1@


GRANT EXECUTE ON PROCEDURE "MY_TENANT_SCHEMA"."INSERT_POLICY_VIOLATIONS" TO USER DB2INST1 WITH GRANT OPTION@



-- **************************************************************
--
-- IBM Confidential
--
-- OCO Source Materials
--
-- 5737-L66
--
-- (C) Copyright IBM Corp. 2020
--
-- The source code for this program is not published or otherwise
-- divested of its trade secrets, irrespective of what has been
-- deposited with the U.S. Copyright Office.
--
-- **************************************************************

CREATE OR REPLACE PROCEDURE "MY_TENANT_SCHEMA"."INSERT_POLICY_VIOLATIONS_v1" (
    IN TNT_ID VARCHAR(1000),
    IN FILENAME VARCHAR(1000),
    IN GLOBALID VARCHAR(1000),
    IN TABLENAME VARCHAR(1000),
    IN DB2MOUNTPOINTPATH VARCHAR(1000)
  )
LANGUAGE SQL
  S1:BEGIN
	-- GLOBAL TABLE NAME PARAMETERS
	DECLARE FILEPATH VARCHAR(1000);
	DECLARE CREATE_STMT VARCHAR(5000);
	DECLARE INSERT_STMT VARCHAR(5000);
  SET FILEPATH = (
  CONCAT(CONCAT(CONCAT(DB2MOUNTPOINTPATH,TNT_ID),'/'),FILENAME));
  SET CREATE_STMT = '
	CREATE EXTERNAL TABLE '||TNT_ID||'.'||TABLENAME||' (
        UTCOffset              FLOAT
        ,OSUser                VARCHAR(255)
        ,DBUserName            VARCHAR(255)
        ,AnalyzedClientIP      VARCHAR(50)
        ,ClientHostName        VARCHAR(255)
        ,SourceProgram         VARCHAR(255)
        ,ServerIP              VARCHAR(50)
        ,ServerType            VARCHAR(30)
        ,Timestamp             TIMESTAMP
        ,TimestampUTC          TIMESTAMP
        ,ServiceName           VARCHAR(80)
        ,Severity              DECIMAL(20)
        ,FullSQLString         VARCHAR(32000)
        ,AccessRuleDescription VARCHAR(100)
        ,ViolationLogId        DECIMAL(20)
        ,ObjectsandVerbs       VARCHAR(1000)
        ,ServerHostName        VARCHAR(255)
        ,SessionId              DECIMAL(20))
	USING (DATAOBJECT '''||FILEPATH||''' ENCODING UTF8 QUOTEDVALUE DOUBLE RequireQuotes TRUE DELIMITER ''~'' NULLVALUE ''\N'' escapeChar ''\'' TRUNCSTRING TRUE CtrlChars TRUE CRinString TRUE SKIPROWS 1)';
  PREPARE STMT_1 FROM CREATE_STMT;
  EXECUTE STMT_1;


SET INSERT_STMT = 'INSERT
	  INTO  "'||TNT_ID||'"."POLICY_VIOLATION" ("MessageType","ID","ViolationID","SessionID","UTCOffset","OSUser","DBUserName","ClientID","ClientHostName","SourceProgram","ServerIP","ServerType","ServiceName","ConstructID","ObjectsandVerbs","AppUserName","AccessRuleID","AccessRuleDescription","Verdict","FullSQL","SendMessage","CurrentCounter","KeyString","CategoryName","ClassificationName","Severity","PolicyDescription","Timestamp","TimestampUTC","ServerHostName","ConfigID","GlobalID")
	  SELECT ''POLICY_VIOLATION'',
      NULL,
      ViolationLogId,
      SessionId,
      UTCOffset,
      OSUser,
      DBUserName,
      AnalyzedClientIP,
      ClientHostName,
      SourceProgram,
      ServerIP,
      ServerType,
      ServiceName,
      NULL,
      ObjectsandVerbs,
      NULL,
      NULL,
      AccessRuleDescription,
      NULL,
      FullSQLString,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      Severity,
      NULL,
      TIMESTAMP,
      TimestampUTC,
      ServerHostName,
      ''0'',
'''||GLOBALID||''' FROM "'||TNT_ID||'"."'||TABLENAME||'";';
  PREPARE STMT_2 FROM INSERT_STMT;
  EXECUTE STMT_2;
  END S1@


GRANT EXECUTE ON PROCEDURE "MY_TENANT_SCHEMA"."INSERT_POLICY_VIOLATIONS_v1" TO USER DB2INST1 WITH GRANT OPTION@



-- **************************************************************
--
-- IBM Confidential
--
-- OCO Source Materials
--
-- 5737-L66
--
-- (C) Copyright IBM Corp. 2020
--
-- The source code for this program is not published or otherwise
-- divested of its trade secrets, irrespective of what has been
-- deposited with the U.S. Copyright Office.
--
-- **************************************************************

CREATE OR REPLACE PROCEDURE "MY_TENANT_SCHEMA"."INSERT_SENTENCE_v1" (
    IN TNT_ID VARCHAR(1000),
    IN FILENAME VARCHAR(1000),
    IN GLOBALID VARCHAR(1000),
    IN TABLENAME VARCHAR(1000),
    IN DB2MOUNTPOINTPATH VARCHAR(1000)
  )
LANGUAGE SQL
  S1:BEGIN
	-- GLOBAL TABLE NAME PARAMETERS
	DECLARE FILEPATH VARCHAR(1000);
	DECLARE CREATE_STMT VARCHAR(5000);
	DECLARE SENTENCEMERGE VARCHAR(5000);
  SET FILEPATH = (
  CONCAT(CONCAT(CONCAT(DB2MOUNTPOINTPATH,TNT_ID),'/'),FILENAME));
  SET CREATE_STMT = '
	CREATE EXTERNAL TABLE '||TNT_ID||'.'||TABLENAME||' (
        UTCOffset               FLOAT
        ,SentenceId             VARCHAR(40)
        ,ConstructId            VARCHAR(40)
        ,Verb                   VARCHAR(40)
        ,Depth                  DECIMAL(11)
        ,ParentSentence         VARCHAR(40)
        ,Timestamp              TIMESTAMP
        ,TimestampUTC           TIMESTAMP)
	USING (DATAOBJECT '''||FILEPATH||''' ENCODING UTF8 QUOTEDVALUE DOUBLE RequireQuotes TRUE DELIMITER ''~'' NULLVALUE ''\N'' escapeChar ''\'' TRUNCSTRING TRUE CtrlChars TRUE CRinString TRUE SKIPROWS 1)';
  PREPARE STMT_1 FROM CREATE_STMT;
  EXECUTE STMT_1;

  -- merge the sentence (verb) rows from the temp table
  SET SENTENCEMERGE = 'MERGE INTO "' || TNT_ID || '"."SENTENCE" AS "SENTENCE"
                      USING (SELECT DISTINCT "UTCOFFSET","SENTENCEID", "CONSTRUCTID", "VERB", "DEPTH", "PARENTSENTENCE", "TIMESTAMP", "TIMESTAMPUTC" from "'||TNT_ID||'"."'||TABLENAME||'") AS "SENTENCE_MERGE"
                      ON "SENTENCE"."ConstructID" = "SENTENCE_MERGE"."CONSTRUCTID" AND "SENTENCE"."SentenceID" = "SENTENCE_MERGE"."SENTENCEID"
                      WHEN NOT MATCHED THEN
                      INSERT ("MessageType", "UTCOffset","SentenceID", "ConstructID", "Verb", "Depth", "ParentSentenceID", "Timestamp", "TimestampUTC", "ConfigID", "GlobalID")
                      VALUES (''SENTENCE'',
                      "SENTENCE_MERGE"."UTCOFFSET",
                      "SENTENCE_MERGE"."SENTENCEID",
                      "SENTENCE_MERGE"."CONSTRUCTID",
                      "SENTENCE_MERGE"."VERB",
                      "SENTENCE_MERGE"."DEPTH",
                      "SENTENCE_MERGE"."PARENTSENTENCE",
                      "SENTENCE_MERGE"."TIMESTAMP",
                      "SENTENCE_MERGE"."TIMESTAMPUTC",
                      ''0'', ''' || GLOBALID || ''')';
  PREPARE SMERGE FROM SENTENCEMERGE;
  EXECUTE SMERGE;

  END S1@


GRANT EXECUTE ON PROCEDURE "MY_TENANT_SCHEMA"."INSERT_SENTENCE_v1" TO USER DB2INST1 WITH GRANT OPTION@


DROP PROCEDURE "MY_TENANT_SCHEMA"."INSERT_SESSION"@
-- **************************************************************
--
-- IBM Confidential
--
-- OCO Source Materials
--
-- 5737-L66
--
-- (C) Copyright IBM Corp. 2020
--
-- The source code for this program is not published or otherwise
-- divested of its trade secrets, irrespective of what has been
-- deposited with the U.S. Copyright Office.
--
-- **************************************************************

CREATE OR REPLACE PROCEDURE "MY_TENANT_SCHEMA"."INSERT_SESSION" (
    IN TNT_ID VARCHAR(1000),
    IN FILENAME VARCHAR(1000),
    IN GLOBALID VARCHAR(1000),
    IN TABLENAME VARCHAR(1000),
    IN DB2MOUNTPOINTPATH VARCHAR(1000)

  )
LANGUAGE SQL
  S1:BEGIN
	-- GLOBAL TABLE NAME PARAMETERS
	DECLARE FILEPATH VARCHAR(1000);
    -- IF YOU GET STRANGE ERRORS, LOOK HERE FIRST!
	DECLARE CREATE_STMT VARCHAR(7000);
	DECLARE INSERT_STMT VARCHAR(7000);

  SET FILEPATH = (
  CONCAT(CONCAT(CONCAT(DB2MOUNTPOINTPATH,TNT_ID),'/'),FILENAME));
  SET CREATE_STMT = '
	CREATE EXTERNAL TABLE '||TNT_ID||'.'||TABLENAME||' (
        UTCOffset           	DOUBLE
        ,SessionId				VARCHAR(20)
        ,AccessId				VARCHAR(40)
        ,SessionStart			VARCHAR(20)
        ,SessionEnd				VARCHAR(20)
        ,DatabaseName			VARCHAR(255)
        ,UidChain				VARCHAR(500)
        ,LoginSucceeded			DECIMAL(11)
        ,DBUserName				VARCHAR(255)
        ,OSUser				    VARCHAR(255)
        ,SourceProgram			VARCHAR(255)
        ,ServerIP				VARCHAR(50)
        ,AnalyzedClientIP		VARCHAR(50)
        ,ServiceName			VARCHAR(80)
        ,ClientHostName			VARCHAR(255)
        ,ServerType				VARCHAR(30)
        ,ServerHostName			VARCHAR(255)
        ,ServerPort				VARCHAR(10)
        ,ClientPort				VARCHAR(30)
        ,NetworkProtocol		VARCHAR(20)
        ,TapIdentifier			VARCHAR(255)
        ,SessionIgnored			VARCHAR(10)
        ,SenderIP				VARCHAR(50)
        ,InactiveFlag           DECIMAL(11))
	USING (DATAOBJECT '''||FILEPATH||''' ENCODING UTF8 QUOTEDVALUE DOUBLE RequireQuotes TRUE DELIMITER '','' NULLVALUE ''\N'' escapeChar ''\'' TRUNCSTRING TRUE CtrlChars TRUE CRinString TRUE SKIPROWS 1)';
  PREPARE STMT_1 FROM CREATE_STMT;
  EXECUTE STMT_1;


SET INSERT_STMT = 'MERGE
	  INTO  "'||TNT_ID||'"."SESSION" AS "SESSION"
      USING "'||TNT_ID||'"."'||TABLENAME||'" AS "SESSION_MERGE" ("UTCOFFSET","SESSIONID","ACCESSID","SESSIONSTART","SESSIONEND","DATABASENAME","UIDCHAIN","LOGINSUCCEEDED","DBUSERNAME","OSUSER","SOURCEPROGRAM","SERVERIP","ANALYZEDCLIENTIP","SERVICENAME","CLIENTHOSTNAME","SERVERTYPE","SERVERHOSTNAME","SERVERPORT","CLIENTPORT","NETWORKPROTOCOL","TAPIDENTIFIER","SESSIONIGNORED","SENDERIP","INACTIVEFLAG")
      ON(
        "SESSION"."SessionID" = CAST("SESSION_MERGE"."SESSIONID" AS DECIMAL(20)) AND
        "SESSION"."ConfigID"  = ''0'' AND
        "SESSION"."GlobalID"  = '''||GLOBALID||'''
        )
    WHEN MATCHED THEN
        UPDATE SET
            "SESSION"."ClientID" = "SESSION_MERGE"."ANALYZEDCLIENTIP",
            "SESSION"."NetworkProtocol" = "SESSION_MERGE"."NETWORKPROTOCOL",
            "SESSION"."DBUserName" = "SESSION_MERGE"."DBUSERNAME",
            "SESSION"."OSUser" = "SESSION_MERGE"."OSUSER",
            "SESSION"."SourceProgram" = "SESSION_MERGE"."SOURCEPROGRAM",
            "SESSION"."ClientHostName" = "SESSION_MERGE"."CLIENTHOSTNAME",
            "SESSION"."ServerHostName" = "SESSION_MERGE"."SERVERHOSTNAME",
            "SESSION"."ServiceName" = "SESSION_MERGE"."SERVICENAME",
            "SESSION"."DatabaseName" = "SESSION_MERGE"."DATABASENAME",
            "SESSION"."SessionStart" = CASE WHEN "SESSION_MERGE"."SESSIONSTART" IS NULL THEN NULL ELSE TO_TIMESTAMP(REPLACE(REPLACE("SESSION_MERGE"."SESSIONSTART",''T'','' ''),''Z'',''''),''YYYY-MM-DD HH24:MI:SS'') END,
            "SESSION"."SessionStartUTC" = CASE WHEN "SESSION_MERGE"."SESSIONSTART" IS NULL THEN NULL ELSE ADD_HOURS(TO_TIMESTAMP(REPLACE(REPLACE("SESSION_MERGE"."SESSIONSTART",''T'','' ''),''Z'',''''),''YYYY-MM-DD HH24:MI:SS''), -("SESSION_MERGE"."UTCOFFSET")) END,
            "SESSION"."SessionEnd" =  CASE WHEN "SESSION_MERGE"."SESSIONEND" IS NULL THEN NULL ELSE TO_TIMESTAMP(REPLACE(REPLACE("SESSION_MERGE"."SESSIONEND",''T'','' ''),''Z'',''''),''YYYY-MM-DD HH24:MI:SS'') END,
            "SESSION"."SessionEndUTC" =  CASE WHEN "SESSION_MERGE"."SESSIONEND" IS NULL THEN NULL ELSE ADD_HOURS(TO_TIMESTAMP(REPLACE(REPLACE("SESSION_MERGE"."SESSIONEND",''T'','' ''),''Z'',''''),''YYYY-MM-DD HH24:MI:SS''), -("SESSION_MERGE"."UTCOFFSET")) END,
            "SESSION"."InactiveFlag" = CAST("SESSION_MERGE"."INACTIVEFLAG" AS DECIMAL(11)),
            "SESSION"."SessionIgnored" = CASE WHEN LOCATE(''No'',"SESSION_MERGE"."SESSIONIGNORED") >= 1 THEN 0 ELSE 1 END,
            "SESSION"."LoginSucceeded" = CAST("SESSION_MERGE"."LOGINSUCCEEDED" AS DECIMAL(11))
    WHEN NOT MATCHED THEN
        INSERT ("MessageType","ID","SessionID","DatabaseType","ServerOS","ClientOS","ServerID","ClientID","NetworkProtocol","DBProtocol","DBProtocolVersion","DBUserName","OSUser","SourceProgram","ClientHostName","ServerHostName","ServiceName","KeyValue","DatabaseName","ClientPort","ServerPort","SourceID","UTCOffset","OldSessionID","SessionStart","SessionStartUTC","SessionEnd","SessionEndUTC","TTL","SessionInfo","InactiveFlag","SessionIgnored","IgnoreSince","IgnoreSinceUTC","UIDChain","UIDChainCompressed","FailOverFlag","FailoverTimestamp","FailoverTimestampUTC","Mills","RequiredUIDChainFromParent","LoginSucceeded","SenderIP","SessionKey","CharEncoding","TapIdentifier","AccessID","ServerIP","ServerType","ConfigID","GlobalID")
        VALUES (
            ''SESSION'',
            NULL,
            "SESSION_MERGE"."SESSIONID",
            NULL,
            NULL,
            NULL,
            NULL,
            "SESSION_MERGE"."ANALYZEDCLIENTIP",
            "SESSION_MERGE"."NETWORKPROTOCOL",
            NULL,
            NULL,
            "SESSION_MERGE"."DBUSERNAME",
            "SESSION_MERGE"."OSUSER",
            "SESSION_MERGE"."SOURCEPROGRAM",
            "SESSION_MERGE"."CLIENTHOSTNAME",
            "SESSION_MERGE"."SERVERHOSTNAME",
            "SESSION_MERGE"."SERVICENAME",
            NULL,
            "SESSION_MERGE"."DATABASENAME",
            "SESSION_MERGE"."CLIENTPORT",
            "SESSION_MERGE"."SERVERPORT",
            NULL,
            "SESSION_MERGE"."UTCOFFSET",
            NULL,
            CASE WHEN "SESSION_MERGE"."SESSIONSTART" IS NULL THEN NULL ELSE TO_TIMESTAMP(REPLACE(REPLACE("SESSION_MERGE"."SESSIONSTART",''T'','' ''),''Z'',''''),''YYYY-MM-DD HH24:MI:SS'') END,
            CASE WHEN "SESSION_MERGE"."SESSIONSTART" IS NULL THEN NULL ELSE ADD_HOURS(TO_TIMESTAMP(REPLACE(REPLACE("SESSION_MERGE"."SESSIONSTART",''T'','' ''),''Z'',''''),''YYYY-MM-DD HH24:MI:SS''), -("SESSION_MERGE"."UTCOFFSET")) END,
            CASE WHEN "SESSION_MERGE"."SESSIONEND" IS NULL THEN NULL ELSE TO_TIMESTAMP(REPLACE(REPLACE("SESSION_MERGE"."SESSIONEND",''T'','' ''),''Z'',''''),''YYYY-MM-DD HH24:MI:SS'') END,
            CASE WHEN "SESSION_MERGE"."SESSIONEND" IS NULL THEN NULL ELSE ADD_HOURS(TO_TIMESTAMP(REPLACE(REPLACE("SESSION_MERGE"."SESSIONEND",''T'','' ''),''Z'',''''),''YYYY-MM-DD HH24:MI:SS''), -("SESSION_MERGE"."UTCOFFSET")) END,
            NULL,
            NULL,
            "SESSION_MERGE"."INACTIVEFLAG",
            CASE WHEN LOCATE(''No'',"SESSION_MERGE"."SESSIONIGNORED") >= 1 THEN 0 ELSE 1 END,
            NULL,
            NULL,
            "SESSION_MERGE"."UIDCHAIN",
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            "SESSION_MERGE"."LOGINSUCCEEDED",
            "SESSION_MERGE"."SENDERIP",
            NULL,
            NULL,
            "SESSION_MERGE"."TAPIDENTIFIER",
            "SESSION_MERGE"."ACCESSID",
            "SESSION_MERGE"."SERVERIP",
            "SESSION_MERGE"."SERVERTYPE",
            ''0'',
            '''||GLOBALID||''')';
  PREPARE STMT_2 FROM INSERT_STMT;
  EXECUTE STMT_2;
  END S1@


GRANT EXECUTE ON PROCEDURE "MY_TENANT_SCHEMA"."INSERT_SESSION" TO USER DB2INST1 WITH GRANT OPTION@


--
-- INSERT_SESSION_v1
-- 

-- **************************************************************
--
-- IBM Confidential
--
-- OCO Source Materials
--
-- 5737-L66
--
-- (C) Copyright IBM Corp. 2020
--
-- The source code for this program is not published or otherwise
-- divested of its trade secrets, irrespective of what has been
-- deposited with the U.S. Copyright Office.
--
-- **************************************************************

CREATE OR REPLACE PROCEDURE "MY_TENANT_SCHEMA"."INSERT_SESSION_v1" (
    IN TNT_ID VARCHAR(1000),
    IN FILENAME VARCHAR(1000),
    IN GLOBALID VARCHAR(1000),
    IN TABLENAME VARCHAR(1000),
    IN DB2MOUNTPOINTPATH VARCHAR(1000)

  )
LANGUAGE SQL
  S1:BEGIN
	-- GLOBAL TABLE NAME PARAMETERS
	DECLARE FILEPATH VARCHAR(1000);
    -- IF YOU GET STRANGE ERRORS, LOOK HERE FIRST!
	DECLARE CREATE_STMT VARCHAR(7000);
	DECLARE INSERT_STMT VARCHAR(7000);

  SET FILEPATH = (
  CONCAT(CONCAT(CONCAT(DB2MOUNTPOINTPATH,TNT_ID),'/'),FILENAME));
  SET CREATE_STMT = '
	CREATE EXTERNAL TABLE '||TNT_ID||'.'||TABLENAME||' (
        UTCOffset           	DOUBLE
        ,SessionId				DECIMAL(20)
        ,AccessId				VARCHAR(40)
        ,SessionStart			TIMESTAMP
        ,SessionStartUTC        TIMESTAMP
        ,SessionEnd				TIMESTAMP
        ,SessionEndUTC          TIMESTAMP
        ,DatabaseName			VARCHAR(255)
        ,UidChain				VARCHAR(500)
        ,LoginSucceeded			DECIMAL(11)
        ,DBUserName				VARCHAR(255)
        ,OSUser				    VARCHAR(255)
        ,SourceProgram			VARCHAR(255)
        ,ServerIP				VARCHAR(50)
        ,AnalyzedClientIP		VARCHAR(50)
        ,ServiceName			VARCHAR(80)
        ,ClientHostName			VARCHAR(255)
        ,ServerType				VARCHAR(30)
        ,ServerHostName			VARCHAR(255)
        ,ServerPort				VARCHAR(10)
        ,ClientPort				VARCHAR(30)
        ,NetworkProtocol		VARCHAR(20)
        ,TapIdentifier			VARCHAR(255)
        ,SessionIgnored			VARCHAR(10)
        ,SenderIP				VARCHAR(50)
        ,InactiveFlag           DECIMAL(11))
	USING (DATAOBJECT '''||FILEPATH||''' ENCODING UTF8 QUOTEDVALUE DOUBLE RequireQuotes TRUE DELIMITER ''~'' NULLVALUE ''\N'' escapeChar ''\'' TRUNCSTRING TRUE CtrlChars TRUE CRinString TRUE SKIPROWS 1)';
  PREPARE STMT_1 FROM CREATE_STMT;
  EXECUTE STMT_1;


SET INSERT_STMT = 'MERGE
	  INTO  "'||TNT_ID||'"."SESSION" AS "SESSION"
      USING "'||TNT_ID||'"."'||TABLENAME||'" AS "SESSION_MERGE" ("UTCOFFSET","SESSIONID","ACCESSID","SESSIONSTART","SESSIONSTARTUTC","SESSIONEND","SESSIONENDUTC","DATABASENAME","UIDCHAIN","LOGINSUCCEEDED","DBUSERNAME","OSUSER","SOURCEPROGRAM","SERVERIP","ANALYZEDCLIENTIP","SERVICENAME","CLIENTHOSTNAME","SERVERTYPE","SERVERHOSTNAME","SERVERPORT","CLIENTPORT","NETWORKPROTOCOL","TAPIDENTIFIER","SESSIONIGNORED","SENDERIP","INACTIVEFLAG")
      ON(
        "SESSION"."SessionID" = "SESSION_MERGE"."SESSIONID" AND
        "SESSION"."ConfigID"  = ''0'' AND
        "SESSION"."GlobalID"  = '''||GLOBALID||'''
        )
    WHEN MATCHED THEN
        UPDATE SET
            "SESSION"."ClientID" = "SESSION_MERGE"."ANALYZEDCLIENTIP",
            "SESSION"."NetworkProtocol" = "SESSION_MERGE"."NETWORKPROTOCOL",
            "SESSION"."DBUserName" = "SESSION_MERGE"."DBUSERNAME",
            "SESSION"."OSUser" = "SESSION_MERGE"."OSUSER",
            "SESSION"."SourceProgram" = "SESSION_MERGE"."SOURCEPROGRAM",
            "SESSION"."ClientHostName" = "SESSION_MERGE"."CLIENTHOSTNAME",
            "SESSION"."ServerHostName" = "SESSION_MERGE"."SERVERHOSTNAME",
            "SESSION"."ServiceName" = "SESSION_MERGE"."SERVICENAME",
            "SESSION"."DatabaseName" = "SESSION_MERGE"."DATABASENAME",
            "SESSION"."SessionStart" = "SESSION_MERGE"."SESSIONSTART",
            "SESSION"."SessionStartUTC" = "SESSION_MERGE"."SESSIONSTARTUTC",
            "SESSION"."SessionEnd" =  "SESSION_MERGE"."SESSIONEND",
            "SESSION"."SessionEndUTC" =  "SESSION_MERGE"."SESSIONENDUTC",
            "SESSION"."InactiveFlag" = "SESSION_MERGE"."INACTIVEFLAG",
            "SESSION"."SessionIgnored" = "SESSION_MERGE"."SESSIONIGNORED",
            "SESSION"."LoginSucceeded" = "SESSION_MERGE"."LOGINSUCCEEDED"
    WHEN NOT MATCHED THEN
        INSERT ("MessageType","ID","SessionID","DatabaseType","ServerOS","ClientOS","ServerID","ClientID","NetworkProtocol","DBProtocol","DBProtocolVersion","DBUserName","OSUser","SourceProgram","ClientHostName","ServerHostName","ServiceName","KeyValue","DatabaseName","ClientPort","ServerPort","SourceID","UTCOffset","OldSessionID","SessionStart","SessionStartUTC","SessionEnd","SessionEndUTC","TTL","SessionInfo","InactiveFlag","SessionIgnored","IgnoreSince","IgnoreSinceUTC","UIDChain","UIDChainCompressed","FailOverFlag","FailoverTimestamp","FailoverTimestampUTC","Mills","RequiredUIDChainFromParent","LoginSucceeded","SenderIP","SessionKey","CharEncoding","TapIdentifier","AccessID","ServerIP","ServerType","ConfigID","GlobalID")
        VALUES (
            ''SESSION'',
            NULL,
            "SESSION_MERGE"."SESSIONID",
            NULL,
            NULL,
            NULL,
            NULL,
            "SESSION_MERGE"."ANALYZEDCLIENTIP",
            "SESSION_MERGE"."NETWORKPROTOCOL",
            NULL,
            NULL,
            "SESSION_MERGE"."DBUSERNAME",
            "SESSION_MERGE"."OSUSER",
            "SESSION_MERGE"."SOURCEPROGRAM",
            "SESSION_MERGE"."CLIENTHOSTNAME",
            "SESSION_MERGE"."SERVERHOSTNAME",
            "SESSION_MERGE"."SERVICENAME",
            NULL,
            "SESSION_MERGE"."DATABASENAME",
            "SESSION_MERGE"."CLIENTPORT",
            "SESSION_MERGE"."SERVERPORT",
            NULL,
            "SESSION_MERGE"."UTCOFFSET",
            NULL,
            "SESSION_MERGE"."SESSIONSTART",
            "SESSION_MERGE"."SESSIONSTARTUTC",
            "SESSION_MERGE"."SESSIONEND",
            "SESSION_MERGE"."SESSIONENDUTC",
            NULL,
            NULL,
            "SESSION_MERGE"."INACTIVEFLAG",
            "SESSION_MERGE"."SESSIONIGNORED",
            NULL,
            NULL,
            "SESSION_MERGE"."UIDCHAIN",
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            "SESSION_MERGE"."LOGINSUCCEEDED",
            "SESSION_MERGE"."SENDERIP",
            NULL,
            NULL,
            "SESSION_MERGE"."TAPIDENTIFIER",
            "SESSION_MERGE"."ACCESSID",
            "SESSION_MERGE"."SERVERIP",
            "SESSION_MERGE"."SERVERTYPE",
            ''0'',
            '''||GLOBALID||''')';
  PREPARE STMT_2 FROM INSERT_STMT;
  EXECUTE STMT_2;
  END S1@


GRANT EXECUTE ON PROCEDURE "MY_TENANT_SCHEMA"."INSERT_SESSION_v1" TO USER DB2INST1 WITH GRANT OPTION@



CREATE OR REPLACE PROCEDURE "MY_TENANT_SCHEMA"."INSERT_VA_v1" (
    IN TNT_ID VARCHAR(1000),
    IN FILENAME VARCHAR(1000),
    IN GLOBALID VARCHAR(1000),
    IN TABLENAME VARCHAR(1000),
    IN DB2MOUNTPOINTPATH VARCHAR(1000)
)
LANGUAGE SQL
S1:BEGIN
	-- GLOBAL TABLE NAME PARAMETERS
	DECLARE FILEPATH VARCHAR(1000);
	DECLARE CREATE_STMT VARCHAR(5000);
	DECLARE INSERT_STMT VARCHAR(5000);

    SET FILEPATH = (CONCAT(CONCAT(CONCAT(DB2MOUNTPOINTPATH,TNT_ID),'/'),FILENAME));

    -- CREATE AN EXTERNAL TABLE FOR THE CSV
    SET CREATE_STMT = '
	CREATE EXTERNAL TABLE '||TNT_ID||'.'||TABLENAME||' (
    UTCOffset   FLOAT,
    TestResultID DECIMAL(20),
    DataSourceName VARCHAR(255),
    DataSourceType VARCHAR(50),
    DBName VARCHAR(255),
    VersionLevel VARCHAR(255),
    PatchLevel VARCHAR(255),
    FullVersionInfo VARCHAR(32000),
    Description VARCHAR(255),
    Host VARCHAR(255),
    TestDescription VARCHAR(150),
    TestScore DECIMAL(11),
    ScoreDescription VARCHAR(255),
    ResultText VARCHAR(32000),
    Recommendation VARCHAR(32000),
    Severity VARCHAR(60),
    Category VARCHAR(60),
    ExecutionDate TIMESTAMP,
    ExecutionDateUTC TIMESTAMP,
    AssessmentDescription VARCHAR(150),
    ServiceName VARCHAR(255),
    Port DECIMAL(11),
    DataSourceID DECIMAL(11),
    ResultDetails VARCHAR(32000))
	USING (DATAOBJECT '''||FILEPATH||''' ENCODING UTF8 QUOTEDVALUE DOUBLE RequireQuotes TRUE DELIMITER ''~'' NULLVALUE ''\N'' escapeChar ''\'' TRUNCSTRING TRUE CtrlChars TRUE CRinString TRUE SKIPROWS 1)';
    PREPARE STMT_1 FROM CREATE_STMT;
    EXECUTE STMT_1;

    SET INSERT_STMT = 'INSERT
	INTO  "'||TNT_ID||'"."VULNERABILITY_ASSESSMENT" ("MessageType", "UTCOffset", "TestResultID", "DataSourceName", "DataSourceType", "DBName", "VersionLevel", "PatchLevel", "FullVersionInfo", "Description", "Host", "TestDescription", "TestScore", "ScoreDescription", "ResultText", "Recommendation", "Severity", "Category", "ExecutionDate", "ExecutionDateUTC", "AssessmentDescription", "ServiceName", "Port", "DataSourceID", "ResultDetails", "ConfigID", "GlobalID")
	SELECT
        ''VULNERABILITY_ASSESSMENT'',
        UTCOffset,
        TestResultID,
        DataSourceName,
        DataSourceType,
        DBName,
        VersionLevel,
        PatchLevel,
        FullVersionInfo,
        Description,
        Host,
        TestDescription,
        TestScore,
        ScoreDescription,
        ResultText,
        Recommendation,
        Severity,
        Category,
        ExecutionDate,
        ExecutionDateUTC,
        AssessmentDescription,
        ServiceName,
        Port,
        DataSourceID,
        ResultDetails,
        ''0'',
        '''||GLOBALID||'''
    FROM
        "'||TNT_ID||'"."'||TABLENAME||'";';
    PREPARE STMT_2 FROM INSERT_STMT;
    EXECUTE STMT_2;
    END S1@


GRANT EXECUTE ON PROCEDURE "MY_TENANT_SCHEMA"."INSERT_VA_v1" TO USER DB2INST1 WITH GRANT OPTION@


CREATE VIEW "MY_TENANT_SCHEMA"."ACTIVITY_DATA" ("MessageType_FULL_SQL", "ID_FULL_SQL", "FullSQLID_FULL_SQL", "SessionID_FULL_SQL", "Timestamp_FULL_SQL", "TimestampUTC_FULL_SQL", "UTCOffset_FULL_SQL", "InstanceID_FULL_SQL", "AccessRuleDescription_FULL_SQL", "FullStatement_FULL_SQL", "TotalRecordsAffected_FULL_SQL", "Succeeded_FULL_SQL", "Status_FULL_SQL", "ResponseTime_FULL_SQL", "ACKResponseTime_FULL_SQL", "ConfigID_FULL_SQL", "GlobalID_FULL_SQL", "TenantID_FULL_SQL", "IngestTimestamp_FULL_SQL", "SQLSequenceInRequest_FULL_SQL", "MessageType_INSTANCE", "ID_INSTANCE", "InstanceID_INSTANCE", "SessionID_INSTANCE", "UTCOffset_INSTANCE", "PeriodStart_INSTANCE", "PeriodStartUTC_INSTANCE", "PeriodEnd_INSTANCE", "PeriodEndUTC_INSTANCE", "ApplicationEventID_INSTANCE", "AppUserName_INSTANCE", "ApplicationEventType_INSTANCE", "ApplicationEventValueStr_INSTANCE", "ApplicationEventValueNum_INSTANCE", "ApplicationEventDate_INSTANCE", "ApplicationEventDateUTC_INSTANCE", "ConstructID_INSTANCE", "OriginalSQL_INSTANCE", "ObjectsandVerbs_INSTANCE", "SuccessfulSqls_INSTANCE", "FailedSqls_INSTANCE", "DBUserName_INSTANCE", "OSUser_INSTANCE", "SourceProgram_INSTANCE", "ServerIP_INSTANCE", "ClientID_INSTANCE", "ServiceName_INSTANCE", "ClientHostName_INSTANCE", "ServerType_INSTANCE", "DatabaseName_INSTANCE", "EventUserName_INSTANCE", "ServerPort_INSTANCE", "NetworkProtocol_INSTANCE", "TotalRecordsAffected_INSTANCE", "ServerHostName_INSTANCE", "Timestamp_INSTANCE", "TimestampUTC_INSTANCE", "AverageExecutionTime_INSTANCE", "ConfigID_INSTANCE", "GlobalID_INSTANCE", "TenantID_INSTANCE", "IngestTimestamp_INSTANCE", "MessageType_SESSION", "ID_SESSION", "SessionID_SESSION", "DatabaseType_SESSION", "ServerOS_SESSION", "ClientOS_SESSION", "ServerID_SESSION", "ClientID_SESSION", "NetworkProtocol_SESSION", "DBProtocol_SESSION", "DBProtocolVersion_SESSION", "DBUserName_SESSION", "OSUser_SESSION", "SourceProgram_SESSION", "ClientHostName_SESSION", "ServerHostName_SESSION", "ServiceName_SESSION", "KeyValue_SESSION", "DatabaseName_SESSION", "ClientPort_SESSION", "ServerPort_SESSION", "SourceID_SESSION", "UTCOffset_SESSION", "OldSessionID_SESSION", "SessionStart_SESSION", "SessionStartUTC_SESSION", "SessionEnd_SESSION", "SessionEndUTC_SESSION", "TTL_SESSION", "SessionInfo_SESSION", "InactiveFlag_SESSION", "SessionIgnored_SESSION", "IgnoreSince_SESSION", "IgnoreSinceUTC_SESSION", "UIDChain_SESSION", "UIDChainCompressed_SESSION", "FailOverFlag_SESSION", "FailoverTimestamp_SESSION", "FailoverTimestampUTC_SESSION", "Mills_SESSION", "RequiredUIDChainFromParent_SESSION", "LoginSucceeded_SESSION", "SenderIP_SESSION", "SessionKey_SESSION", "CharEncoding_SESSION", "TapIdentifier_SESSION", "AccessID_SESSION", "ServerIP_SESSION", "ServerType_SESSION", "ConfigID_SESSION", "GlobalID_SESSION", "TenantID_SESSION", "IngestTimestamp_SESSION") AS SELECT "a"."MessageType", "a"."ID", "a"."FullSQLID", "a"."SessionID", "a"."Timestamp", "a"."TimestampUTC", "a"."UTCOffset", "a"."InstanceID", "a"."AccessRuleDescription", "a"."FullStatement", "a"."TotalRecordsAffected", "a"."Succeeded", "a"."Status", "a"."ResponseTime", "a"."ACKResponseTime", "a"."ConfigID", "a"."GlobalID", "a"."TenantID", "a"."IngestTimestamp", "a"."SQLSequenceInRequest", "b"."MessageType", "b"."ID", "b"."InstanceID", "b"."SessionID", "b"."UTCOffset", "b"."PeriodStart", "b"."PeriodStartUTC", "b"."PeriodEnd", "b"."PeriodEndUTC", "b"."ApplicationEventID", "b"."AppUserName", "b"."ApplicationEventType", "b"."ApplicationEventValueStr", "b"."ApplicationEventValueNum", "b"."ApplicationEventDate", "b"."ApplicationEventDateUTC", "b"."ConstructID", "b"."OriginalSQL", "b"."ObjectsandVerbs", "b"."SuccessfulSqls", "b"."FailedSqls", "b"."DBUserName", "b"."OSUser", "b"."SourceProgram", "b"."ServerIP", "b"."ClientID", "b"."ServiceName", "b"."ClientHostName", "b"."ServerType", "b"."DatabaseName", "b"."EventUserName", "b"."ServerPort", "b"."NetworkProtocol", "b"."TotalRecordsAffected", "b"."ServerHostName", "b"."Timestamp", "b"."TimestampUTC", "b"."AverageExecutionTime", "b"."ConfigID", "b"."GlobalID", "b"."TenantID", "b"."IngestTimestamp", "c"."MessageType", "c"."ID", "c"."SessionID", "c"."DatabaseType", "c"."ServerOS", "c"."ClientOS", "c"."ServerID", "c"."ClientID", "c"."NetworkProtocol", "c"."DBProtocol", "c"."DBProtocolVersion", "c"."DBUserName", "c"."OSUser", "c"."SourceProgram", "c"."ClientHostName", "c"."ServerHostName", "c"."ServiceName", "c"."KeyValue", "c"."DatabaseName", "c"."ClientPort", "c"."ServerPort", "c"."SourceID", "c"."UTCOffset", "c"."OldSessionID", "c"."SessionStart", "c"."SessionStartUTC", "c"."SessionEnd", "c"."SessionEndUTC", "c"."TTL", "c"."SessionInfo", "c"."InactiveFlag", "c"."SessionIgnored", "c"."IgnoreSince", "c"."IgnoreSinceUTC", "c"."UIDChain", "c"."UIDChainCompressed", "c"."FailOverFlag", "c"."FailoverTimestamp", "c"."FailoverTimestampUTC", "c"."Mills", "c"."RequiredUIDChainFromParent", "c"."LoginSucceeded", "c"."SenderIP", "c"."SessionKey", "c"."CharEncoding", "c"."TapIdentifier", "c"."AccessID", "c"."ServerIP", "c"."ServerType", "c"."ConfigID", "c"."GlobalID", "c"."TenantID", "c"."IngestTimestamp" FROM "MY_TENANT_SCHEMA"."FULL_SQL" "a" FULL OUTER JOIN "MY_TENANT_SCHEMA"."INSTANCE" "b" ON "a"."SessionID" = "b"."SessionID" FULL OUTER JOIN "MY_TENANT_SCHEMA"."SESSION" "c" ON "b"."SessionID" = "c"."SessionID"@


GRANT CONTROL ON "MY_TENANT_SCHEMA"."ACTIVITY_DATA" TO USER DB2INST1@
GRANT SELECT ON "MY_TENANT_SCHEMA"."ACTIVITY_DATA" TO USER DB2INST1 WITH GRANT OPTION@


CREATE VIEW "MY_TENANT_SCHEMA"."EXCEPTION_DATA" ("MessageType", "ID", "ExceptionTypeID", "ExceptionID", "UserName", "SourceAddress", "DestinationAddress", "DBProtocol", "AppUserName", "ExceptionDescription", "SQLStatement", "ErrorCause", "ErrorCode", "Timestamp", "TimestampUTC", "SessionID", "InformationLink", "UTCOffset", "Count", "SourceID", "ConfigID", "GlobalID", "TenantID", "IngestTimestamp") AS SELECT "MessageType", "ID", "ExceptionTypeID", "ExceptionID", "UserName", "SourceAddress", "DestinationAddress", "DBProtocol", "AppUserName", "ExceptionDescription", "SQLStatement", "ErrorCause", "ErrorCode", "Timestamp", "TimestampUTC", "SessionID", "InformationLink", "UTCOffset", "Count", "SourceID", "ConfigID", "GlobalID", "TenantID", "IngestTimestamp" FROM "MY_TENANT_SCHEMA"."EXCEPTION"@


GRANT CONTROL ON "MY_TENANT_SCHEMA"."EXCEPTION_DATA" TO USER DB2INST1@
GRANT SELECT ON "MY_TENANT_SCHEMA"."EXCEPTION_DATA" TO USER DB2INST1 WITH GRANT OPTION@
GRANT UPDATE ON "MY_TENANT_SCHEMA"."EXCEPTION_DATA" TO USER DB2INST1 WITH GRANT OPTION@
GRANT INSERT ON "MY_TENANT_SCHEMA"."EXCEPTION_DATA" TO USER DB2INST1 WITH GRANT OPTION@
GRANT DELETE ON "MY_TENANT_SCHEMA"."EXCEPTION_DATA" TO USER DB2INST1 WITH GRANT OPTION@


CREATE VIEW "MY_TENANT_SCHEMA"."POLICY_VIOLATION_DATA" ("MessageType", "ID", "ViolationID", "SessionID", "UTCOffset", "OSUser", "DBUserName", "ClientID", "ClientHostName", "SourceProgram", "ServerIP", "ServerType", "ServiceName", "ConstructID", "ObjectsandVerbs", "AppUserName", "AccessRuleID", "AccessRuleDescription", "Verdict", "FullSQL", "SendMessage", "CurrentCounter", "KeyString", "CategoryName", "ClassificationName", "Severity", "PolicyDescription", "Timestamp", "TimestampUTC", "ServerHostName", "ConfigID", "GlobalID", "TenantID", "IngestTimestamp") AS SELECT "MessageType", "ID", "ViolationID", "SessionID", "UTCOffset", "OSUser", "DBUserName", "ClientID", "ClientHostName", "SourceProgram", "ServerIP", "ServerType", "ServiceName", "ConstructID", "ObjectsandVerbs", "AppUserName", "AccessRuleID", "AccessRuleDescription", "Verdict", "FullSQL", "SendMessage", "CurrentCounter", "KeyString", "CategoryName", "ClassificationName", "Severity", "PolicyDescription", "Timestamp", "TimestampUTC", "ServerHostName", "ConfigID", "GlobalID", "TenantID", "IngestTimestamp" FROM "MY_TENANT_SCHEMA"."POLICY_VIOLATION"@


GRANT CONTROL ON "MY_TENANT_SCHEMA"."POLICY_VIOLATION_DATA" TO USER DB2INST1@
GRANT SELECT ON "MY_TENANT_SCHEMA"."POLICY_VIOLATION_DATA" TO USER DB2INST1 WITH GRANT OPTION@
GRANT UPDATE ON "MY_TENANT_SCHEMA"."POLICY_VIOLATION_DATA" TO USER DB2INST1 WITH GRANT OPTION@
GRANT INSERT ON "MY_TENANT_SCHEMA"."POLICY_VIOLATION_DATA" TO USER DB2INST1 WITH GRANT OPTION@
GRANT DELETE ON "MY_TENANT_SCHEMA"."POLICY_VIOLATION_DATA" TO USER DB2INST1 WITH GRANT OPTION@

