from sqlalchemy import Column, Integer, String, ForeignKey, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.dialects.postgresql import ARRAY,JSONB
from sqlalchemy.orm import relationship
from flask_cors import CORS
from dotenv import load_dotenv
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
load_dotenv(dotenv_path='./pro.env')


# Base = declarative_base()


# PG_DB_URL = os.getenv('SUPABASE_PG_DATABASE_URL')
# print("This is the url ---------- ",PG_DB_URL)
# engine = create_engine(PG_DB_URL)
# Base.metadata.create_all(engine)

# Session = sessionmaker(bind=engine)



class Organization(Base):
    __tablename__ = 'Organization'

    id = Column(Integer, primary_key=True)
    email = Column(String, unique=True, nullable=False)
    password = Column(String, nullable=False)
    institute_name = Column(String, nullable=True)

    routes = relationship("Route", back_populates="organization", cascade="all, delete-orphan")
    buses = relationship("Bus", back_populates="organization", cascade="all, delete-orphan")
    drivers = relationship("Driver", back_populates="organization", cascade="all, delete-orphan")
    students = relationship("Student", back_populates="organization", cascade="all, delete-orphan")


    def __init__(self, email, password, institute_name):
        self.email = email
        self.password = password
        self.institute_name = institute_name


class BusAssignment(Base):
    __tablename__ = 'BusAssignment'

    id = Column(Integer, primary_key=True)
    bus_id = Column(Integer, ForeignKey('Bus.id'), nullable=False)
    route_id = Column(Integer, ForeignKey('Route.id'), nullable=False)
    shift = Column(String, nullable=False)  # e.g., 'Morning', 'Evening', 'Night'
    time = Column(String, nullable=False) 
    
    student_id = Column(Integer, ForeignKey('Student.id'),nullable=True)
    driver_id = Column(Integer, ForeignKey('Driver.id'), nullable=True)

    bus = relationship("Bus", back_populates="assignments")
    route = relationship("Route",back_populates="assignments")
    driver = relationship("Driver",back_populates="assignments")
    student = relationship("Student", back_populates="assignments")

    organization_id = Column(Integer, ForeignKey('Organization.id'), nullable=False)
    organization = relationship("Organization", back_populates="assignments")


    def __init__(self, organization_id,bus_id, route_id, shift, time, student_id=None, driver_id=None):
        self.organization_id = organization_id
        self.bus_id = bus_id
        self.route_id = route_id
        self.shift = shift
        self.time = time
        self.student_id = student_id
        self.driver_id = driver_id
    
    def assign_driver(self,driver_id):
        self.driver_id = driver_id
    
    def assign_student(self,student_id):
        self.student_id = student_id

    def __repr__(self):
        bus_number = self.bus.bus_number if self.bus else "N/A"
        route_number = self.route.route_number if self.route else "N/A"
        driver_name = self.driver.driver_name if self.driver else "N/A"
        return f"<BusAssignment(bus_number='{bus_number}', route_number='{route_number}', shift='{self.shift}', time='{self.time}', driver_name='{driver_name}', student_id='{self.student_id}')>"

    def to_json(self):
        return {
            "id": self.id,
            "bus_id": self.bus_id,
            "route_id": self.route_id,
            "shift": self.shift,
            "time": self.time,
            "student_id": self.student_id,
            "driver_id": self.driver_id
        }

class Route(Base):
    __tablename__ = 'Route'

    id = Column(Integer,primary_key = True,nullable=False)
    route_number = Column(String,nullable=False)
    route_name = Column(String,nullable=False)
    source= Column(JSONB, nullable=False)
    destination = Column(JSONB, nullable=False)
    stops = Column(ARRAY(JSONB),nullable=False)

    assignments = relationship("BusAssignment", back_populates="route")

    organization_id = Column(Integer, ForeignKey('Organization.id'), nullable=False)
    organization = relationship("Organization", back_populates="routes")

    def __init__(self, route_number, route_name, source, destination, stops, organization_id):
        self.route_number = route_number
        self.route_name = route_name
        self.source = source
        self.destination = destination
        self.stops = stops
        self.organization_id = organization_id
    
    def to_json(self):
        return {
            "id": self.id,
            "route_number": self.route_number,
            "route_name": self.route_name,
            "source": self.source,
            "destination": self.destination,
            "stops": self.stops
        }

    def __repr__(self):
        organization_name = self.organization.institute_name if self.organization else "N/A"
        return f"<Route(route_number='{self.route_number}', route_name='{self.route_name}', source='{self.source}', destination='{self.destination}', stops='{self.stops}', organization_name='{organization_name}')>"

