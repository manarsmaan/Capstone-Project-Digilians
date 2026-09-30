

CREATE DATABASE Cash-Flow_Risk;
GO

USE Cash-Flow_Risk;
GO


CREATE SCHEMA bronze;
--عدد الصفوف 
SELECT COUNT(*) AS Total_Rows
FROM[bronze].[sales_raw]

--- اول 10 صفوف 
SELECT TOP 10 *
FROM [bronze].[sales_raw];

--عدد الاعمدة 
SELECT COUNT(*) AS Total_Columns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'bronze'
  AND TABLE_NAME = 'sales_raw';
   

   --اظهار اسماء الاعمدة ونوع كل عمود 
  SELECT
    ORDINAL_POSITION,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'bronze'
  AND TABLE_NAME = 'sales_raw'
ORDER BY ORDINAL_POSITION;


--- هنا تأكد اني معنديش null ف الاعمدة من خلال دالة count لانها هتعدلي ال قيم من غير ال null 
SELECT
    COUNT(*) AS Total_Rows,
    COUNT(Type_of_transaction) AS Type_of_transaction,
    COUNT(Days_for_shipping_real) AS Days_for_shipping_real,
    COUNT(Days_for_shipment_scheduled) AS Days_for_shipment_scheduled,
    COUNT(Delivery_Status) AS Delivery_Status,
    COUNT(Late_delivery_risk) AS Late_delivery_risk,
    COUNT(Category_Name) AS Category_Name,
    COUNT(Customer_City) AS Customer_City,
    COUNT(Customer_Country) AS Customer_Country,
    COUNT(Customer_Id) AS Customer_Id,
    COUNT(Full_name) AS Full_name,
    COUNT(Customer_Segment) AS Customer_Segment,
    COUNT(Customer_State) AS Customer_State,
    COUNT(Department_Name) AS Department_Name,
    COUNT(Market) AS Market,
    COUNT(Order_City) AS Order_City,
    COUNT(Order_Country) AS Order_Country,
    COUNT(order_date_DateOrders) AS order_date_DateOrders,
    COUNT(Order_Id) AS Order_Id,
    COUNT(Order_Item_Discount) AS Order_Item_Discount,
    COUNT(Order_Item_Discount_Rate) AS Order_Item_Discount_Rate,
    COUNT(Order_Item_Id) AS Order_Item_Id,
    COUNT(Order_Item_Profit_Ratio) AS Order_Item_Profit_Ratio,
    COUNT(Order_Item_Quantity) AS Order_Item_Quantity,
    COUNT(Sales) AS Sales,
    COUNT(Order_Item_Total) AS Order_Item_Total,
    COUNT(Benefit_Per_Order) AS Benefit_Per_Order,
    COUNT(Order_Region) AS Order_Region,
    COUNT(Order_State) AS Order_State,
    COUNT(Order_Status) AS Order_Status,
    COUNT(Product_Card_Id) AS Product_Card_Id,
    COUNT(Product_Name) AS Product_Name,
    COUNT(Product_Price) AS Product_Price,
    COUNT(shipping_date_DateOrders) AS shipping_date_DateOrders,
    COUNT(Shipping_Mode) AS Shipping_Mode
FROM bronze.sales_raw;

--التأكد من عدد ال order  Item  id ان مفهاش duplicate 
SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT Order_Item_Id) AS Unique_Order_Item_Id
FROM bronze.sales_raw;

--معرفة عدد ال order item لكل اوردر 
SELECT
    Order_Id,
    COUNT(*) AS Item_Count
FROM bronze.sales_raw
GROUP BY Order_Id
HAVING COUNT(*) > 1
ORDER BY Item_Count DESC;

--معرفة عدد الاوردرات لكل حالة اوردر 
SELECT
    Order_Status,
    COUNT(*) AS Row_Count
FROM bronze.sales_raw
GROUP BY Order_Status
ORDER BY Row_Count DESC;

SELECT
    Order_Status,
    COUNT(distinct Order_Id) AS Row_Count
FROM bronze.sales_raw
GROUP BY Order_Status
ORDER BY Row_Count DESC;

--معرفة عدد الاوردرات لكل Delivery_Status
SELECT
    Delivery_Status,
    COUNT(*) AS Row_Count
FROM bronze.sales_raw
GROUP BY Delivery_Status
ORDER BY Row_Count DESC;

--معرفة عدد الاوردرات لكل Shipping_Mode
SELECT
    Shipping_Mode,
    COUNT(*) AS Row_Count
FROM bronze.sales_raw
GROUP BY Shipping_Mode
ORDER BY Row_Count DESC;

---------------------
-- Min,Max , Avg Sales 
SELECT
    MIN(Sales) AS Min_Sales,
    MAX(Sales) AS Max_Sales,
    AVG(Sales) AS Avg_Sales
FROM bronze.sales_raw;

------------------
--Min , Max , Avg Discount 

SELECT
    MIN(Order_Item_Discount) AS Min_Discount,
    MAX(Order_Item_Discount) AS Max_Discount,
    AVG(Order_Item_Discount) AS Avg_Discount
FROM bronze.sales_raw;

------------------------------------------
-- Min , max , avg QTY

SELECT
    MIN(Order_Item_Quantity) AS Min_Quantity,
    MAX(Order_Item_Quantity) AS Max_Quantity,
    AVG(Order_Item_Quantity) AS Avg_Quantity
FROM bronze.sales_raw;

--بتأكد ان الفرق بين الايرادات والخصم هو نفس العمود Order_Item_Total

SELECT
    COUNT(*) AS Formula_Errors
