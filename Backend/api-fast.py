from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, HTMLResponse
from pydantic import BaseModel
from dotenv import load_dotenv
import os
from Services.organization import add_organization, get_organization_data, login_organization
from Services.bus import add_bus, get_all_bus, delete_bus, update_bus
from Services.routes import add_route, get_all_routes, delete_route, update_route
from Services.driver import add_driver, get_all_drivers, delete_driver, update_driver, assign_bus_to_driver, revoke_driver_from_bus
from Services.student import add_student, get_all_students, delete_student, get_details_from_student, update_student
from ai_chat import chat_query

load_dotenv(dotenv_path='./pro.env')

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class QueryModel(BaseModel):
    query: str

class DataModel(BaseModel):
    data: dict


@app.post("/ai-chat-query")
async def handle_ai_chat_query(query: QueryModel):
    response = None
    for _ in range(3):
        response = chat_query(query.query)
        if isinstance(response, tuple) and len(response) > 1 and response[1] == 200:
            return JSONResponse(content=response[0], status_code=200)
        elif isinstance(response, dict):
            return JSONResponse(content=response)
    return JSONResponse(content=response if response else {"error": "Failed to generate response"})


@app.post("/add-student")
async def handle_add_student(data: dict):
    return add_student(data)

@app.post("/get-all-students")
async def handle_get_all_students(data: dict):
    return get_all_students(data)

@app.delete("/delete-student")
async def handle_delete_student(data: dict):
    return delete_student(data)

@app.put("/update-student")
async def handle_update_student(data: dict):
    return update_student(data)

@app.get("/get-details-from-student")
async def handle_get_details_from_student(request: Request):
    data = await request.json()
    return get_details_from_student(data)

@app.post("/add-driver")
async def handle_add_driver(data: dict):
    return add_driver(data)

@app.post("/get-all-drivers")
async def handle_get_all_drivers(data: dict):
    return get_all_drivers(data)

@app.delete("/delete-driver")
async def handle_delete_driver(data: dict):
    return delete_driver(data)

@app.put("/update-driver")
async def handle_update_driver(data: dict):
    return update_driver(data)

@app.post("/assign-bus-to-driver")
async def handle_assign_bus_to_driver(data: dict):
    return assign_bus_to_driver(data)

@app.post("/revoke-driver-from-bus")
async def handle_revoke_driver_from_bus(data: dict):
    return revoke_driver_from_bus(data)

@app.post("/add-bus")
async def handle_add_bus(data: dict):
    return add_bus(data)

@app.post("/get-all-bus")
async def handle_get_all_bus(data: dict):
    return get_all_bus(data)

@app.delete("/delete-bus")
async def handle_delete_bus(data: dict):
    return delete_bus(data)

@app.put("/update-bus")
async def handle_update_bus(data: dict):
    return update_bus(data)

@app.post("/add-organization")
async def handle_add_organization(data: dict):
    return add_organization(data)

@app.get("/get-organization-data/{id}")
async def handle_get_organization_data(id: str):
    return get_organization_data(id)

@app.post("/login-organization")
async def handle_login_organization(data: dict):
    return login_organization(data)

@app.post("/get-all-routes")
async def handle_get_all_routes(data: dict):
    return get_all_routes(data)

@app.post("/add-route")
async def handle_add_route(data: dict):
    return add_route(data)

@app.delete("/delete-route")
async def handle_delete_route(data: dict):
    return delete_route(data)

@app.put("/update-route")
async def handle_update_route(data: dict):
    return update_route(data)

@app.get("/")
async def test_route():
    html_content = """
    <!DOCTYPE html>
    <html lang=\"en\">
    <head>
        <meta charset=\"UTF-8\">
        <title>Karoza Backend</title>
        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
        <style>body{background:linear-gradient(135deg,#1e3c72 0%,#2a5298 100%);color:#fff;font-family:'Segoe UI',Arial,sans-serif;display:flex;flex-direction:column;align-items:center;justify-content:center;min-height:100vh;margin:0}.container{background:rgba(0,0,0,0.4);padding:40px 60px;border-radius:18px;box-shadow:0 8px 32px 0 rgba(31,38,135,0.37);text-align:center}h1{font-size:2.8rem;margin-bottom:10px;letter-spacing:2px}p{font-size:1.2rem;margin-top:0;margin-bottom:20px}.logo{width:80px;height:80px;margin-bottom:20px;border-radius:50%;background:#fff;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 16px rgba(0,0,0,0.2)}.logo span{font-size:2.5rem;color:#2a5298;font-weight:bold;font-family:'Segoe UI',Arial,sans-serif}@media(max-width:600px){.container{padding:20px 10px}h1{font-size:2rem}}</style>
    </head>
    <body>
        <div class=\"container\">
<div class=\"logo\"><span>🚌</span></div>
            <h1>Welcome to Karoza Backend</h1>
            <p>Your backend API is running.<br>
            Track-Karo Bus System - Backend Service</p>
        </div>
    </body>
    </html>
    """
    return HTMLResponse(content=html_content, status_code=200)
