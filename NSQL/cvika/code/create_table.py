import psycopg2

def create_table():
    conn = psycopg2.connect(
        dbname="your_db",
        user="your_user",
        password="your_pass",
        host="db",  # The container name of the PostgreSQL service
        port="5432"  # Ensure the correct port is specified
    )
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS recipes (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            ingredients TEXT NOT NULL,
            instructions TEXT NOT NULL
        );
    """)
    conn.commit()
    cursor.close()
    conn.close()
    print("Table created successfully")

if __name__ == '__main__':
    create_table()
