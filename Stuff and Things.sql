SELECT *
FROM CalendarDim
WHERE (((CalendarDim.[Date])>=DateAdd(month,DateDiff(month,'1/1/1901',GetDate()),'1/1/1900') 
    And (CalendarDim.[Date])<DateAdd(month,DateDiff(month,'1/1/1900',GetDate()),'1/1/1900')))