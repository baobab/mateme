class CreateConceptMaps < ActiveRecord::Migration
  def self.up
    create_table :concept_maps do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :concept_maps
  end
end
