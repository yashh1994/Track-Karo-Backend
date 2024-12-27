from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from orms import Base, Route, Organization, Driver, Bus

load_dotenv()
app = Flask(__name__)   
CORS(app)


PG_DB_URL = os.getenv('PG_DATABASE_URL')
print("This is the url ---------- ",PG_DB_URL)
engine = create_engine(PG_DB_URL)
Base.metadata.create_all(engine)

Session = sessionmaker(bind=engine)




@app.route('/get-organization-data/<string:id>', methods=['GET'])
def get_organization_data(id):
    session = Session()
    organization = session.query(Organization).filter_by(id=id).first()
    organization_buses = session.query(Bus).filter_by(organization_id=id).all()
    organization_routes = session.query(Route).filter_by(organization_id=id).all()
    organization_drivers = session.query(Driver).filter_by(organization_id=id).all()



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
        "drivers": [driver.__repr__() for driver in organization_drivers]
    }

    session.close()


    if organization_data:
        print("This is the organization data: ",organization_data)
        return jsonify(organization_data), 200
    else:
        return jsonify({"error": "Organization not found"}), 404


@app.route('/get-all-bus',methods=['GET'])
def get_all_bus():
    
    data = request.get_json()
    organization_id = data['organization_id']
    session = Session()
    buses = session.query(Bus).filter_by(organization_id=organization_id).all()
    session.close()

    print(buses)
    
    if buses:
        return jsonify([bus.__repr__() for bus in buses]), 200
    else:
        return jsonify({"error": "No buses found"}), 404









#! Add Routes

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


























@app.route('/', methods=['GET'])
def test_route():
    return "The routes are working!", 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
    print("Server is running on port 5000")