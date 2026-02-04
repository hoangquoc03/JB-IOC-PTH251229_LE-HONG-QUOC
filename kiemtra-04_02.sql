-- PHAN 1 Thao tác với dữ liệu các bảng
-- 1.1 Tạo 4 bảng Customer, Room, Booking, Payment với cấu trúc và kiểu dữ liệu hợp lý. Đảm bảo có các khóa chính (PK) và khóa ngoại (FK) để liên kết các bảng
CREATE TABLE Customer (
    customer_id varchar(5) not null primary key,
	customer_full_name varchar(100) not null,
	customer_email varchar(100) not null unique,
	customer_phone varchar(15) not null,
	customer_address varchar(255) not null
);
CREATE TABLE Room (
    room_id varchar(5) not null primary key,
	room_type varchar(50) not null,
	room_price decimal(10,2) not null,
	room_status varchar(20) not null,
	room_area int not null
);
CREATE TABLE Booking (
    booking_id serial primary key,
	customer_id varchar(5) not null references Customer(customer_id),
	room_id varchar(5) not null references Room(room_id),
	check_in_date date not null,
	check_out_date date not null,
	total_amount decimal(10,2)
);
CREATE TABLE Payment (
    payment_id serial primary key,
	booking_id int not null references  Booking(booking_id),
	payment_method varchar(50) not null,
    payment_date date not null,
	payment_amount decimal(10,2) not null
);
-- 1.2  Chèn dữ liệu (8 điểm) Thêm dữ liệu vào 4 bảng đã tạo:
INSERT INTO Customer 
VALUES
('C001','Nguyen Anh Tu','tu.nguyen@example.com','0912345678','Hanoi, Vietnam'),
('C002','Tran Thi Mai','mai.tran@example.com','0923456789','Ho Chi Minh, Vietnam'),
('C003','Le Minh Hoang','hoang.le@example.com','0934567890','Danang, Vietnam'),
('C004','Pham Hoang Nam','nam.pham@example.com','0945678901','Hue, Vietnam'),
('C005','Vu Minh Thu','thu.vu@example.com','0956789012','Hai Phong, Vietnam');
INSERT INTO Room
VALUES 
('R001','Single',100.0,'Available',25),
('R002','Double',150.0,'Booked',40),
('R003','Suite',250.0,'Available',60),
('R004','Single',120.0,'Booked',30),
('R005','Double',160.0,'Available',35);
INSERT INTO Booking 
VALUES
(1,'C001','R001','2025-03-01','2025-03-05',400.0),
(2,'C002','R002','2025-03-02','2025-03-06',600.0),
(3,'C003','R003','2025-03-03','2025-03-07',1000.0),
(4,'C004','R004','2025-03-04','2025-03-08',480.0),
(5,'C005','R005','2025-03-05','2025-03-09',800.0);
INSERT INTO Payment
VALUES
(1,1,'Cash','2025-03-05',400.0),
(2,2,'Credit Card','2025-03-06',600.0),
(3,3,'Bank Transfer','2025-03-07',1000.0),
(4,4,'Cash','2025-03-08',480.0),
(5,5,'Credit Card','2025-03-09',800.0);
-- 1.3 Cập nhật dữ liệu (6 điểm) Viết câu lệnh UPDATE để cập nhật lại total_amount trong bảng Booking theo công thức: total_amount = room_price * (số ngày lưu trú).
UPDATE booking b 
SET total_amount= room_price * (b.check_out_date-b.check_in_date)
FROM room r 
WHERE b.room_id=r.room_id AND 
r.room_status='Booked' AND b.check_in_date < current_date;

-- 1.4 Xóa dữ liệu (6 điểm)
DELETE FROM Payment
WHERE payment_method = 'Cash'
AND payment_amount < 500;
--Phan 2 Truy vấn dữ liệu
-- 2.5
SELECT *
FROM Customer
ORDER BY customer_full_name ASC;
-- 2.6
SELECT room_id ,
	room_type ,
	room_price ,
	room_area 
FROM Room
ORDER BY room_price DESC;
-- 2.7
SELECT c.customer_id,
       c.customer_full_name,
	   r.room_id,
	   b.check_in_date,
	   b.check_out_date
FROM Booking b
JOIN Room r
ON r.room_id = b.room_id
JOIN Customer c
ON c.customer_id = b.customer_id;
-- 2.8
SELECT c.customer_id,
       c.customer_full_name,
	   p.payment_method,
	   p.payment_amount
