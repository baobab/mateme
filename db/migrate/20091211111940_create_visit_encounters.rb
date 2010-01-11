class CreateVisitEncounters < ActiveRecord::Migration
  def self.up
    create_table :visit_encounters do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :visit_encounters
  end
end
