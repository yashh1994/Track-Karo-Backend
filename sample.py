from dotenv import load_dotenv
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from orms import Base, Route, Organization, Driver, Bus

load_dotenv()

PG_DB_URL = os.getenv('PG_DATABASE_URL')

engine = create_engine(PG_DB_URL)
Base.metadata.create_all(engine)

Session = sessionmaker(bind=engine)

session = Session() 

new_organization = Organization(
    email='sample@gmail.com',
    password='password',
    institute_name='Sample Institute'
)
session.add(new_organization)
session.commit()

