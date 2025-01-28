from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from orms import Base, Bus, Driver, Organization, Route, Student

load_dotenv(dotenv_path='./pro.env')
app = Flask(__name__)   
CORS(app)


PG_DB_URL = os.getenv('PG_DATABASE_URL')
print("This is the url ---------- ",PG_DB_URL)
engine = create_engine(PG_DB_URL)
Base.metadata.create_all(engine)

Session = sessionmaker(bind=engine)



#! Organization

@app.route('/add-organization', methods=['POST'])
def add_organization():
    data = request.get_json()

    organization_name = data['institute_name']
    organization_email = data['email']
    organization_password = data['password']

    new_organization = Organization(
        institute_name=organization_name,
        email=organization_email,
        password=organization_password
    )

    session = Session()
    try:
        session.add(new_organization)
        session.commit()
        return jsonify({"message": "Organization added successfully"}), 201
    except Exception as e:
        session.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        session.close()

@app.route('/get-organization-data/<string:id>', methods=['GET'])
def get_organization_data(id):
    session = Session()
    organization = session.query(Organization).filter_by(id=id).first()
    organization_buses = session.query(Bus).filter_by(organization_id=id).all()
    organization_routes = session.query(Route).filter_by(organization_id=id).all()
    organization_drivers = session.query(Driver).filter_by(organization_id=id).all()
    organization_students = session.query(Student).filter_by(organization_id=id).all()




    if not organization:
        return jsonify({"error": "Organization not found"}), 404
    
    organization_data = {
        "Detials": {
            "id": organization.id,
            "institute_name": organization.institute_name,
            "email": organization.email,
            "password": organization.password
        },
        "buses": [bus.__repr__() for bus in organization_buses],
        "routes": [route.__repr__() for route in organization_routes],
        "drivers": [driver.__repr__() for driver in organization_drivers],
        "Students": [student.__repr__() for student in organization_students]
    }

    session.close()


    if organization_data:
        print("This is the organization data: ",organization_data)
        return jsonify(organization_data), 200
    else:
        return jsonify({"error": "Organization not found"}), 404

@app.route('/login-organization', methods=['POST'])
def login_organization():
    data = request.get_json()

    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        return jsonify({"error": "Invalid input. 'email' and 'password' are required."}), 400

    session = Session()
    try:
        organization = session.query(Organization).filter_by(email=email, password=password).first()
        if not organization:
            return jsonify({"error": "Invalid email or password"}), 401

        return jsonify({"message": "Login successful", "organization_id": organization.id}), 200
    except Exception as e:
        app.logger.error(f"Error logging in organization: {e}")
        return jsonify({"error": "An internal error occurred"}), 500
    finally:
        session.close()


#! Routes
@app.route('/get-all-routes', methods=['GET'])
def get_all_routes():
    session = Session()
    try:
        data = request.get_json()

        organization_id = data.get('organization_id', None)
        
        if organization_id is None:
            return jsonify({"error": "organization_id is required as a query parameter"}), 400
        
        routes = session.query(Route).filter_by(organization_id=organization_id).all()
        
        if not routes:
            return jsonify({"error": "No routes found for the given organization_id"}), 404
        
        route_data = [route.to_json() for route in routes]
        
        return jsonify(route_data), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        session.close()

@app.route('/add-route', methods=['POST'])
def add_route():
    # Get data from the request body (assumed to be JSON)
    data = request.get_json()

    # Extract data from the request
    route_number = data['route_number']
    route_name = data['route_name']
    source = data['source']
    destination = data['destination']
    stops = data['stops'] 
    organization_id = data['organization_id']


    # Create a new route object
    new_route = Route(
        route_number=route_number,
        route_name=route_name,
        source=source,
        destination=destination,
        stops=stops,
        organization_id=organization_id
    )

    # Create a session and add the new route
    session = Session()
    try:
        session.add(new_route)
        session.commit()
        return jsonify({"message": "Route added successfully"}), 201
    except Exception as e:
        session.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        session.close()

