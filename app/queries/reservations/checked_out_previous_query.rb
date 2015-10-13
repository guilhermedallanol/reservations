module Reservations
  class CheckedOutPreviousQuery

    # delegate to new instance of query object, see
    # http://craftingruby.com/posts/2015/06/29/query-objects-through-scopes.html
    class << self
      delegate :call, to: :new
    end

    def initialize(relation = Reservation.all)
      @relation = relation
    end

    def call
      @relation.where('checked_out < ?', Time.zone.today)
    end
  end
end
