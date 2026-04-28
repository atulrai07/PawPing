import psycopg2
import sys

conn_str = "postgresql://postgres:Pawping@team16@db.xvehkasclpwlihskjrhb.supabase.co:5432/postgres"

try:
    conn = psycopg2.connect(conn_str)
    cur = conn.cursor()
    
    print("Updating schema...")
    cur.execute("ALTER TABLE vaccines ADD COLUMN IF NOT EXISTS type text DEFAULT 'vaccine';")
    cur.execute("ALTER TABLE vaccines ADD COLUMN IF NOT EXISTS vet_name text;")
    cur.execute("ALTER TABLE vaccines ADD COLUMN IF NOT EXISTS vet_address text;")
    cur.execute("ALTER TABLE vaccines ADD COLUMN IF NOT EXISTS vet_phone text;")
    cur.execute("ALTER TABLE vaccines ADD COLUMN IF NOT EXISTS vet_latitude double precision;")
    cur.execute("ALTER TABLE vaccines ADD COLUMN IF NOT EXISTS vet_longitude double precision;")
    
    conn.commit()
    print("Schema updated successfully.")
    
    # Check RLS
    cur.execute("SELECT tablename, policyname, permissive, roles, cmd, qual, with_check FROM pg_policies WHERE tablename = 'vaccines';")
    policies = cur.fetchall()
    print("\nRLS Policies for 'vaccines':")
    for p in policies:
        print(f"  {p[1]} (Cmd: {p[4]})")
        
    cur.close()
    conn.close()
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
