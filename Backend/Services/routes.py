from Model.orm_models import Organization, BusAssignment, Bus, Driver, Route, Student
from db.session import Session
from flask import jsonify




def get_all_routes(data):
    session = Session()
    try:

        organization_id = data.get('organization_id', None)
        
        if organization_id is None:
            return jsonify({"error": "organization_id is required as a query parameter"}), 400
        
        routes = session.query(Route).filter_by(organization_id=organization_id).all()
        
        if not routes:
            return jsonify([]), 200
        
        route_data = [route.to_json() for route in routes]
        
        return jsonify(route_data), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        session.close()


def add_route(data):
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
        print(f"----- Error while Adding Route: {e} ------------")
        return jsonify({"error": str(e)}), 500
    finally:
        session.close()


def delete_route(data):
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
            return jsonify({"error": "An internal error occurred"}), 500


def update_route(data):
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
            return jsonify({"error": "An internal error occurred"}), 500

