module Reservations
  class ActiveQuery < Reservations::ReservationsQueryBase

    def call
      @relation.where(status:
        Reservation.statuses.values_at(*%w(reserved checked_out)))
    end
  end
end
