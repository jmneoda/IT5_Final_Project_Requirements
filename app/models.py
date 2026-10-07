"""Data models used to validate API input and output."""

from datetime import date, datetime, time
from typing import Literal

from pydantic import BaseModel, Field

Species = Literal["Dog", "Cat", "Bird", "Rabbit", "Hamster", "Other"]
Gender = Literal["Male", "Female"]
AppointmentType = Literal["Checkup", "Vaccination", "Surgery", "Grooming"]
AppointmentStatus = Literal["scheduled", "confirmed", "completed", "no_show", "canceled"]


def now() -> str:
    """Current local time in the same text format used by the seed data."""
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def to_dict(row):
    """Turn a sqlite3.Row into a plain dict (or None) so FastAPI can return it as JSON."""
    return dict(row) if row is not None else None


# --------------------------------------------------------------------------- users

USER_COLUMNS = "id, name, email, role, phone_number, is_active"


class User(BaseModel):
    """A staff member. Read-only through the API; the password is never returned."""

    id: int
    name: str
    email: str
    role: str
    phone_number: str | None = None
    is_active: int

    @staticmethod
    def list_users(database_connection):
        with database_connection() as connection:
            rows = connection.execute(
                f"SELECT {USER_COLUMNS} FROM users ORDER BY id"
            ).fetchall()
        return [to_dict(row) for row in rows]

    @staticmethod
    def get_user(user_id, database_connection):
        with database_connection() as connection:
            row = connection.execute(
                f"SELECT {USER_COLUMNS} FROM users WHERE id = ?", (user_id,)
            ).fetchone()
        return to_dict(row)


# ----------------------------------------------------------------------- customers


class CustomerInput(BaseModel):
    """Fields sent when creating or updating a customer (pet owner)."""

    first_name: str = Field(min_length=1)
    last_name: str = Field(min_length=1)
    email: str | None = None
    contact_number: str = Field(min_length=1)
    address: str | None = None
    registered_by: int | None = None


