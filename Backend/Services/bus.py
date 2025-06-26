from Model.orm_models import Organization, BusAssignment, Bus, Driver, Route, Student
from db.session import Session
from flask import jsonify
from sqlalchemy.exc import IntegrityError


from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm.exc import NoResultFound

def add_bus(data):
    bus_number = data['bus_number']
    bus_seats = data['bus_seats']
    register_numberplate = data['register_numberplate']
    status = data['status']
    organization_id = data['organization_id']
    time = data['time']
    shift = data['shift']
    route_id = data['route_id']

    session = Session()
    try:
        # 1. Check if a bus with same registration plate already exists
        existing_bus = session.query(Bus).filter_by(
            register_numberplate=register_numberplate,
            organization_id=organization_id
        ).first()

        if existing_bus:
            bus_id = existing_bus.id
            print(f"Using existing bus with ID: {bus_id}")
        else:
            # 2. Add new bus if not found
            new_bus = Bus(
                bus_number=bus_number,
                bus_seats=bus_seats,
                register_numberplate=register_numberplate,
                status=status,
                organization_id=organization_id
            )
            session.add(new_bus)
            session.flush()  # Get new_bus.id without commit
            bus_id = new_bus.id
            print(f"Created new bus with ID: {bus_id}")

        # 3. Add BusAssignment for this bus
        bus_assignment = BusAssignment(
            organization_id=organization_id,
            bus_id=bus_id,
            shift=shift,
            time=time,
            route_id=route_id,
        )

        session.add(bus_assignment)
        session.commit()

        return jsonify({"message": "Bus assignment added successfully", "bus_id": bus_id}), 201

    except IntegrityError as e:
        session.rollback()
        if "uq_bus_shift_time" in str(e.orig):
            return jsonify({"error": "This bus already has an assignment for the given time and shift"}), 400
        return jsonify({"error": "Database integrity error"}), 400

    except Exception as e:
        session.rollback()
        print(f"Exception occurred while adding bus or assignment: {e}")
        return jsonify({"error": str(e)}), 500

    finally:
        session.close()


def get_all_bus(data):
    session = Session()
    try:
        organization_id = data.get('organization_id', None)
        
        if organization_id is None:
            return jsonify({"error": "organization_id is required as a query parameter"}), 400
        
        buses = session.query(Bus).filter_by(organization_id=organization_id).all()
        
        if not buses:
            return jsonify([]), 200
        
        bus_data = [bus.to_json() for bus in buses]
        
        return jsonify(bus_data), 200

    except Exception as e:
        print(f"Exception occurred while fetching buses: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        session.close()


def delete_bus(data):
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
            print(f"Exception occurred while deleting bus: {e}")
            return jsonify({"error": "An internal error occurred"}), 500
        finally:
            session.close()

def update_bus(data):
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
            bus.register_numberplate = data.get('register_numberplate', bus.register_numberplate)
            bus.status = data.get('status', bus.status)

            session.commit()
            return jsonify({"message": "Bus updated successfully"}), 200

        except Exception as e:
            print(f"Exception occurred while updating bus: {e}")
            return jsonify({"error": "An internal error occurred"}), 500
        finally:
            session.close()

