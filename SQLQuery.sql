-- Total Order
SELECT 
  CASE 
    WHEN SUM(s."Units") >= 1000000 
      THEN CONCAT(ROUND(SUM(s."Units") / 1000000.0, 1), 'M')
    WHEN SUM(s."Units") >= 1000 
      THEN CONCAT(ROUND(SUM(s."Units") / 1000.0, 1), 'K')
    ELSE SUM(s."Units")::text
  END AS "Total Order"
FROM "sales" s
LEFT JOIN "stores" st 
    ON s."Store_ID" = st."id"
LEFT JOIN "products" p 
    ON s."Product_ID" = p."Product_ID"
WHERE 
  1=1
  AND {{Date_Filter}}
  AND {{store_filter}}
  AND {{Categories_Filter}}
  AND {{Store_Location}}
  


SELECT 
    CASE 
        WHEN SUM(p."Product_Price" * s."Units") >= 1000000 
            THEN CONCAT(ROUND(SUM(p."Product_Price" * s."Units") / 1000000, 1), 'M')
        WHEN SUM(p."Product_Price" * s."Units") >= 1000 
            THEN CONCAT(ROUND(SUM(p."Product_Price" * s."Units") / 1000, 1), 'K')
        ELSE SUM(p."Product_Price" * s."Units")::text
    END AS revenue
FROM "sales" s
LEFT JOIN "stores" st 
    ON s."Store_ID" = st."id"
LEFT JOIN "products" p 
    ON s."Product_ID" = p."Product_ID"
WHERE 
  1=1
  AND {{Date_Filter}}
  AND {{store_filter}}
  AND {{Categories_Filter}}
  AND {{Store_Location}};


-- Which product categories have the highest  margin?

SELECT 
    CONCAT(
        ROUND(
            (SUM(s."Units" * p."Product_Price") - SUM(s."Units" * p."Product_Cost"))
            / SUM(s."Units" * p."Product_Price") * 100
        , 2),
        '%'
    ) AS profit_margin_kpi
FROM "sales" s
LEFT JOIN "stores" st 
    ON s."Store_ID" = st."id"
LEFT JOIN "products" p 
    ON s."Product_ID" = p."Product_ID"
WHERE 
  1=1
  AND {{Date_Filter}}
  AND {{store_filter}}
  AND {{Categories_Filter}}
  AND {{Store_Location}}
  


-- Total profit
SELECT
  CASE 
    WHEN SUM(s."Units" * p."Product_Price" - p."Product_Cost") >= 1000000 
      THEN CONCAT(ROUND(SUM(s."Units" * p."Product_Price" - p."Product_Cost") / 1000000, 1), 'M')
    WHEN SUM(s."Units" * p."Product_Price" - p."Product_Cost") >= 1000 
      THEN CONCAT(ROUND(SUM(s."Units" * p."Product_Price" - p."Product_Cost") / 1000, 1), 'K')
    ELSE SUM(s."Units" * p."Product_Price" - p."Product_Cost")::text
  END AS profit
FROM "sales" s
LEFT JOIN "stores" st ON s."Store_ID" = st."id"
LEFT JOIN "products" p ON s."Product_ID" = p."Product_ID"
WHERE 
  1=1
  AND {{Date_Filter}}
  AND {{store_filter}}
  AND {{Categories_Filter}}
  AND {{Store_Location}}




-- Which product categories have the highest  margin?
SELECT
    p."Product_Category",
    ( (SUM(s."Units" * p."Product_Price") - SUM(s."Units" * p."Product_Cost")) 
      / SUM(s."Units" * p."Product_Price") ) * 100 AS profit_margin
FROM "sales" s
LEFT JOIN "stores" st 
  ON s."Store_ID" = st."id"
LEFT JOIN "products" p 
  ON s."Product_ID" = p."Product_ID"
WHERE 
  1=1
  AND {{Date_Filter}}
  AND {{store_filter}}
  AND {{Categories_Filter}}
  AND {{Store_Location}}
GROUP BY p."Product_Category"
ORDER BY profit_margin DESC
LIMIT 15;

-- Monthly or weekly sales trends

SELECT
  {{Date}} AS Date, 
  SUM(s."Units" * p."Product_Price") AS total_sales
FROM "sales" s
JOIN "products" p
  ON s."Product_ID" = p."Product_ID"
