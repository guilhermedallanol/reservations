module Reservations
  class CheckedOutTodayQuery < Reservations::ReservationsQueryBase

    def call
      @relation.where(checked_out: Time.zone.today)
    end
  end
end
