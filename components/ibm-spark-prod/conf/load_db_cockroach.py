import psycopg2
import sys

def closeConnection(cursor, connection):
    cursor.close()
    connection.commit()
    connection.close()
    print("Cockroach DB connection is closed")

def upgrade_sql(version):
    switcher={
        0:'',
        1:'ALTER TABLE INSTANCE_MANAGER ADD COLUMN cpu_quota INT, ADD COLUMN memory_quota TEXT, ADD COLUMN avail_cpu_quota INT, ADD COLUMN avail_memory_quota TEXT; ALTER TABLE JOB ADD COLUMN resources_updated BOOLEAN;',
        2:'ALTER TABLE INSTANCE_MANAGER ADD COLUMN context_type TEXT, ADD COLUMN context_id TEXT, ADD COLUMN spark_confs jsonb;',
        3:'ALTER TABLE DATAPLANE_MANAGER ADD COLUMN additional_details jsonb;',
        4:'ALTER TABLE DEPLOY_REQUEST ADD COLUMN runtime_id TEXT;',
        5:'ALTER TABLE DEPLOYMENT ADD COLUMN deployer_type TEXT; ALTER TABLE INSTANCE_MANAGER ADD COLUMN job_def_id VARCHAR (512); ALTER TABLE JOB ADD COLUMN context_type TEXT, ADD COLUMN context_id TEXT, ADD COLUMN job_def_id TEXT, ADD COLUMN job_run_id TEXT; ALTER TABLE SERVICE_PROVIDER ADD COLUMN space_id STRING, ADD COLUMN job_def_id STRING;'
    }
    return switcher.get(version)

def checkIfUpgrade(url, version):
    try:
       #print ("About to make a connection")
       connection = psycopg2.connect(url)
       print ("Zen metastore connection obtained")
       cursor = connection.cursor()
       sql="set database=spark;show tables;"
       cursor.execute(sql)
       row_count = cursor.rowcount
       row = cursor.fetchall()
       if row_count != 0 and ("db_version",) not in row:
           print("db_version table not present")
           current_version=0
       elif row_count != 0 and ("db_version",) in row:
           print("db_version table present")
           cursor.execute("SELECT * from DB_VERSION")
           current_version=cursor.fetchone()[0]
       else:
           current_version=version
    except (Exception, psycopg2.Error) as error :
        print ("Error while connecting to Cockroach DB", error)
        raise Exception('Error executing sql')
        exit(1)
    finally:
        if(connection):
            closeConnection(cursor, connection)
        return current_version

def load_db(url, sql_file):
    try:
       #print ("About to make a connection")
       connection = psycopg2.connect(url)
       print ("Zen metastore connection obtained")
       cursor = connection.cursor()
       cursor.execute(open(sql_file, "r").read())
       print (" sql execution completed")
    except (Exception, psycopg2.Error) as error :
        print ("Error while connecting to Cockroach DB", error)
        raise Exception('Error executing sql')
        exit(1)
    finally:
        if(connection):
            closeConnection(cursor, connection)


def upgrade(url,current_version, version):
    try:
       #print ("About to make a connection")
       connection = psycopg2.connect(url)
       print ("Zen metastore connection obtained")
       cursor = connection.cursor()
       rows = cursor.execute("SELECT * from DB_VERSION")
       row_count = cursor.rowcount
       if row_count == 0:
           print("Version table is empty")
           sql="INSERT into DB_VERSION VALUES(%d)" % (current_version)
           cursor.execute(sql)
           print (" sql execution completed")
       else:
           print("Version table not empty, take current version from table.")
           current_version=cursor.fetchone()[0]
           print(current_version)

       closeConnection(cursor, connection)

       connection = psycopg2.connect(url)
       print ("Zen metastore connection obtained")
       cursor = connection.cursor()
       if current_version<version:
           print("upgrade here")
           for x in range(current_version+1, version+1):
               cursor.execute(upgrade_sql(x))
           sql="UPDATE DB_VERSION SET version=(%d)" % (version)
           cursor.execute(sql)
       else:
           print("do not upgrade")
    except (Exception, psycopg2.Error) as error :
        print ("Error while connecting to Cockroach DB", error)
        raise Exception('Error executing sql')
        exit(1)
    finally:
        if(connection):
            closeConnection(cursor, connection)


if __name__ == "__main__":
    if len (sys.argv) < 4 :
        print("Error : missing one or more arguments")
        print("Usage : python {0} <db_url> <sql_filename> <db_version>".format(sys.argv[0]))
        exit(1)
    else:
        db_url = sys.argv[1]
        sql_file = sys.argv[2]
        version = int(sys.argv[3])
    try:
        current_version=checkIfUpgrade(db_url,version)
        load_db(db_url, sql_file)
        upgrade(db_url, current_version, version)
        exit(0)
    except Exception, err:
        sys.stderr.write('ERROR: %sn' % str(err))
        exit(1)