FROM bronze.sales_raw
WHERE ABS(
    (Sales - Order_Item_Discount)
    - Order_Item_Total
) > 0.01;

--قياس مدى الفرق بين ال SALES - DISCOUNT & ORDER ITEM TOTAL 
SELECT
    MIN(
        (Sales - Order_Item_Discount) - Order_Item_Total
    ) AS Min_Difference,

    MAX(
        (Sales - Order_Item_Discount) - Order_Item_Total
    ) AS Max_Difference,

    AVG(
        (Sales - Order_Item_Discount) - Order_Item_Total
    ) AS Avg_Difference
FROM bronze.sales_raw
WHERE ABS(
    (Sales - Order_Item_Discount) - Order_Item_Total
) > 0.001;


---هل في صفوف مكررة بالكامل 

SELECT
    Order_Id,
    Order_Item_Id,
    COUNT(*) AS Duplicate_Count
FROM bronze.sales_raw
GROUP BY
    Order_Id,
    Order_Item_Id
HAVING COUNT(*) > 1
ORDER BY Duplicate_Count DESC;

-------------------------------------------------------------------



SELECT
    MIN(Sales) AS Min_Sales,
    MAX(Sales) AS Max_Sales,
    MIN(Order_Item_Discount) AS Min_Discount,
    MAX(Order_Item_Discount) AS Max_Discount,
    MIN(Order_Item_Total) AS Min_Order_Item_Total,
    MAX(Order_Item_Total) AS Max_Order_Item_Total,
    MIN(Order_Item_Profit_Ratio) AS Min_Profit_Ratio,
    MAX(Order_Item_Profit_Ratio) AS Max_Profit_Ratio
FROM bronze.sales_raw;


--------------------------------
--- عدد ال null في كل عمود 
SELECT
    'Type_of_transaction'          AS Column_Name, SUM(CASE WHEN Type_of_transaction IS NULL THEN 1 ELSE 0 END) AS Null_Count FROM bronze.sales_raw
UNION ALL SELECT 'Days_for_shipping_real',        SUM(CASE WHEN Days_for_shipping_real IS NULL THEN 1 ELSE 0 END) FROM bronze.sales_raw
UNION ALL SELECT 'Days_for_shipment_scheduled',   SUM(CASE WHEN Days_for_shipment_scheduled IS NULL THEN 1 ELSE 0 END) FROM bronze.sales_raw
UNION ALL SELECT 'Delivery_Status',               SUM(CASE WHEN Delivery_Status IS NULL THEN 1 ELSE 0 END) FROM bronze.sales_raw
UNION ALL SELECT 'Category_Name',                 SUM(CASE WHEN Category_Name IS NULL THEN 1 ELSE 0 END) FROM bronze.sales_raw
UNION ALL SELECT 'Customer_City',                 SUM(CASE WHEN Customer_City IS NULL THEN 1 ELSE 0 END) FROM bronze.sales_raw
UNION ALL SELECT 'Customer_Country',              SUM(CASE WHEN Customer_Country IS NULL THEN 1 ELSE 0 END) FROM bronze.sales_raw
UNION ALL SELECT 'Full_name',                     SUM(CASE WHEN Full_name IS NULL THEN 1 ELSE 0 END) FROM bronze.sales_raw
UNION ALL SELECT 'Customer_Segment',              SUM(CASE WHEN Customer_Segment IS NULL THEN 1 ELSE 0 END) FROM bronze.sales_raw
UNION ALL SELECT 'Customer_State',                SUM(CASE WHEN Customer_State IS NULL THEN 1 ELSE 0 END) FROM bronze.sales_raw
UNION ALL SELECT 'Department_Name',               SUM(CASE WHEN Department_Name IS NULL THEN 1 ELSE 0 END) FROM bronze.sales_raw
UNION ALL SELECT 'Market',                        SUM(CASE WHEN Market IS NULL THEN 1 ELSE 0 END) FROM bronze.sales_raw
UNION ALL SELECT 'Order_City',                    SUM(CASE WHEN Order_City IS NULL THEN 1 ELSE 0 END) FROM bronze.sales_raw
UNION ALL SELECT 'Order_Country',                 SUM(CASE WHEN Order_Country IS NULL THEN 1 ELSE 0 END) FROM bronze.sales_raw
UNION ALL SELECT 'order_date_DateOrders',         SUM(CASE WHEN order_date_DateOrders IS NULL THEN 1 ELSE 0 END) FROM bronze.sales_raw
UNION ALL SELECT 'Product_Name',                  SUM(CASE WHEN Product_Name IS NULL THEN 1 ELSE 0 END) FROM bronze.sales_raw
UNION ALL SELECT 'Product_Price',                 SUM(CASE WHEN Product_Price IS NULL THEN 1 ELSE 0 END) FROM bronze.sales_raw
UNION ALL SELECT 'shipping_date_DateOrders',      SUM(CASE WHEN shipping_date_DateOrders IS NULL THEN 1 ELSE 0 END) FROM bronze.sales_raw
UNION ALL SELECT 'Shipping_Mode',                 SUM(CASE WHEN Shipping_Mode IS NULL THEN 1 ELSE 0 END) FROM bronze.sales_raw;
 
 --اتأكد ان ال ORDER ITEM ID بدون DUPLICATE 
 SELECT
    Order_Item_Id,
    COUNT(*) AS Repeat_Count
FROM bronze.sales_raw
GROUP BY Order_Item_Id
HAVING COUNT(*) > 1;

