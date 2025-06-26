from Model.orm_models import Organization, BusAssignment, Bus, Driver, Route, Student
from db.session import Session
from flask import jsonify




# def revoke_student_from_bus(data):
#     session = Session()
#     try:
#         organization_id = data['organization_id']
#         student_id = data['student_id']
#         assignment_id = data['assignment_id']

#         bus_assignment = session.query(BusAssignment).filter_by(
#             id=assignment_id,
#             organization_id=organization_id
#         ).first()

#         if not bus_assignment:
#             return jsonify({"error": "No matching bus assignment found for this driver and bus"}), 404

#         student_id.driver_id = None
#         session.commit()
#         return jsonify({"message": "Driver revoked from bus successfully"}), 200

#     except Exception as e:
#         session.rollback()
#         print(f"Error revoking driver from bus: {e}")
#         return jsonify({"error": str(e)}), 500

#     finally:
#         session.close()


# def assign_bus_to_driver(data):
#     session = Session()
#     try:
#         organization_id = data['organization_id']
#         driver_id = data['driver_id']
#         assignment_id = data['assignment_id']  # FIX: previously wrongly named as bus_id

#         bus_assignment = session.query(BusAssignment).filter_by(
#             id=assignment_id,
#             organization_id=organization_id
#         ).first()

#         if not bus_assignment:
#             return jsonify({"error": "Invalid bus assignment: not found for this organization"}), 404

#         bus_assignment.driver_id = driver_id
#         session.commit()
#         return jsonify({"message": "Bus assigned to driver successfully"}), 200
        
#     except Exception as e:
#         session.rollback()
#         print(f"Error assigning bus to driver: {e}")
#         return jsonify({"error": str(e)}), 500

#     finally:
#         session.close()




def add_student(data):
    if not data:
        return jsonify({"error": "Invalid data provided"}), 400

    session = Session()

    try:
        # Extract student fields
        photo = data.get('photo')
        enrollment_number = data.get('enrollment_number')
        student_name = data.get('student_name')
        student_phone = data.get('student_phone')
        student_address = data.get('student_address')
        busfee_paid = data.get('busfee_paid')
        email = data.get('email')
        organization_id = data.get('organization_id')

        # Optional arrival/departure assignment IDs
        arrival_id = data.get('arrival_id')
        departure_id = data.get('departure_id')

        # Validate required fields
        required_fields = ['enrollment_number', 'student_name', 'student_phone',
                           'student_address', 'busfee_paid', 'email', 'organization_id']
        missing = [f for f in required_fields if data.get(f) is None]
        if missing:
            return jsonify({"error": f"Missing required fields: {', '.join(missing)}"}), 400

        # Create the student with IDs directly
        new_student = Student(
            photo=photo,
            enrollment_number=enrollment_number,
            student_name=student_name,
            student_phone=student_phone,
            student_address=student_address,
            busfee_paid=busfee_paid,
            email=email,
            organization_id=organization_id
        )

        # ✅ Just assign the IDs
        if arrival_id:
            new_student.arrival_bus_assignment_id = arrival_id
        if departure_id:
            new_student.departure_bus_assignment_id = departure_id

        session.add(new_student)
        session.commit()

        return jsonify({
            "message": "Student added successfully",
            "student_id": new_student.id
        }), 201

    except Exception as e:
        session.rollback()
        print(f"Error adding student: {e}")
        return jsonify({"error": str(e)}), 500

    finally:
        session.close()


