## Video  

[![See on YouTube](assets/thumb.png)](https://youtu.be/AuNqQtyNu6M)  

## Agenda  

1. Create a Power BI Incremental Semantic Model  
2. Refresh specific tables
3. Refresh partitions  

## Links  
https://learn.microsoft.com/en-us/power-bi/connect-data/incremental-refresh-overview  
https://learn.microsoft.com/en-us/power-bi/connect-data/incremental-refresh-xmla#partitions  

## Partitions Example  

`Refresh policy with 1 month`  

### 2024: Start of Year

| Partition |  
|---|  
|2022|  
|2023|  
|2024Q101|  
|2024Q102|  
|2024Q103|  

### 2024: Quarter 2  

| Partition |    
|---|  
|2022|  
|2023|  
|2024Q1|  
|2024Q204|  
|2024Q205|  
|2024Q206|  

### 2024: Quarter 3      

| Partition |    
|---|  
|2022|  
|2023|  
|2024Q1|  
|2024Q2|  
|2024Q307|  
|2024Q308|  
|2024Q309|  

### 2024: Quarter 4    

| Partition |    
|---|  
|2022|  
|2023|  
|2024Q1|  
|2024Q2|  
|2024Q3|  
|2024Q410|  
|2024Q311|  
|2024Q312|    

### 2025: Start of Year    

| Partition |    
|---|  
|2022|  
|2023|  
|2024|  
|2025Q101|  

### Now: 2025, Aug 30th   

| Partition |    
|---|  
|2022|  
|2023|  
|2024|  
|2025Q1|  
|2025Q2|  
|2025Q307|  
|2025Q308|    




