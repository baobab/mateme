class Heartbeat < ActiveRecord::Migration
  def self.up
    create_table :heart_beat do |t|
      t.column :ip, :string, :limit => 20
      t.column :property, :string, :limit => 200
      t.column :value, :string, :limit => 200
      t.column :time_stamp, :datetime
      t.column :username, :string, :limit => 10
      t.column :url, :string, :limit => 100
    end
  end

  def self.down
    drop_table :heart_beat
  end
end
