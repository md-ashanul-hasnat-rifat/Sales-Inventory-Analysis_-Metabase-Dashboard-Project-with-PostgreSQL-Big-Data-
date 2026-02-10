# Sales Analytics SQL Queries

This repository contains a collection of production-ready SQL queries used for **sales performance analysis, profitability tracking, store performance evaluation, and inventory insights**. These queries are designed to support **dashboards, management reports, and stakeholder presentations**.

---

## 1. Executive KPIs (Top-Level Metrics)

### Total Orders

* Calculates total units sold
* Formats output dynamically (K / M)
* Used for headline KPI cards

**Business Insight:**
Shows overall demand volume within selected filters (date, store, category, location).

---

### Total Revenue

* Calculates total sales value (Price × Units)
* Auto-formatted for readability (K / M)

**Business Insight:**
Tracks topline performance and growth trends.

---

### Total Profit

* Revenue minus product cost
* Indicates absolute profitability

**Business Insight:**
Helps management assess bottom-line contribution.

---

### Overall Profit Margin (KPI)

* Profit as a percentage of revenue

**Business Insight:**
Quick view of pricing efficiency and cost control.

---

## 2. Product Performance Analysis

### Product Categories with Highest Profit Margin

* Calculates margin by category
* Sorted descending

**Business Questions Answered:**

* Which categories are most profitable?
* Where should we invest more?

---

### Seasonal Product Spikes

* Monthly sales aggregation
* Compares monthly units against product average
* Flags >30% spikes

**Business Insight:**
Identifies seasonality for inventory planning and promotions.

---

## 3. Store & Location Performance

### Stores Generating the Most Revenue

* Revenue by store
* Top 15 ranking

**Business Insight:**
Highlights high-performing stores for best-practice replication.

---

### Underperforming Stores

* Profit by store and city
* Bottom 10 performers

**Business Insight:**
Supports corrective actions such as pricing review or cost optimization.

---

### Cities Selling the Most Units

* Unit sales by city

**Business Insight:**
Identifies high-demand markets and regional opportunities.

---

## 4. Sales Trends

### Monthly / Weekly Sales Trends

* Date-based aggregation
* Supports time-series charts

**Business Insight:**
Tracks growth, seasonality, and sales momentum over time.

---

## 5. Inventory Analysis

### Inventory Value at Risk

* Calculates inventory value (Stock × Price)
* Sorted by highest value

**Business Insight:**
Shows capital tied up in inventory and potential overstock risk.

---

## 6. Detailed Transaction-Level Metrics

### Product-Level Performance Table

Includes:

* Total Orders
* Revenue
* Profit
* Profit Margin

**Use Case:**

* Drill-down analysis
* Export for Excel or BI tools
* Audit-level reporting

---

## 7. Filters Supported

All queries support dynamic filters:

* Date range
* Store
* Product category
* Store location

This makes them reusable across **dashboards, BI tools, and ad-hoc analysis**.

---

## 8. Ideal Use Cases

* Power BI / Tableau dashboards
* Monthly MIS reports
* Executive presentations
* Business performance reviews

---

## Author

**Md. Ahsanul Hasnat Rifat**
Data Analyst | SQL | Power BI | Python | MIS Reporting

---

## 9. SQL Query Sections

Below are the actual SQL queries organized by analysis area. These can be copied directly into BI tools, SQL editors, or used in presentations to explain logic.

---

### 9.1 Total Orders (Formatted KPI)

```sql
SELECT 
  CASE 
    WHEN SUM(s."Units") >= 1000000 
      THEN CONCAT(ROUND(SUM(s."Units") / 1000000.0, 1), 'M')
    WHEN SUM(s."Units") >= 1000 
      THEN CONCAT(ROUND(SUM(s."Units") / 1000.0, 1), 'K')
    ELSE SUM(s."Units")::text
  END AS "Total Order"
FROM "sales" s
LEFT JOIN "stores" st ON s."Store_ID" = st."id"
LEFT JOIN "products" p ON s."Product_ID" = p."Product_ID"
WHERE 1=1
  AND {{Date_Filter}}
  AND {{store_filter}}
  AND {{Categories_Filter}}
  AND {{Store_Location}};
```

