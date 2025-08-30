-- Check the original data
select * from Production
where ProductionDate = '2025-07-05'
  and ProductID = 9047
	and BranchID = 3
	and ShiftID = 2
	and MachineID = 1303;
-- 2688

select * from Production
where ProductionDate = '2024-05-27'
  and ProductID = 9047
	and BranchID = 3
	and ShiftID = 2
	and MachineID = 1303;
-- 2541


-- Update the units for the specific production dates
update Production
set Units = 268888888
where ProductionDate = '2025-07-05'
  and ProductID = 9047
	and BranchID = 3
	and ShiftID = 2
	and MachineID = 1303;

update Production
set Units = 254111111
where ProductionDate = '2024-05-27'
  and ProductID = 9047
	and BranchID = 3
	and ShiftID = 2
	and MachineID = 1303;


-- Return to the original values
update Production
set Units = 2688
where ProductionDate = '2025-07-05'
  and ProductID = 9047
	and BranchID = 3
	and ShiftID = 2
	and MachineID = 1303;

update Production
set Units = 2541
where ProductionDate = '2024-05-27'
  and ProductID = 9047
	and BranchID = 3
	and ShiftID = 2
	and MachineID = 1303;
