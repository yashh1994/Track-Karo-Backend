from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
import os
from Services.organization import add_organization, get_organization_data, login_organization
from Services.bus import add_bus, get_all_bus, delete_bus, update_bus
from Services.routes import add_route, get_all_routes, delete_route, update_route
from Services.driver import add_driver, get_all_drivers, delete_driver, update_driver, assign_bus_to_driver, revoke_driver_from_bus
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


@app.route('/assign-bus-to-driver',methods=['POST'])
def handle_assign_bus_to_driver():
    data = request.get_json()
    return assign_bus_to_driver(data)

@app.route('/revoke-driver-from-bus',methods=['POST'])
def handle_revoke_driver_from_bus():
    data = request.get_json()
    return revoke_driver_from_bus(data)





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
    return """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Karoza Backend</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body {
                background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
                color: #fff;
                font-family: 'Segoe UI', Arial, sans-serif;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                min-height: 100vh;
                margin: 0;
            }
            .container {
                background: rgba(0,0,0,0.4);
                padding: 40px 60px;
                border-radius: 18px;
                box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
                text-align: center;
            }
            h1 {
                font-size: 2.8rem;
                margin-bottom: 10px;
                letter-spacing: 2px;
            }
            p {
                font-size: 1.2rem;
                margin-top: 0;
                margin-bottom: 20px;
            }
            .logo {
                width: 80px;
                height: 80px;
                margin-bottom: 20px;
                border-radius: 50%;
                background: #fff;
                display: flex;
                align-items: center;
                justify-content: center;
                box-shadow: 0 4px 16px rgba(0,0,0,0.2);
            }
            .logo span {
                font-size: 2.5rem;
                color: #2a5298;
                font-weight: bold;
                font-family: 'Segoe UI', Arial, sans-serif;
            }
            @media (max-width: 600px) {
                .container {
                    padding: 20px 10px;
                }
                h1 {
                    font-size: 2rem;
                }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="logo"><span>🚌</span></div>
            <h1>Welcome to Karoza Backend</h1>
            <p>Your backend API is running.<br>
            Track-Karo Bus System - Backend Service</p>
        </div>
    </body>
    </html>
    """, 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
    print("Server is running on port 5000")