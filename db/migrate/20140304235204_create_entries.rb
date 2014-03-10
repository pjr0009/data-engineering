class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.references :report
      t.references :merchant
      t.references :deal
      t.references :customer
      t.string :purchaser_name  
      t.integer :purchase_count  
      t.timestamps
    end
  end
end
