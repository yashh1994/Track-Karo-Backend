from dotenv import load_dotenv
import re
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from Model.orm_models import Organization, BusAssignment, Bus, Driver, Route, Student
from sqlalchemy import text
import google.generativeai as genai
from db.session import Session


load_dotenv(dotenv_path='./pro.env')
GEMINI_MODEL_API_KEY = os.getenv('GEMINI_MODEL_API_KEY')

genai.configure(api_key=GEMINI_MODEL_API_KEY)  # Replace with your actual key
model = genai.GenerativeModel("gemini-2.0-flash-lite")

def get_driver_details(driver_name: str):
    session = Session()
    try:
        # Search for the driver case-insensitively
        driver = session.query(Driver).filter(Driver.driver_name.ilike(driver_name)).first()

        if not driver:
            return {"error": f"Driver '{driver_name}' not found."}, 404

        # Fetch all assignments for this driver
        assignments = session.query(BusAssignment).filter(
            BusAssignment.driver_id == driver.id
        ).all()

        assignment_data = []
        for a in assignments:
            bus = session.query(Bus).filter(Bus.id == a.bus_id).first()
            assignment_data.append({
                "bus_number": bus.bus_number if bus else "Unknown",
                "shift": a.shift,
                "time": a.time.strftime("%H:%M") if hasattr(a.time, 'strftime') else str(a.time)
            })

        data = {
            "driver_name": driver.driver_name,
            "driver_phone": driver.driver_phone,
            "assignments": assignment_data
        }

        return {"message": humanize_message("Driver Status", data)}, 200

    except Exception as e:
        return {"error": f"An unexpected error occurred: {str(e)}"}, 500

    finally:
        session.close()

def get_free_drivers():
    session = Session()
    try:
        # Get all assigned driver IDs
        assigned_driver_ids = {
            ba.driver_id for ba in session.query(BusAssignment).filter(BusAssignment.driver_id != None).all()
        }

        # Get all drivers not in assigned list
        free_drivers = session.query(Driver).filter(~Driver.id.in_(assigned_driver_ids)).all()

        # Format result
        result = [
            {
                "driver_name": d.driver_name,
                "driver_phone": d.driver_phone
            } for d in free_drivers
        ]

        query = "List all drivers who are currently free (not assigned to any bus)."
        return {"message": humanize_message(query, result)}, 200

    except Exception as e:
        return {"error": f"An error occurred while fetching free drivers: {str(e)}"}, 500

    finally:
        session.close()

def get_stops_on_route(route_number: str):
    session = Session()
    try:
        # Find route by route_number
        route = session.query(Route).filter(Route.route_number == str(route_number)).first()

        if not route:
            return {
                'success': False,
                'message': f'Route with number {route_number} not found',
                'data': None
            }, 404

        # Extract location_name from each stop
        stops = [
            stop.get("location_name", "Unnamed Stop")
            for stop in route.stops if isinstance(stop, dict)
        ]

        # data = {
        #     "route_number": route.route_number,
        #     "route_name": route.route_name,
        #     "source": route.source.get("location_name", "Unknown Source"),
        #     "destination": route.destination.get("location_name", "Unknown Destination"),
        #     "stops": stops,
        #     "total_stops": len(stops)
        # }

        query = f"Show all stops for route {route_number}"
        return {"message": humanize_message(query, stops)}, 200

    except Exception as e:
        return {"error": f"Error retrieving route: {str(e)}"}, 500

    finally:
        session.close()

def get_buses_on_route(route_number: str):
    session = Session()
    try:
        # Find the route by its number
        route = session.query(Route).filter(Route.route_number == str(route_number)).first()

        if not route:
            return {
                "error": f"Route with number {route_number} not found."
            }, 404

        # Get all bus assignments for the route
        assignments = session.query(BusAssignment).filter(BusAssignment.route_id == route.id).all()

        # Get distinct bus IDs from assignments
        bus_ids = {a.bus_id for a in assignments}

        # Get all buses matching those IDs
        buses = session.query(Bus).filter(Bus.id.in_(bus_ids)).all()

        bus_numbers = [bus.bus_number for bus in buses]

        data = {
            "route_number": route.route_number,
            "route_name": route.route_name,
            "bus_count": len(bus_numbers),
            "bus_numbers": bus_numbers
        }

        query = f"Show all buses assigned to route {route_number}"
        return {"message": humanize_message(query, data)}, 200

    except Exception as e:
        return {"error": f"Error fetching buses: {str(e)}"}, 500

    finally:
        session.close()

