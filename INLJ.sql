CREATE OR REPLACE PROCEDURE "SCOTT"."INLJ_ALG" AS 
rowsCount number;
chunk number;
temp varchar2(30);
totalTransactions number;
dayBlock varchar2(4);
monthBlock varchar2(4);
quarterBlock varchar2(2);
yearBlock number(4,0);
timeID varchar2(8);
nextTimeID VARCHAR2(8);
BEGIN
  SELECT count(transaction_id) into totalTransactions FROM transactions;
  timeID:=0;
  chunk:=50;

 -- Looping all transactions 
  while chunk<=totalTransactions LOOP
  
-- Getting chunked transactions

      FOR chunkedTransactions IN (SELECT * FROM transactions WHERE transaction_id>chunk-50 AND transaction_id<=chunk)  LOOP
  
-- Getting chunked joined Data

        FOR chunkedDBData IN (SELECT product_name,supplier_id,supplier_name,price FROM MASTERDATA WHERE product_id=chunkedTransactions.product_id) LOOP

  --Dim Customer Table

            SELECT count(*) into rowsCount FROM d_customers WHERE customer_id=chunkedTransactions.customer_id;
            IF rowsCount=1 THEN
                SELECT customer_name into temp FROM d_customers WHERE customer_id=chunkedTransactions.customer_id;
                IF chunkedTransactions.customer_name=temp THEN
                    null;
                ELSE
                    UPDATE D_customers SET customer_name=chunkedTransactions.customer_name WHERE customer_id=chunkedTransactions.customer_id;
                END IF;
            ELSE
                INSERT INTO D_Customers VALUES(chunkedTransactions.customer_id,chunkedTransactions.customer_name);
            END IF;
            rowsCount:=0;
            
-- Dim Products table

            SELECT count(*) into rowsCount FROM d_products WHERE product_id=chunkedTransactions.product_id;
            IF rowsCount=1 THEN
                SELECT product_name into temp FROM d_products WHERE product_id=chunkedTransactions.product_id;
                IF chunkedDBData.product_name=temp THEN
                    null;
                ELSE
                    UPDATE D_products SET product_name=chunkedDBData.product_name WHERE product_id=chunkedTransactions.product_id;
                END IF;
            ELSE
                INSERT INTO D_Products VALUES(chunkedTransactions.product_id,chunkedDBData.product_name);
            END IF;
            rowsCount:=0;
            
-- Dim  Store table
            
            
            SELECT count(*) into rowsCount FROM d_stores WHERE store_id=chunkedTransactions.store_id;
            IF rowsCount=1 THEN
                SELECT store_name into temp FROM d_stores WHERE store_id=chunkedTransactions.store_id;
                IF chunkedTransactions.store_name=temp THEN
                    null;
                ELSE
                    UPDATE D_stores SET store_name=chunkedTransactions.store_name WHERE store_id=chunkedTransactions.store_id;
                END IF;
            ELSE
                INSERT INTO D_Stores VALUES(chunkedTransactions.store_id,chunkedTransactions.store_name);
            END IF;
            rowsCount:=0;
            
-- Dim  Supplier table
            
            
            SELECT count(*) into rowsCount FROM d_suppliers WHERE supplier_id=chunkedDBData.supplier_id;
            IF rowsCount=1 THEN
                SELECT supplier_name into temp FROM d_suppliers WHERE supplier_id=chunkedDBData.supplier_id;
                IF chunkedDBData.supplier_name=temp THEN
                    null;
                ELSE
                    UPDATE D_suppliers SET supplier_name=chunkedDBData.supplier_name WHERE supplier_id=chunkedDBData.supplier_id;
                END IF;
            ELSE
                INSERT INTO D_Suppliers VALUES(chunkedDBData.supplier_id,chunkedDBData.supplier_name);
            END IF;
            rowsCount:=0;
            
            

-- Dim  Time Table table


            SELECT count(*) into rowsCount FROM d_time WHERE s_date=chunkedTransactions.t_date;
            IF rowsCount=1 THEN
                SELECT time_id into nextTimeID FROM d_time WHERE s_date=chunkedTransactions.t_date;
            ELSE
                timeID:=timeID+1;
                nextTimeID:=timeID;
                dayBlock:=extract(day FROM chunkedTransactions.t_date);
                monthBlock:=extract(month FROM chunkedTransactions.t_date);
                yearBlock:=extract(year FROM chunkedTransactions.t_date);
                IF (monthBlock<4) THEN
                    quarterBlock:=1;
                ELSIF (monthBlock>3 AND monthBlock<7) THEN
                    quarterBlock:=2;
                ELSIF (monthBlock>6 AND monthBlock<10) THEN
                    quarterBlock:=3;
                ELSE
                    quarterBlock:=4;
                END IF;
                INSERT INTO D_time VALUES(timeID,chunkedTransactions.t_date,dayBlock,monthBlock,quarterBlock,yearBlock);
            END IF;
            rowsCount:=0;
            
-- Fact Table update           
            
            SELECT count(*) into rowsCount FROM FACTS_t WHERE transaction_id=chunkedTransactions.transaction_id;
            IF rowsCount=1 THEN
                UPDATE facts_t SET customer_id=chunkedTransactions.customer_id,product_id=chunkedTransactions.product_id,store_id=chunkedTransactions.store_id,supplier_id=chunkedDBData.supplier_id,time_id=nextTimeID,Quantity=chunkedTransactions.Quantity, Price=chunkedDBData.Price, Sale=chunkedTransactions.Quantity*chunkedDBData.Price WHERE transaction_id=chunkedTransactions.transaction_id;
            ELSE
                INSERT INTO facts_t VALUES(chunkedTransactions.transaction_id,chunkedTransactions.customer_id,chunkedTransactions.product_id,chunkedTransactions.store_id,chunkedDBData.supplier_id,nextTimeID,chunkedTransactions.Quantity,chunkedDBData.Price,chunkedTransactions.Quantity*chunkedDBData.price);
            END IF;
            
            
            rowsCount:=0;     
        END LOOP;
      END LOOP;
            chunk:=chunk+50;
    END LOOP;
END INLJ_ALG;

/