@app.route('/delete-route', methods=['DELETE'])
def delete_route():
    data = request.get_json()
    id = data.get('id')
    organization_id = data.get('organization_id')  # Use .get() to handle missing keys gracefully

    if not id or not organization_id:
        return jsonify({"error": "Invalid input. 'id' and 'organization_id' are required."}), 400

    with Session() as session:
        try:
            route = session.query(Route).filter_by(id=id, organization_id=organization_id).first()
            if not route:
                return jsonify({"error": "Route not found"}), 404

            session.delete(route)
            session.commit()
            return jsonify({"message": "Route deleted successfully"}), 200

        except Exception as e:
            app.logger.error(f"Error deleting route: {e}")
            return jsonify({"error": "An internal error occurred"}), 500

@app.route('/update-route', methods=['PUT'])
def update_route():
    data = request.get_json()

    id = data.get('id')
    organization_id = data.get('organization_id')

    if not id or not organization_id:
        return jsonify({"error": "Invalid input. 'id' and 'organization_id' are required."}), 400
    
    with Session() as session:
        try:
            route = session.query(Route).filter_by(id=id, organization_id=organization_id).first()
            if not route:
                return jsonify({"error": "Route not found"}), 404

            route.route_number = data.get('route_number', route.route_number)
            route.route_name = data.get('route_name', route.route_name)
            route.source = data.get('source', route.source)
            route.destination = data.get('destination', route.destination)
            route.stops = data.get('stops', route.stops)

            session.commit()
            return jsonify({"message": "Route updated successfully"}), 200

        except Exception as e:
            app.logger.error(f"Error updating route: {e}")
            return jsonify({"error": "An internal error occurred"}), 500






#! Driver
@app.route('/add-driver', methods=['POST'])
def add_driver():
    data = request.get_json()

    driver_photo = data.get('driver_photo')
    driver_name = data['driver_name']
    driver_phone = data['driver_phone']
    driver_address = data['driver_address']
    driver_route = data.get('driver_route')
    driver_busnumber = data.get('driver_busnumber')
    organization_id = data['organization_id']
    driver_salary = data.get('driver_salary')
    status = data.get('status')

    new_driver = Driver(
        driver_photo=driver_photo,
        driver_name=driver_name,
        driver_phone=driver_phone,
        driver_address=driver_address,
        driver_route=driver_route,
        driver_busnumber=driver_busnumber,
        organization_id=organization_id,
        driver_salary=driver_salary,
        status=status
    )

    session = Session()
    try:
        session.add(new_driver)
        session.commit()
        return jsonify({"message": "Driver added successfully"}), 201
    except Exception as e:
        session.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        session.close()

@app.route('/get-all-drivers', methods=['GET'])
def get_all_drivers():
    data = request.get_json()

    try:
        organization_id = data.get('organization_id', None)

        if organization_id is None:
            return jsonify({"error": "organization_id is required as a query parameter"}), 400
        
        session = Session()

        drivers = session.query(Driver).filter_by(organization_id=organization_id).all()
        
        if not drivers:
            return jsonify({"error": "No drivers found for the given organization_id"}), 404
        
        driver_data = [driver.to_json() for driver in drivers]

        return jsonify(driver_data), 200
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        session.close()

@app.route('/delete-driver', methods=['DELETE'])
def delete_driver():
    data = request.get_json()
    id = data.get('id')
    organization_id = data.get('organization_id')

    if not id or not organization_id:
        return jsonify({"error": "Invalid input. 'id' and 'organization_id' are required."}), 400
    
    with Session() as session:
        try:
            driver = session.query(Driver).filter_by(id=id, organization_id=organization_id).first()
            if not driver:
                return jsonify({"error": "Driver not found"}), 404

            session.delete(driver)
            session.commit()
            return jsonify({"message": "Driver deleted successfully"}), 200

        except Exception as e:
            app.logger.error(f"Error deleting driver: {e}")
            return jsonify({"error": "An internal error occurred"}), 500
   
