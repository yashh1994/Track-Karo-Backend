from dotenv import load_dotenv
import os



load_dotenv(dotenv_path='./sam.env')

PG_DB_URL = os.getenv('yash')

print("This is the url: ", PG_DB_URL)


