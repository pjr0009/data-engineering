class AddAggregateTotal < ActiveRecord::Migration
  def change
    add_column :entries, :aggregate_total, :float
  end
end
