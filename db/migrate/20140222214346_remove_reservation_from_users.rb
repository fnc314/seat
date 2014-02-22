class RemoveReservationFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :reservation, :integer
  end
end
