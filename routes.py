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

engine = create_engine(PG_DB_URL)
Base.metadata.create_all(engine)

Session = sessionmaker(bind=engine)



@app.route('/add_route', methods=['POST'])
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