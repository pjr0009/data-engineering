class Customer < ActiveRecord::Base
  # :polymorphic => true would be wise if the customer relationship was more complex
  belongs_to :merchant
  belongs_to :entry
  attr_accessible :merchant_id, :entry_id, :name
end
