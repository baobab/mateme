class CreatePersonAttributeTypes < ActiveRecord::Migration
  def self.up
    create_table :person_attribute_types do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :person_attribute_types
  end
end