class Customer(CustomerInput):
    """A customer record returned by the API."""

    id: int
    created_at: str | None = None
    updated_at: str | None = None

    @staticmethod
    def list_customers(database_connection):
        with database_connection() as connection:
            rows = connection.execute("SELECT * FROM customers ORDER BY id").fetchall()
        return [to_dict(row) for row in rows]

    @staticmethod
    def get_customer(customer_id, database_connection):
        with database_connection() as connection:
            row = connection.execute(
                "SELECT * FROM customers WHERE id = ?", (customer_id,)
            ).fetchone()
        return to_dict(row)

    @staticmethod
    def create_customer(customer_input, database_connection):
        with database_connection() as connection:
            cursor = connection.execute(
                """
                INSERT INTO customers
                    (registered_by, first_name, last_name, email, contact_number,
                     address, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    customer_input.registered_by,
                    customer_input.first_name,
                    customer_input.last_name,
                    customer_input.email,
                    customer_input.contact_number,
                    customer_input.address,
                    now(),
                    now(),
                ),
            )
            row = connection.execute(
                "SELECT * FROM customers WHERE id = ?", (cursor.lastrowid,)
            ).fetchone()
        return to_dict(row)

    @staticmethod
    def update_customer(customer_id, customer_input, database_connection):
        with database_connection() as connection:
            connection.execute(
                """
                UPDATE customers
                SET registered_by = ?, first_name = ?, last_name = ?, email = ?,
                    contact_number = ?, address = ?, updated_at = ?
                WHERE id = ?
                """,
                (
                    customer_input.registered_by,
                    customer_input.first_name,
                    customer_input.last_name,
                    customer_input.email,
                    customer_input.contact_number,
                    customer_input.address,
                    now(),
                    customer_id,
                ),
            )
            row = connection.execute(
                "SELECT * FROM customers WHERE id = ?", (customer_id,)
            ).fetchone()
        return to_dict(row)

    @staticmethod
    def delete_customer(customer_id, database_connection):
        """Return True if a row was deleted. Pets and appointments cascade."""
        with database_connection() as connection:
            cursor = connection.execute(
                "DELETE FROM customers WHERE id = ?", (customer_id,)
            )
        return cursor.rowcount > 0


# ---------------------------------------------------------------------------- pets


class PetInput(BaseModel):
    """Fields sent when creating or updating a pet."""

    customer_id: int
    pet_name: str = Field(min_length=1)
    species: Species
    breed: str | None = None
    gender: Gender | None = None
    birthdate: date | None = None
    color: str | None = None
    weight: float | None = Field(default=None, ge=0)
    medical_notes: str | None = None


class Pet(PetInput):
    """A pet record returned by the API."""

    id: int
    created_at: str | None = None
    updated_at: str | None = None

    @staticmethod
    def list_pets(database_connection, customer_id=None):
        query = "SELECT * FROM pets"
        params = ()
        if customer_id is not None:
            query += " WHERE customer_id = ?"
            params = (customer_id,)
        with database_connection() as connection:
            rows = connection.execute(query + " ORDER BY id", params).fetchall()
        return [to_dict(row) for row in rows]

    @staticmethod
    def get_pet(pet_id, database_connection):
        with database_connection() as connection:
            row = connection.execute(
                "SELECT * FROM pets WHERE id = ?", (pet_id,)
            ).fetchone()
        return to_dict(row)

    @staticmethod
    def _values(pet_input):
        birthdate = pet_input.birthdate.isoformat() if pet_input.birthdate else None
        return (
            pet_input.customer_id,
            pet_input.pet_name,
            pet_input.species,
            pet_input.breed,
            pet_input.gender,
            birthdate,
            pet_input.color,
            pet_input.weight,
            pet_input.medical_notes,
        )

    @staticmethod
    def create_pet(pet_input, database_connection):
        with database_connection() as connection:
            cursor = connection.execute(
                """
                INSERT INTO pets
                    (customer_id, pet_name, species, breed, gender, birthdate,
                     color, weight, medical_notes, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                Pet._values(pet_input) + (now(), now()),
            )
            row = connection.execute(
                "SELECT * FROM pets WHERE id = ?", (cursor.lastrowid,)
            ).fetchone()
        return to_dict(row)

    @staticmethod
    def update_pet(pet_id, pet_input, database_connection):
        with database_connection() as connection:
            connection.execute(
                """
                UPDATE pets
                SET customer_id = ?, pet_name = ?, species = ?, breed = ?, gender = ?,
                    birthdate = ?, color = ?, weight = ?, medical_notes = ?, updated_at = ?
                WHERE id = ?
                """,
                Pet._values(pet_input) + (now(), pet_id),
            )
            row = connection.execute(
                "SELECT * FROM pets WHERE id = ?", (pet_id,)
            ).fetchone()
        return to_dict(row)

    @staticmethod
    def delete_pet(pet_id, database_connection):
        """Return True if a row was deleted. Appointments for the pet cascade."""
        with database_connection() as connection:
            cursor = connection.execute("DELETE FROM pets WHERE id = ?", (pet_id,))
        return cursor.rowcount > 0


# ---------------------------------------------------------------------- appointments


class AppointmentInput(BaseModel):
    """Fields sent when creating or updating an appointment."""

    customer_id: int
    pet_id: int
    veterinarian_id: int
    scheduled_date: date
    scheduled_time: time
    reason_for_visit: str | None = None
    type: AppointmentType | None = None
    status: AppointmentStatus = "scheduled"
    # The staff member making this change. Stored as created_by / updated_by
    # and as changed_by in the status history.
    user_id: int | None = None


class AppointmentStatusHistory(BaseModel):
    """One entry in an appointment's status log."""

    id: int
    appointment_id: int
    status: str
    changed_by: int | None = None
    changed_at: str


class Appointment(BaseModel):
    """An appointment record returned by the API."""

    id: int
    customer_id: int
    pet_id: int
    veterinarian_id: int
    scheduled_date: date
    scheduled_time: time
    reason_for_visit: str | None = None
    type: AppointmentType | None = None
    status: AppointmentStatus
    created_by: int | None = None
    updated_by: int | None = None
    created_at: str | None = None
    updated_at: str | None = None

    @staticmethod
    def list_appointments(database_connection, status=None, scheduled_date=None):
        conditions, params = [], []
        if status is not None:
            conditions.append("status = ?")
            params.append(status)
        if scheduled_date is not None:
            conditions.append("scheduled_date = ?")
            params.append(scheduled_date.isoformat())
        query = "SELECT * FROM appointments"
        if conditions:
            query += " WHERE " + " AND ".join(conditions)
        with database_connection() as connection:
            rows = connection.execute(
                query + " ORDER BY scheduled_date, scheduled_time, id", params
            ).fetchall()
        return [to_dict(row) for row in rows]

    @staticmethod
    def get_appointment(appointment_id, database_connection):
        with database_connection() as connection:
            row = connection.execute(
                "SELECT * FROM appointments WHERE id = ?", (appointment_id,)
            ).fetchone()
        return to_dict(row)

    @staticmethod
    def pet_belongs_to_customer(pet_id, customer_id, database_connection):
        """Check the pet exists and is owned by the customer."""
        with database_connection() as connection:
            row = connection.execute(
                "SELECT 1 FROM pets WHERE id = ? AND customer_id = ?",
                (pet_id, customer_id),
            ).fetchone()
        return row is not None

    @staticmethod
    def create_appointment(appointment_input, database_connection):
        with database_connection() as connection:
            cursor = connection.execute(
                """
                INSERT INTO appointments
                    (customer_id, pet_id, veterinarian_id, scheduled_date, scheduled_time,
                     reason_for_visit, type, status, created_by, updated_by,
                     created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    appointment_input.customer_id,
                    appointment_input.pet_id,
                    appointment_input.veterinarian_id,
                    appointment_input.scheduled_date.isoformat(),
                    appointment_input.scheduled_time.strftime("%H:%M:%S"),
                    appointment_input.reason_for_visit,
                    appointment_input.type,
                    appointment_input.status,
                    appointment_input.user_id,
                    appointment_input.user_id,
                    now(),
                    now(),
                ),
            )
            appointment_id = cursor.lastrowid
            connection.execute(
                """
                INSERT INTO appointment_status_histories
                    (appointment_id, status, changed_by, changed_at)
                VALUES (?, ?, ?, ?)
                """,
                (
                    appointment_id,
                    appointment_input.status,
                    appointment_input.user_id,
                    now(),
                ),
            )
            row = connection.execute(
                "SELECT * FROM appointments WHERE id = ?", (appointment_id,)
            ).fetchone()
        return to_dict(row)

    @staticmethod
    def update_appointment(appointment_id, appointment_input, database_connection):
        """Update an appointment. A status change is also written to the history."""
        with database_connection() as connection:
            current = connection.execute(
                "SELECT status FROM appointments WHERE id = ?", (appointment_id,)
            ).fetchone()
            if current is None:
                return None
            connection.execute(
                """
                UPDATE appointments
                SET customer_id = ?, pet_id = ?, veterinarian_id = ?, scheduled_date = ?,
                    scheduled_time = ?, reason_for_visit = ?, type = ?, status = ?,
                    updated_by = ?, updated_at = ?
                WHERE id = ?
                """,
                (
                    appointment_input.customer_id,
                    appointment_input.pet_id,
                    appointment_input.veterinarian_id,
                    appointment_input.scheduled_date.isoformat(),
                    appointment_input.scheduled_time.strftime("%H:%M:%S"),
                    appointment_input.reason_for_visit,
                    appointment_input.type,
                    appointment_input.status,
                    appointment_input.user_id,
                    now(),
                    appointment_id,
                ),
            )
            if current["status"] != appointment_input.status:
                connection.execute(
                    """
                    INSERT INTO appointment_status_histories
                        (appointment_id, status, changed_by, changed_at)
                    VALUES (?, ?, ?, ?)
                    """,
                    (
                        appointment_id,
                        appointment_input.status,
                        appointment_input.user_id,
                        now(),
                    ),
                )
            row = connection.execute(
                "SELECT * FROM appointments WHERE id = ?", (appointment_id,)
            ).fetchone()
        return to_dict(row)

    @staticmethod
    def delete_appointment(appointment_id, database_connection):
        """Return True if a row was deleted. Its status history cascades."""
        with database_connection() as connection:
            cursor = connection.execute(
                "DELETE FROM appointments WHERE id = ?", (appointment_id,)
            )
        return cursor.rowcount > 0

    @staticmethod
    def list_history(appointment_id, database_connection):
        with database_connection() as connection:
            rows = connection.execute(
                """
                SELECT id, appointment_id, status, changed_by, changed_at
                FROM appointment_status_histories
                WHERE appointment_id = ?
                ORDER BY changed_at, id
                """,
                (appointment_id,),
            ).fetchall()
        return [to_dict(row) for row in rows]
