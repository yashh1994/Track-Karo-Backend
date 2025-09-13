from Model.orm_models import Organization, BusAssignment, Bus, Driver, Route, Student
from db.session import Session
from flask import jsonify
from sqlalchemy.exc import IntegrityError


from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm.exc import NoResultFound




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