def get_all_students(data):
    try:
        organization_id = data.get('organization_id', None)

        if organization_id is None:
            return jsonify({"error": "organization_id is required as a query parameter"}), 400
        
        session = Session()

        students = session.query(Student).filter_by(organization_id=organization_id).all()
        
        if not students:
            return jsonify([]), 200
        
        student_data = [student.to_json() for student in students]

        return jsonify(student_data), 200
    
    except Exception as e:
        print(f"Error fetching students: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        session.close()


def delete_student(data):
    id = data.get('id')
    organization_id = data.get('organization_id')

    if not id or not organization_id:
        return jsonify({"error": "Invalid input. 'id' and 'organization_id' are required."}), 400
    
    with Session() as session:
        try:
            student = session.query(Student).filter_by(id=id, organization_id=organization_id).first()
            if not student:
                return jsonify({"error": "Student not found"}), 404

            session.delete(student)
            session.commit()
            return jsonify({"message": "Student deleted successfully"}), 200

        except Exception as e:
            print(f"Error deleting student: {e}")
            return jsonify({"error": "An internal error occurred"}), 500


def update_student(data):
    id = data.get('id')
    organization_id = data.get('organization_id')

    if not id or not organization_id:
        return jsonify({"error": "Invalid input. 'id' and 'organization_id' are required."}), 400

    with Session() as session:
        try:
            student = session.query(Student).filter_by(id=id, organization_id=organization_id).first()
            if not student:
                return jsonify({"error": "Student not found"}), 404

            # Update basic fields
            student.photo = data.get('photo', student.photo)
            student.enrollment_number = data.get('enrollment_number', student.enrollment_number)
            student.student_name = data.get('student_name', student.student_name)
            student.student_phone = data.get('student_phone', student.student_phone)
            student.student_address = data.get('student_address', student.student_address)
            student.busfee_paid = data.get('busfee_paid', student.busfee_paid)
            student.email = data.get('email', student.email)

            # ✅ Optional: update arrival/departure assignment by ID
            if 'arrival_bus_assignment_id' in data:
                student.arrival_bus_assignment_id = data['arrival_bus_assignment_id']

            if 'departure_bus_assignment_id' in data:
                student.departure_bus_assignment_id = data['departure_bus_assignment_id']

            session.commit()
            return jsonify({"message": "Student updated successfully"}), 200

        except Exception as e:
            print(f"Error updating student: {e}")
            return jsonify({"error": f"An internal error occurred: {e}"}), 500


def get_details_from_student(data):
    student_id = data.get('student_id')
    organization_id = data.get('organization_id')

    if not student_id or not organization_id:
        return jsonify({"error": "Invalid input. 'student_id' and 'organization_id' are required."}), 400
    
    with Session() as session:
        try:
            student = session.query(Student).filter_by(id=student_id, organization_id=organization_id).first()
            if not student:
                return jsonify({"error": "Student not found"}), 404
            
            bus_number = student.bus_number
            route_number = student.route
            
            route = session.query(Route).filter_by(route_number=route_number, organization_id=organization_id).first()
            driver = session.query(Driver).filter_by(driver_busnumber=bus_number, driver_route=route_number,organization_id=organization_id).first()
            bus = session.query(Bus).filter_by(bus_number=bus_number, bus_route=route_number, organization_id=organization_id).first()


            student_data = {
                "route_details": {
                    "route_number": route.route_number if route and route.route_number else "Unknown",
                    "route_name": route.route_name if route and route.route_name else "Unknown",
                    "source": route.source if route and route.source else "Unknown",
                    "destination": route.destination if route and route.destination else "Unknown",
                    "stops": route.stops if route and route.stops else "Unknown"
                },
                "driver_details": {
                    "driver_photo": driver.driver_photo if driver and driver.driver_photo else "Unknown",
                    "driver_name": driver.driver_name if driver and driver.driver_name else "Unknown",
                    "driver_phone": driver.driver_phone if driver and driver.driver_phone else "Unknown",
                    "driver_status": driver.status if driver and driver.status else "Unknown",
                    "bus_number": driver.driver_busnumber if driver and driver.driver_busnumber else "Unknown",
                    "shift": bus.shift if bus and bus.shift else "Unknown",
                    "time": bus.time if bus and bus.time else "Unknown"
                },
                "student_details": {
                    "student_name": student.student_name if student and student.student_name else "Unknown",
                    "student_phone": student.student_phone if student and student.student_phone else "Unknown",
                    "student_address": student.student_address if student and student.student_address else "Unknown",
                    "busfee": student.busfee if student and student.busfee else "Unknown",
                    "student_class": student.student_class if student and student.student_class else "Unknown",
                    "email": student.email if student and student.email else "Unknown"
                }
            }

            return jsonify(student_data), 200

        except Exception as e:

            return jsonify({"error": "An internal error occurred"}), 500
        



