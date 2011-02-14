class CreateConceptSources < ActiveRecord::Migration
  def self.up
    create_table :concept_sources do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :concept_sources
  end
end
