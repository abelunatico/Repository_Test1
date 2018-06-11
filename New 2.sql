DECLARE
--   CURSOR table_with_227_rows_cur
--   IS
--      SELECT * FROM table_with_227_rows;
--
--   TYPE table_with_227_rows_aat IS TABLE OF table_with_227_rows_cur%ROWTYPE
--      INDEX BY PLS_INTEGER;
--
--   l_table_with_227_rows   table_with_227_rows_aat;
   
   CURSOR mtl_trx_cur
   IS
       SELECT /*+ FULL(MP) */ MMT.TRANSACTION_ID MMT_TRANSACTION_ID, 
       MMT.MVT_STAT_STATUS, 
       MMT.INVENTORY_ITEM_ID, 
       MSN.SERIAL_NUMBER, 
       MMT.SHIP_TO_LOCATION_ID, 
       ABS(MMT.TRANSACTION_QUANTITY) TRANSACTION_QUANTITY, 
       (SELECT MTLN.LOT_NUMBER 
          FROM MTL_TRANSACTION_LOT_NUMBERS MTLN 
         WHERE MTLN.TRANSACTION_ID = MMT.TRANSACTION_ID 
           AND MTLN.ORGANIZATION_ID = MMT.ORGANIZATION_ID) LOT_NUMBER, 
       MMT.TRANSACTION_UOM, 
       MMT.ORGANIZATION_ID vld_organization_id, 
       CIH.INSTANCE_ID 
  FROM MTL_MATERIAL_TRANSACTIONS MMT, 
       MTL_SERIAL_NUMBERS MSN, 
       MTL_TRANSACTION_TYPES MTT, 
       CSI.CSI_TRANSACTIONS CT, 
       CSI_ITEM_INSTANCES_H CIH, 
       MTL_PARAMETERS MP 
 WHERE MTT.transaction_type_id = MMT.transaction_type_id 
   AND MMT.TRANSACTION_ID = CT.INV_MATERIAL_TRANSACTION_ID 
   AND CT.TRANSACTION_ID = CIH.TRANSACTION_ID 
   AND (MTT.TRANSACTION_TYPE_NAME = 'EIB Salida a Sitio HZ' 
         OR MTT.TRANSACTION_TYPE_NAME = 'EIB-Salida a Sitio  Pedido') 
   AND MSN.LAST_TRANSACTION_ID (+) = MMT.TRANSACTION_ID 
   AND MMT.TRANSACTION_DATE >= SYSDATE - 2 
   AND mp.ORGANIZATION_ID = MMT.ORGANIZATION_ID 
   AND MP.ORGANIZATION_CODE LIKE '16%' 
   AND NOT EXISTS (SELECT 1 
                     FROM XXN.XXN_EIB_TRX_CTRL_TBL XETT 
                    WHERE XETT.MTT_TRX_ID = MMT.TRANSACTION_ID) 
 ORDER BY MMT.TRANSACTION_ID ;

      
       TYPE table_mtl_trx_cur IS TABLE OF mtl_trx_cur%ROWTYPE
      INDEX BY PLS_INTEGER;
   
    l_table_mtl_trx_cur   table_mtl_trx_cur;
    l_start     NUMBER;
   
BEGIN

 l_start := DBMS_UTILITY.get_time;
 
--   OPEN table_with_227_rows_cur;
--
--   LOOP
--      FETCH table_with_227_rows_cur
--         BULK COLLECT INTO l_table_with_227_rows
--         LIMIT 100;
--
--      EXIT WHEN table_with_227_rows_cur%NOTFOUND;  /* cause of missing rows */
--
--      FOR indx IN 1 .. l_table_with_227_rows.COUNT
--      LOOP
--         analyze_compensation (l_table_with_227_rows (indx));
--      END LOOP;
--   END LOOP;
--
--   CLOSE table_with_227_rows_cur;
   
   /* TRX  MTL */ 
    OPEN mtl_trx_cur;

   LOOP
      FETCH mtl_trx_cur
         BULK COLLECT INTO l_table_mtl_trx_cur
         LIMIT 100;

     -- EXIT WHEN mtl_trx_cur%NOTFOUND;  /* cause of missing rows */
         EXIT WHEN l_table_mtl_trx_cur.COUNT = 0;

      FOR indx IN 1 .. l_table_mtl_trx_cur.COUNT
      LOOP
--         analyze_compensation (l_table_mtl_trx_cur (indx));
         
         DBMS_OUTPUT.put_line ('Mensaje 100' ||l_table_mtl_trx_cur (indx) ) ; 
         
         
      END LOOP;
   END LOOP;

   CLOSE mtl_trx_cur;
   
    DBMS_OUTPUT.put_line ('LIMIT 100 : ' || (DBMS_UTILITY.get_time - l_start));
   
   
   
END;