module Reservations
  class OverdueQuery < Reservations::ReservationsQueryBase

    def call
      @relation.where(overdue: true).checked_out
    end
  end
end
