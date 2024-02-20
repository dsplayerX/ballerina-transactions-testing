SELECT * FROM techtalk.stock;


INSERT INTO `techtalk`.`stock`
(`itemId`, `amount`, `unitPrice`)
VALUES
(1, 100, 20),
(2, 150, 25),
(3, 200, 18),
(4, 10, 60);

-- DELETE FROM techtalk.stock WHERE amount > 0;

CREATE DATABASE techtalk;

-- DROP TABLE techtalk.stock;

CREATE TABLE IF NOT EXISTS Stock (
    itemId INT PRIMARY KEY,
    amount INT,
    unitPrice INT
);

        