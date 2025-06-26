import psycopg2
from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from orms import  Base, Bus, Driver, Organization, Route, Student
from Model.orm_models import Base
from sqlalchemy import text
import google.generativeai as genai


# Load environment variables
load_dotenv(dotenv_path='./pro.env')

# Get the database URL from the environment variable
PG_DB_URL = os.getenv('NEW_SUPABASE_PG_DATABASE_URL')

# Replace with your API key
genai.configure(api_key="AIzaSyBkJB0HKjs46sAqXr62WLHxXezTPiO8iuY")

# Choose the model you want to use (from list_models output)

# Create a chat session

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


def delete_create_table():
    engine = create_engine(PG_DB_URL)

    with engine.connect() as conn:
        conn.execute(text("DROP TABLE IF EXISTS \"BusAssignment\" CASCADE"))
        conn.execute(text("DROP TABLE IF EXISTS \"Student\" CASCADE"))
        conn.commit()

    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)

    Session = sessionmaker(bind=engine)

    print("-- TABLES are created ------")


def is_gemini_model_working():

    model = genai.GenerativeModel('gemini-2.0-flash-lite')  # or 'gemini-1.0-pro'

    chat = model.start_chat()

    print("🤖 Gemini Chatbot is ready! Type 'exit' to quit.\n")
    user_input="hey introduce yourself"
    # Chat loop
    response = chat.send_message(user_input)
    print(f"Gemini: {response.text}\n")








# Call the function to check the connection
# check_database_connection()
# delete_create_table()