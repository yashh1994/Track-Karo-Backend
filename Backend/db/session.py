from sqlalchemy.ext.declarative import declarative_base
from dotenv import load_dotenv
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
load_dotenv(dotenv_path='./pro.env')

Base = declarative_base()



PG_DB_URL = os.getenv('SUPABASE_PG_DATABASE_URL')
print("This is the url ---------- ",PG_DB_URL)
engine = create_engine(PG_DB_URL)
Base.metadata.drop_all(engine)
Base.metadata.create_all(engine)

Session = sessionmaker(bind=engine)
