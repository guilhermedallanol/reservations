module ReservationScopes
  def self.included(base) # rubocop:disable MethodLength, AbcSize
    base.class_eval do
      default_scope { order('start_date, due_date, reserver_id') }
      scope :user_sort, ->() { order('reserver_id') }

      scope :flagged, Reservations::FlaggedQuery
      scope :not_flagged, Reservations::NotFlaggedQuery

      scope :active, Reservations::ActiveQuery
      scope :finalized, Reservations::FinalizedQuery

      scope :checked_out_today, Reservations::CheckedOutTodayQuery
      scope :checked_out_previous, Reservations::CheckedOutPreviousQuery
      scope :overdue, Reservations::OverdueQuery

      scope :checked_in, ->() { returned }

      scope :returned_on_time, Reservations::ReturnedOnTimeQuery
      scope :returned_overdue, Reservations::ReturnedOverdueQuery
      scope :upcoming, Reservations::UpcomingQuery
      scope :due_soon, Reservations::DueSoonQuery
      scope :checkoutable, Reservations::CheckoutableQuery
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
