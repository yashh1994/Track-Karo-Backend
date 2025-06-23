import psycopg2
from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from orms import  Base, Bus, Driver, Organization, Route, Student
from new_orm_desing import Base

# Load environment variables
load_dotenv(dotenv_path='./pro.env')

# Get the database URL from the environment variable
PG_DB_URL = os.getenv('NEW_SUPABASE_PG_DATABASE_URL')

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


def initialize_table():
    print("This is the url ---------- ",PG_DB_URL)
    engine = create_engine(PG_DB_URL)
    Base.metadata.create_all(engine)

    Session = sessionmaker(bind=engine)

    print("-- TABLES are created ------")

# Call the function to check the connection
# check_database_connection()
initialize_table()