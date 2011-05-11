class CreateLocationTagMap < ActiveRecord::Migration
  def self.up
    execute "CREATE TABLE `location_tag_map` (
    `location_id` int(11) NOT NULL,
    `location_tag_id` int(11) NOT NULL,
    PRIMARY KEY (`location_id`,`location_tag_id`),
    KEY `location_tag_map_tag` (`location_tag_id`),
    CONSTRAINT `location_tag_map_location` FOREIGN KEY (`location_id`) REFERENCES `location` (`location_id`),
    CONSTRAINT `location_tag_map_tag` FOREIGN KEY (`location_tag_id`) REFERENCES `location_tag` (`location_tag_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=latin1;"
  end

  def self.down
    drop_table :location_tag_map
  end
end