---

### 9.2 Total Revenue KPI

```sql
SELECT 
  CASE 
    WHEN SUM(p."Product_Price" * s."Units") >= 1000000 
      THEN CONCAT(ROUND(SUM(p."Product_Price" * s."Units") / 1000000, 1), 'M')
    WHEN SUM(p."Product_Price" * s."Units") >= 1000 
      THEN CONCAT(ROUND(SUM(p."Product_Price" * s."Units") / 1000, 1), 'K')
    ELSE SUM(p."Product_Price" * s."Units")::text
  END AS revenue
FROM "sales" s
LEFT JOIN "stores" st ON s."Store_ID" = st."id"
LEFT JOIN "products" p ON s."Product_ID" = p."Product_ID"
WHERE 1=1
  AND {{Date_Filter}}
  AND {{store_filter}}
  AND {{Categories_Filter}}
  AND {{Store_Location}};
```

---

### 9.3 Overall Profit Margin (KPI)

```sql
SELECT 
  CONCAT(
    ROUND(
      (SUM(s."Units" * p."Product_Price") - SUM(s."Units" * p."Product_Cost"))
      / SUM(s."Units" * p."Product_Price") * 100, 2
    ), '%'
  ) AS profit_margin_kpi
FROM "sales" s
LEFT JOIN "stores" st ON s."Store_ID" = st."id"
LEFT JOIN "products" p ON s."Product_ID" = p."Product_ID"
WHERE 1=1
  AND {{Date_Filter}}
  AND {{store_filter}}
  AND {{Categories_Filter}}
  AND {{Store_Location}};
```

---

### 9.4 Profit Margin by Product Category

```sql
SELECT
  p."Product_Category",
  ((SUM(s."Units" * p."Product_Price") - SUM(s."Units" * p."Product_Cost"))
   / SUM(s."Units" * p."Product_Price")) * 100 AS profit_margin
FROM "sales" s
LEFT JOIN "stores" st ON s."Store_ID" = st."id"
LEFT JOIN "products" p ON s."Product_ID" = p."Product_ID"
WHERE 1=1
  AND {{Date_Filter}}
  AND {{store_filter}}
  AND {{Categories_Filter}}
  AND {{Store_Location}}
GROUP BY p."Product_Category"
ORDER BY profit_margin DESC
LIMIT 15;
```

---

### 9.5 Store Revenue Ranking

```sql
SELECT 
  st."name" AS store_name,
  SUM(p."Product_Price" * s."Units") AS revenue
FROM "sales" s
LEFT JOIN "stores" st ON s."Store_ID" = st."id"
LEFT JOIN "products" p ON s."Product_ID" = p."Product_ID"
WHERE 1=1
  AND {{Date_Filter}}
  AND {{store_filter}}
  AND {{Categories_Filter}}
  AND {{Store_Location}}
GROUP BY 1
ORDER BY 2 DESC
LIMIT 15;
```

---

### 9.6 Underperforming Stores (Low Profit)

```sql
SELECT
  st."name" AS store_name,
  st."Store_City",
  SUM(s."Units" * p."Product_Price" - p."Product_Cost") AS profit
FROM "sales" s
LEFT JOIN "stores" st ON s."Store_ID" = st."id"
LEFT JOIN "products" p ON s."Product_ID" = p."Product_ID"
WHERE 1=1
  AND {{Date_Filter}}
  AND {{store_filter}}
  AND {{Categories_Filter}}
  AND {{Store_Location}}
GROUP BY 1,2
ORDER BY profit ASC
LIMIT 10;
```

---

### 9.7 Inventory Value Analysis

```sql
SELECT
  p."Product_Name",
  SUM(i."stock_in_hand" * p."Product_Price") AS inventory_value
FROM "inventory" i
JOIN "products" p ON i."Product_ID" = p."Product_ID"
GROUP BY 1
ORDER BY 2 DESC;
```

---

These sections make the repository **presentation-ready**, allowing reviewers to understand both **business logic and SQL skills** instantly.

---

If you want next:

* Slide-wise explanation for interviews
* Optimized version for PostgreSQL / MySQL
* Star-schema + data model explanation
* README badges & visuals
