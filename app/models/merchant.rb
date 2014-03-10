class Merchant < ActiveRecord::Base
  belongs_to :user 
  belongs_to :entry
  has_many :customers
  has_many :deals

end
