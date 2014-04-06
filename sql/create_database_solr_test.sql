CREATE DATABASE solr_test;
USE solr_test;
CREATE  TABLE products (
  product_id INT NOT NULL AUTO_INCREMENT ,
  name VARCHAR(100),
  description TEXT,
  price FLOAT(2),
  PRIMARY KEY (`product_id`) );

INSERT INTO products (product_id, name, description, price) VALUES ('1', 'Nokia Lumia 521', 'Snap and share photos of friends and family with a 5MP camera that features special digital lenses. ', '29.99');
INSERT INTO products (product_id, name, description, price)  VALUES ('2', 'Nokia Lumia 521 - Refurbished', 'Get great features at a great value with the Nokia Lumia 521.', '14.99');
INSERT INTO products (product_id, name, description, price)  VALUES ('3', 'Huawei Summit - Refurbished', 'Easily make calls and send text messages on a beautiful touch screen phone.', '49.99');
INSERT INTO products (product_id, name, description, price) VALUES ('4', 'ALCATEL ONETOUCH Fierce', 'Experience more with the ALCATEL ONETOUCH Fierce™,', '39.99');
INSERT INTO products (product_id, name, description, price) VALUES ('5', 'Samsung Galaxy S 5', 'The Next Big Thing Is Here. Stunning. Innovative.', '129.99');
