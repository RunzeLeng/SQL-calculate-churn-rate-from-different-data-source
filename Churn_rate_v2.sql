INSERT INTO new123.test2
SELECT SUBSTRING(salemonth, 1, 10), salecount, MID FROM new123.test
WHERE salemonth > '2020-12-01 00:00:00';

DELETE FROM new123.test3
WHERE salemonth <= '2020-08-01';

SELECT salemonth, SUM(salecount) AS account FROM new123.test2
GROUP BY salemonth
ORDER BY salemonth;

SELECT salemonth , SUM(salecount) AS account FROM new123.test3
GROUP BY salemonth
ORDER BY salemonth;

CREATE TABLE new123.test4 (
  salemonth DATE NOT NULL,
  total INT
);
CREATE TABLE new123.test5 (
  salemonth DATE NOT NULL,
  total INT
);
CREATE TABLE new123.test6 (
  salemonth DATE NOT NULL,
  DUP INT
);

CREATE TABLE new123.test7 AS
SELECT * FROM new123.test6;


INSERT INTO new123.test4
SELECT
  A.salemonth, (3208+SUM(B.account)) AS total
FROM  
(SELECT SUM(salecount) AS account, salemonth FROM new123.test2
GROUP BY salemonth
ORDER BY salemonth) AS A
CROSS JOIN 
(SELECT SUM(salecount) AS account, salemonth FROM new123.test2
GROUP BY salemonth
ORDER BY salemonth) AS B
WHERE B.salemonth <= A.salemonth
GROUP BY A.salemonth
ORDER BY A.salemonth;

INSERT INTO new123.test5
SELECT
  A.salemonth, SUM(B.account) AS total
FROM  
(SELECT SUM(salecount) AS account, salemonth FROM new123.test3
GROUP BY salemonth
ORDER BY salemonth) AS A
CROSS JOIN 
(SELECT SUM(salecount) AS account, salemonth FROM new123.test3
GROUP BY salemonth
ORDER BY salemonth) AS B
WHERE B.salemonth <= A.salemonth
GROUP BY A.salemonth
ORDER BY A.salemonth;

#INSERT INTO new123.test7
#SELECT C.salemonth, D.DUP FROM new123.test6 AS C
#LEFT JOIN
#(SELECT A.salemonth, COUNT(A.MID) AS DUP FROM new123.test2 AS A
#INNER JOIN new123.test3 AS B
#ON A.MID = B.MID AND A.salemonth = B.salemonth
#GROUP BY A.salemonth
#ORDER BY A.salemonth) AS D
#ON C.salemonth = D.salemonth;

#UPDATE new123.test7
#SET DUP = 0
#WHERE DUP IS NULL;


SELECT MID, CONCAT(SUBSTRING(closedate,1,8),'01') AS saledate_tomonth 
FROM new123.test3;

INSERT INTO new123.test7
SELECT DISTINCT(C.salemonth), 
CASE WHEN D.DUP IS NULL THEN 0
ELSE D.DUP
END AS DUP
FROM new123.test2 AS C
LEFT JOIN
(SELECT A.salemonth, COUNT(A.MID) AS DUP 
FROM new123.test2 AS A
INNER JOIN 
(SELECT MID, CONCAT(SUBSTRING(closedate,1,8),'01') AS saledate_tomonth 
FROM new123.test3) AS B
ON A.MID = B.MID AND A.salemonth = B.saledate_tomonth
GROUP BY A.salemonth
ORDER BY A.salemonth) AS D
ON C.salemonth = D.salemonth
ORDER BY C.salemonth;



INSERT INTO new123.test7
SELECT DISTINCT(C.salemonth), 
CASE WHEN D.DUP IS NULL THEN 0
ELSE D.DUP
END AS DUP
FROM new123.test2 AS C
LEFT JOIN
(SELECT A.salemonth, COUNT(A.MID) AS DUP FROM new123.test2 AS A
INNER JOIN new123.test3 AS B
ON A.MID = B.MID AND A.salemonth = B.salemonth
GROUP BY A.salemonth
ORDER BY A.salemonth) AS D
ON C.salemonth = D.salemonth
ORDER BY C.salemonth;




SELECT A.salemonth, 
(A.total-B.total-C.account_open+D.account_close) AS Live_begin, 
(C.account_open-E.DUP) AS open_account,
(D.account_close-E.DUP) AS close_account,
E.DUP AS open_and_close,
(A.total-B.total) AS Live_end,
CONCAT(ROUND((D.account_close-E.DUP)/(A.total-B.total-C.account_open+D.account_close)*100.0, 2),'%') AS Churn_rate
FROM new123.test4 AS A
INNER JOIN new123.test5 AS B
ON A.salemonth = B.salemonth
INNER JOIN
(SELECT SUM(salecount) AS account_open, salemonth FROM new123.test2
GROUP BY salemonth
ORDER BY salemonth) AS C
ON A.salemonth = C.salemonth
INNER JOIN
(SELECT SUM(salecount) AS account_close, salemonth FROM new123.test3
GROUP BY salemonth
ORDER BY salemonth) AS D
ON A.salemonth = D.salemonth
INNER JOIN
new123.test7 AS E
ON A.salemonth = E.salemonth
#WHERE A.salemonth BETWEEN 'start_date' AND 'end_date'
ORDER BY A.salemonth;