class CreateLocationTagDiabetesReferralCenter < ActiveRecord::Migration
  def self.up
      execute "INSERT INTO `location_tag` (`tag`, `description`, `creator`, `date_created`, `retired`, `retired_by`, `date_retired`, `retire_reason`, `uuid`) 
               VALUES ('Diabetes Referral Center', NULL, 1, '2011-04-27 14:58:31', 0, NULL, NULL, NULL, '');"
  end

  def self.down

  end
end
