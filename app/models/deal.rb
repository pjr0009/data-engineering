class Deal < ActiveRecord::Base
  belongs_to :merchant
  belongs_to :entry
  attr_accessible :item_description, :item_price, :merchant_id
end
