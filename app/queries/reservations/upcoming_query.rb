module Reservations
  class UpcomingQuery < Reservations::ReservationsQueryBase

    def call
      @relation.unscoped.where(start_date: Time.zone.today).reserved.user_sort
    end
  end
end
