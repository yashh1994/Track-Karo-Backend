import psycopg2
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv(dotenv_path='./pro.env')

# Get the database URL from the environment variable
PG_DB_URL = os.getenv('SUPABASE_PG_DATABASE_URL')

def check_database_connection():
    try:
        # Establish a connection to the database
        connection = psycopg2.connect(PG_DB_URL)
        cursor = connection.cursor()
        
        # Execute a simple query to check the connection
        cursor.execute("SELECT 1;")
        result = cursor.fetchone()
        
        if result:
            print("Database connection successful!")
        else:
            print("Database connection failed!")
        
        # Close the cursor and connection
        cursor.close()
        connection.close()
    except Exception as e:
        print("Error while connecting to the database:", e)

# Call the function to check the connection
check_database_connection()
