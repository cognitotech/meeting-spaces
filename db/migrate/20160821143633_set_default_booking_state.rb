class SetDefaultBookingState < ActiveRecord::Migration
  def change
    change_column_default :bookings, :state, 0
  end
end
