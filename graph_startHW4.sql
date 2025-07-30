drop database if exists graph;
create database graph;
use graph;

create table node (
 node_id int primary key,
 type varchar(20)
 );
 
 create table edge (
 edge_id int primary key,
  in_node int,
  out_node int,
  type varchar(20)
  );
  
create table node_props (
  node_id int,
  propkey varchar(20),
  string_value varchar(100),
  num_value double
  );
  
 
 insert into node values 
 (1,'Person'),
 (2,'Person'),
 (3,'Person'),
 (4,'Person'),
 (5,'Person'),
 (6,'Book'),
 (7,'Book'),
 (8,'Book'),
 (9,'Book');
 
 insert into node_props values
 (1, 'name', 'Emily', null),
 (2, 'name', 'Spencer', null),
 (3, 'name', 'Brendan', null),
 (4, 'name', 'Trevor', null),
 (5, 'name', 'Paxton', null),
 (6, 'title', 'Cosmos', null),
 (6, 'price', null, 17.00),
 (7, 'title', 'Database Design', null),
 (7, 'price', null, 195.00),
 (8, 'title', 'The Life of Cronkite', null),
 (8, 'price', null, 29.95),
 (9, 'title', 'DNA and you', null),
 (9, 'price', null, 11.50);
 
 insert into edge values
 (1, 1, 7, 'bought'),
 (2, 2, 6, 'bought'),
 (3, 2, 7, 'bought'),
 (4, 3, 7, 'bought'),
 (5, 3, 9, 'bought'),
 (6, 4, 6, 'bought'),
 (7, 4, 7, 'bought'), 
 (8, 5, 7, 'bought'),
 (9, 5, 8, 'bought'),
 (10, 1,2,'knows'),
 (11, 2, 1, 'knows'),
 (12, 2, 3, 'knows');
 
 
-- a. what is the sum of all book prices?
SELECT SUM(num_value) AS all_book_prices
FROM node_props
WHERE propkey = 'price';


-- b. Who does spencer know?
SELECT np.string_value AS name
FROM edge e
JOIN node n ON e.out_node = n.node_id
JOIN node_props np ON n.node_id = np.node_id
WHERE e.in_node = (SELECT node_id FROM node_props WHERE string_value = 'Spencer' AND propkey = 'name')
AND e.type = 'knows'
AND np.propkey = 'name';


-- c. What books did spencer buy? 
SELECT np_title.string_value AS title, np_price.num_value AS price
FROM edge e
JOIN node_props np_title ON e.out_node = np_title.node_id
JOIN node_props np_price ON np_title.node_id = np_price.node_id
WHERE e.in_node = (SELECT node_id FROM node_props WHERE string_value = 'Spencer' AND propkey = 'name')
AND e.type = 'bought'
AND np_title.propkey = 'title'
AND np_price.propkey = 'price';


-- d. Who knows each other?
SELECT np1.string_value AS person1, np2.string_value AS person2
FROM edge e
JOIN node_props np1 ON e.in_node = np1.node_id
JOIN node_props np2 ON e.out_node = np2.node_id
WHERE e.type = 'knows'
AND np1.propkey = 'name'
AND np2.propkey = 'name';


-- e. Recommendation Engine
SELECT DISTINCT np_title.string_value AS title
FROM edge e1
JOIN edge e2 ON e1.out_node = e2.in_node
JOIN node_props np_title ON e2.out_node = np_title.node_id
WHERE e1.in_node = (SELECT node_id FROM node_props WHERE string_value = 'Spencer' AND propkey = 'name')
AND e1.type = 'knows'
AND e2.type = 'bought'
AND np_title.propkey = 'title'
AND NOT EXISTS (
    SELECT 1
    FROM edge e_own
    JOIN node_props np_own ON e_own.out_node = np_own.node_id
    WHERE e_own.in_node = (SELECT node_id FROM node_props WHERE string_value = 'Spencer' AND propkey = 'name')
    AND e_own.type = 'bought'
    AND np_own.propkey = 'title'
    AND np_own.string_value = np_title.string_value
);
