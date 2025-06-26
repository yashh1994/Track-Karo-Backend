from sqlalchemy import Column, Integer, String, ForeignKey, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.dialects.postgresql import ARRAY,JSONB
from sqlalchemy.orm import relationship
from flask_cors import CORS
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from db.session import Base
from sqlalchemy import UniqueConstraint


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

    assignments = relationship("BusAssignment", back_populates="organization")


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
    
    driver_id = Column(Integer, ForeignKey('Driver.id'), nullable=True)
    
    organization_id = Column(Integer, ForeignKey('Organization.id'), nullable=False)

    bus = relationship("Bus", back_populates="assignments")
    route = relationship("Route", back_populates="assignments")
    driver = relationship("Driver", back_populates="assignments")

    organization = relationship("Organization", back_populates="assignments")

    arrival_students = relationship(
    "Student",
    foreign_keys='Student.arrival_bus_assignment_id',
    back_populates="arrival_assignment"
    )

    departure_students = relationship(
        "Student",
        foreign_keys='Student.departure_bus_assignment_id',
        back_populates="departure_assignment"
    )

    __table_args__ = (
        UniqueConstraint('bus_id', 'shift', 'time', name='uq_bus_shift_time'),
    )

    def assign_driver(self, driver_id):
        self.driver_id = driver_id

    def __repr__(self):
        bus_number = self.bus.bus_number if self.bus else "N/A"
        route_number = self.route.route_number if self.route else "N/A"
        driver_name = self.driver.driver_name if self.driver else "N/A"
        return f"<BusAssignment(bus_number='{bus_number}', route_number='{route_number}', shift='{self.shift}', time='{self.time}', driver_name='{driver_name}')>"

    def to_json(self):
        return {
            "id": self.id,
            "bus_id": self.bus_id,
            "route_id": self.route_id,
            "shift": self.shift,
            "time": self.time,
            "driver_id": self.driver_id,
            "arrival_student_count": len(self.arrival_students),
            "departure_student_count": len(self.departure_students)
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
    organization_id = Column(Integer, ForeignKey('Organization.id'), nullable=False)

    assignments = relationship("BusAssignment", back_populates="bus")
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

    arrival_bus_assignment_id = Column(Integer, ForeignKey('BusAssignment.id'), nullable=True)
    departure_bus_assignment_id = Column(Integer, ForeignKey('BusAssignment.id'), nullable=True)

    arrival_assignment = relationship(
    "BusAssignment",
    foreign_keys=[arrival_bus_assignment_id],
    back_populates="arrival_students"
    )

    departure_assignment = relationship(
        "BusAssignment",
        foreign_keys=[departure_bus_assignment_id],
        back_populates="departure_students"
    )


    organization_id = Column(Integer, ForeignKey('Organization.id'), nullable=False)
    organization = relationship("Organization", back_populates="students")


    def __init__(self, photo, enrollment_number, student_name, student_phone, student_address, busfee_paid, email, organization_id):
        self.photo = photo
        self.enrollment_number = enrollment_number
        self.student_name = student_name
        self.student_phone = student_phone
        self.student_address = student_address
        self.busfee_paid = busfee_paid
        self.email = email
        self.organization_id = organization_id

    def __repr__(self):
        organization_name = self.organization.institute_name if self.organization else "N/A"
        return f"<Student(photo='{self.photo}', enrollment_number='{self.enrollment_number}', student_name='{self.student_name}', student_phone='{self.student_phone}', student_address='{self.student_address}', busfee_paid='{self.busfee_paid}', email='{self.email}', organization_name='{organization_name}')>"
    
    def to_json(self):
        return {
            "photo": self.photo,
            "enrollment_number": self.enrollment_number,
            "student_name": self.student_name,
            "student_phone": self.student_phone,
            "student_address": self.student_address,
            "busfee_paid": self.busfee_paid,
            "email": self.email,
            "id":self.id,
            "arrival_bus_assignment_id":self.arrival_bus_assignment_id,
            "departure_assignment":self.departure_assignment
        }

