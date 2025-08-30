/*============================================
  SQL Query for SSMS - PRODUCTION DATA GENERATOR
  Optimized for SQL Server Management Studio execution
=============================================*/

-- SSMS Configuration for large operations
set nocount on;
set datefirst 1;
set ansi_warnings off;  -- Suppress warnings for large operations

/*====================
  PARAMETERS - Full Scale for SSMS
====================*/
declare 
    @StartDate          date = '2022-01-01',
    @EndDate            date = '2025-08-26',
    @Products           int  = 100,
    @Branches           int  = 5,
    @Shifts             int  = 3,
    @MachinesPerBranch  int  = 6,
    @BatchYears         int  = 1;     -- Process 1 year at a time

-- Parameter validation
if @StartDate > @EndDate or @Products < 1 or @Branches < 1 or @Shifts < 1 or @MachinesPerBranch < 1
    throw 50000, 'Invalid parameters: Check date range and ensure all counts >= 1', 1;

-- Estimate and display volume
declare @TotalDays int = datediff(day, @StartDate, @EndDate) + 1;
declare @EstimatedRecords bigint = cast(@TotalDays as bigint) * @Products * @Branches * @Shifts * @MachinesPerBranch;

print '================================================';
print 'PRODUCTION DATA GENERATOR - SSMS OPTIMIZED';
print '================================================';
print concat('Date Range: ', @StartDate, ' to ', @EndDate);
print concat('Products: ', @Products, ' | Branches: ', @Branches, ' | Shifts: ', @Shifts, ' | Machines/Branch: ', @MachinesPerBranch);
print concat('Estimated Records: ', format(@EstimatedRecords, 'N0'));
print concat('Processing in ', @BatchYears, '-year batches for optimal performance');
print '================================================';
print '';

/*=======================
  UTILITY: Numbers table
========================*/
if object_id('tempdb..#num') is not null drop table #num;
with nums(n) as (
    select 1 union all 
    select n + 1 from nums where n < 50000
)
select n into #num from nums option (maxrecursion 0);
print concat('✓ Created utility table with ', @@rowcount, ' numbers');

/*================================
  DIMENSIONS CREATION
==================================*/
declare @StartTime datetime2 = getdate();
print 'Creating dimension tables...';

-- Dates - Optimized recursive approach
if object_id('dbo.Dates','U') is not null 
begin
    drop table dbo.Dates;
    print '  ✓ Dropped existing Dates table';
end;

create table dbo.Dates (
    [Date]             date        primary key,
    [Year]             int         not null,
    [Month]            tinyint     not null,
    MonthName          varchar(20) null,
    MonthNameShort     varchar(3)  null,
    [Day]              tinyint     not null
);

with date_range as (
    select @StartDate as d
    union all
    select dateadd(day, 1, d) from date_range where d < @EndDate
)
insert dbo.Dates 
select 
    d,
    year(d),
    month(d),
    format(d, 'MMMM', 'en-US'),
    format(d, 'MMM', 'en-US'),
    day(d)
from date_range
option (maxrecursion 0);

print concat('  ✓ Dates: ', @@rowcount, ' records created');

-- Product
if object_id('dbo.Product','U') is not null drop table dbo.Product;
create table dbo.Product (
    ProductID          int primary key,
    ProductGroup       varchar(20) not null
);

insert dbo.Product 
select 
    9000 + n,
    case when abs(checksum(9000 + n)) % 100 < 65 then 'STD' else 'PREMIUM' end
