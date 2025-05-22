-- ĐỀ BÀI: PHÂN TÍCH HÀNH VI KHÁCH HÀNG VÀ HIỆU QUẢ CỦA CÁC CHIẾN DỊCH MARKETING
-- 1.Tiền xử lý dữ liệu
---1.1 Kiểm tra trước các dữ liệu
SELECT TOP 100 * FROM marketing;
SELECT DISTINCT COUNT (*) AS Total_row1 FROM marketing
--- Không có dữ liệu bị trùng tất cả giá trị
SELECT 
	SUM(CASE WHEN Income IS NULL THEN 1 ELSE 0 END) AS Null_income 
FROM marketing;
-- Có 24 giá trị null trong income

---1.2 Thực hiện xử lý và định dạng lại dữ liệu
DELETE FROM marketing WHERE income IS NULL;

ALTER TABLE marketing
ADD DtCustomer Date;
UPDATE marketing
SET DtCustomer = CONVERT( Date,Dt_Customer)

ALTER TABLE marketing
DROP COLUMN Dt_Customer;

---1.3 Tạo thêm cột hoặc các chỉ số tính toán mới cần thiết cho phân tích khách hàng
ALTER TABLE marketing
ADD Year_Enrolled INT, TotalSpend INT, TotalPeople INT, TotalPurchases INT, Age INT, CampaignsAccepted INT;

UPDATE marketing
SET
	Year_Enrolled = Year (DtCustomer),
	TotalSpend = MntWines + MntFruits + MntMeatProducts +
                 MntFishProducts + MntSweetProducts + MntGoldProds,
	TotalPeople = Kidhome + Teenhome,
	TotalPurchases = NumWebPurchases + NumCatalogPurchases + NumStorePurchases,
	Age = Year_Enrolled - Year_Birth,
	CampaignsAccepted =  AcceptedCmp1 + AcceptedCmp2 + AcceptedCmp3 + AcceptedCmp4 + AcceptedCmp5;

---1.4 Xóa các cột, dòng outlier hoặc không có ý nghĩa phân tích hoặc có giá trị giống nhau
ALTER TABLE marketing
DROP COLUMN Z_CostContact, Z_Revenue;

DELETE FROM marketing WHERE Age >75 OR Age <15;
-- 2.Phân tích khách hàng:
---2.1 Thống kê các đặc trưng của mẫu như số lượng, trung bình
SELECT COUNT (*) AS Total_row FROM marketing
SELECT Education, COUNT (Education) AS Count_Edu FROM marketing GROUP BY Education;
SELECT Marital_Status, COUNT (Marital_Status) AS Count_Status FROM marketing GROUP BY Marital_Status;
SELECT AVG (Income) AS Avg_income, AVG(Recency) AS Avg_Recency, AVG(TotalSpend) AS Avg_spend, 
		AVG(NumDealsPurchases) AS Avg_deals, AVG(TotalPeople) AS Avg_children, 
		AVG(TotalPurchases) AS Avg_perchases,AVG(Age) AS Avg_age, 
		AVG(NumWebVisitsMonth) AS Avg_visitweb FROM marketing;

---2.2 Dựa trên thời gian khách hàng mua hàng lần nữa
---- Khách hàng mua hàng có thời gian quay lại mua hàng ngắn nhất
SELECT * FROM marketing WHERE Recency = 0;
SELECT 
	COUNT(ID) AS num_customers_min_recency, 
	AVG(Income) AS Avg_income, AVG(TotalSpend) AS Avg_spend, AVG(TotalPeople) AS Avg_children, 
	AVG(NumDealsPurchases) AS Avg_deals  FROM marketing WHERE Recency = 0


---- Khách hàng mua hàng có thời gian quay lại mua hàng dài nhất nhất
SELECT * FROM marketing
WHERE Recency = (SELECT MAX(Recency) FROM marketing);
SELECT 
	COUNT(ID) AS num_customers_min_recency, 
	AVG(Income) AS Avg_income, AVG(TotalSpend) AS Avg_spend, AVG(TotalPeople) AS Avg_children, 
	AVG(NumDealsPurchases) AS Avg_deals  FROM marketing WHERE Recency = (SELECT MAX(Recency) FROM marketing);

--- 2.3 Dựa trên phản hồi của khách hàng sau mua
SELECT 
  Complain,
  COUNT(ID) AS Customer_Count,
  AVG(TotalPurchases) AS Avg_Purchases,
  CAST(AVG(Recency) AS DECIMAL (5,2)) AS Avg_Recency
FROM marketing
GROUP BY Complain;

SELECT Education, COUNT(*) AS Complain, AVG(Age) AS Avg_age, AVG(Income) AS Avg_income
FROM marketing
WHERE Complain = 1
GROUP BY Education
ORDER BY Complain DESC;

