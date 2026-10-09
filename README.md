# PVAS - Pet Veterinary Appointment System API

FastAPI + SQLite backend for a small pet clinic. The database was converted from
`pvas_database.sql` (MySQL) to SQLite.

## Problem and solution

**Problem.** Small veterinary clinics often schedule visits in paper logbooks or
spreadsheets. This causes double-booked veterinarians, lost records of who
canceled or missed a visit, and pets linked to the wrong owner.

**Intended users.**
- Receptionist: registers owners and pets, books and reschedules appointments.
- Veterinarian: checks their own schedule and marks visits completed or no-show.
- Admin: manages staff accounts and reviews appointment history.

**How the system solves it.**

| Problem | Feature |
|---|---|
| Double-booked veterinarian | A booking or reschedule is rejected if the vet already has an active appointment at that date and time. `GET /appointments/schedule` shows what is already taken. |
| Wrong pet or owner on a booking | The pet must belong to the customer, or the booking is rejected. |
| Unclear visit status | Status follows a fixed workflow and cannot jump (for example scheduled straight to completed). |
| No record of who changed what | Every status change is logged with the staff member and the time. |
| Lost records when data is deleted | Foreign keys protect related records, and a vet with appointments cannot be deleted. |

## Appointment workflow

```
scheduled --> confirmed --> completed
    |             |
    |             +--> no_show
    +--> canceled <-----+
```

- A new appointment must start as `scheduled` or `confirmed`.
- `completed`, `no_show`, and `canceled` are final.
- `canceled` and `no_show` free the veterinarian's time slot.
- Booking, status change, and the history entry happen in one database
  transaction, so they succeed or fail together.

## Run it on Windows

```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
python -m uvicorn main:app --reload
```

Open http://127.0.0.1:8000/pvas to try every endpoint.

On the first run the app creates `pvas.db` and loads the sample data from
`app/seed.sql`. To reset the data, stop the server and delete `pvas.db`.

## Project structure

- `main.py` - FastAPI app and routes
- `app/database.py` - SQLite connection, table creation, seed loading
- `app/models.py` - Pydantic data classes and SQL helper methods
- `app/services.py` - `AppointmentService` class with the booking and status rules
- `app/seed.sql` - sample data converted from `pvas_database.sql`

## How the code is organized (OOP)

- **Models** (`models.py`): classes such as `Customer`, `PetInput`, and `AppointmentInput`
  describe the data and hold its SQL. `UserUpdate` inherits from `UserInput`.
- **Service** (`services.py`): `AppointmentService` is created once with the database
  connection and holds the business rules. It raises `AppointmentRuleError`
  subclasses (`SlotTakenError`, `InvalidStatusChangeError`, `PetOwnerError`,
  `AppointmentNotFoundError`), each carrying its own HTTP status code.
- **Routes** (`main.py`): only translate HTTP to method calls and back.

## Tables

users, customers, pets, appointments, appointment_status_histories.
(The Laravel tables such as cache, jobs, sessions and migrations were left out
because they are framework internals, not part of the appointment system.)

## Endpoints

| Resource | Endpoints |
|---|---|
| Users | `GET /users` (optional `?role=`), `GET /users/{id}`, `POST /user`, `PUT /user/{id}`, `DELETE /user/{id}` |
| Customers | `GET /customers` (optional `?search=`), `GET /customers/{id}`, `POST /customer`, `PUT /customer/{id}`, `DELETE /customer/{id}` |
| Pets | `GET /pets` (optional `?customer_id=`, `?species=`, `?search=`), `GET /pets/{id}`, `POST /pet`, `PUT /pet/{id}`, `DELETE /pet/{id}` |
| Appointments | `GET /appointments` (optional `?status=`, `?scheduled_date=`, `?veterinarian_id=`, `?customer_id=`, `?pet_id=`), `GET /appointments/{id}`, `GET /appointments/{id}/history`, `GET /appointments/schedule` (`?veterinarian_id=` and `?scheduled_date=`), `POST /appointment`, `PUT /appointment/{id}`, `PATCH /appointments/{id}/status`, `DELETE /appointment/{id}` |

Notes:
- `PUT` replaces the whole record, so send every field you want to keep.
- `user_id` in an appointment body is the staff member making the change. It fills
  `created_by`, `updated_by`, and the history's `changed_by`.
- Passwords are stored hashed and are never returned. A user who is the veterinarian
  on an appointment cannot be deleted; set `is_active` to false instead.
- Deleting a customer also deletes their pets and appointments.
- Error codes: 400 rule broken (wrong pet owner, bad starting status), 404 not found,
  409 conflict (slot taken, invalid status change, duplicate email, database rule),
  422 invalid input.
