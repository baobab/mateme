class CreateVisit < ActiveRecord::Migration
  def self.up

ActiveRecord::Base.connection.execute <<EOF

CREATE TABLE IF NOT EXISTS `visit` (
  `visit_id` int(11) NOT NULL auto_increment,
  `patient_id` int(11) NOT NULL default 0,
  `start_date` datetime NOT NULL default '0000-00-00 00:00:00',
  `end_date` datetime default NULL,
  `ended_by` int(11) NOT NULL default 0,
  `creator` int(11) NOT NULL,      
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `voided` tinyint(1) NOT NULL default 0,
  `voided_by` int(11) default NULL,
  `date_voided` datetime default NULL,
  `void_reason` varchar(255) default NULL,
  PRIMARY KEY (`visit_id`),
  INDEX `visit_patient_id` (`patient_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
EOF
    
  end

  def self.down
    drop_table :visit
  end
end