--اتأكد من منطقية التواريخ وان تاريخ الطلب قبل تاريخ التوصيل 
SELECT COUNT(*) AS Invalid_Date_Rows
FROM bronze.sales_raw
WHERE shipping_date_DateOrders < order_date_DateOrders;

---- 4) قيم شاذة محتملة (Negative values في أعمدة المفروض تكون موجبة)
SELECT COUNT(*) AS Negative_Sales FROM bronze.sales_raw WHERE Sales < 0;
SELECT COUNT(*) AS Negative_Quantity FROM bronze.sales_raw WHERE Order_Item_Quantity < 0;
SELECT COUNT(*) AS Negative_Price FROM bronze.sales_raw WHERE Product_Price < 0;

--اتاكد ان PRODUCT ID ل اسم منتج واحد 

SELECT Product_Card_Id, COUNT(DISTINCT Product_Name) AS Distinct_Names
FROM bronze.sales_raw
GROUP BY Product_Card_Id
HAVING COUNT(DISTINCT Product_Name) > 1;

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'bronze'
  AND TABLE_NAME = 'sales_raw'
  AND COLUMN_NAME IN ('order_date_DateOrders', 'shipping_date_DateOrders');
GO

SELECT
    Customer_Country,
    COUNT(*) AS Row_Count,
    COUNT(DISTINCT Customer_Id) AS Customer_Count
FROM bronze.sales_raw
GROUP BY Customer_Country
ORDER BY Customer_Count DESC;


SELECT
    Customer_Country,
    COUNT(DISTINCT Customer_City) AS Cities,
    COUNT(DISTINCT Customer_State) AS States
FROM bronze.sales_raw
GROUP BY Customer_Country;


SELECT
    Customer_Id,
    COUNT(DISTINCT Customer_Country) AS Country_Count
FROM bronze.sales_raw
GROUP BY Customer_Id
HAVING COUNT(DISTINCT Customer_Country) > 1;

SELECT
    Order_Country,
    COUNT(*) AS Row_Count,
    COUNT(DISTINCT Order_Id) AS Order_Count
FROM bronze.sales_raw
GROUP BY Order_Country
ORDER BY Order_Count DESC;

SELECT
    Order_Country,
    COUNT(DISTINCT Order_City) AS Cities,
    COUNT(DISTINCT Order_State) AS States
FROM bronze.sales_raw
GROUP BY Order_Country
ORDER BY Order_Country;

-- هل العميل مرتبط بأكثر من State؟
SELECT
    Customer_Id,
    COUNT(DISTINCT Customer_State) AS State_Count
FROM bronze.sales_raw
GROUP BY Customer_Id
HAVING COUNT(DISTINCT Customer_State) > 1;

-- هل العميل مرتبط بأكثر من City؟
SELECT
    Customer_Id,
    COUNT(DISTINCT Customer_City) AS City_Count
FROM bronze.sales_raw
GROUP BY Customer_Id
HAVING COUNT(DISTINCT Customer_City) > 1;
-- بعمل schema silver 
USE Operational_CashFlow_Advisor;
GO

SELECT
    Shipping_Mode,
    Delivery_Status,
    Late_delivery_risk,
    COUNT(*) AS Row_Count
FROM bronze.sales_raw
GROUP BY
    Shipping_Mode,
    Delivery_Status,
    Late_delivery_risk
ORDER BY Row_Count DESC;
SELECT
    COUNT(*) AS Total_Rows,

    COUNT(DISTINCT Shipping_Mode) AS Shipping_Modes,

    COUNT(DISTINCT Delivery_Status) AS Delivery_Statuses,

    COUNT(DISTINCT Late_delivery_risk) AS Late_Risk_Values
FROM bronze.sales_raw;

SELECT
    MIN(Days_for_shipping_real) AS Min_Real_Days,
    MAX(Days_for_shipping_real) AS Max_Real_Days,

    MIN(Days_for_shipment_scheduled) AS Min_Scheduled_Days,
    MAX(Days_for_shipment_scheduled) AS Max_Scheduled_Days
FROM bronze.sales_raw;





--------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

--silver schema 

CREATE SCHEMA silver;
GO
--DIM Customer
CREATE TABLE silver.Dim_Customer
(
    Customer_Id INT NOT NULL,
    Full_name NVARCHAR(255) NOT NULL,
    Customer_Segment NVARCHAR(100) NOT NULL,
    Customer_City NVARCHAR(100) NOT NULL,
    Customer_State NVARCHAR(100) NOT NULL,
    Customer_Country NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_Dim_Customer
        PRIMARY KEY (Customer_Id)
);

--Dim_Product
CREATE TABLE silver.Dim_Product
(
    Product_Card_Id INT NOT NULL,
    Product_Name NVARCHAR(255) NOT NULL,
    Category_Name NVARCHAR(150) NOT NULL,
    Department_Name NVARCHAR(150) NOT NULL,
    Product_Price DECIMAL(18,2) NOT NULL,


    CONSTRAINT PK_Dim_Product
        PRIMARY KEY (Product_Card_Id) ,
	CONSTRAINT CK_Dim_Product_Price 
		CHECK (Product_Price >= 0)
);

--Dim Geography

CREATE TABLE silver.Dim_Geography
(
    Geography_Key INT IDENTITY(1,1) NOT NULL,

    Market NVARCHAR(100) NOT NULL,
    Order_Region NVARCHAR(150) NOT NULL,
    Order_Country NVARCHAR(150) NOT NULL,
    Order_State NVARCHAR(150) NOT NULL,
    Order_City NVARCHAR(150) NOT NULL,

    CONSTRAINT PK_Dim_Geography
        PRIMARY KEY (Geography_Key),

    CONSTRAINT UQ_Dim_Geography
        UNIQUE
        (
            Market,
            Order_Region,
            Order_Country,
            Order_State,
            Order_City
        )
);

