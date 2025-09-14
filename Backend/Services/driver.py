from Model.orm_models import Organization, BusAssignment, Bus, Driver, Route, Student
from db.session import Session
from flask import jsonify


def add_driver(data):
    driver_photo = data.get('driver_photo')
    driver_name = data['driver_name']
    driver_phone = data['driver_phone']
    driver_address = data['driver_address']
    organization_id = data['organization_id']
    driver_salary = data.get('driver_salary')
    

    new_driver = Driver(
        driver_photo=driver_photo,
        driver_name=driver_name,
        driver_phone=driver_phone,
        driver_address=driver_address,
        organization_id=organization_id,
        driver_salary=driver_salary,
    )

    session = Session()
    try:
        # Step 1: Add new driver
        session.add(new_driver)
        # session.flush()  # Get new_driver.id before commit

        # Step 2: Find the matching BusAssignment
        # bus_assignment = session.query(BusAssignment).filter_by(
        #     bus_id=bus_id,
        #     time=time,
        #     shift=shift
        # ).first()

        # if not bus_assignment:
        #     session.rollback()
        #     return jsonify({"error": "No matching bus assignment found for the given bus_id, time, and shift"}), 404

        # # Step 3: Assign the driver to the BusAssignment
        # bus_assignment.driver_id = new_driver.id

        session.commit()
        return jsonify({
            "message": "Driver added and assigned to bus successfully",
            "driver_id": new_driver.id,
            # "bus_assignment_id": bus_assignment.id
        }), 200

    except Exception as e:
        session.rollback()
        print(f"Error adding driver or assigning to bus: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        session.close()

def revoke_driver_from_bus(data):
    session = Session()
    try:
        organization_id = data['organization_id']
        driver_id = data['driver_id']
        assignment_id = data['assignment_id']

        bus_assignment = session.query(BusAssignment).filter_by(
            id=assignment_id,
            organization_id=organization_id,
            driver_id=driver_id
        ).first()

        if not bus_assignment or bus_assignment.driver_id != driver_id:
            return jsonify({"error": "No matching bus assignment found for this driver and bus"}), 404
 
        bus_assignment.driver_id = None
        session.commit()
        return jsonify({"message": "Driver revoked from bus successfully"}), 200

    except Exception as e:
        session.rollback()
        print(f"Error revoking driver from bus: {e}")
        return jsonify({"error": str(e)}), 500

    finally:
        session.close()


def assign_bus_to_driver(data):
    session = Session()
    try:
        organization_id = data['organization_id']
        driver_id = data['driver_id']
        assignment_id = data['assignment_id']  # FIX: previously wrongly named as bus_id

        bus_assignment = session.query(BusAssignment).filter_by(
            id=assignment_id,
            organization_id=organization_id
        ).first()

        if not bus_assignment:
            return jsonify({"error": "Invalid bus assignment: not found for this organization"}), 404

        bus_assignment.driver_id = driver_id
        session.commit()
        return jsonify({"message": "Bus assigned to driver successfully"}), 200
        
    except Exception as e:
        session.rollback()
        print(f"Error assigning bus to driver: {e}")
        return jsonify({"error": str(e)}), 500

    finally:
        session.close()



def get_all_drivers(data):
    try:
        organization_id = data.get('organization_id', None)

        if organization_id is None:
            return jsonify({"error": "organization_id is required as a query parameter"}), 400
        
        session = Session()

        drivers = session.query(Driver).filter_by(organization_id=organization_id).all()
        
        if not drivers:
            return jsonify([]), 200
        
        driver_data = [driver.to_json() for driver in drivers]

        return jsonify(driver_data), 200
    
    except Exception as e:
        print(f"Error fetching drivers: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        session.close()


def delete_driver(data):
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
            print(f"Error deleting driver: {e}")
            return jsonify({"error": "An internal error occurred"}), 500
  

def update_driver(data):
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
            driver.driver_salary = data.get('driver_salary', driver.driver_salary)

            session.commit()
            return jsonify({"message": "Driver updated successfully"}), 200

        except Exception as e:
            print(f"Error updating driver: {e}")
            return jsonify({"error": "An internal error occurred"}), 500    