@app.route('/update-driver', methods=['PUT'])
def update_driver():
    data = request.get_json()

    id = data.get('id')
    organization_id = data.get('organization_id')

    if not id or not organization_id:
        return jsonify({"error": "Invalid input. 'id' and 'organization_id' are required."}), 400

    with Session() as session:
        try:
            driver = session.query(Driver).filter_by(id=id, organization_id=organization_id).first()
            if not driver:
                return jsonify({"error": "Driver not found"}), 404

            driver.driver_photo = data.get('driver_photo', driver.driver_photo)
            driver.driver_name = data.get('driver_name', driver.driver_name)
            driver.driver_phone = data.get('driver_phone', driver.driver_phone)
            driver.driver_address = data.get('driver_address', driver.driver_address)
            driver.driver_route = data.get('driver_route', driver.driver_route)
            driver.driver_busnumber = data.get('driver_busnumber', driver.driver_busnumber)
            driver.driver_salary = data.get('driver_salary', driver.driver_salary)
            driver.status = data.get('status', driver.status)

            session.commit()
            return jsonify({"message": "Driver updated successfully"}), 200

        except Exception as e:
            app.logger.error(f"Error updating driver: {e}")
            return jsonify({"error": "An internal error occurred"}), 500    





#! Bus

@app.route('/add-bus',methods=['POST'])
def add_bus():
    data = request.get_json()

    bus_number = data['bus_number']
    bus_seats = data['bus_seats']
    bus_route = data['bus_route']
    driver_name = data.get('driver_name')
    driver_phone = data.get('driver_phone')
    register_numberplate = data['register_numberplate']
    status = data['status']
    shift = data['shift']
    time = data['time']
    organization_id = data['organization_id']

    new_bus = Bus(
        bus_number=bus_number,
        bus_seats=bus_seats,
        bus_route=bus_route,
        driver_name=driver_name,
        driver_phone=driver_phone,
        register_numberplate=register_numberplate,
        status=status,
        shift=shift,
        time=time,
        organization_id=organization_id
    )

    session = Session()
    try:
        session.add(new_bus)
        session.commit()
        print("______________ This is the Bus data: ",new_bus.id)
        return jsonify({"message": "Bus added successfully"}), 201
    except Exception as e:
        session.rollback()
        print("Error is ",e)
        return jsonify({"error": str(e)}), 500
    finally:
        session.close()

@app.route('/get-all-bus', methods=['GET'])
def get_all_bus():
    session = Session()
    try:
        data = request.get_json()

        organization_id = data.get('organization_id', None)
        
        if organization_id is None:
            return jsonify({"error": "organization_id is required as a query parameter"}), 400
        
        buses = session.query(Bus).filter_by(organization_id=organization_id).all()
        
        if not buses:
            return jsonify({"error": "No buses found for the given organization_id"}), 404
        
        bus_data = [bus.to_json() for bus in buses]
        
        return jsonify(bus_data), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        session.close()

@app.route('/delete-bus', methods=['DELETE'])
def delete_bus():
    data = request.get_json()
    id = data.get('id')
    organization_id = data.get('organization_id')  # Use .get() to handle missing keys gracefully

    if not id or not organization_id:
        return jsonify({"error": "Invalid input. 'Bus id' and 'organization_id' are required."}), 400

    with Session() as session:
        try:
            bus = session.query(Bus).filter_by(id=id, organization_id=organization_id).first()
            if not bus:
                return jsonify({"error": "Bus not found"}), 404

            session.delete(bus)
            session.commit()
            return jsonify({"message": "Bus deleted successfully"}), 200

        except Exception as e:
            # Log the exception with additional context
            app.logger.error(f"Error deleting bus with id {id} for organization {organization_id}: {e}")
            return jsonify({"error": "An internal error occurred"}), 500

