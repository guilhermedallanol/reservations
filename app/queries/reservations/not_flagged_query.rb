module Reservations
  class NotFlaggedQuery < Reservations::ReservationsQueryBase

    def call(flag)
      @relation.where('flags & ? = 0', Reservation::FLAGS[flag])
    end
  end
end
