SET FOREIGN_KEY_CHECKS=0;
ALTER TABLE `orders` ADD COLUMN `obs_id` int(11) DEFAULT NULL;
ALTER TABLE `orders` ADD KEY `obs_for_order` (`obs_id`);
ALTER TABLE `orders` ADD CONSTRAINT `obs_for_order` FOREIGN KEY (`obs_id`) REFERENCES `obs` (`obs_id`);
SET FOREIGN_KEY_CHECKS=1;