--Dim_Shipping
CREATE TABLE silver.Dim_Shipping
(
    Shipping_Key       INT IDENTITY(1,1) NOT NULL,
    Shipping_Mode       NVARCHAR(50)  NOT NULL,
    Delivery_Status       NVARCHAR(50)  NOT NULL,
    Late_delivery_risk       INT           NOT NULL,
    CONSTRAINT PK_Dim_Shipping
        PRIMARY KEY (Shipping_Key),
    CONSTRAINT UQ_Dim_Shipping
        UNIQUE
        (
            Shipping_Mode,
            Delivery_Status,
            Late_delivery_risk
        ),
    CONSTRAINT CK_Dim_Shipping_Risk
        CHECK (Late_delivery_risk IN (0, 1))
);


----Dim_Date
CREATE TABLE silver.Dim_Date
(
    Full_Date        DATE        NOT NULL,
    [Year]            INT         NOT NULL,
    [Month]            INT         NOT NULL,
    [Day]               INT         NOT NULL,
    Month_Name           NVARCHAR(20) NOT NULL,
    Quarter                INT         NOT NULL,
    CONSTRAINT PK_Dim_Date
        PRIMARY KEY (Full_Date),
    CONSTRAINT CK_Dim_Date_Month
        CHECK ([Month] BETWEEN 1 AND 12),
    CONSTRAINT CK_Dim_Date_Quarter
        CHECK (Quarter BETWEEN 1 AND 4)
);



--Fact_Orders
CREATE TABLE silver.Fact_Orders
(
    Order_Item_Id                  INT             NOT NULL,
    Order_Id                        INT             NOT NULL,
    Customer_Id                      INT             NOT NULL,
    Product_Card_Id                   INT             NOT NULL,
    Geography_Key                      INT             NOT NULL,
    Shipping_Key                        INT             NOT NULL,
    Order_Date                           DATE            NOT NULL,
    Shipping_Date                         DATE            NOT NULL,
    Type_of_transaction                    NVARCHAR(50)    NOT NULL,
    Order_Status                            NVARCHAR(50)    NOT NULL,
    Days_for_shipping_real                   INT             NOT NULL,
    Days_for_shipment_scheduled               INT             NOT NULL,
    Order_Item_Quantity                        INT             NOT NULL,
    Sales                                       DECIMAL(18,2)   NOT NULL,
    Order_Item_Discount                          DECIMAL(18,2)   NOT NULL,
    Order_Item_Discount_Rate                      DECIMAL(9,4)    NOT NULL,
    Order_Item_Total                               DECIMAL(18,2)   NOT NULL,
    Benefit_Per_Order                               DECIMAL(18,2)   NOT NULL,
    Order_Item_Profit_Ratio                          DECIMAL(9,4)    NOT NULL,
 
    CONSTRAINT PK_Fact_Orders
        PRIMARY KEY (Order_Item_Id),
 
    CONSTRAINT FK_Fact_Orders_Customer
        FOREIGN KEY (Customer_Id)
        REFERENCES silver.Dim_Customer (Customer_Id),
 
    CONSTRAINT FK_Fact_Orders_Product
        FOREIGN KEY (Product_Card_Id)
        REFERENCES silver.Dim_Product (Product_Card_Id),
 
    CONSTRAINT FK_Fact_Orders_Geography
        FOREIGN KEY (Geography_Key)
        REFERENCES silver.Dim_Geography (Geography_Key),
 
    CONSTRAINT FK_Fact_Orders_Shipping
        FOREIGN KEY (Shipping_Key)
        REFERENCES silver.Dim_Shipping (Shipping_Key),
 
    CONSTRAINT FK_Fact_Orders_OrderDate
        FOREIGN KEY (Order_Date)
        REFERENCES silver.Dim_Date (Full_Date),
 
    CONSTRAINT FK_Fact_Orders_ShippingDate
        FOREIGN KEY (Shipping_Date)
        REFERENCES silver.Dim_Date (Full_Date),
 
    CONSTRAINT CK_Fact_Orders_Quantity
        CHECK (Order_Item_Quantity > 0),
 
    CONSTRAINT CK_Fact_Orders_Sales
        CHECK (Sales >= 0),
 
    CONSTRAINT CK_Fact_Orders_Discount
        CHECK (Order_Item_Discount >= 0),
 
    CONSTRAINT CK_Fact_Orders_DiscountRate
        CHECK (Order_Item_Discount_Rate BETWEEN 0 AND 1)
);

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------


-- تعبئة silver.Dim_Customer من bronze.sales_raw (مع TRIM على الأعمدة النصية)
INSERT INTO silver.Dim_Customer
    (Customer_Id, Full_name, Customer_Segment, Customer_City, Customer_State, Customer_Country)
SELECT DISTINCT
    Customer_Id,
    TRIM(Full_name)         AS Full_name,
    TRIM(Customer_Segment)  AS Customer_Segment,
    TRIM(Customer_City)     AS Customer_City,
    TRIM(Customer_State)    AS Customer_State,
    TRIM(Customer_Country)  AS Customer_Country
FROM bronze.sales_raw;
GO
 
-- تأكيد سريع: عدد العملاء الفريدين اللي دخلوا
SELECT COUNT(*) AS Total_Customers FROM silver.Dim_Customer;



------------------------------------------------------------




