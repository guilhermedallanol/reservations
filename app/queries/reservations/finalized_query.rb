module Reservations
  class FinalizedQuery < Reservations::ReservationsQueryBase

    def call
      @relation.where.not(status:
        Reservation.statuses.values_at(*%w(denied requested)))
    end
  end
end
