#QUESTION 1
CREATE TABLE Agent (
    AgentID int,
    AgentName varchar(100)
    );
INSERT INTO Agent (AgentID, AgentName)
VALUES ('101','ABC'),('102','Express'),('103','Discount');

CREATE TABLE Product (
    ProdID int,
    ProdName varchar(100)
    );
INSERT INTO Product (ProdID, ProdName)
VALUES ('1001','Money Transfer'),('1002','Check Cashing');

CREATE TABLE Transaction (
    OrderID int,
    AgentID int,
    ProdID int,
    TransactionDate datetime,
    OrderAmount decimal(6,2)
    );
INSERT INTO Transaction (OrderID, AgentID, ProdID, TransactionDate, OrderAmount)
VALUES 
('111','101','1001','2015-01-01','15.00'), 
('112','101','1002','2015-01-02','40.00'),
('113','102','1001','2015-01-04','95.00'),
('114','103','1001','2015-01-04','75.00'),
('115','103','1002','2015-01-05','50.00'),
('116','103','1001','2015-02-01','100.00');

#QUESTION 2
ALTER TABLE Agent ADD COLUMN AgentNo varchar(50) AFTER agentname;
set SQL_SAFE_UPDATES = 0;
UPDATE Agent SET AgentNo = CONCAT(AgentID, ' - ', AgentName);
SELECT * from Agent;

#QUESTION 3
INSERT INTO Product (ProdID, ProdName)
VALUES ('1003','Bill Payment');
SELECT * from Product;

#QUESTION 4
UPDATE product
SET ProdName = 'MT'
WHERE ProdID = 1001;

UPDATE product
SET ProdName = 'CC'
WHERE ProdID = 1002;

UPDATE product
SET ProdName = 'BP'
WHERE ProdID = 1003;
SELECT * from Product;

#QUESTION 5
SELECT Agent.AgentID, AgentName, count(OrderID) as TotalTransaction, sum(OrderAmount) as TotalOrderAmount 
FROM Agent JOIN Transaction
ON Agent.AgentID = transaction.AgentID
WHERE month(transaction.transactiondate) =1 or month(transaction.transactiondate) = 2
GROUP BY AgentID
HAVING TotalOrderAmount > 100;

#QUESTION 6
SELECT Agent.AgentID, AgentName, year(TransactionDate) as Year, month(TransactionDate) as Month, ProdName, count(OrderID) as Transaction, OrderAmount 
FROM Agent JOIN Transaction
ON Agent.AgentID = Transaction.AgentID
JOIN Product
On Product.ProdID = Transaction.ProdID
GROUP BY OrderAmount
ORDER by AgentID, Month, ProdName;

#QUESTION 7
SELECT Agent.AgentID, AgentName, 
sum(transaction.ProdID = 1001) as Transaction_MT, sum(CASE WHEN transaction.ProdID = 1001 THEN OrderAmount END) as OrderAmount_MT, 
sum(transaction.ProdID = 1002) as Transaction_CC, COALESCE(sum(CASE WHEN transaction.ProdID = 1002 THEN OrderAmount END),0) as OrderAmount_CC
FROM Agent JOIN Transaction
ON Agent.AgentID = Transaction.AgentID
JOIN Product
On Product.ProdID = Transaction.ProdID
GROUP BY AgentID
ORDER BY AgentID;

#QUESTION 8
WITH new_transaction as (
SELECT *,
CASE WHEN OrderAmount BETWEEN 0 AND 24.99 THEN '0-24.99'
	WHEN orderamount BETWEEN 25 AND 49.99 THEN '25-49.99'
	WHEN orderamount BETWEEN 50 AND 99.99 THEN '50-99.99'
	ELSE '100+'
	END AS AmountTier
FROM Transaction)

SELECT any_value(agent.agentid) as AgentID, any_value(agent.agentname) as AgentName, 
any_value(new_transaction.AmountTier) as AmountTier, count(distinct new_transaction.OrderID) as Transaction, any_value(new_transaction.OrderAmount) as OrderAmount, round(avg(OrderAmount),2) as AverageOrderAmount
FROM new_transaction JOIN Agent
ON new_transaction.AgentID = Agent.AgentID
WHERE Year(TransactionDate) = 2015 and Month(TransactionDate) = 1 and new_transaction.ProdID = '1001'
GROUP BY Agent.AgentID;

#QUESTION 9
SELECT Agent.AgentID, AgentName, Product.ProdName, sum(OrderAmount) as OrderAmount, RANK()OVER(PARTITION BY AgentID ORDER BY OrderAmount DESC) as 'Rank'
FROM Agent JOIN Transaction
ON Agent.AgentID = Transaction.AgentID
JOIN Product
On Product.ProdID = Transaction.ProdID
GROUP BY AgentID, ProdName;

# Parsing numbers from string
# Input: ‘My phone number is 323-111-CALL’
# Output: ‘323111’

DELIMITER $$
CREATE FUNCTION `ExtractNumber`(in_string VARCHAR(50)) 
RETURNS INT
NO SQL
BEGIN
    DECLARE ctrNumber VARCHAR(50);
    DECLARE finNumber VARCHAR(50) DEFAULT '';
    DECLARE sChar VARCHAR(1);
    DECLARE inti INTEGER DEFAULT 1;

    IF LENGTH(in_string) > 0 THEN
        WHILE(inti <= LENGTH(in_string)) DO
            SET sChar = SUBSTRING(in_string, inti, 1);
            SET ctrNumber = FIND_IN_SET(sChar, '0,1,2,3,4,5,6,7,8,9'); 
            IF ctrNumber > 0 THEN
                SET finNumber = CONCAT(finNumber, sChar);
            END IF;
            SET inti = inti + 1;
        END WHILE;
        RETURN CAST(finNumber AS UNSIGNED);
    ELSE
        RETURN 0;
    END IF;    
END$$
DELIMITER ;

SELECT ExtractNumber("My phone number is 323-111-CALL") AS number;