-- تعبئة silver.Dim_Product من bronze.sales_raw (مع TRIM على الأعمدة النصية)
INSERT INTO silver.Dim_Product
    (Product_Card_Id, Product_Name, Category_Name, Department_Name, Product_Price)
SELECT DISTINCT
    Product_Card_Id,
    TRIM(Product_Name)      AS Product_Name,
    TRIM(Category_Name)     AS Category_Name,
    TRIM(Department_Name)   AS Department_Name,
    Product_Price
FROM bronze.sales_raw;
GO
 
-- تأكيد سريع: عدد المنتجات الفريدة اللي دخلت
SELECT COUNT(*) AS Total_Products FROM silver.Dim_Product;




----------------------------------------------------------------




-- تعبئة silver.Dim_Geography من bronze.sales_raw (مع TRIM على الأعمدة النصية)
INSERT INTO silver.Dim_Geography
    (Market, Order_Region, Order_Country, Order_State, Order_City)
SELECT DISTINCT
    TRIM(Market)         AS Market,
    TRIM(Order_Region)   AS Order_Region,
    TRIM(Order_Country)  AS Order_Country,
    TRIM(Order_State)    AS Order_State,
    TRIM(Order_City)     AS Order_City
FROM bronze.sales_raw;
GO
 
-- تأكيد سريع: عدد التركيبات الجغرافية الفريدة اللي دخلت
SELECT COUNT(*) AS Total_Geographies FROM silver.Dim_Geography;
 



--------------------------------------------------------------------------


-- تعبئة silver.Dim_Shipping من bronze.sales_raw (مع TRIM على الأعمدة النصية)
INSERT INTO silver.Dim_Shipping
    (Shipping_Mode, Delivery_Status, Late_delivery_risk)
SELECT DISTINCT
    TRIM(Shipping_Mode)    AS Shipping_Mode,
    TRIM(Delivery_Status)  AS Delivery_Status,
    Late_delivery_risk
FROM bronze.sales_raw;
GO
 
-- تأكيد سريع: عدد التركيبات الفريدة اللي دخلت
SELECT COUNT(*) AS Total_Shipping_Combos FROM silver.Dim_Shipping;
--------------------------------------------------------------------------


-- تعبئة silver.Dim_Date بمدى متصل من الأيام
-- من (أصغر تاريخ بين order_date و shipping_date) لـ (أكبر تاريخ بينهم)
-- كل يوم في المدى ده هيتحط، سواء فيه أوردر أو لأ
 
;WITH DateBounds AS (
    SELECT
        MIN(D) AS Min_Date,
        MAX(D) AS Max_Date
    FROM (
        SELECT CAST(order_date_DateOrders AS DATE) AS D FROM bronze.sales_raw
        UNION ALL
        SELECT CAST(shipping_date_DateOrders AS DATE) FROM bronze.sales_raw
    ) AS AllDates
),
DateSeries AS (
    -- نقطة البداية: أصغر تاريخ
    SELECT Min_Date AS D, Max_Date
    FROM DateBounds
 
    UNION ALL
 
    -- كل مرة نزود يوم واحد لحد ما نوصل لأكبر تاريخ
    SELECT DATEADD(DAY, 1, D), Max_Date
    FROM DateSeries
    WHERE D < Max_Date
)
INSERT INTO silver.Dim_Date (Full_Date, [Year], [Month], [Day], Month_Name, Quarter)
SELECT
    D                       AS Full_Date,
    YEAR(D)                 AS [Year],
    MONTH(D)                AS [Month],
    DAY(D)                  AS [Day],
    DATENAME(MONTH, D)      AS Month_Name,
    DATEPART(QUARTER, D)    AS Quarter
FROM DateSeries
OPTION (MAXRECURSION 0);   -- لازم نلغي حد التكرار الافتراضي (100) لأن المدى ممكن يعدي 100 يوم
GO
 
-- تأكيد سريع
SELECT
    MIN(Full_Date) AS First_Day,
    MAX(Full_Date) AS Last_Day,
    COUNT(*)       AS Total_Days
FROM silver.Dim_Date;


--------------------------------------------------------------------------------------------



	-- تعبئة silver.Fact_Orders من bronze.sales_raw (مع TRIM على الأعمدة النصية)
-- ملحوظة: بما إن Dim_Geography و Dim_Shipping اتخزنوا بقيم TRIM شدة،
-- لازم الـ JOIN كمان يقارن بقيم TRIM من bronze عشان التطابق يظبط 100%
 
INSERT INTO silver.Fact_Orders
(
    Order_Item_Id, Order_Id, Customer_Id, Product_Card_Id,
    Geography_Key, Shipping_Key, Order_Date, Shipping_Date,
    Type_of_transaction, Order_Status,
    Days_for_shipping_real, Days_for_shipment_scheduled,
    Order_Item_Quantity, Sales, Order_Item_Discount,
    Order_Item_Discount_Rate, Order_Item_Total,
    Benefit_Per_Order, Order_Item_Profit_Ratio
)
SELECT
    s.Order_Item_Id,
    s.Order_Id,
    s.Customer_Id,
    s.Product_Card_Id,
    g.Geography_Key,
    sh.Shipping_Key,
    CAST(s.order_date_DateOrders AS DATE),
    CAST(s.shipping_date_DateOrders AS DATE),
    TRIM(s.Type_of_transaction)   AS Type_of_transaction,
    TRIM(s.Order_Status)           AS Order_Status,
    s.Days_for_shipping_real,
    s.Days_for_shipment_scheduled,
    s.Order_Item_Quantity,
    s.Sales,
    s.Order_Item_Discount,
    s.Order_Item_Discount_Rate,
    s.Order_Item_Total,
    s.Benefit_Per_Order,
    s.Order_Item_Profit_Ratio
