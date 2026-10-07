# PVAS - Pet Veterinary Appointment System API

FastAPI + SQLite backend for a pet clinic appointment system. The database was
converted from `pvas_database.sql` (MySQL) to SQLite.

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
- `app/models.py` - Pydantic models and SQL helper methods
- `app/seed.sql` - sample data converted from `pvas_database.sql`

## Tables

users, customers, pets, appointments, appointment_status_histories.
(The Laravel tables such as cache, jobs, sessions and migrations were left out
because they are framework internals, not part of the appointment system.)

## Endpoints

| Resource | Endpoints |
|---|---|
| Users | `GET /users` (optional `?role=`), `GET /users/{user_id}`, `POST /user`, `PUT /user/{id}`, `DELETE /user/{id}` |
| Customers | `GET /customers` (optional `?search=`), `GET /customers/{id}`, `POST /customer`, `PUT /customer/{id}`, `DELETE /customer/{id}` |
| Pets | `GET /pets` (optional `?customer_id=`, `?species=`, `?search=`), `GET /pets/{id}`, `POST /pet`, `PUT /pet/{id}`, `DELETE /pet/{id}` |
| Appointments | `GET /appointments` (optional `?status=`, `?scheduled_date=`, `?veterinarian_id=`, `?customer_id=`, `?pet_id=`), `GET /appointments/{id}`, `GET /appointments/{id}/history`, `POST /appointment`, `PUT /appointment/{id}`, `DELETE /appointment/{id}` |

Notes:
- `PUT` replaces the whole record, so send every field you want to keep.
- Creating an appointment logs its first status. Changing `status` through
  `PUT /appointment/{id}` adds a row to the appointment's history.
- Passwords are stored hashed and are never returned. A user who is the veterinarian on an appointment cannot be deleted; set `is_active` to false instead.
- `user_id` in an appointment body is the staff member making the change.
- Deleting a customer also deletes their pets and appointments.
