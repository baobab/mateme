class CreateVisitEncounter < ActiveRecord::Migration
  def self.up

ActiveRecord::Base.connection.execute <<EOF

CREATE TABLE IF NOT EXISTS `visit_encounters` (
  `id` int(11) NOT NULL auto_increment,
  `visit_id` int(11) NOT NULL,
  `encounter_id` int(11) NOT NULL,
  `creator` int(11) NOT NULL,      
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `voided` tinyint(1) NOT NULL default 0,
  `voided_by` int(11) default NULL,
  `date_voided` datetime default NULL,
  `void_reason` varchar(255) default NULL,
  PRIMARY KEY (`id`),
  INDEX `visit_id_enc_id_index` (`visit_id`,`encounter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
EOF


  end

  def self.down
    drop_table :visit_encounters
  end
end