FROM bronze.sales_raw s
JOIN silver.Dim_Geography g
    ON g.Market        = TRIM(s.Market)
   AND g.Order_Region   = TRIM(s.Order_Region)
   AND g.Order_Country  = TRIM(s.Order_Country)
   AND g.Order_State    = TRIM(s.Order_State)
   AND g.Order_City     = TRIM(s.Order_City)
JOIN silver.Dim_Shipping sh
    ON sh.Shipping_Mode      = TRIM(s.Shipping_Mode)
   AND sh.Delivery_Status     = TRIM(s.Delivery_Status)
   AND sh.Late_delivery_risk  = s.Late_delivery_risk;
GO
 
-- تأكيد نهائي: هل كل صفوف bronze اتنقلت من غير فقد؟
SELECT
    (SELECT COUNT(*) FROM bronze.sales_raw)      AS Bronze_Rows,
    (SELECT COUNT(*) FROM silver.Fact_Orders)    AS Fact_Rows;
	---------------------------------------------------------------------





	USE Operational_CashFlow_Advisor;
GO
 
CREATE SCHEMA gold;
GO
 
-- ---------------------------------------------------------
-- View: Customer
-- ---------------------------------------------------------
CREATE VIEW gold.vw_Dim_Customer AS
SELECT
    Customer_Id,
    Full_name,
    Customer_Segment,
    Customer_City,
    Customer_State,
    Customer_Country
FROM silver.Dim_Customer;
GO
 

-- ---------------------------------------------------------
-- View: Product
-- ---------------------------------------------------------
CREATE VIEW gold.vw_Dim_Product AS
SELECT
    Product_Card_Id,
    Product_Name,
    Category_Name,
    Department_Name,
    Product_Price
FROM silver.Dim_Product;
GO

-- ---------------------------------------------------------
-- View: Geography
-- ---------------------------------------------------------
CREATE VIEW gold.vw_Dim_Geography AS
SELECT
    Geography_Key,
    Market,
    Order_Region,
    Order_Country,
    Order_State,
    Order_City
FROM silver.Dim_Geography;
GO

-- ---------------------------------------------------------
-- View: Shipping
-- ---------------------------------------------------------
CREATE VIEW gold.vw_Dim_Shipping AS
SELECT
    Shipping_Key,
    Shipping_Mode,
    Delivery_Status,
    Late_delivery_risk
FROM silver.Dim_Shipping;
GO

-- ---------------------------------------------------------
-- View: Date
-- ---------------------------------------------------------
CREATE VIEW gold.vw_Dim_Date AS
SELECT
    Full_Date,
    [Year],
    [Month],
    [Day],
    Month_Name,
    Quarter
FROM silver.Dim_Date;
GO

-- ---------------------------------------------------------
-- View: Fact Orders
-- ---------------------------------------------------------

CREATE OR ALTER VIEW gold.vw_Fact_Orders AS
SELECT
    Order_Item_Id,
    Order_Id,
    Customer_Id,
    Product_Card_Id,
    Geography_Key,
    Shipping_Key,
    Order_Date,
    Shipping_Date,
    Type_of_transaction,
    Order_Status,
    Days_for_shipping_real,
    Days_for_shipment_scheduled,
    Order_Item_Quantity,
    Sales,
    Order_Item_Discount,
    Order_Item_Discount_Rate,
    Order_Item_Total   AS Net_Sales,
    Benefit_Per_Order   AS Profit,
    Order_Item_Profit_Ratio
FROM silver.Fact_Orders;
GO
 
-- تأكيد سريع
SELECT TOP 5 * FROM gold.vw_Fact_Orders;





 
-- ---------------------------------------------------------
-- تأكيد سريع: تجربة الـ views
-- ---------------------------------------------------------
SELECT TOP 10 * FROM gold.Dim_Customer;
SELECT TOP 10 * FROM gold.Fact_Orders;
 
SELECT
    (SELECT COUNT(*) FROM silver.Fact_Orders) AS Silver_Rows,
    (SELECT COUNT(*) FROM gold.Fact_Orders)   AS Gold_Rows;

----------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
SELECT
    COUNT(*) AS Total_Items,
 
    SUM(CASE
        WHEN Profit < 0 THEN 1
        ELSE 0
    END) AS Negative_Profit_Items,
 
    CAST(
        100.0 *
        SUM(CASE
            WHEN Profit < 0 THEN 1
            ELSE 0
        END)
        / COUNT(*)
        AS DECIMAL(10,2)
    ) AS Negative_Profit_Rate
FROM gold.vw_Fact_Orders;
-- طلع عندي 33784 طلب ربحه سالب بنسبة 18.71 %
---------------------------------------------------------------------------------
 
--- هل الخصم له علاقة بالخسارة بتاعتي
--هل بخسر علشان الخصم عندي كبير
SELECT
    CASE
        WHEN Order_Item_Discount_Rate < 0.05 THEN '0-5%'
        WHEN Order_Item_Discount_Rate < 0.10 THEN '5-10%'
        WHEN Order_Item_Discount_Rate < 0.20 THEN '10-20%'
        ELSE '>20%'
    END AS Discount_Band,
 
    COUNT(*) AS Order_Items,
 
    SUM(CASE
        WHEN Profit < 0 THEN 1
        ELSE 0
    END) AS Negative_Profit_Items,
 
    CAST(
        100.0 *
        SUM(CASE
            WHEN Profit < 0 THEN 1
            ELSE 0
        END)
        / COUNT(*)
        AS DECIMAL(10,2)
    ) AS Negative_Profit_Rate,
 
    AVG(Order_Item_Profit_Ratio) AS Avg_Profit_Ratio,
 
    SUM(Order_Item_Discount) AS Total_Discount
