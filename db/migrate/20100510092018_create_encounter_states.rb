class CreateEncounterStates < ActiveRecord::Migration
  def self.up
    #, :primary_key => :encounter_id, :auto_increment => false
    
    create_table :encounter_state, :primary_key => :encounter_state_id do |t|
      t.column :encounter_state_id, :integer, :null => false
      t.column :encounter_id, :integer, :null => false
      t.column :state, :boolean

      t.timestamps
    end

    execute "alter table encounter_state add constraint fk_encounter_id
              foreign key (encounter_id) references encounter(encounter_id)"
  end

  def self.down
    drop_table :encounter_state
  end
end
