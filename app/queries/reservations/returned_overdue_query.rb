module Reservations
  class ReturnedOverdueQuery < Reservations::ReservationsQueryBase

    def call
      @relation.where(overdue: true).returned
    end
  end
end