FROM gold.vw_Fact_Orders
GROUP BY
    CASE
        WHEN Order_Item_Discount_Rate < 0.05 THEN '0-5%'
        WHEN Order_Item_Discount_Rate < 0.10 THEN '5-10%'
        WHEN Order_Item_Discount_Rate < 0.20 THEN '10-20%'
        ELSE '>20%'
    END
ORDER BY Negative_Profit_Rate DESC;
 
 
-----------------------------------------------------------
-----------------------------------------------------------
--هل التأخير له علاقة بالخسارة
SELECT
    CASE
        WHEN Days_for_shipping_real >
             Days_for_shipment_scheduled
        THEN 'Delayed'
        ELSE 'On Time'
    END AS Delivery_Performance,
 
    COUNT(*) AS Order_Items,
 
    SUM(CASE
        WHEN Profit < 0 THEN 1
        ELSE 0
    END) AS Negative_Profit_Items,
 
    CAST(
        100.0 *
        SUM(CASE
            WHEN Profit < 0 THEN 1
            ELSE 0
        END)
        / COUNT(*)
        AS DECIMAL(10,2)
    ) AS Negative_Profit_Rate,
 
    AVG(Order_Item_Profit_Ratio) AS Avg_Profit_Ratio,
 
    SUM(Profit) AS Total_Benefit
FROM gold.vw_Fact_Orders
GROUP BY
    CASE
        WHEN Days_for_shipping_real >
             Days_for_shipment_scheduled
        THEN 'Delayed'
        ELSE 'On Time'
    END;
 
	--------------------------------------------------------
	---------------------------------------------------------
	--هل لو دمجت الاتنين مع بعض ممكن يأثروا على الخسارة
	SELECT
    CASE
        WHEN Days_for_shipping_real >
             Days_for_shipment_scheduled
        THEN 'Delayed'
        ELSE 'On Time'
    END AS Delivery_Performance,
 
    CASE
        WHEN Order_Item_Discount_Rate < 0.10
            THEN 'Low Discount'
        WHEN Order_Item_Discount_Rate < 0.20
            THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS Discount_Level,
 
    COUNT(*) AS Order_Items,
 
    SUM(CASE
        WHEN Profit < 0 THEN 1
        ELSE 0
    END) AS Negative_Profit_Items,
 
    CAST(
        100.0 *
        SUM(CASE
            WHEN Profit < 0 THEN 1
            ELSE 0
        END)
        / COUNT(*)
        AS DECIMAL(10,2)
    ) AS Negative_Profit_Rate,
 
    AVG(Order_Item_Profit_Ratio) AS Avg_Profit_Ratio
 
FROM gold.vw_Fact_Orders
 
GROUP BY
    CASE
        WHEN Days_for_shipping_real >
             Days_for_shipment_scheduled
        THEN 'Delayed'
        ELSE 'On Time'
    END,
 
    CASE
        WHEN Order_Item_Discount_Rate < 0.10
            THEN 'Low Discount'
        WHEN Order_Item_Discount_Rate < 0.20
            THEN 'Medium Discount'
        ELSE 'High Discount'
    END
 
