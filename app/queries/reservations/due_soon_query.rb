module Reservations
  class DueSoonQuery < Reservations::ReservationsQueryBase

    def call
      @relation.where(due_date: Time.zone.today)
    end
  end
end
