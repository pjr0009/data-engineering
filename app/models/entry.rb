class Entry < ActiveRecord::Base
  belongs_to :report
  belongs_to :merchant
  belongs_to :customer
  belongs_to :deal

  attr_accessible :purchaser_name, :item_description, :item_price,
  :purchase_count, :merchant_address, :merchant_name, :report_id, :aggregate_total,
  :merchant_id
end
