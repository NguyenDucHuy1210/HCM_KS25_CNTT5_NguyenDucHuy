CREATE DATABASE sales_management;
USE sales_management;
USE SESSION08;

CREATE TABLE Customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    gender ENUM('M', 'F') ,
    birth_date DATE
);

CREATE TABLE Category (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL
);

CREATE TABLE Product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(12,2),
    category_id INT,

    FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE,

    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

CREATE TABLE Order_Detail (
    order_id INT,
    product_id INT,
	quantity INT NOT NULL,
	unit_price DECIMAL(12,2) NOT NULL,

    PRIMARY KEY(order_id, product_id),

    FOREIGN KEY (order_id) REFERENCES Orders(order_id),

    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

INSERT INTO Category(category_name)
VALUES
('Điện tử'),
('Thời trang'),
('Gia dụng'),
('Sách'),
('Thể thao');

INSERT INTO Customer(full_name, email, gender, birth_date)
VALUES
('Nguyen Van A', 'a@gmail.com', 'M', '2000-05-10'),
('Tran Thi B', 'b@gmail.com', 'F', '1998-03-21'),
('Le Van C', 'c@gmail.com', 'M', '2003-07-15'),
('Pham Thi D', 'd@gmail.com', 'F', '2001-09-12'),
('Hoang Van E', 'e@gmail.com', 'F', '1995-11-01');



INSERT INTO Product(product_name, price, category_id)
VALUES
('Laptop', 1500, 1),
('Tai nghe', 200, 1),
('Ao thun', 25, 2),
('Noi com dien', 80, 3),
('Bong da', 30, 5),
('Quan jean', 40, 2),
('Sach SQL', 15, 4);

INSERT INTO Orders(customer_id, order_date)
VALUES
(1, '2025-01-10'),
(2, '2025-01-15'),
(1, '2025-02-01'),
(3, '2025-02-20'),
(5, '2025-03-01');

INSERT INTO Order_Detail(order_id, product_id, quantity, unit_price)
VALUES
(1, 1, 1, 1500),
(1, 2, 2, 200),
(2, 3, 3, 25),
(3, 4, 1, 80),
(5, 5, 2, 30);

-- Cập nhật giá bán cho một sản phẩm.
UPDATE Product
SET price = 1700
WHERE product_id = 1;

-- Cập nhật email cho một khách hàng.
UPDATE Customer
SET email = 'newemail@gmail.com'
WHERE customer_id = 2;


-- Xóa một bản ghi chi tiết đơn hàng không hợp lệ (hoặc một đơn hàng bị hủy).
DELETE FROM Order_Detail
WHERE quantity < 0 OR unit_price < 0;

-- Phần V - Truy vấn dữ liệu 


-- câu 1-4


-- Lấy ra tên,email và giới tính theo 'Nam' hoặc 'Nữ'
-- Cách 1
SELECT 
full_name, email, CASE
	WHEN gender = 'M' THEN 'Nam'
	WHEN gender = 'F' THEN 'Nữ'
    ELSE 'GIỚI TÍNH KHÔNG RÕ'
    END AS Gioi_tinh
FROM Customer;

-- Cách 2
SELECT 
    full_name,
    email,
    IF(gender = 'M', 'Nam', 'Nữ') AS Gioi_tinh
FROM Customer;



-- Lấy ra thông tin 3 người trẻ nhất
-- Cách 1
SELECT full_name, email, gender,birth_date,
YEAR(NOW()) - YEAR(birth_date) AS age
FROM Customer 
ORDER BY age ASC
LIMIT 3;

-- Cách 2
SELECT full_name, email, gender,birth_date,
TIMESTAMPDIFF(YEAR, birth_date,NOW()) AS age
FROM Customer 
ORDER BY age ASC
LIMIT 3;



-- Hiển thị tên khách hàng và danh sách đơn hàng
-- Cách 1
SELECT c.full_name, o.order_id, o.order_date FROM Orders o
INNER JOIN Customer c
ON o.customer_id = c.customer_id;

-- Cách 2
SELECT (SELECT full_name
        FROM Customer c
        WHERE c.customer_id = o.customer_id) AS full_name, 
o.order_id, o.order_date 
FROM Orders o;



-- Đếm số lượng sản phẩm theo từng danh mục
-- Cách 1
SELECT c.category_name, COUNT(p.product_id) AS quantity_product FROM Product p
JOIN Category c
ON c.category_id = p.category_id
GROUP BY c.category_name
HAVING COUNT(p.product_id) >= 2;

-- Cách 2
SELECT *
FROM (
    SELECT 
        c.category_name,
        COUNT(p.product_id) AS quantity_product
    FROM Product p
    JOIN Category c
    ON c.category_id = p.category_id
    GROUP BY c.category_name
) AS temp
WHERE quantity_product >= 2;



-- CÂU 5 --
-- Cách 1: Scalar
SELECT 
    product_id, 
    product_name, 
    price 
FROM 
    Product 
WHERE 
    price > (SELECT AVG(price) FROM Product);
    
-- Cách 2: dùng join với subsquery
    SELECT 
    p1.product_id, 
    p1.product_name, 
    p1.price
FROM 
    Product p1
WHERE EXISTS (
    SELECT 1 
    FROM (SELECT AVG(price) AS av FROM Product) p2
    WHERE p1.price > p2.av
); 
-- Dùng exists để kiểm tra tồn tại, nếu có sản phẩm nào có giá lớn hơn trung bình sẽ trả về true luôn với exists và lấy luôn sản phẩm đó


-- CÂU 6

-- cách 1 dùng NOT IN
SELECT full_name, email
FROM Customer
WHERE customer_id NOT IN (
    SELECT customer_id
    FROM Orders
);
-- cách 2 dùng NOT EXISTS

SELECT full_name, email
FROM Customer c
WHERE NOT EXISTS (
    SELECT *
    FROM Orders o
    WHERE c.customer_id = o.customer_id
);

-- CÂU 7 (Subquery với hàm tổng hợp) Tìm các phòng ban/danh mục có tổng doanh thu lớn hơn 120% doanh thu trung bình của toàn bộ cửa hàng.

-- Cách 1: Truy vấn lồng trong HAVING
SELECT 
    c.Category_Name, 
    SUM(od.Quantity * od.Price) AS Total_Category_Revenue
FROM Category c
JOIN Product p ON c.Category_ID = p.Category_ID
JOIN Order_Detail od ON p.Product_ID = od.Product_ID
GROUP BY c.Category_ID, c.Category_Name
HAVING SUM(od.Quantity * od.Price) > (
    -- Subquery tính 120% doanh thu trung bình của tất cả danh mục
    SELECT AVG(Category_Revenue) * 1.2
    FROM (
        SELECT SUM(Quantity * Price) AS Category_Revenue
        FROM Order_Detail od2
        JOIN Product p2 ON od2.Product_ID = p2.Product_ID
        GROUP BY p2.Category_ID
    ) AS Revenue_Summary
);

-- Cách 2: Sử dụng Subquery trong mệnh đề FROM
SELECT 
    Result.Category_Name, 
    Result.Total_Revenue
FROM (
    -- Bảng tạm 1: Tính doanh thu từng danh mục
    SELECT 
        c.Category_Name, 
        SUM(od.Quantity * od.Price) AS Total_Revenue
    FROM Category c
    JOIN Product p ON c.Category_ID = p.Category_ID
    JOIN Order_Detail od ON p.Product_ID = od.Product_ID
    GROUP BY c.Category_ID, c.Category_Name
) AS Result, 
(
    -- Bảng tạm 2: Tính ngưỡng doanh thu mục tiêu (120% trung bình)
    SELECT AVG(Cat_Sum) * 1.2 AS Target_Threshold
    FROM (
        SELECT SUM(Quantity * Price) AS Cat_Sum
        FROM Order_Detail od2
        JOIN Product p2 ON od2.Product_ID = p2.Product_ID
        GROUP BY p2.Category_ID
    ) AS InnerTemp
) AS Benchmark
WHERE Result.Total_Revenue > Benchmark.Target_Threshold;


-- câu 8 (Correlated Subquery) Lấy danh sách các sản phẩm có giá đắt nhất trong từng danh mục (Truy vấn con tham chiếu đến outer query).
-- lấy sản phẩm đắt nhất theo từng danh mục
-- cach 1
SELECT p1.product_name, p1.price, p1.category_id
FROM Product p1
WHERE price =
(
    SELECT MAX(p2.price)
    FROM Product p2
    WHERE p1.category_id = p2.category_id
);
-- cach 2
SELECT p.product_name, p.price, p.category_id
FROM Product p
JOIN
(
    SELECT category_id, MAX(price) AS max_price
    FROM Product
    GROUP BY category_id
) temp
ON p.category_id = temp.category_id
AND p.price = temp.max_price;


-- CÂU 9
-- Cách 1: Dùng hai điều kiện IN song song 
SELECT full_name 
FROM Customer 
WHERE 
    -- ---------------------------------------------------------
    -- MẢNH GHÉP 1: Bóc hành 4 lớp để tìm người mua đồ 'Điện tử'
    -- ---------------------------------------------------------
    customer_id IN (
        -- Lớp 4: Lấy mã khách hàng từ đơn hàng
        SELECT customer_id FROM Orders WHERE order_id IN (
            -- Lớp 3: Lấy mã đơn hàng từ chi tiết đơn
            SELECT order_id FROM Order_Detail WHERE product_id IN (
                -- Lớp 2: Lấy mã sản phẩm thuộc nhóm danh mục
                SELECT product_id FROM Product WHERE category_id = (
                    -- Lớp 1 (Sâu nhất): Tìm mã của danh mục 'Điện tử'
                    SELECT category_id FROM Category WHERE category_name = 'Điện tử'
                )
            )
        )
    )
    
    AND 
    
    -- Lọc VIP (Tổng chi tiêu > 1000)
    customer_id IN (
        SELECT o.customer_id
        FROM Orders o
        JOIN Order_Detail od ON o.order_id = od.order_id
        GROUP BY o.customer_id
        HAVING SUM(od.quantity * od.unit_price) > 1000
    );


-- Cách 2: Tạo "Bảng tạm" chứa VIP rồi lồng ghép
SELECT c.full_name 
FROM Customer c
JOIN (
    --  Tạo Bảng tạm 'DanhSachVIP' (Chi tiêu > 1000)
    SELECT o.customer_id
    FROM Orders o
    JOIN Order_Detail od ON o.order_id = od.order_id
    GROUP BY o.customer_id
    HAVING SUM(od.quantity * od.unit_price) > 1000
) AS DanhSachVIP 
ON c.customer_id = DanhSachVIP.customer_id

WHERE 
    -- iếp tục lồng 4 cấp tìm người mua 'Điện tử'
    c.customer_id IN (
        SELECT customer_id FROM Orders WHERE order_id IN (
            SELECT order_id FROM Order_Detail WHERE product_id IN (
                SELECT product_id FROM Product WHERE category_id = (
                    SELECT category_id FROM Category WHERE category_name = 'Điện tử'
                )
            )
        )
    );
