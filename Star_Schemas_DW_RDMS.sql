set define off;

  CREATE OR REPLACE PROCEDURE DW_CREATE AUTHID CURRENT_USER IS
--if the table already exisits then delete them using execute immediate
begin
  for c in (select table_name from user_tables where table_name like 'D_%' OR table_name like 'FACT%') loop
    execute IMMEDIATE ('drop table '||c.table_name||' cascade constraints');
  end loop;
  
   
  execute immediate 'CREATE TABLE D_Customers
 ( customer_id varchar2(4) NOT NULL,
  customer_name varchar2(30) ,
  CONSTRAINT customers_pk PRIMARY KEY (customer_id))';            
  
  execute immediate 'CREATE TABLE D_Products
 ( product_id varchar2(6) NOT NULL,
  product_name varchar2(30) ,
  CONSTRAINT products_pk PRIMARY KEY (product_id))';
  
  execute immediate 'CREATE TABLE D_Stores
 ( store_id varchar2(4) NOT NULL,
  store_name varchar2(30) ,
  CONSTRAINT stores_pk PRIMARY KEY (store_id))';
  
  execute immediate 'CREATE TABLE D_Suppliers
 ( supplier_id varchar2(5) NOT NULL,
  supplier_name varchar2(30) ,
  CONSTRAINT supplier_pk PRIMARY KEY (supplier_id))';
  
  execute immediate 'CREATE TABLE D_Time
 ( time_id varchar2(8) NOT NULL,
  s_date date,
  day varchar2(4),
  month varchar2(4),
  quarter varchar2(2),
  year number(4,0),
  CONSTRAINT time_pk PRIMARY KEY (time_id))';
  
  execute immediate 'CREATE TABLE Facts_T
 ( transaction_id varchar2(8) NOT NULL,
  customer_id varchar2(4) NOT NULL,
  product_id varchar2(6) NOT NULL,
  store_id varchar2(4) NOT NULL,
  supplier_id varchar2(5) NOT NULL,
  time_id varchar2(4) NOT NULL,
  quantity number(3,0),
  price number(5,2),
  sale number (8,2),
  CONSTRAINT fact_pk PRIMARY KEY (transaction_id),
  CONSTRAINT cust_fk FOREIGN KEY(customer_id) REFERENCES D_Customers(customer_id),
  CONSTRAINT prd_fk FOREIGN KEY(product_id) REFERENCES D_Products(product_id),
  CONSTRAINT str_fk FOREIGN KEY(store_id) REFERENCES D_Stores(store_id),
  CONSTRAINT spl_fk FOREIGN KEY(supplier_id) REFERENCES D_Suppliers(supplier_id),
  CONSTRAINT time_fk FOREIGN KEY(time_id) REFERENCES D_Time(time_id))';
    
END DW_CREATE;

/