from (select top (@Products) n from #num order by n) v;

print concat('  ✓ Product: ', @@rowcount, ' records created');

-- Branch
if object_id('dbo.Branch','U') is not null drop table dbo.Branch;
create table dbo.Branch (
    BranchID int primary key,
    Region varchar(20) not null
);

insert dbo.Branch 
select 
    n,
    case (n - 1) % 5
        when 0 then 'North'
        when 1 then 'South'
        when 2 then 'Southeast'
        when 3 then 'Midwest'
        else 'Northeast'
    end
from (select top (@Branches) n from #num order by n) v;

print concat('  ✓ Branch: ', @@rowcount, ' records created');

-- Shift
if object_id('dbo.Shift','U') is not null drop table dbo.Shift;
create table dbo.Shift (
    ShiftID     int primary key,
    Shift         varchar(20) not null
);

with base_shifts as (
    select 1 as ShiftID, 'Morning' as Shift union all
    select 2, 'Afternoon' union all
    select 3, 'Night' union all
    select 4, 'Shift 4' union all
    select 5, 'Shift 5'
)
insert dbo.Shift 
select * from base_shifts where ShiftID <= @Shifts;

print concat('  ✓ Shift: ', @@rowcount, ' records created');

-- Machine
if object_id('dbo.Machine','U') is not null drop table dbo.Machine;
create table dbo.Machine (
    MachineID int primary key,
    BranchID  int not null
);

insert dbo.Machine 
select 
    1000 + (b.BranchID * 100) + m.n,
    b.BranchID
from dbo.Branch b
cross join (select top (@MachinesPerBranch) n from #num order by n) m;

print concat('  ✓ Machine: ', @@rowcount, ' records created');

print concat('All dimensions created in ', datediff(second, @StartTime, getdate()), ' seconds');
print '';

/*===================================
  FACT TABLE - YEARLY BATCH PROCESSING
=====================================*/
if object_id('dbo.Production','U') is not null 
begin
    drop table dbo.Production;
    print '✓ Dropped existing Production table';
end;

create table dbo.Production (
    ProductionDate   date not null,
    ProductID        int  not null,
    BranchID         int  not null,
    ShiftID          int  not null,
    MachineID        int  not null,
    Units            int  not null
);

-- Create helpful indexes upfront
create nonclustered index IX_ProductionDate on dbo.Production (ProductionDate);
create nonclustered index IX_Production_product on dbo.Production (ProductID);
print '✓ Created fact table with indexes';
print '';

print 'Starting YEARLY batch processing...';
set @StartTime = getdate();

declare @BatchStart date = @StartDate;
declare @BatchEnd date;
declare @BatchNum int = 1;
declare @TotalInserted bigint = 0;

while @BatchStart <= @EndDate
begin
    -- Calculate batch end (end of year or final date)
    set @BatchEnd = case 
        when datefromparts(year(@BatchStart), 12, 31) > @EndDate 
        then @EndDate 
        else datefromparts(year(@BatchStart), 12, 31)
    end;
    
    declare @BatchStartTime datetime2 = getdate();
    print concat('BATCH ', @BatchNum, ': Processing ', @BatchStart, ' to ', @BatchEnd, '...');
    
    -- Insert year batch with optimized calculation
    insert dbo.Production
    select 
        d.[Date],
        p.ProductID,
        m.BranchID,
        s.ShiftID,
        m.MachineID,
        
        -- Optimized Units calculation
        case when final_units < 1000 then 1000 else final_units end
        
    from dbo.Dates d
    cross join dbo.Product p  
    cross join dbo.Machine m
    cross join dbo.Shift s
    cross apply (
        select 
            cast(
                -- Base Units by product type
                (case p.ProductGroup 
                    when 'STD' then 1600 + (abs(checksum(concat('std:', p.ProductID))) % 121) * 10
                    else 2200 + (abs(checksum(concat('prm:', p.ProductID))) % 151) * 10
                end) *
                
                -- Combined factors for performance
                (case month(d.[Date]) when 12 then 1.10 when 1 then 0.92 when 7 then 1.05 else 1.00 end) *
                (case datepart(weekday, d.[Date]) when 2 then 1.03 when 3 then 1.05 when 4 then 1.03 
                      when 5 then 1.02 when 6 then 0.97 when 7 then 0.95 else 1.00 end) *
                (case s.ShiftID when 1 then 1.00 when 2 then 0.95 when 3 then 0.90 
                      else 0.88 - ((s.ShiftID-4) * 0.02) end) *
                (0.85 + (abs(checksum(concat(m.BranchID, ':', m.MachineID))) % 21) / 100.0) *
                (0.90 + (abs(checksum(concat(p.ProductID, d.[Date], m.MachineID))) % 21) / 100.0)
            as int) as final_units
    ) calc
    where d.[Date] between @BatchStart and @BatchEnd
      and m.BranchID in (select BranchID from dbo.Branch);
    
    declare @BatchRecords int = @@rowcount;
    set @TotalInserted = @TotalInserted + @BatchRecords;
    
    declare @BatchSeconds int = datediff(second, @BatchStartTime, getdate());
    print concat('  ✓ Inserted ', format(@BatchRecords, 'N0'), ' records in ', @BatchSeconds, ' seconds');
    print concat('  ✓ Total so far: ', format(@TotalInserted, 'N0'), ' records');
    print '';
    
    -- Move to next year
    set @BatchStart = dateadd(year, 1, @BatchStart);
    set @BatchStart = datefromparts(year(@BatchStart), 1, 1);  -- Start of next year
    set @BatchNum = @BatchNum + 1;
end;

declare @TotalSeconds int = datediff(second, @StartTime, getdate());
print '================================================';
print 'BATCH PROCESSING COMPLETED!';
print concat('Total records inserted: ', format(@TotalInserted, 'N0'));
print concat('Total processing time: ', @TotalSeconds, ' seconds');
print concat('Average records/second: ', format(@TotalInserted / nullif(@TotalSeconds, 0), 'N0'));
print '================================================';
print '';

-- Final verification with comprehensive stats
print 'FINAL VERIFICATION:';
select 
    count(*) as total_records,
    min(ProductionDate) as first_date,
    max(ProductionDate) as last_date,
    count(distinct year(ProductionDate)) as distinct_years,
    count(distinct ProductID) as distinct_products,
    count(distinct BranchID) as distinct_branches,
    count(distinct ShiftID) as distinct_shifts,
    count(distinct MachineID) as distinct_machines,
    format(avg(cast(Units as float)), 'N0') as avg_Units,
    format(min(Units), 'N0') as min_Units,
    format(max(Units), 'N0') as max_Units
from dbo.Production;

-- Sample data preview
print '';
print 'SAMPLE DATA (first 10 records):';
select top 10 * from dbo.Production order by ProductionDate, ProductID;

-- Clean up
drop table #num;
set ansi_warnings on;

print '';
print '✓ Data generation completed successfully!';
