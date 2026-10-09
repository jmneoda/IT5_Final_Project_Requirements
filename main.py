"""Create the FastAPI app and connect its route modules."""

import sqlite3
from datetime import date
from typing import Annotated

from fastapi import FastAPI, HTTPException, Path, Query, Request
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
    Role,
    Species,
    StatusChangeInput,
    User,
    UserInput,
    UserUpdate,
)

from app.services import AppointmentRuleError, AppointmentService

# Each tag becomes a collapsible group in the /pvas page.
tags_metadata = [
    {"name": "General", "description": "Welcome message."},
    {"name": "Users", "description": "Clinic staff accounts (admin, veterinarian, ...)."},
    {"name": "Customers", "description": "Pet owners."},
    {"name": "Pets", "description": "Pets that belong to a customer."},
    {"name": "Appointments", "description": "Bookings and their status history."},
]

app = FastAPI(
    title="PVAS - Pet Veterinary Appointment System API",
    docs_url="/pvas",
    openapi_tags=tags_metadata,
)

# A positive id taken from the URL, for example /customers/3
IdPath = Annotated[int, Path(gt=0)]

# Holds the appointment workflow rules (see app/services.py).
appointment_service = AppointmentService(database_connection)


@app.exception_handler(AppointmentRuleError)
def handle_appointment_rule_error(request: Request, error: AppointmentRuleError):
    """Turn a broken appointment rule into a clear HTTP error."""
    return JSONResponse(status_code=error.status_code, content={"detail": error.message})


@app.exception_handler(sqlite3.IntegrityError)
def handle_integrity_error(request: Request, error: sqlite3.IntegrityError):
    """Turn database rule violations (duplicate email, unknown id, ...) into a clean 409."""
    return JSONResponse(status_code=409, content={"detail": str(error)})


def found(result, name: str):
    """Return the result, or raise a 404 if the record does not exist."""
    if result is None:
        raise HTTPException(status_code=404, detail=f"{name} not found")
    return result


@app.get("/", tags=["General"])
def home():
    """Show a welcome message."""
    return {"message": "Welcome to PVAS! Visit /pvas to try the API."}


# ----------------------------------------------------------------------- users


@app.get("/users", tags=["Users"])
def get_users(role: Role | None = None):
    """List all staff users. Optional: filter by role."""
    result = User.list_users(database_connection=database_connection, role=role)
    return {"users": result}


@app.get("/users/{user_id}", tags=["Users"])
def get_user(user_id: IdPath):
    """Get one staff user by id."""
    result = User.get_user(user_id=user_id, database_connection=database_connection)
    return {"user": found(result, "User")}


@app.post("/user", status_code=201, tags=["Users"])
def create_user(user: UserInput):
    """Create a staff user. The password is stored hashed and is never returned."""
    result = User.create_user(user_input=user, database_connection=database_connection)
    return {"user": result}


@app.put("/user/{user_id}", tags=["Users"])
def edit_user(user_id: IdPath, user: UserUpdate):
    """Replace a staff user's details. Leave the password out to keep the current one."""
    result = User.update_user(
        user_id=user_id, user_input=user, database_connection=database_connection
    )
    return {"user": found(result, "User")}


@app.delete("/user/{user_id}", tags=["Users"])
def delete_user(user_id: IdPath):
    """Delete a staff user. Not allowed if they are the veterinarian on an appointment."""
    if User.is_assigned_to_appointments(
        user_id=user_id, database_connection=database_connection
    ):
        raise HTTPException(
            status_code=409,
            detail=(
                "This user is the veterinarian on existing appointments. "
                "Set is_active to false with PUT instead of deleting."
            ),
        )
    deleted = User.delete_user(user_id=user_id, database_connection=database_connection)
    found(deleted or None, "User")
    return {"message": "User deleted successfully"}


# ------------------------------------------------------------------- customers


@app.get("/customers", tags=["Customers"])
def get_customers(search: str | None = None):
    """List all customers. Optional: search by name, email, or contact number."""
    result = Customer.list_customers(
        database_connection=database_connection, search=search
    )
    return {"customers": result}


@app.get("/customers/{customer_id}", tags=["Customers"])
def get_customer(customer_id: IdPath):
    """Get one customer by id."""
    result = Customer.get_customer(
        customer_id=customer_id, database_connection=database_connection
    )
    return {"customer": found(result, "Customer")}


@app.post("/customer", status_code=201, tags=["Customers"])
def create_customer(customer: CustomerInput):
    """Create a customer."""
    result = Customer.create_customer(
        customer_input=customer, database_connection=database_connection
    )
    return {"customer": result}


@app.put("/customer/{customer_id}", tags=["Customers"])
def edit_customer(customer_id: IdPath, customer: CustomerInput):
    """Replace a customer's details. Send every field you want to keep."""
    result = Customer.update_customer(
        customer_id=customer_id,
        customer_input=customer,
        database_connection=database_connection,
    )
    return {"customer": found(result, "Customer")}


