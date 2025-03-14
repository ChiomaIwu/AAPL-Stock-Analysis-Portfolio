drop table if exists `stock_prices`;
use `aapl_stocks_project`;


CREATE TABLE stock_prices (
    `Date` DATE,
    `Open` FLOAT,
    `High` FLOAT,
    `Low` FLOAT,
    `Close` FLOAT,
    `Volume` BIGINT
);

SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/aapl_us_2025.csv'  
INTO TABLE stock_prices
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


SHOW VARIABLES LIKE 'secure_file_priv';

select *
from stock_prices LIMIT 11000;

select min(date) as start_date, max(date) as end_date from stock_prices;

CREATE TABLE stock_prices_backup AS 
SELECT * FROM stock_prices;

delete from stock_prices
where `Date` between '1984-09-07' and '2019-12-31';

select * 
from stock_prices
where `date` between '2020-01-02' and '2025-01-17'
order by `date` asc;


-----MAX CLOSING PRICE
select `date`, `close`
from stock_prices
where `close` = (select max(close) from stock_prices);


-----MIN CLOSING PRICE
select `date`, `close`
from stock_prices
where `close` = (select min(close) from stock_prices);


-----AVG CLOSING PRICE
select avg(close) as avg_close from stock_prices;


-----MONTHLY AVERAGE CLOSING PRICES 
select date_format (`date`, '%Y-%m') as month, avg(close) as avg_close 
from stock_prices
group by month
order by month asc;


-----DAILY PERCENTAGE CHANGE IN CLOSING PRICE
select `date`, close,
	lag(close) over (order by `date`) as previous_close,
    (close - lag(close) over (order by `date`)) / lag(close) over (order by `date`) * 100 as Daily_Return
from stock_prices;


-----PERCENTAGE CHANGE IN CLOSING PRICE (ADJUST ACCORDING TO YEAR)
select `date`, close,
	lag(close) over (order by `date`) as previous_close,
    (close - lag(close) over (order by `date`)) / lag(close) over (order by `date`) * 100 as Daily_Return
from stock_prices
where `date` between '2024-01-01' and '2024-12-31';


-----SIMPLE MOVING AVERAGE (change 9 to 19 or 49 to calculate a 20 0r 50 day SMA)
select `date`, close,
	avg(close) over (order by `date` rows between 9 preceding and current row) as SMA_10
from stock_prices
where `date` between '2024-01-01' and '2024-12-31';


-----DAILY RETURNS
SELECT date, close,  
       (close - LAG(close) OVER (ORDER BY date)) / LAG(close) OVER (ORDER BY date) * 100 AS daily_return  
FROM stock_prices;


-----ROLLING VOLATILITY (50d is 50 days)
WITH daily_returns AS (
    SELECT date,  
           (close - LAG(close) OVER (ORDER BY date)) / LAG(close) OVER (ORDER BY date) * 100 AS daily_return  
    FROM stock_prices
)
SELECT date,  
       STDDEV(daily_return) OVER (ORDER BY date ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS volatility_50d  
FROM daily_returns
where `date` between '2024-01-01' and '2024-12-31';


























































