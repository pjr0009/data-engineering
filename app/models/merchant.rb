class Merchant < ActiveRecord::Base
  belongs_to :user 
  has_many :customers
  has_many :deals

end
