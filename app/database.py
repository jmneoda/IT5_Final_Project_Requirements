"""SQLite connection and table setup."""

import sqlite3
from collections.abc import Iterator
from contextlib import contextmanager
from pathlib import Path

DATABASE_FILE = Path(__file__).resolve().parent.parent / "pvas.db"
SEED_FILE = Path(__file__).resolve().parent / "seed.sql"


@contextmanager
def database_connection() -> Iterator[sqlite3.Connection]:
    """Open a database connection and always close it after the operation."""

    connection = sqlite3.connect(DATABASE_FILE)
    connection.row_factory = sqlite3.Row
    # SQLite does not enforce foreign keys unless this is switched on for every connection.
    connection.execute("PRAGMA foreign_keys = ON")
    try:
        yield connection
        connection.commit()
    except Exception:
        connection.rollback()
        raise
    finally:
        connection.close()


def initialize_database() -> None:
    """Create the PVAS tables the first time the app runs, then load sample data."""

    with database_connection() as connection:
        connection.executescript(
            """
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                email TEXT NOT NULL UNIQUE,
                password TEXT NOT NULL,
                role TEXT NOT NULL DEFAULT 'staff' CHECK (role IN (
                    'admin', 'veterinarian', 'receptionist', 'vet_nurse',
                    'vet_assistant', 'groomer', 'staff'
                )),
                phone_number TEXT,
                is_active INTEGER NOT NULL DEFAULT 1,
                created_at TEXT,
                updated_at TEXT
            );

            CREATE TABLE IF NOT EXISTS customers (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                registered_by INTEGER REFERENCES users (id) ON DELETE SET NULL,
                first_name TEXT NOT NULL,
                last_name TEXT NOT NULL,
                email TEXT UNIQUE,
                contact_number TEXT NOT NULL,
                address TEXT,
                created_at TEXT,
                updated_at TEXT
            );

            CREATE TABLE IF NOT EXISTS pets (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                customer_id INTEGER NOT NULL REFERENCES customers (id) ON DELETE CASCADE,
                pet_name TEXT NOT NULL,
                species TEXT NOT NULL CHECK (species IN (
                    'Dog', 'Cat', 'Bird', 'Rabbit', 'Hamster', 'Other'
                )),
                breed TEXT,
                gender TEXT CHECK (gender IN ('Male', 'Female')),
                birthdate TEXT,
                color TEXT,
                weight REAL CHECK (weight IS NULL OR weight >= 0),
                medical_notes TEXT,
                created_at TEXT,
                updated_at TEXT
            );

            CREATE TABLE IF NOT EXISTS appointments (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                customer_id INTEGER NOT NULL REFERENCES customers (id) ON DELETE CASCADE,
                pet_id INTEGER NOT NULL REFERENCES pets (id) ON DELETE CASCADE,
                veterinarian_id INTEGER NOT NULL REFERENCES users (id) ON DELETE CASCADE,
                scheduled_date TEXT NOT NULL,
                scheduled_time TEXT NOT NULL,
                reason_for_visit TEXT,
                type TEXT CHECK (type IN ('Checkup', 'Vaccination', 'Surgery', 'Grooming')),
                status TEXT NOT NULL DEFAULT 'scheduled' CHECK (status IN (
                    'scheduled', 'confirmed', 'completed', 'no_show', 'canceled'
                )),
                created_by INTEGER REFERENCES users (id) ON DELETE SET NULL,
                updated_by INTEGER REFERENCES users (id) ON DELETE SET NULL,
                created_at TEXT,
                updated_at TEXT
            );

            CREATE TABLE IF NOT EXISTS appointment_status_histories (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                appointment_id INTEGER NOT NULL REFERENCES appointments (id) ON DELETE CASCADE,
                status TEXT NOT NULL,
                changed_by INTEGER REFERENCES users (id) ON DELETE SET NULL,
                changed_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
            );
            """
        )

        # Load the converted sample data from pvas_database.sql once, on an empty database.
        has_users = connection.execute("SELECT 1 FROM users LIMIT 1").fetchone()
        if not has_users:
            connection.executescript(SEED_FILE.read_text(encoding="utf8"))
