class Deal < ActiveRecord::Base
  belongs_to :merchant
  belongs_to :entry
end