@app.delete("/customer/{customer_id}", tags=["Customers"])
def delete_customer(customer_id: IdPath):
    """Delete a customer. Their pets and appointments are deleted too."""
    deleted = Customer.delete_customer(
        customer_id=customer_id, database_connection=database_connection
    )
    found(deleted or None, "Customer")
    return {"message": "Customer deleted successfully"}


# ------------------------------------------------------------------------ pets


@app.get("/pets", tags=["Pets"])
def get_pets(
    customer_id: int | None = None,
    species: Species | None = None,
    search: str | None = None,
):
    """List all pets. Optional: filter by owner, species, or search pet name and breed."""
    result = Pet.list_pets(
        database_connection=database_connection,
        customer_id=customer_id,
        species=species,
        search=search,
    )
    return {"pets": result}


@app.get("/pets/{pet_id}", tags=["Pets"])
def get_pet(pet_id: IdPath):
    """Get one pet by id."""
    result = Pet.get_pet(pet_id=pet_id, database_connection=database_connection)
    return {"pet": found(result, "Pet")}


@app.post("/pet", status_code=201, tags=["Pets"])
def create_pet(pet: PetInput):
    """Create a pet for an existing customer."""
    result = Pet.create_pet(pet_input=pet, database_connection=database_connection)
    return {"pet": result}


@app.put("/pet/{pet_id}", tags=["Pets"])
def edit_pet(pet_id: IdPath, pet: PetInput):
    """Replace a pet's details. Send every field you want to keep."""
    result = Pet.update_pet(
        pet_id=pet_id, pet_input=pet, database_connection=database_connection
    )
    return {"pet": found(result, "Pet")}


@app.delete("/pet/{pet_id}", tags=["Pets"])
def delete_pet(pet_id: IdPath):
    """Delete a pet. Its appointments are deleted too."""
    deleted = Pet.delete_pet(pet_id=pet_id, database_connection=database_connection)
    found(deleted or None, "Pet")
    return {"message": "Pet deleted successfully"}


# ---------------------------------------------------------------- appointments


@app.get("/appointments", tags=["Appointments"])
def get_appointments(
    status: AppointmentStatus | None = None,
    scheduled_date: date | None = None,
    veterinarian_id: int | None = None,
    customer_id: int | None = None,
    pet_id: int | None = None,
):
    """List all appointments. Optional: filter by status, date, vet, customer, or pet."""
    result = Appointment.list_appointments(
        database_connection=database_connection,
        status=status,
        scheduled_date=scheduled_date,
        veterinarian_id=veterinarian_id,
        customer_id=customer_id,
        pet_id=pet_id,
    )
    return {"appointments": result}


@app.get("/appointments/schedule", tags=["Appointments"])
def get_vet_schedule(veterinarian_id: Annotated[int, Query(gt=0)], scheduled_date: date):
    """Show the time slots a veterinarian already has booked on a date."""
    result = appointment_service.schedule(
        veterinarian_id=veterinarian_id, scheduled_date=scheduled_date
    )
    return {"booked": result}


@app.get("/appointments/{appointment_id}", tags=["Appointments"])
def get_appointment(appointment_id: IdPath):
    """Get one appointment by id."""
    return {"appointment": appointment_service.get(appointment_id)}


@app.get("/appointments/{appointment_id}/history", tags=["Appointments"])
def get_appointment_history(appointment_id: IdPath):
    """Show every status change of an appointment, oldest first."""
    return {"history": appointment_service.history(appointment_id)}


@app.post("/appointment", status_code=201, tags=["Appointments"])
def create_appointment(appointment: AppointmentInput):
    """Book an appointment.

    Rules: it must start as scheduled or confirmed, the pet must belong to the
    customer, and the veterinarian must be free at that date and time.
    """
    return {"appointment": appointment_service.book(appointment)}


@app.put("/appointment/{appointment_id}", tags=["Appointments"])
def edit_appointment(appointment_id: IdPath, appointment: AppointmentInput):
    """Edit or reschedule an appointment. The same booking and status rules apply."""
    return {"appointment": appointment_service.update(appointment_id, appointment)}


@app.patch("/appointments/{appointment_id}/status", tags=["Appointments"])
def change_appointment_status(appointment_id: IdPath, status_change: StatusChangeInput):
    """Move an appointment to a new status and log it in its history.

    Allowed: scheduled to confirmed or canceled; confirmed to completed,
    no_show, or canceled. Completed, no_show, and canceled are final.
    """
    return {"appointment": appointment_service.change_status(appointment_id, status_change)}


@app.delete("/appointment/{appointment_id}", tags=["Appointments"])
def delete_appointment(appointment_id: IdPath):
    """Delete an appointment. Its status history is deleted too."""
    appointment_service.delete(appointment_id)
    return {"message": "Appointment deleted successfully"}


initialize_database()
