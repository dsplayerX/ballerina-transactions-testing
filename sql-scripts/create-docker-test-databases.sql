-- Create first database
CREATE database m2;

CREATE TABLE m2.test3 (
  id INT NOT NULL AUTO_INCREMENT,
  hello VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE m2.test4 (
  id INT NOT NULL AUTO_INCREMENT,
  hello VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
);

-- Create second database
CREATE database m3;

CREATE TABLE m3.test5 (
  id INT NOT NULL AUTO_INCREMENT,
  hello VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE m3.test6 (
  id INT NOT NULL AUTO_INCREMENT,
  hello VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
);


INSERT INTO m2.test3 (id, hello) VALUES (8, 'hi');