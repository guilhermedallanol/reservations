module Reservations
  class ReturnedOnTimeQuery < Reservations::ReservationsQueryBase

    def call
      @relation.where(overdue: false).returned
    end
  end
end
