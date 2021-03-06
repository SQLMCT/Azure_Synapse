/*
  =================================
     Create Rowgroup Health View
  =================================
  This query will create a view that contains useful information such as the number of rows in rowgroups
  and the reason for trimming if there was trimming. See source link for more info. 
  
  Adapted from: https://docs.microsoft.com/en-us/azure/sql-data-warehouse/sql-data-warehouse-memory-optimizations-for-columnstore-compression
*/

IF object_id('vCCI_Stats_Detail') IS NOT NULL DROP VIEW vCCI_Stats_Detail
GO

CREATE VIEW dbo.vCCI_Stats_Detail
AS
WITH CCI_Stats AS (
  SELECT
    tb.[name] AS [logical_table_name], 
    rg.[row_group_id] AS [row_group_id], 
    rg.[state] AS [state], 
    rg.[state_desc] AS [state_desc], 
    rg.[total_rows] AS [total_rows], 
    rg.[trim_reason_desc] AS trim_reason_desc, 
    mp.[physical_name] AS physical_name 
  FROM 
    sys.[schemas] sm 
    INNER JOIN sys.[tables] tb ON sm.[schema_id] = tb.[schema_id] 
    INNER JOIN sys.[pdw_table_mappings] mp ON tb.[object_id] = mp.[object_id] 
    INNER JOIN sys.[pdw_nodes_tables] nt ON nt.[name] = mp.[physical_name] 
    INNER JOIN sys.[dm_pdw_nodes_db_column_store_row_group_physical_stats] rg 
      ON  rg.[object_id] = nt.[object_id] 
      AND rg.[pdw_node_id] = nt.[pdw_node_id] 
      AND rg.[distribution_id] = nt.[distribution_id]
) 
SELECT *
FROM CCI_Stats;