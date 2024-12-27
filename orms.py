from sqlalchemy import Column, Integer, String, ForeignKey, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.dialects.postgresql import ARRAY,JSONB
from sqlalchemy.orm import relationship

Base = declarative_base()


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



class Route(Base):
    __tablename__ = 'Route'

    id = Column(Integer,primary_key = True)
    route_number = Column(String,nullable=False)
    route_name = Column(String,nullable=False)
    source= Column(String,nullable=False)
    destination = Column(String,nullable=False)
    stops = Column(ARRAY(String),nullable=False)
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

class Driver(Base):

    __tablename__ = 'Driver'

    id = Column(Integer, primary_key=True)
    driver_photo = Column(String, nullable=True)
    driver_name = Column(String, nullable=False)
    driver_phone = Column(String, nullable=False)
    driver_address = Column(String, nullable=False)
    driver_route = Column(String, nullable=True)
    driver_busnumber = Column(String, nullable=True)
    driver_salary = Column(String, nullable=True)
    status = Column(Boolean, nullable=False)

    organization_id = Column(Integer, ForeignKey('Organization.id'), nullable=False)
    organization = relationship("Organization", back_populates="drivers")

    def __init__(self, driver_photo, driver_name, driver_phone, driver_address, driver_route, driver_busnumber, driver_salary, status,organization_id):
        self.driver_photo = driver_photo
        self.driver_name = driver_name
        self.driver_phone = driver_phone
        self.driver_address = driver_address
        self.driver_route = driver_route
        self.driver_busnumber = driver_busnumber
        self.driver_salary = driver_salary
        self.status = status
        self.organization_id = organization_id


    def to_json(self):
        return {
            "id": self.id,
            "driver_photo": self.driver_photo,
            "driver_name": self.driver_name,
            "driver_phone": self.driver_phone,
            "driver_address": self.driver_address,
            "driver_route": self.driver_route,
            "driver_busnumber": self.driver_busnumber,
            "driver_salary": self.driver_salary,
            "status": self.status
        }

    def __repr__(self):
        organization_name = self.organization.institute_name if self.organization else "N/A"
        return f"<Driver(driver_photo='{self.driver_photo}', driver_name='{self.driver_name}', driver_phone='{self.driver_phone}', driver_address='{self.driver_address}', driver_route='{self.driver_route}', driver_busnumber='{self.driver_busnumber}', driver_salary='{self.driver_salary}', status='{self.status}', organization_name='{organization_name}')>"


class Bus(Base):

    __tablename__ = 'Bus'

    id = Column(Integer, primary_key=True)
    bus_number = Column(String, nullable=False)
    bus_seats = Column(String, nullable=False)
    bus_route = Column(String, nullable=False)
    driver_name = Column(String, nullable=True)
    driver_phone = Column(String, nullable=True)
    register_numberplate = Column(String, nullable=False)
    status = Column(Boolean, nullable=False)
    shift = Column(String, nullable=False)
    time = Column(String, nullable=False)

    organization_id = Column(Integer, ForeignKey('Organization.id'), nullable=False)
    organization = relationship("Organization", back_populates="buses")


    def __init__(self, bus_number, bus_seats, bus_route, driver_name, driver_phone, register_numberplate, status, shift,time,organization_id):
        self.bus_number = bus_number
        self.bus_seats = bus_seats
        self.bus_route = bus_route
        self.driver_name = driver_name
        self.driver_phone = driver_phone
        self.register_numberplate = register_numberplate
        self.status = status
        self.shift = shift
        self.time = time
        self.organization_id = organization_id

    def to_json(self):
        return {
            "id": self.id,
            "bus_number": self.bus_number,
            "bus_seats": self.bus_seats,
            "bus_route": self.bus_route,
            "driver_name": self.driver_name,
            "driver_phone": self.driver_phone,
            "register_numberplate": self.register_numberplate,
            "status": self.status,
            "shift": self.shift,
            "time": self.time
        }
    
    def __repr__(self):
        organization_name = self.organization.institute_name if self.organization else "N/A"
        return f"<Bus(bus_number='{self.bus_number}', bus_seats='{self.bus_seats}', bus_route='{self.bus_route}', driver_name='{self.driver_name}', driver_phone='{self.driver_phone}', register_numberplate='{self.register_numberplate}', status='{self.status}', shift='{self.shift}', time='{self.time}', organization_name='{organization_name}')>"


class Student(Base):

    __tablename__ = "Student"

    id = Column(Integer, primary_key=True)
    photo = Column(String, nullable=True)
    enrollment_number = Column(String, nullable=False)
    student_name = Column(String, nullable=False)
    student_phone = Column(String, nullable=False)
    bus_number = Column(String, nullable=False)
    route = Column(String, nullable=False)
    student_address = Column(String, nullable=False)
    busfee = Column(String, nullable=False)
    student_class = Column(String, nullable=False)  
    status = Column(Boolean, nullable=False)
    email = Column(String, nullable=False)
    
    organization_id = Column(Integer, ForeignKey('Organization.id'), nullable=False)
    organization = relationship("Organization", back_populates="students")


    def __init__(self, photo, enrollment_number, student_name, student_phone, bus_number, route, student_address, busfee, student_class, status, email, organization_id):
        self.photo = photo
        self.enrollment_number = enrollment_number
        self.student_name = student_name
        self.student_phone = student_phone
        self.bus_number = bus_number
        self.route = route
        self.student_address = student_address
        self.busfee = busfee
        self.student_class = student_class
        self.status = status
        self.email = email
        self.organization_id = organization_id

    def __repr__(self):
        organization_name = self.organization.institute_name if self.organization else "N/A"
        return f"<Student(photo='{self.photo}', enrollment_number='{self.enrollment_number}', student_name='{self.student_name}', student_phone='{self.student_phone}', bus_number='{self.bus_number}', route='{self.route}', student_address='{self.student_address}', busfee='{self.busfee}', student_class='{self.student_class}', status='{self.status}', email='{self.email}', organization_name='{organization_name}')>"
    
    def to_json(self):
        return {
            "photo": self.photo,
            "enrollment_number": self.enrollment_number,
            "student_name": self.student_name,
            "student_phone": self.student_phone,
            "bus_number": self.bus_number,
            "route": self.route,
            "student_address": self.student_address,
            "busfee": self.busfee,
            "student_class": self.student_class,
            "status": self.status,
            "email": self.email
        }

