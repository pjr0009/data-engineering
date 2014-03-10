class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.references :merchant
      t.string :name
      t.timestamps
    end
  end
end
