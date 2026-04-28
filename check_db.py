import psycopg2
import sys

conn_str = "postgresql://postgres:Pawping@team16@db.xvehkasclpwlihskjrhb.supabase.co:5432/postgres"

try:
    conn = psycopg2.connect(conn_str)
    cur = conn.cursor()
    
    # Check table structure
    cur.execute("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'vaccines';")
    columns = cur.fetchall()
    print("Columns in 'vaccines' table:")
    for col in columns:
        print(f"  {col[0]} ({col[1]})")
    
    # Check sample data
    cur.execute("SELECT * FROM vaccines LIMIT 5;")
    rows = cur.fetchall()
    print("\nSample rows:")
    for row in rows:
        print(row)
        
    cur.close()
    conn.close()
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