@app.route('/update-bus', methods=['PUT'])
def update_bus():
    data = request.get_json()

    id = data.get('id')
    organization_id = data.get('organization_id')

    if not id or not organization_id:
        return jsonify({"error": "Invalid input. 'id' and 'organization_id' are required."}), 400

    with Session() as session:
        try:
            bus = session.query(Bus).filter_by(id=id, organization_id=organization_id).first()
            if not bus:
                return jsonify({"error": "Bus not found"}), 404

            bus.bus_number = data.get('bus_number', bus.bus_number)
            bus.bus_seats = data.get('bus_seats', bus.bus_seats)
            bus.bus_route = data.get('bus_route', bus.bus_route)
            bus.driver_name = data.get('driver_name', bus.driver_name)
            bus.driver_phone = data.get('driver_phone', bus.driver_phone)
            bus.register_numberplate = data.get('register_numberplate', bus.register_numberplate)
            bus.status = data.get('status', bus.status)
            bus.shift = data.get('shift', bus.shift)
            bus.time = data.get('time', bus.time)

            session.commit()
            return jsonify({"message": "Bus updated successfully"}), 200

        except Exception as e:
            app.logger.error(f"Error updating bus: {e}")
            return jsonify({"error": "An internal error occurred"}), 500

@app.route('/get-bus-from-route',methods=['GET'])
def get_bus_from_route():
    data = request.get_json()

    route_number = data.get('route_number')
    organization_id = data.get('organization_id')

    if not route_number or not organization_id:
        return jsonify({"error": "Invalid input. 'route_number' and 'organization_id' are required."}), 400
    
    with Session() as session:
        try:
            buses = session.query(Bus).filter_by(bus_route=route_number, organization_id=organization_id).all()
            if not buses:
                return jsonify({"error": "Bus not found"}), 404
            
            bus_data = [bus.to_json() for bus in buses]

            return jsonify(bus_data), 200

        except Exception as e:
            app.logger.error(f"Error getting bus: {e}")
            return jsonify({"error": "An internal error occurred"}), 500







#! Student

@app.route('/add-student', methods=['POST'])
def add_student():
    data = request.get_json()
    if not data:
        return jsonify({"error": "Invalid data provided"}), 400

    session = Session()

    try:
        # Extract data from the JSON payload
        photo = data.get('photo', None)
        enrollment_number = data.get('enrollment_number')
        student_name = data.get('student_name')
        student_phone = data.get('student_phone')
        bus_number = data.get('bus_number')
        route = data.get('route')
        student_address = data.get('student_address')
        busfee = data.get('busfee')
        student_class = data.get('student_class')
        status = data.get('status', True)
        email = data.get('email')
        organization_id = data.get('organization_id')

        # Validate required fields
        required_fields = ['enrollment_number', 'student_name', 'student_phone', 'bus_number', 
                           'route', 'student_address', 'busfee', 'student_class', 'email', 'organization_id']
        missing_fields = [field for field in required_fields if not data.get(field)]
        if missing_fields:
            return jsonify({"error": f"Missing required fields: {', '.join(missing_fields)}"}), 400

        # Create a new Student object
        new_student = Student(
            photo=photo,
            enrollment_number=enrollment_number,
            student_name=student_name,
            student_phone=student_phone,
            bus_number=bus_number,
            route=route,
            student_address=student_address,
            busfee=busfee,
            student_class=student_class,
            status=status,
            email=email,
            organization_id=organization_id
        )

        # Add the new student to the database
        
        session.add(new_student)
        session.commit()

        return jsonify({"message": "Student added successfully", "student_id": new_student.to_json()}), 201

    except Exception as e:
        session.rollback()
        return jsonify({"error": str(e)}), 500

@app.route('/get-all-students', methods=['GET'])
def get_all_students():
    data = request.get_json()

    try:
        organization_id = data.get('organization_id', None)

        if organization_id is None:
            return jsonify({"error": "organization_id is required as a query parameter"}), 400
        
        session = Session()

        students = session.query(Student).filter_by(organization_id=organization_id).all()
        
        if not students:
            return jsonify({"error": "No students found for the given organization_id"}), 404
        
        student_data = [student.to_json() for student in students]

        return jsonify(student_data), 200
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        session.close()

@app.route('/delete-student', methods=['DELETE'])
def delete_student():
    data = request.get_json()
    id = data.get('id')
    organization_id = data.get('organization_id')

    if not id or not organization_id:
        return jsonify({"error": "Invalid input. 'id' and 'organization_id' are required."}), 400
    
    with Session() as session:
        try:
            student = session.query(Student).filter_by(id=id, organization_id=organization_id).first()
            if not student:
                return jsonify({"error": "Student not found"}), 404

            session.delete(student)
            session.commit()
            return jsonify({"message": "Student deleted successfully"}), 200

        except Exception as e:
            app.logger.error(f"Error deleting student: {e}")
            return jsonify({"error": "An internal error occurred"}), 500

