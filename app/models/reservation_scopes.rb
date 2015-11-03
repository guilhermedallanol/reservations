module ReservationScopes
  def self.included(base) # rubocop:disable MethodLength, AbcSize
    base.class_eval do
      default_scope { order('start_date, due_date, reserver_id') }

      scope :flagged, lambda { |flag|
        where('flags & ? > 0', Reservation::FLAGS[flag])
      }
      scope :not_flagged, lambda {|flag|
        where('flags & ? = 0', Reservation::FLAGS[flag])
      }

      scope :active, Reservations::ActiveQuery.new
      scope :finalized, Reservations::FinalizedQuery.new

      scope :checked_out_today, Reservations::CheckedOutTodayQuery.new
      scope :checked_out_previous, Reservations::CheckedOutPreviousQuery.new
      scope :overdue, Reservations::OverdueQuery.new

      scope :checked_in, ->() { returned }

      scope :returned_on_time, Reservations::ReturnedOnTimeQuery.new
      scope :returned_overdue, Reservations::ReturnedOverdueQuery.new
      scope :upcoming, Reservations::UpcomingQuery.new
      scope :due_soon, Reservations::DueSoonQuery.new
      scope :checkoutable, Reservations::CheckoutableQuery.new
      scope :future, lambda {
        where('start_date > ?', Time.zone.today.to_time).reserved
      }
      scope :starts_on_days, lambda { |start_date, end_date|
        where(start_date: start_date..end_date)
      }
      scope :ends_on_days, lambda { |start_date, end_date|
        where(due_date: start_date..end_date)
      }
      scope :reserved_on_date, lambda { |date|
        overlaps_with_date(date).active
      }
      scope :for_eq_model, lambda { |eq_model|
        where(equipment_model_id: eq_model.id)
      }
      scope :active_or_requested, lambda {
        where(status: Reservation.statuses.values_at(
          *%w(requested reserved checked_out)))
      }
      scope :notes_unsent, ->() { where(notes_unsent: true) }

      scope :approved_requests, lambda {
        flagged(:request).finalized
      }

      scope :missed_requests, lambda {
        where('start_date < ?', Time.zone.today).requested
      }
      scope :for_reserver, ->(reserver) { where(reserver_id: reserver) }
      scope :reserved_in_date_range, lambda { |start_date, end_date|
        where('start_date <= ? and due_date >= ?', end_date, start_date)
          .reserved
      }
      scope :overlaps_with_date, lambda { |date|
        where('start_date <= ? and due_date >= ?', date, date)
      }
      scope :has_notes, ->() { where.not(notes: nil) }
      scope :with_categories, lambda {
        joins(:equipment_model)
          .select('reservations.*, equipment_models.category_id as category_id')
      }
    end
  end
end