-- No WHERE clause for the grouping variable
GROUP BY 1
ORDER BY 1;





--Which stores generate the most revenue?
SELECT 
    st."name" AS store_name,
    SUM(p."Product_Price" * s."Units") AS revenue
FROM "sales" s
LEFT JOIN "stores" st 
    ON s."Store_ID" = st."id"
LEFT JOIN "products" p 
    ON s."Product_ID" = p."Product_ID"
WHERE 
  1=1
  AND {{Date_Filter}}
  AND {{store_filter}}
  AND {{Categories_Filter}}
  AND {{Store_Location}}
GROUP BY 1
ORDER BY 2 DESC
LIMIT 15;


-- Which cities sell the most units?

SELECT
 "Store_City",
 sum("Units") as total_units
FROM "sales" s
LEFT JOIN "stores" st 
  ON s."Store_ID" = st."id"
LEFT JOIN "products" p 
  ON s."Product_ID" = p."Product_ID" 
WHERE 
  1=1
  AND {{Date_Filter}}
  AND {{store_filter}}
  AND {{Categories_Filter}}
  AND {{Store_Location}}
GROUP BY 1
ORDER BY 2 DESC
LIMIT 15

--Which stores underperform?
SELECT
    st."name" AS Store_Name,
    st."Store_City",
    SUM(s."Units" * p."Product_Price" - p."Product_Cost") AS profit
FROM "sales" s
LEFT JOIN "stores" st 
    ON s."Store_ID" = st."id"
LEFT JOIN "products" p 
    ON s."Product_ID" = p."Product_ID"
WHERE 
  1=1
  AND {{Date_Filter}}
  AND {{store_filter}}
  AND {{Categories_Filter}}
  AND {{Store_Location}}
GROUP BY 1, 2
ORDER BY profit ASC
LIMIT 10;
-- Products with seasonal spikes
WITH monthly_sales AS (
    SELECT
        p."Product_Name",
        DATE_TRUNC('month', s."Date") AS month,
        SUM(s."Units") AS total_units
    FROM "sales" s
    JOIN "products" p 
        ON s."Product_ID" = p."Product_ID"
    GROUP BY 1, 2
),
avg_sales AS (
    SELECT
        "Product_Name",
        AVG(total_units) AS avg_units
    FROM monthly_sales
    GROUP BY 1
)
SELECT
    m."Product_Name",
    m.month,
    m.total_units,
    a.avg_units,
    ROUND((m.total_units - a.avg_units) / a.avg_units * 100, 1) AS percent_spike
FROM monthly_sales m
JOIN avg_sales a
    ON m."Product_Name" = a."Product_Name"
WHERE
    (m.total_units - a.avg_units) / a.avg_units * 100 > 30   -- more than +30% spike
ORDER BY percent_spike DESC;


--Total value of inventory tied up!

SELECT
   p."Product_Name",
    SUM(i."stock_in_hand" * p."Product_Price") AS "Product_Inventory_Value"
FROM "inventory" i
JOIN "products" p 
    ON i."Product_ID" = p."Product_ID"
GROUP BY 1
ORDER BY 2 DESC





-- Details

SELECT
    s."Product_ID",
    s."Date",
    p."Product_Name",
    
    -- Total order (numeric)
    SUM(s."Units") AS total_order,
    
    -- Revenue (numeric)
    ROUND(SUM(p."Product_Price" * s."Units"), 0) AS revenue,
    
    -- Profit margin (numeric percentage)
    ROUND(
        (SUM(s."Units" * p."Product_Price") - SUM(s."Units" * p."Product_Cost"))
        / NULLIF(SUM(s."Units" * p."Product_Price"), 0) * 100
    , 2) AS profit_margin,
    
    -- Profit (numeric)
    SUM(s."Units" * p."Product_Price" - s."Units" * p."Product_Cost") AS profit

FROM "sales" s
LEFT JOIN "stores" st 
    ON s."Store_ID" = st."id"
LEFT JOIN "products" p 
    ON s."Product_ID" = p."Product_ID"

WHERE 
  1=1
  AND {{Date_Filter}}
  AND {{store_filter}}
  AND {{Categories_Filter}}
  AND {{Store_Location}}
GROUP BY 
    s."Product_ID",
    s."Date",
    p."Product_Name"





