class CreateDeals < ActiveRecord::Migration
  def change
    create_table :deals do |t|
      t.references :merchant
      t.string :item_description
      t.float :item_price
      t.timestamps
    end
  end
end
