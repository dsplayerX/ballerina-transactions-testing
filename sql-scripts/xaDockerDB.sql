SELECT * FROM xaDockerDB.xaTesting;

XA RECOVER;

CREATE DATABASE xaDockerDB;

CREATE TABLE xaDockerDB.xaTesting (
  id INT NOT NULL AUTO_INCREMENT,
  hello VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
);

INSERT INTO xaDockerDB.xaTesting (id, hello) VALUES (1, 'yoooo');