class Bus(Base):

    __tablename__ = 'Bus'

    id = Column(Integer, primary_key=True,nullable=False)
    bus_number = Column(String, nullable=False)
    bus_seats = Column(String, nullable=False)
    register_numberplate = Column(String, nullable=False)
    status = Column(Boolean,nullable=False)
    assignments = relationship("BusAssignment", back_populates="bus")

    organization_id = Column(Integer, ForeignKey('Organization.id'), nullable=False)
    organization = relationship("Organization", back_populates="buses")


    def __init__(self, bus_number, bus_seats, status, register_numberplate,organization_id):
        self.bus_number = bus_number
        self.bus_seats = bus_seats
        self.status = status
        self.register_numberplate = register_numberplate
        self.organization_id = organization_id

    def to_json(self):
        return {
            "id": self.id,
            "bus_number": self.bus_number,
            "bus_seats": self.bus_seats,
            "register_numberplate": self.register_numberplate,
            "status":self.status
        }
    
    def __repr__(self):
        organization_name = self.organization.institute_name if self.organization else "N/A"
        return f"<Bus(bus_number='{self.bus_number}', bus_seats='{self.bus_seats}', register_numberplate='{self.register_numberplate}', organization_name='{organization_name}, status='{self.status}')>"

class Driver(Base):

    __tablename__ = 'Driver'

    id = Column(Integer, primary_key=True)
    driver_photo = Column(String, nullable=True)
    driver_name = Column(String, nullable=False)
    driver_phone = Column(String, nullable=False)
    driver_address = Column(String, nullable=False)
    driver_salary = Column(String, nullable=True)
    
    assignments = relationship("BusAssignment", back_populates="driver")

    organization_id = Column(Integer, ForeignKey('Organization.id'), nullable=False)
    organization = relationship("Organization", back_populates="drivers")

    def __init__(self, driver_photo, driver_name, driver_phone, driver_address, driver_salary,organization_id):
        self.driver_photo = driver_photo
        self.driver_name = driver_name
        self.driver_phone = driver_phone
        self.driver_address = driver_address
        self.driver_salary = driver_salary
        self.organization_id = organization_id


    def to_json(self):
        return {
            "id": self.id,
            "driver_photo": self.driver_photo,
            "driver_name": self.driver_name,
            "driver_phone": self.driver_phone,
            "driver_address": self.driver_address,
            "driver_salary": self.driver_salary,
        }

    def __repr__(self):
        organization_name = self.organization.institute_name if self.organization else "N/A"
        return f"<Driver(driver_photo='{self.driver_photo}', driver_name='{self.driver_name}', driver_phone='{self.driver_phone}', driver_address='{self.driver_address}', driver_salary='{self.driver_salary}', organization_name='{organization_name}')>"

class Student(Base):

    __tablename__ = "Student"

    id = Column(Integer, primary_key=True)
    photo = Column(String, nullable=True)
    enrollment_number = Column(String, nullable=False)
    student_name = Column(String, nullable=False)
    student_phone = Column(String, nullable=False)
    student_address = Column(String, nullable=False)
    busfee_paid = Column(Boolean, nullable=False)
    email = Column(String, nullable=False)

    assignments = relationship("BusAssignment", back_populates="student")
    
    organization_id = Column(Integer, ForeignKey('Organization.id'), nullable=False)
    organization = relationship("Organization", back_populates="students")


    def __init__(self, photo, enrollment_number, student_name, student_phone, student_address, busfee, email, organization_id):
        self.photo = photo
        self.enrollment_number = enrollment_number
        self.student_name = student_name
        self.student_phone = student_phone
        self.student_address = student_address
        self.busfee = busfee
        self.email = email
        self.organization_id = organization_id

    def __repr__(self):
        organization_name = self.organization.institute_name if self.organization else "N/A"
        return f"<Student(photo='{self.photo}', enrollment_number='{self.enrollment_number}', student_name='{self.student_name}', student_phone='{self.student_phone}', student_address='{self.student_address}', busfee='{self.busfee}', email='{self.email}', organization_name='{organization_name}')>"
    
    def to_json(self):
        return {
            "photo": self.photo,
            "enrollment_number": self.enrollment_number,
            "student_name": self.student_name,
            "student_phone": self.student_phone,
            "student_address": self.student_address,
            "busfee": self.busfee,
            "email": self.email,
            "id":self.id
        }

