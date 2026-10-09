"""Business rules for the appointment workflow.

The models in models.py only talk to the database. This module decides what is
allowed: who can be booked when, and how an appointment moves between statuses.
"""

from app.models import Appointment


class AppointmentRuleError(Exception):
    """Base class for a broken appointment rule. Carries the HTTP status to return."""

    status_code = 400

    def __init__(self, message: str):
        super().__init__(message)
        self.message = message


class AppointmentNotFoundError(AppointmentRuleError):
    status_code = 404


class SlotTakenError(AppointmentRuleError):
    status_code = 409


class InvalidStatusChangeError(AppointmentRuleError):
    status_code = 409


class PetOwnerError(AppointmentRuleError):
    status_code = 400


class AppointmentService:
    """Booking, rescheduling, and status workflow for appointments.

    One instance is created in main.py and handed the database connection, so
    every rule below runs against the same database as the rest of the app.
    """

    # Statuses a new appointment may start with.
    STARTING_STATUSES = ("scheduled", "confirmed")

    # Statuses that occupy a vet's time slot. Canceled and no-show free the slot.
    BLOCKING_STATUSES = ("scheduled", "confirmed", "completed")

    # Allowed moves. A status with no moves is final.
    TRANSITIONS = {
        "scheduled": ("confirmed", "canceled"),
        "confirmed": ("completed", "no_show", "canceled"),
        "completed": (),
        "no_show": (),
        "canceled": (),
    }

    def __init__(self, database_connection):
        self.database_connection = database_connection

    # ----------------------------------------------------------------- reading

    def get(self, appointment_id):
        """Return one appointment, or raise a 404 rule error."""
        appointment = Appointment.get_appointment(
            appointment_id=appointment_id,
            database_connection=self.database_connection,
        )
        if appointment is None:
            raise AppointmentNotFoundError("Appointment not found")
        return appointment

    def history(self, appointment_id):
        """Return the status log of an appointment."""
        self.get(appointment_id)
        return Appointment.list_history(
            appointment_id=appointment_id,
            database_connection=self.database_connection,
        )

    def schedule(self, veterinarian_id, scheduled_date):
        """Return the time slots a vet already has booked on a date, earliest first."""
        appointments = Appointment.list_appointments(
            database_connection=self.database_connection,
            veterinarian_id=veterinarian_id,
            scheduled_date=scheduled_date,
        )
        return [
            appointment
            for appointment in appointments
            if appointment["status"] in self.BLOCKING_STATUSES
        ]

    # --------------------------------------------------------------- workflows

    def book(self, appointment_input):
        """Book a new appointment after checking all rules."""
        if appointment_input.status not in self.STARTING_STATUSES:
            raise AppointmentRuleError(
                "A new appointment must start as 'scheduled' or 'confirmed'"
            )
        self._check_pet_owner(appointment_input)
        self._check_slot_free(appointment_input)
        return Appointment.create_appointment(
            appointment_input=appointment_input,
            database_connection=self.database_connection,
        )

    def update(self, appointment_id, appointment_input):
        """Edit an appointment (reschedule, change vet, or move its status)."""
        current = self.get(appointment_id)
        self._check_pet_owner(appointment_input)

        if appointment_input.status != current["status"]:
            self._check_transition(current["status"], appointment_input.status)

        slot_changed = (
            appointment_input.veterinarian_id != current["veterinarian_id"]
            or appointment_input.scheduled_date.isoformat() != current["scheduled_date"]
            or appointment_input.scheduled_time.strftime("%H:%M:%S")
            != current["scheduled_time"]
        )
        # A canceled or no-show appointment holds no slot, so only check the others.
        if slot_changed and appointment_input.status in self.BLOCKING_STATUSES:
            self._check_slot_free(appointment_input, exclude_id=appointment_id)

        return Appointment.update_appointment(
            appointment_id=appointment_id,
            appointment_input=appointment_input,
            database_connection=self.database_connection,
        )

    def change_status(self, appointment_id, status_change):
        """Move an appointment to a new status if the workflow allows it."""
        current = self.get(appointment_id)
        self._check_transition(current["status"], status_change.status)
        return Appointment.change_status(
            appointment_id=appointment_id,
            status=status_change.status,
            user_id=status_change.user_id,
            database_connection=self.database_connection,
        )

    def delete(self, appointment_id):
        """Delete an appointment and its status history."""
        self.get(appointment_id)
        Appointment.delete_appointment(
            appointment_id=appointment_id,
            database_connection=self.database_connection,
        )

    # ------------------------------------------------------------ rule helpers

    def _check_pet_owner(self, appointment_input):
        """The pet must exist and belong to the customer making the booking."""
        if not Appointment.pet_belongs_to_customer(
            pet_id=appointment_input.pet_id,
            customer_id=appointment_input.customer_id,
            database_connection=self.database_connection,
        ):
            raise PetOwnerError(
                "Pet does not exist or does not belong to this customer"
            )

    def _check_slot_free(self, appointment_input, exclude_id=None):
        """The vet must not already have an appointment at this date and time."""
        conflict = Appointment.find_conflict(
            veterinarian_id=appointment_input.veterinarian_id,
            scheduled_date=appointment_input.scheduled_date,
            scheduled_time=appointment_input.scheduled_time,
            blocking_statuses=self.BLOCKING_STATUSES,
            database_connection=self.database_connection,
            exclude_id=exclude_id,
        )
        if conflict is not None:
            raise SlotTakenError(
                "This veterinarian is already booked at that date and time "
                f"(appointment {conflict['id']})"
            )

    def _check_transition(self, current_status, new_status):
        """The new status must be an allowed move from the current one."""
        if new_status not in self.TRANSITIONS[current_status]:
            allowed = ", ".join(self.TRANSITIONS[current_status]) or "none (final status)"
            raise InvalidStatusChangeError(
                f"Cannot change status from '{current_status}' to '{new_status}'. "
                f"Allowed: {allowed}"
            )