FROM Payment p
JOIN Booking b
ON p.booking_id =b.booking_id
JOIN Customer c
ON b.customer_id =c.customer_id
ORDER BY p.payment_amount DESC;
-- 2.9
SELECT *
FROM Customer
ORDER BY customer_full_name 
LIMIT 3 offset 1;
-- 2.10
SELECT c.customer_id,
       c.customer_full_name,
	   COUNT(b.room_id) AS total_room
FROM Payment p
JOIN Booking b
ON p.booking_id = b.booking_id
JOIN Customer c 
ON b.customer_id = c.customer_id
GROUP BY c.customer_id,
         c.customer_full_name,
		 p.payment_amount
HAVING COUNT(b.room_id) >= 2
AND p.payment_amount > 1000;

-- 2.11
SELECT r.room_id,
       r.room_type,
	   r.room_price, 
	   sum(p.payment_amount) AS total_amount
FROM customer c
JOIN booking b
ON b.customer_id = c.customer_id
JOIN room r
ON r.room_id = b.room_id
JOIN payment p 
ON p.booking_id = b.booking_id
GROUP BY r.room_id,
         r.room_type,
		 r.room_price
HAVING sum(p.payment_amount) <1000 AND
COUNT(distinct b.customer_id)>= 3;
-- 2.12
SELECT c.customer_id, 
       c.customer_full_name, 
	   r.room_id,
	   SUM(p.payment_amount) AS total_paid
FROM Payment p
JOIN Booking b
ON p.booking_id = b.booking_id
JOIN Customer c 
ON b.customer_id = c.customer_id
JOIN Room r 
ON b.room_id = r.room_id
GROUP BY c.customer_id, c.customer_full_name, r.room_id
HAVING SUM(p.payment_amount) > 1000;
-- 2.13
SELECT customer_id,
       customer_full_name,
	   customer_email,
	   customer_phone
FROM Customer
WHERE customer_full_name ILIKE '%Minh%' OR customer_address ILIKE '%Hanoi%'
ORDER BY customer_full_name ASC;
-- 2.14
SELECT room_id,
       room_type,
	   room_price
FROM Room
ORDER BY room_price DESC
LIMIT 5 OFFSET 5;
-- Phan 3 Tạo View
-- 3.15
CREATE VIEW vw_check_date AS
SELECT r.room_id,
       r.room_type,
	   c.customer_id,
	   c.customer_full_name
FROM Booking b
JOIN Customer c
ON c.customer_id =b.customer_id
JOIN Room r
ON r.room_id = b.room_id
WHERE b.check_in_date < '2025-01-10';
-- 3.16
CREATE VIEW vw_check_area AS
SELECT c.customer_id,
       c.customer_full_name,
	   r.room_id,
	   r.room_area
FROM Booking b
JOIN Customer c
ON c.customer_id =b.customer_id
JOIN Room r
ON r.room_id = b.room_id
WHERE r.room_area >30;
-- Phan 4 Tạo Trigger
-- 4.17
CREATE OR REPLACE FUNCTION fn_check_insert_booking()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.check_in_date > NEW.check_out_date THEN
        RAISE EXCEPTION 'Ngày đặt phòng không thể sau ngày trả phòng được!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_insert_booking
BEFORE INSERT ON Booking
FOR EACH ROW
EXECUTE FUNCTION fn_check_insert_booking();
-- 4.18
CREATE OR REPLACE FUNCTION fn_update_room_status_on_booking()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Room
    SET room_status = 'Booked'
    WHERE room_id = NEW.room_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_room_status_on_booking
AFTER INSERT ON Booking
FOR EACH ROW
EXECUTE FUNCTION fn_update_room_status_on_booking();
-- Phan 5 Tạo Store Procedure
-- 5.19
CREATE OR REPLACE PROCEDURE add_customer(
    p_customer_id varchar(5) ,
	p_customer_full_name varchar(100) ,
	p_customer_email varchar(100),
	p_customer_phone varchar(15) ,
	p_customer_address varchar(255) 
)
AS $$
BEGIN
     INSERT INTO Customer
	 VALUES (p_customer_id,p_customer_full_name,p_customer_email,p_customer_phone,p_customer_address);
END;
$$ language plpgsql;
-- 5.20
CREATE OR REPLACE PROCEDURE add_payment(
	p_booking_id int,
	p_payment_method varchar(50),
	p_payment_amount decimal(10,2),
	p_payment_date date 
)
AS $$
BEGIN
     INSERT INTO Payment (booking_id,payment_method,payment_amount,payment_date)
	 VALUES (p_booking_id,p_payment_method,p_payment_amount,p_payment_date);
END;
$$ language plpgsql;