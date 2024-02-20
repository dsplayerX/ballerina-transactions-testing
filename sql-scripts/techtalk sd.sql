SELECT * FROM techtalk.Payments;


CREATE DATABASE techtalk;

CREATE TABLE IF NOT EXISTS `techtalk`.`Payments` (
    `cardno` VARCHAR(16) NOT NULL PRIMARY KEY,
    `amount` INT NOT NULL
);


-- DROP TABLE `techtalk`.`Payments`;

INSERT INTO `techtalk`.`Payments`
(`cardno`, `amount`)
VALUES
('card1', 1000),
('card2', 2000),
('card3', 5000);


-- DELETE FROM techtalk.Payments WHERE amount > 1000;-- 