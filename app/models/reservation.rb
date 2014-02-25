class Reservation < ActiveRecord::Base
  belongs_to :server # either system does automatically or Admin/Manager makes assignment
  belongs_to :user
  belongs_to :restaurant
  has_many :tables, through: :reservetables
  has_many :reservetables
  validates :begin, presence: true
  validates :party_size, :numericality => { :greater_than => 0, :less_than => 24 }, :presence => true

  def date

  end

  def start_time

  end

  def end_time

  end
  
end
