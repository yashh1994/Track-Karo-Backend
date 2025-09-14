from Model.orm_models import Organization, BusAssignment, Bus, Driver, Route, Student
from db.session import Session
from flask import jsonify
from sqlalchemy.exc import IntegrityError


from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm.exc import NoResultFound



def update_bus_assignment(data):
    session = Session()
    try:
        organization_id = data.get('organization_id')
        bus_assignment_id = data.get('bus_assignment_id')
        route_id = data.get('route_id')
        shift = data.get('shift')
        time = data.get('time')
        driver_id = data.get('driver_id')

        bus_assignment = session.query(BusAssignment).filter_by(id=bus_assignment_id, organization_id=organization_id).one_or_none()
        if not bus_assignment:
            return jsonify({"error": "Bus assignment not found"}), 404

        if route_id is not None and route_id != bus_assignment.route_id:
            # Check if the route exists
            route = session.query(Route).filter_by(id=route_id, organization_id=organization_id).one_or_none()
            if not route:
                return jsonify({"error": "Route not found"}), 404

        bus_assignment.route_id = route_id or bus_assignment.route_id
        bus_assignment.shift = shift or bus_assignment.shift
        bus_assignment.time = time or bus_assignment.time
        
        if driver_id is not None and driver_id != bus_assignment.driver_id:
            # Check if the driver exists
            driver = session.query(Driver).filter_by(id=driver_id, organization_id=organization_id).one_or_none()
            if not driver:
                return jsonify({"error": "Driver not found"}), 404
        bus_assignment.driver_id = driver_id or bus_assignment.driver_id
        

        
        session.commit()
        return jsonify({"message": "Bus assignment updated successfully"}), 200
    except NoResultFound:
        return jsonify({"error": "Bus assignment not found"}), 404
    except Exception as e:
        print(f"Error updating bus assignment: {e}")
        return jsonify({"error": str(e)}), 500


def get_all_bus_assignments(data):
    session = Session()
    try:
        organization_id = data.get('organization_id', None)
        
        if organization_id is None:
            return jsonify({"error": "organization_id is required as a query parameter"}), 400

        bus_assignments = session.query(BusAssignment).filter_by(organization_id=organization_id).all()

        if not bus_assignments:
            return jsonify([]), 200
        
        bus_data = [bus_assignment.to_json() for bus_assignment in bus_assignments]
        
        return jsonify(bus_data), 200

    except Exception as e:
        print(f"Exception occurred while fetching buses: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        session.close()
