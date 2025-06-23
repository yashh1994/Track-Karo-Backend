from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
import os
load_dotenv(dotenv_path='./pro.env')
app = Flask(__name__)   
CORS(app)



#! Organization

@app.route('/add-organization', methods=['POST'])
def handle_add_organization():
    return jsonify(add_organization(data))


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

