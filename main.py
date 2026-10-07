"""Create the FastAPI app and connect its route modules."""

import sqlite3
from datetime import date

from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse

from app.database import database_connection, initialize_database
from app.models import (
    Appointment,
    AppointmentInput,
    AppointmentStatus,
    Customer,
    CustomerInput,
    Pet,
    PetInput,
    User,
)

app = FastAPI(
    title="PVAS - Pet Veterinary Appointment System API",
    docs_url="/pvas",
)


@app.exception_handler(sqlite3.IntegrityError)
def handle_integrity_error(request: Request, error: sqlite3.IntegrityError):
    """Turn database rule violations (duplicate email, unknown id, ...) into a clean 409."""
    return JSONResponse(status_code=409, content={"detail": str(error)})


def found(result, name: str):
    """Return the result, or raise a 404 if the record does not exist."""
    if result is None:
        raise HTTPException(status_code=404, detail=f"{name} not found")
    return result


@app.get("/")
def home():
    return {"message": "Welcome to PVAS! Visit /pvas to try the API."}


# ----------------------------------------------------------------------- users


@app.get("/users")
def get_users():
    result = User.list_users(database_connection=database_connection)
    return {"users": result}


@app.get("/users/{user_id}")
def get_user(user_id: int):
    result = User.get_user(user_id=user_id, database_connection=database_connection)
    return {"user": found(result, "User")}


# ------------------------------------------------------------------- customers


@app.get("/customers")
def get_customers():
    result = Customer.list_customers(database_connection=database_connection)
    return {"customers": result}


@app.get("/customers/{customer_id}")
def get_customer(customer_id: int):
    result = Customer.get_customer(
        customer_id=customer_id, database_connection=database_connection
    )
    return {"customer": found(result, "Customer")}


@app.post("/customer", status_code=201)
def create_customer(customer: CustomerInput):
    result = Customer.create_customer(
        customer_input=customer, database_connection=database_connection
    )
    return {"customer": result}


@app.put("/customer/{customer_id}")
def edit_customer(customer_id: int, customer: CustomerInput):
    result = Customer.update_customer(
        customer_id=customer_id,
        customer_input=customer,
        database_connection=database_connection,
    )
    return {"customer": found(result, "Customer")}


@app.delete("/customer/{customer_id}")
def delete_customer(customer_id: int):
    deleted = Customer.delete_customer(
        customer_id=customer_id, database_connection=database_connection
    )
    found(deleted or None, "Customer")
    return {"message": "Customer deleted successfully"}


# ------------------------------------------------------------------------ pets


@app.get("/pets")
def get_pets(customer_id: int | None = None):
    result = Pet.list_pets(
        database_connection=database_connection, customer_id=customer_id
    )
    return {"pets": result}


@app.get("/pets/{pet_id}")
def get_pet(pet_id: int):
    result = Pet.get_pet(pet_id=pet_id, database_connection=database_connection)
    return {"pet": found(result, "Pet")}


@app.post("/pet", status_code=201)
def create_pet(pet: PetInput):
    result = Pet.create_pet(pet_input=pet, database_connection=database_connection)
    return {"pet": result}


@app.put("/pet/{pet_id}")
def edit_pet(pet_id: int, pet: PetInput):
    result = Pet.update_pet(
        pet_id=pet_id, pet_input=pet, database_connection=database_connection
    )
    return {"pet": found(result, "Pet")}


@app.delete("/pet/{pet_id}")
def delete_pet(pet_id: int):
    deleted = Pet.delete_pet(pet_id=pet_id, database_connection=database_connection)
    found(deleted or None, "Pet")
    return {"message": "Pet deleted successfully"}


# ---------------------------------------------------------------- appointments


@app.get("/appointments")
def get_appointments(
    status: AppointmentStatus | None = None, scheduled_date: date | None = None
):
    result = Appointment.list_appointments(
        database_connection=database_connection,
        status=status,
        scheduled_date=scheduled_date,
    )
    return {"appointments": result}


@app.get("/appointments/{appointment_id}")
def get_appointment(appointment_id: int):
    result = Appointment.get_appointment(
        appointment_id=appointment_id, database_connection=database_connection
    )
    return {"appointment": found(result, "Appointment")}


@app.get("/appointments/{appointment_id}/history")
def get_appointment_history(appointment_id: int):
    found(
        Appointment.get_appointment(
            appointment_id=appointment_id, database_connection=database_connection
        ),
        "Appointment",
    )
    result = Appointment.list_history(
        appointment_id=appointment_id, database_connection=database_connection
    )
    return {"history": result}


def check_pet_owner(appointment: AppointmentInput):
    """An appointment's pet must belong to the appointment's customer."""
    if not Appointment.pet_belongs_to_customer(
        pet_id=appointment.pet_id,
        customer_id=appointment.customer_id,
        database_connection=database_connection,
    ):
        raise HTTPException(
            status_code=400, detail="Pet does not exist or does not belong to this customer"
        )


@app.post("/appointment", status_code=201)
def create_appointment(appointment: AppointmentInput):
    check_pet_owner(appointment)
    result = Appointment.create_appointment(
        appointment_input=appointment, database_connection=database_connection
    )
    return {"appointment": result}


@app.put("/appointment/{appointment_id}")
def edit_appointment(appointment_id: int, appointment: AppointmentInput):
    check_pet_owner(appointment)
    result = Appointment.update_appointment(
        appointment_id=appointment_id,
        appointment_input=appointment,
        database_connection=database_connection,
    )
    return {"appointment": found(result, "Appointment")}


@app.delete("/appointment/{appointment_id}")
def delete_appointment(appointment_id: int):
    deleted = Appointment.delete_appointment(
        appointment_id=appointment_id, database_connection=database_connection
    )
    found(deleted or None, "Appointment")
    return {"message": "Appointment deleted successfully"}


initialize_database()
