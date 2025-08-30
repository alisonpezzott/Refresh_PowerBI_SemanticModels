declare 
    @StartDate          date = '2025-08-27',
    @EndDate            date = '2025-08-29';

with date_range as (
    select @StartDate as d
    union all
    select dateadd(day, 1, d) from date_range where d < @EndDate
)
insert into Production 
select 
    date_range.d as ProductionDate,
    ProductID,
    BranchID,
    ShiftID,
    MachineID,
    Units
from date_range
cross join Production
where Production.ProductionDate = dateadd(month, -1, date_range.d);

with date_range as (
    select @StartDate as d
    union all
    select dateadd(day, 1, d) from date_range where d < @EndDate
)
insert into Dates
select 
    d as [Date],
    year(d) as [Year],
    month(d) as [Month],
    format(d, 'MMMM') as MonthName,
    format(d, 'MMM') as MonthNameShort,
    day(d) as [Day]
from date_range;