SELECT Marital_Status, COUNT(*) AS Complain, AVG(Age) AS Avg_age, AVG(TotalPeople) AS Avg_child
FROM marketing
WHERE Complain = 1
GROUP BY Marital_Status
ORDER BY Complain DESC;

---2.4 Dựa trên đặc điểm nhân khẩu học
---- Theo tuổi (age)
SELECT TOP 10 Age, TotalPurchases, TotalSpend, NumDealsPurchases, Complain, NumWebVisitsMonth
FROM marketing ORDER BY TotalPurchases DESC;
SELECT TOP 10 Age, TotalPurchases, TotalSpend, NumDealsPurchases, Complain, NumWebVisitsMonth
FROM marketing ORDER BY TotalPurchases ASC;

SELECT
	CASE 
	WHEN Age < 30 THEN 'Under30'
	WHEN Age > 30 AND Age <60 THEN '30-60' 
	ELSE 'Above60' 
	END AS Age_group,
	COUNT (ID) AS Number,
	AVG(TotalPurchases) AS Avg_purchases,
	AVG(TotalSpend) AS Avg_spend,
	CAST(AVG(NumDealsPurchases) AS DECIMAL (5,2))AS Avg_deals,
	CAST(AVG(NumWebVisitsMonth)AS DECIMAL (5,2)) AS Avg_webvisit,
	SUM(Response) AS Responded_Customers,