@app.route('/update-student', methods=['PUT'])
def update_student():
    data = request.get_json()

    id = data.get('id')
    organization_id = data.get('organization_id')

    if not id or not organization_id:
        return jsonify({"error": "Invalid input. 'id' and 'organization_id' are required."}), 400

    with Session() as session:
        try:
            student = session.query(Student).filter_by(id=id, organization_id=organization_id).first()
            if not student:
                return jsonify({"error": "Student not found"}), 404

            student.photo = data.get('photo', student.photo)
            student.enrollment_number = data.get('enrollment_number', student.enrollment_number)
            student.student_name = data.get('student_name', student.student_name)
            student.student_phone = data.get('student_phone', student.student_phone)
            student.bus_number = data.get('bus_number', student.bus_number)
            student.route = data.get('route', student.route)
            student.student_address = data.get('student_address', student.student_address)
            student.busfee = data.get('busfee', student.busfee)
            student.student_class = data.get('student_class', student.student_class)
            student.status = data.get('status', student.status)
            student.email = data.get('email', student.email)

            session.commit()
            return jsonify({"message": "Student updated successfully"}), 200

        except Exception as e:
            app.logger.error(f"Error updating student: {e}")
            return jsonify({"error": "An internal error occurred"}), 500

@app.route('/get-details-from-student',methods=['GET'])
def get_details_from_student():
    data = request.get_json()

    student_id = data.get('student_id')
    organization_id = data.get('organization_id')

    if not student_id or not organization_id:
        return jsonify({"error": "Invalid input. 'student_id' and 'organization_id' are required."}), 400
    
    with Session() as session:
        try:
            student = session.query(Student).filter_by(id=student_id, organization_id=organization_id).first()
            if not student:
                return jsonify({"error": "Student not found"}), 404
            
            bus_number = student.bus_number
            route_number = student.route
            
            route = session.query(Route).filter_by(route_number=route_number, organization_id=organization_id).first()
            driver = session.query(Driver).filter_by(driver_busnumber=bus_number, driver_route=route_number,organization_id=organization_id).first()
            bus = session.query(Bus).filter_by(bus_number=bus_number, bus_route=route_number, organization_id=organization_id).first()


            student_data = {
                "route_details": {
                    "route_number": route.route_number if route and route.route_number else "Unknown",
                    "route_name": route.route_name if route and route.route_name else "Unknown",
                    "source": route.source if route and route.source else "Unknown",
                    "destination": route.destination if route and route.destination else "Unknown",
                    "stops": route.stops if route and route.stops else "Unknown"
                },
                "driver_details": {
                    "driver_photo": driver.driver_photo if driver and driver.driver_photo else "Unknown",
                    "driver_name": driver.driver_name if driver and driver.driver_name else "Unknown",
                    "driver_phone": driver.driver_phone if driver and driver.driver_phone else "Unknown",
                    "driver_status": driver.status if driver and driver.status else "Unknown",
                    "bus_number": driver.driver_busnumber if driver and driver.driver_busnumber else "Unknown",
                    "shift": bus.shift if bus and bus.shift else "Unknown",
                    "time": bus.time if bus and bus.time else "Unknown"
                },
                "student_details": {
                    "student_name": student.student_name if student and student.student_name else "Unknown",
                    "student_phone": student.student_phone if student and student.student_phone else "Unknown",
                    "student_address": student.student_address if student and student.student_address else "Unknown",
                    "busfee": student.busfee if student and student.busfee else "Unknown",
                    "student_class": student.student_class if student and student.student_class else "Unknown",
                    "email": student.email if student and student.email else "Unknown"
                }
            }

            return jsonify(student_data), 200

        except Exception as e:
            app.logger.error(f"Error getting student: {e}")
            return jsonify({"error": "An internal error occurred"}), 500


















@app.route('/', methods=['GET'])
def test_route():
    return "The routes are working!", 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
    print("Server is running on port 5000")