from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
import os
from Services.organization import add_organization, get_organization_data, login_organization
from Services.bus import add_bus, get_all_bus, delete_bus, update_bus
from Services.routes import add_route, get_all_routes, delete_route, update_route
from Services.driver import add_driver, get_all_drivers, delete_driver, update_driver
from Services.student import add_student, get_all_students, delete_student, get_details_from_student, update_student

load_dotenv(dotenv_path='./pro.env')
app = Flask(__name__)   
CORS(app)









#! Student

@app.route('/add-student', methods=['POST'])
def handle_add_student():
    data = request.get_json()
    return add_student(data)

@app.route('/get-all-students', methods=['POST'])
def handle_get_all_students():
    data = request.get_json()
    return get_all_students(data)


@app.route('/delete-student', methods=['DELETE'])
def handle_delete_student():
    data = request.get_json()
    return delete_student(data)


@app.route('/update-student', methods=['PUT'])
def handle_update_student():
    data = request.get_json()
    return update_student(data)


@app.route('/get-details-from-student',methods=['GET'])
def handle_get_details_from_student():
    data = request.get_json()
    return get_details_from_student(data)












#! Driver
@app.route('/add-driver', methods=['POST'])
def handle_add_driver():
    data = request.get_json()
    return add_driver(data)

@app.route('/get-all-drivers', methods=['POST'])
def handle_get_all_drivers():
    data = request.get_json()
    return get_all_drivers(data)

@app.route('/delete-driver', methods=['DELETE'])
def handle_delete_driver():
    data = request.get_json()
    return delete_driver(data)

@app.route('/update-driver', methods=['PUT'])
def handle_update_driver():
    data = request.get_json()
    return update_driver(data)



#! Bus

@app.route('/add-bus',methods=['POST'])
def handle_add_bus():
    data = request.get_json()
    return add_bus(data)


@app.route('/get-all-bus', methods=['POST'])
def handle_get_all_bus():
    data = request.get_json()
    return get_all_bus(data)


@app.route('/delete-bus', methods=['DELETE'])
def handle_delete_bus():
    data = request.get_json()
    return delete_bus(data)


@app.route('/update-bus', methods=['PUT'])
def handle_update_bus():
    data = request.get_json()
    return update_bus(data)





#! Organization

@app.route('/add-organization', methods=['POST'])
def handle_add_organization():
    data = request.get_json()
    return add_organization(data)


@app.route('/get-organization-data/<string:id>', methods=['GET'])
def handle_get_organization_Data(id):
    return get_organization_data(id)


@app.route('/login-organization', methods=['POST'])
def handle_login_organization():
    data = request.get_json()
    return login_organization(data)





#! Routes

@app.route('/get-all-routes', methods=['POST'])
def handle_get_all_routes():
    data = request.get_json()
    return get_all_routes(data)


@app.route('/add-route', methods=['POST'])
def handle_add_route():
    data = request.get_json()
    return add_route(data)


@app.route('/delete-route', methods=['DELETE'])
def handle_delete_route():
    data = request.get_json()
    return delete_route(data)


@app.route('/update-route', methods=['PUT'])
def handle_update_route():
    data = request.get_json()
    return update_route(data)






@app.route('/', methods=['GET'])
def test_route():
    return "The routes are working!", 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
    print("Server is running on port 5000")