CAST(SUM(Response) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS ResponseRate_Percent
FROM marketing
GROUP BY 
CASE 
	WHEN Age < 30 THEN 'Under30'
	WHEN Age > 30 AND Age <60 THEN '30-60' 
	ELSE 'Above60' 
	END
ORDER BY Number DESC;

---- Trình độ học vấn
SELECT TOP 10 Education, TotalPurchases, TotalSpend, NumDealsPurchases, Complain
FROM marketing ORDER BY TotalPurchases DESC;

SELECT
	Education,
	COUNT (ID) AS Number,
	AVG(TotalPurchases) AS Avg_purchases,
	AVG(TotalSpend) AS Avg_spend,
	CAST(AVG(NumDealsPurchases) AS DECIMAL (5,2))AS Avg_deals,
	CAST(AVG(NumWebVisitsMonth)AS DECIMAL (5,2)) AS Avg_webvisit,
	SUM(Response) AS Responded_Customers,
CAST(SUM(Response) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS ResponseRate_Percent
FROM marketing
GROUP BY Education
ORDER BY Number DESC;

----Theo thu nhập
SELECT 
  CASE 
    WHEN Income < 30000 THEN 'Low'
    WHEN Income BETWEEN 30000 AND 70000 THEN 'MediumLow'
	WHEN Income BETWEEN 70000 AND 100000 THEN 'MediumHigh'
    ELSE 'High'
  END AS Income_Group,
  COUNT(ID) AS Customer_Count,
  AVG(TotalSpend) AS Avg_Spend,
  AVG(TotalPurchases) AS Avg_purchases,
  CAST(AVG(NumDealsPurchases) AS DECIMAL (5,2))AS Avg_deals,
CAST(AVG(NumWebVisitsMonth)AS DECIMAL (5,2)) AS Avg_webvisit
FROM marketing
WHERE Income IS NOT NULL
GROUP BY 
  CASE 
    WHEN Income < 30000 THEN 'Low'
    WHEN Income BETWEEN 30000 AND 70000 THEN 'MediumLow'
	WHEN Income BETWEEN 70000 AND 100000 THEN 'MediumHigh'
    ELSE 'High'
  END
 ORDER BY Avg_purchases;

----Theo tình trạng hôn nhân
SELECT TOP 10 Marital_Status, TotalPurchases, TotalSpend, NumDealsPurchases, Complain, TotalPeople
FROM marketing ORDER BY TotalPurchases DESC;

SELECT
	Marital_Status, TotalPeople,
	COUNT (ID) AS Number,
	AVG(TotalPurchases) AS Avg_purchases,
	AVG(TotalSpend) AS Avg_spend,
	CAST(AVG(NumDealsPurchases) AS DECIMAL (5,2))AS Avg_deals,
	CAST(AVG(NumWebVisitsMonth)AS DECIMAL (5,2)) AS Avg_webvisit,
	SUM(Response) AS Responded_Customers,
CAST(SUM(Response) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS ResponseRate_Percent
FROM marketing
GROUP BY 
Marital_Status,TotalPeople
ORDER BY Number DESC;

SELECT Marital_Status, TotalPeople, COUNT(*) AS Complain
FROM marketing
WHERE Complain = 1
GROUP BY Marital_Status, TotalPeople
ORDER BY Complain;

SELECT
  CASE
    WHEN TotalPeople > 1 THEN 'Children'
    ELSE 'Child'
  END AS Num_children,
  COUNT(ID) AS Num_customer,
  AVG(TotalSpend) AS Avg_spend,
  AVG(TotalPurchases) AS Avg_purchases,
  CAST(AVG(NumDealsPurchases) AS DECIMAL(5,2)) AS Avg_deals,
  CAST(AVG(NumWebVisitsMonth) AS DECIMAL(5,2)) AS Avg_webvisit,
  SUM(Response) AS Responded_Customers,
  CAST(SUM(Response) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS ResponseRate_Percent
FROM marketing
GROUP BY 
  CASE
    WHEN TotalPeople > 1 THEN 'Children'
    ELSE 'Child'
  END
ORDER BY Num_customer DESC;

---2.5 Phân tích khách hàng theo chi tiêu vào các danh mục sản phẩm
SELECT
	Year_Enrolled,
  SUM(MntWines) AS Total_Wine,
  SUM(MntMeatProducts) AS Total_Meat,
  SUM(MntFishProducts) AS Total_Fish,
  SUM(MntSweetProducts) AS Total_Sweets,
  SUM(MntGoldProds) AS Total_Gold,
  SUM(MntFruits) AS Total_Fruit,
  Sum(TotalSpend) AS Total_spend
FROM marketing
GROUP BY Year_Enrolled
ORDER BY Year_Enrolled ASC;

SELECT  
	Age, Education, Marital_Status, TotalPeople,
	CAST((MntWines/TotalSpend)*100 AS DECIMAL(5,2)) AS Winespend_percent,
	CAST((MntFruits/TotalSpend)*100 AS DECIMAL(5,2)) AS Fruitspend_percent,
	CAST((MntMeatProducts/TotalSpend)*100 AS DECIMAL(5,2)) AS Meatspend_percent,
	CAST((MntFishProducts/TotalSpend)*100 AS DECIMAL(5,2)) AS Fishspend_percent,
	CAST((MntSweetProducts/TotalSpend)*100 AS DECIMAL(5,2)) AS Sweetspend_percent,
	CAST((MntGoldProds/TotalSpend)*100 AS DECIMAL(5,2)) AS Goldspend_percent,
	TotalSpend, CAST((TotalSpend/TotalSpend)*100 AS DECIMAL(5,0)) AS Total_percent

FROM marketing
ORDER BY TotalSpend DESC;
---> Nhận thấy danh mục rượu và thịt là hai danh mục sản phẩm được chi tiêu nhiều nhất
---- Danh mục rượu
----Đặc điểm của khách hàng dành >90% chi tiêu hai năm qua cho sản phẩm rượu
SELECT 
	 Education, Marital_Status, TotalPeople, CAST((MntWines/TotalSpend)*100 AS DECIMAL(5,2)) AS Wine_percent
FROM marketing 
WHERE CAST((MntWines/TotalSpend)*100 AS DECIMAL(5,2)) > 90 
ORDER BY Wine_percent DESC

SELECT 
  AVG(Age) AS Avg_age,
  AVG(TotalPeople) AS Avg_children,
  CAST(AVG(Income) AS DECIMAL(10,2)) AS Avg_income,
  CAST(AVG(Recency) AS DECIMAL(10,2)) AS Avg_Recency,
  AVG(TotalPurchases) AS Avg_Purchases
FROM marketing 
WHERE TotalSpend > 0
  AND (CAST(MntWines AS FLOAT) / TotalSpend) * 100 > 90;

----Đặc điểm của khách hàng dành >50% chi tiêu hai năm qua cho sản phẩm thịt
SELECT 
	Education, Marital_Status,
	CAST((MntMeatProducts/TotalSpend)*100 AS DECIMAL(5,2)) AS Meatspend_percent
FROM marketing 
WHERE CAST((MntMeatProducts/TotalSpend)*100 AS DECIMAL(5,2)) > 50 
ORDER BY Meatspend_percent DESC

SELECT 
  AVG(Age) AS Avg_age,
  AVG(TotalPeople) AS Avg_children,
  CAST(AVG(Income) AS DECIMAL(10,2)) AS Avg_income,
  CAST(AVG(Recency) AS DECIMAL(10,2)) AS Avg_Recency,
  AVG(TotalPurchases) AS Avg_Purchases
FROM marketing 
WHERE TotalSpend > 0
  AND (CAST(MntMeatProducts AS FLOAT) / TotalSpend) * 100 > 50;

---2.5 Phân tích các kênh mua sắm
SELECT 
Year_Enrolled,
  SUM(NumWebPurchases) AS Total_Web_Purchases,
  SUM(NumCatalogPurchases) AS Total_Catalog_Purchases,
  SUM(NumStorePurchases) AS Total_Store_Purchases,
  SUM(TotalPurchases) AS Total
FROM marketing
GROUP BY Year_Enrolled
ORDER BY Year_Enrolled ASC;
---> Qua các năm khách hàng vẫn ưa chuộng mua hàng trực tiếp tại cửa hàng hơn các phương thức khác
--- Đặc điểm của khách hàng chỉ mua sắm qua các cửa hàng
SELECT Age, Education, Marital_Status, TotalPeople,
CAST((NumStorePurchases/ NULLIF(TotalPurchases,0))*100 AS DECIMAL (5,2)) AS Store_percent
FROM marketing
WHERE CAST((NumStorePurchases/ NULLIF(TotalPurchases,0))*100 AS DECIMAL (5,2)) = 100
ORDER BY Store_percent DESC

SELECT 
  AVG(Age) AS Avg_age,
  AVG(TotalPeople) AS Avg_children,
  CAST(AVG(Income) AS DECIMAL(10,2)) AS Avg_income,
  CAST(AVG(Recency) AS DECIMAL(10,2)) AS Avg_Recency,
  AVG(TotalPurchases) AS Avg_Purchases
FROM marketing 
WHERE CAST((NumStorePurchases/ NULLIF(TotalPurchases,0))*100 AS DECIMAL (5,2)) = 100

-- Tương quan giữa số lần tìm kiếm trên web và số lần mua hàng trên web
SELECT 
  NumWebVisitsMonth,
  CAST(AVG(NumWebPurchases) AS DECIMAL (5,2)) AS Avg_Web_Purchases
FROM marketing
GROUP BY NumWebVisitsMonth
ORDER BY NumWebVisitsMonth;

---2.6 Phân tích tác động của các chiến dịch quảng bá, khuyến mãi đến hành vi mua sắm
----Tỷ lệ phản hồi của từng chiến dịch
SELECT
  CAST(SUM(AcceptedCmp1) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Cmp1_ResponseRate,
  CAST(SUM(AcceptedCmp2) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Cmp2_ResponseRate,
  CAST(SUM(AcceptedCmp3) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Cmp3_ResponseRate,
  CAST(SUM(AcceptedCmp4) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Cmp4_ResponseRate,
  CAST(SUM(AcceptedCmp5) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Cmp5_ResponseRate,
  CAST(SUM(Response) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS FinalCampaign_ResponseRate
FROM marketing;

SELECT Age, Education, Marital_Status, TotalPeople, TotalSpend, TotalPurchases, Recency, Income
FROM marketing WHERE AcceptedCmp1 = 1 AND AcceptedCmp2 = 1 AND AcceptedCmp3 = 1 AND AcceptedCmp4 = 1
AND AcceptedCmp5 = 1 AND Response = 1 
---> Không có bất kì khách hàng nào phản hồi tất cả các chiến dịch

SELECT 
  Age, Education, Marital_Status, TotalPeople, TotalSpend, TotalPurchases, Recency, Income
FROM marketing
WHERE (AcceptedCmp1 + AcceptedCmp2 + AcceptedCmp3 + AcceptedCmp4 + AcceptedCmp5 + Response) >= 3
ORDER BY TotalPurchases DESC

---- Chiến dịch cuối cùng là chiến dịch phản hồi nhiều nhất. Tác động của chiến dịch cuối cùng đến số lần mua
SELECT 
  Response,
  COUNT(ID) AS Customer_Count,
  AVG(TotalPurchases) AS Avg_Purchases
FROM marketing
GROUP BY Response;
--- Tác động của các chiến dịch trước đến số lần mua
SELECT 
  CampaignsAccepted,
  COUNT(ID) AS Customer_Count,
  AVG(TotalPurchases) AS Avg_Purchases
FROM marketing
GROUP BY CampaignsAccepted
ORDER BY CampaignsAccepted ASC;

---Khách hàng phản hồi có thường mua hàng khuyến mãi nhiều hơn không?
SELECT 
  (AcceptedCmp1 + AcceptedCmp2 + AcceptedCmp3 + AcceptedCmp4 + AcceptedCmp5 + Response) AS Total_Response,
  CAST(AVG(NumDealsPurchases) AS DECIMAL(5,2)) AS Avg_Deals_Purchases
FROM marketing
GROUP BY 
  (AcceptedCmp1 + AcceptedCmp2 + AcceptedCmp3 + AcceptedCmp4 + AcceptedCmp5 + Response)
ORDER BY Total_Response;






















