class CreateContributions < ActiveRecord::Migration
  def change
    create_table :contributions do |t|
      t.integer :count
      t.date :date

      t.timestamps
    end
  end
end
