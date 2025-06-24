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
        session.add(new_driver)
        session.commit()
        return jsonify({"message": "Driver added successfully"}), 200
    except Exception as e:
        session.rollback()
        print(f"Error adding driver: {e}")
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