ORDER BY Negative_Profit_Rate DESC;
-------------------------------------------------------------------------
-------------------------------------------------------------------
--هل نوع الشحن له علاقة بالخسارة
SELECT
    s.Shipping_Mode,
    COUNT(*) AS Total_Items,
    SUM(CASE WHEN f.Profit < 0 THEN 1 ELSE 0 END) AS Negative_Profit_Items,
    CAST(100.0 * SUM(CASE WHEN f.Profit < 0 THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(10,2)) AS Negative_Profit_Rate,
    AVG(f.Order_Item_Profit_Ratio) AS Avg_Profit_Ratio
FROM gold.vw_Fact_Orders f
INNER JOIN gold.vw_Dim_Shipping s
    ON f.Shipping_Key = s.Shipping_Key
GROUP BY s.Shipping_Mode
ORDER BY Negative_Profit_Rate DESC;
 
--------------------------------------------------------------------------------
----------------------------------------------------------------------
--اى اعلى منتج بيسبب خسارة
SELECT
    p.Product_Name,
 
    SUM(f.Sales) AS Sales,
 
    SUM(f.Profit) AS Total_Profit,
 
    AVG(f.Order_Item_Profit_Ratio) AS Avg_Profit_Ratio,
 
    AVG(f.Order_Item_Discount_Rate) AS Avg_Discount_Rate,
 
    COUNT(*) AS Order_Items
 
FROM gold.vw_Fact_Orders f
JOIN gold.vw_Dim_Product p
    ON f.Product_Card_Id = p.Product_Card_Id
 
GROUP BY p.Product_Name
 
HAVING SUM(f.Profit) < 0
 
ORDER BY Total_Profit ASC;
 
-----------------------------------------------------------------
-------------------------------------------------------------------
--هل الماركيت له علاقة بالخسارة
SELECT
    g.Market,
 
    SUM(f.Sales) AS Total_Sales,
 
    SUM(f.Profit) AS Total_Profit,
 
    AVG(f.Order_Item_Profit_Ratio) AS Avg_Profit_Ratio,
 
    AVG(f.Order_Item_Discount_Rate) AS Avg_Discount_Rate,
 
    AVG(
        CAST(f.Days_for_shipping_real AS FLOAT)
        -
        CAST(f.Days_for_shipment_scheduled AS FLOAT)
    ) AS Avg_Delay_Days
 
FROM gold.vw_Fact_Orders f
JOIN gold.vw_Dim_Geography g
    ON f.Geography_Key = g.Geography_Key
 
GROUP BY g.Market
 
ORDER BY Total_Profit ASC;
 
 
---------------------------------------------------------------------------
--------------------------------------------------------------------------
--
SELECT
    g.Market,
 
    COUNT(*) AS Order_Items,
 
    SUM(CASE
        WHEN f.Profit < 0 THEN 1
        ELSE 0
    END) AS Negative_Profit_Items,
 
    CAST(
        100.0 *
        SUM(CASE
            WHEN f.Profit < 0 THEN 1
            ELSE 0
        END)
        / COUNT(*)
        AS DECIMAL(10,2)
    ) AS Negative_Profit_Rate,
 
    SUM(CASE
        WHEN f.Profit < 0 THEN f.Profit
        ELSE 0
    END) AS Total_Loss_Amount,
 
    AVG(f.Order_Item_Profit_Ratio) AS Avg_Profit_Ratio
 
FROM gold.vw_Fact_Orders f
JOIN gold.vw_Dim_Geography g
    ON f.Geography_Key = g.Geography_Key
 
GROUP BY g.Market
 
ORDER BY Negative_Profit_Rate DESC;
 

-----------------------------------------------------------------
-------------------------------------------------------------------
--عدد ال orders الخسارة والرابحة من مجمل ال orders 
SELECT
    COUNT(*) AS Total_Orders,

    SUM(
        CASE
            WHEN Total_Order_Profit < 0 THEN 1
            ELSE 0
        END
    ) AS Loss_Making_Orders,

    SUM(
        CASE
            WHEN Total_Order_Profit >= 0 THEN 1
            ELSE 0
        END
    ) AS Profitable_Orders,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN Total_Order_Profit < 0 THEN 1
                ELSE 0
            END
        ) / COUNT(*)
        AS DECIMAL(10,2)
    ) AS Loss_Making_Order_Rate

FROM
(
    SELECT
        Order_Id,
        SUM(Profit) AS Total_Order_Profit
    FROM gold.vw_Fact_Orders
    GROUP BY Order_Id
) AS Orders;


---------------------------------------------------------------------
--هشوف هل ال order items خسارة بس المجمل بتاع الاوردر ربح ولا هو بيأثر على خسارة الاوردرككل 
WITH Order_Level AS
(
    SELECT
        Order_Id,

        SUM(Profit) AS Total_Order_Profit,

        SUM(
            CASE
                WHEN Profit < 0 THEN 1
                ELSE 0
            END
        ) AS Negative_Profit_Items,

        COUNT(*) AS Total_Items

    FROM gold.vw_Fact_Orders

    GROUP BY Order_Id
)

SELECT

    CASE
        WHEN Negative_Profit_Items > 0
             AND Total_Order_Profit < 0
            THEN 'Loss-Making Order'

        WHEN Negative_Profit_Items > 0
             AND Total_Order_Profit >= 0
            THEN 'Mixed Order - Overall Profitable'

        ELSE 'Fully Profitable Order'
    END AS Order_Profit_Status,

    COUNT(*) AS Order_Count,

    CAST(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER()
        AS DECIMAL(10,2)
    ) AS Order_Percentage

FROM Order_Level

GROUP BY
    CASE
        WHEN Negative_Profit_Items > 0
             AND Total_Order_Profit < 0
            THEN 'Loss-Making Order'

        WHEN Negative_Profit_Items > 0
             AND Total_Order_Profit >= 0
            THEN 'Mixed Order - Overall Profitable'

        ELSE 'Fully Profitable Order'
    END

ORDER BY Order_Count DESC;

--------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
--الفرق بين ال Loss-Making/Profitable

WITH Order_Level AS
(
    SELECT
        Order_Id,

        SUM(Sales) AS Total_Sales,

        SUM(Order_Item_Discount) AS Total_Discount,

        SUM(Profit) AS Total_Profit,

        AVG(Order_Item_Discount_Rate) AS Avg_Discount_Rate,

        AVG(Order_Item_Profit_Ratio) AS Avg_Profit_Ratio,

        SUM(Order_Item_Quantity) AS Total_Quantity,

        AVG(
            CAST(Days_for_shipping_real AS FLOAT)
            - CAST(Days_for_shipment_scheduled AS FLOAT)
        ) AS Avg_Delay_Days

    FROM gold.vw_Fact_Orders

    GROUP BY Order_Id
)

SELECT
    CASE
        WHEN Total_Profit < 0
            THEN 'Loss-Making Order'
        ELSE 'Profitable Order'
    END AS Order_Status,

    COUNT(*) AS Order_Count,

    AVG(Total_Sales) AS Avg_Order_Sales,

    AVG(Total_Discount) AS Avg_Order_Discount,

    AVG(Avg_Discount_Rate) AS Avg_Discount_Rate,

    AVG(Total_Profit) AS Avg_Order_Profit,

    AVG(Avg_Profit_Ratio) AS Avg_Profit_Ratio,

    AVG(Total_Quantity) AS Avg_Quantity,

    AVG(Avg_Delay_Days) AS Avg_Delay_Days

FROM Order_Level

GROUP BY
    CASE
        WHEN Total_Profit < 0
            THEN 'Loss-Making Order'
        ELSE 'Profitable Order'
    END;
