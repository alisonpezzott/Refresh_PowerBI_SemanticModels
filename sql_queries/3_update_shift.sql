select * from Shift;


update Shift
set Shift = case
    when ShiftID = 1 then 'First Shift'
    when ShiftID = 2 then 'Second Shift'
    when ShiftID = 3 then 'Third Shift'
    else Shift
end
where ShiftID in (1, 2, 3);


update Shift
set Shift = case
    when ShiftID = 1 then 'Morning'
    when ShiftID = 2 then 'Afternoon'
    when ShiftID = 3 then 'Evening'
    else Shift
end
where ShiftID in (1, 2, 3);
