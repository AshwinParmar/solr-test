CREATE DATABASE solr-tut;
USE solr-tut;
CREATE  TABLE products (
  product_id INT NOT NULL AUTO_INCREMENT ,
  name VARCHAR(100),
  description TEXT,
  price FLOAT(2),
  PRIMARY KEY (`product_id`) );

INSERT INTO products (product_id, name, description, price) VALUES ('1', 'Amstrad CPC 464', 'Vintage computing, horrible design', '29.99');
INSERT INTO products (product_id, name, description, price)  VALUES ('2', 'Vic 20', 'Now you are talking - pure retro joy ', '14.99');
INSERT INTO products (product_id, name, description, price)  VALUES ('3', 'ZX Spectrum', 'One for the rubber enthusiasts.  48 whole k.', '49.99');
INSERT INTO products (product_id, name, description, price) VALUES ('4', 'Commodore 64', 'Games Central', '39.99');
INSERT INTO products (product_id, name, description, price) VALUES ('5', 'BBC Micro Model B', 'State of the art turtle navigation.', '129.99');
