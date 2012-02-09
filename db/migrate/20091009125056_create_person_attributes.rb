class CreatePersonAttributes < ActiveRecord::Migration
  def self.up
    create_table :person_attributes do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :person_attributes
  end
end