def get_students_on_route(route_number: str):
    session = Session()
    try:
        # Get the route (case-insensitive)
        route = session.query(Route).filter(Route.route_number.ilike(route_number)).first()
        if not route:
            return {"error": f"Route '{route_number}' not found."}, 404

        # Get all bus assignments for the route
        assignments = session.query(BusAssignment).filter(BusAssignment.route_id == route.id).all()
        if not assignments:
            return {"message": f"No buses assigned to route '{route_number}'."}, 200

        assignment_ids = {a.id for a in assignments}

        # Get all students whose arrival or departure assignment matches one of the bus assignments
        students = session.query(Student).filter(
            (Student.arrival_bus_assignment_id.in_(assignment_ids)) |
            (Student.departure_bus_assignment_id.in_(assignment_ids))
        ).all()

        student_names = [s.student_name for s in students]

        query = f"Show students traveling on route '{route_number}'"
        data = {
            "route_name": route.route_name,
            "route_number": route.route_number,
            "total_students": len(student_names),
            "students": student_names
        }

        return {"message": humanize_message(query, data)}, 200

    except Exception as e:
        return {"error": f"Failed to fetch students: {str(e)}"}, 500

    finally:
        session.close()




def humanize_message(query, response):
    prompt = f"""
    Convert the following JSON data into a clear, human-readable message that summarizes the key information in a friendly and concise way. Only describe the contents of the JSON response. Do not explain errors, the query, or add extra commentary.Only give me Message nothing else.

    Query:
    {query}
    
    JSON response:
    {response}
    """
    res = model.generate_content(prompt).text.strip()
    return res 




# def chat_query(query):
#     prompt = f"""
#     As an admin assistant, map this to one of:
#     get_driver_status(driver_name)
#     get_students_on_route(route_number)
#     get_free_drivers()
#     get_stops_on_route(route_number)
#     get_buses_on_route(route_number)

#     Query: {query}
#     Only reply with the function call.
#     """
#     mapped = model.generate_content(prompt).text.strip()
#     return run_action(mapped)


def chat_query(query: str):
    prompt = f"""
    You are a backend assistant. Your job is to convert admin questions into exact function calls.

    Available functions:
    - get_driver_details(driver_name)
    - get_students_on_route(route_name)
    - get_free_drivers()
    - get_stops_on_route(route_number)
    - get_buses_on_route(route_number)

    Your response must only be a valid function call, nothing else.

    Query:
    {query}
        """.strip()

    mapped_call = model.generate_content(prompt).text.strip()
    print("🔁 Mapped to:", mapped_call)
    return run_action(mapped_call)


def run_action(action_text: str):
    match = re.match(r'(\w+)\((.*)\)', action_text)
    if not match:
        return {"error": "Couldn't parse function call."}, 400

    fn_name, arg_string = match.groups()
    kwargs = {}
    args = []

    if arg_string.strip():
        for token in re.split(r',(?![^{]*\})', arg_string):  # supports JSON-like arguments
            if "=" in token:
                key, value = map(str.strip, token.split("="))
                kwargs[key] = value.strip('"').strip("'")
            else:
                args.append(token.strip('"').strip("'"))

    # Execute based on matched function
    try:
        if fn_name == "get_driver_details":
            driver_name = kwargs.get("driver_name") or (args[0] if args else None)
            return get_driver_details(driver_name)
        
        elif fn_name == "get_students_on_route":
            route_name = kwargs.get("route_name") or (args[0] if args else None)
            return get_students_on_route(route_name)
        
        elif fn_name == "get_free_drivers":
            return get_free_drivers()
        
        elif fn_name == "get_stops_on_route":
            route_number = kwargs.get("route_number") or (args[0] if args else None)
            return get_stops_on_route(route_number)
        
        elif fn_name == "get_buses_on_route":
            route_number = kwargs.get("route_number") or (args[0] if args else None)
            return get_buses_on_route(route_number)
        
        return {"error": f"Unknown function: {fn_name}"}, 400

    except Exception as e:
        return {"error": f"Failed to execute {fn_name}: {str(e)}"}, 500

# print(get_students_on_route("104"))
# print(get_stops_on_route("105"))
# print(get_free_drivers()[0]['message'])
# print(humanize_message("driver status",get_driver_details("Driver 1")))





