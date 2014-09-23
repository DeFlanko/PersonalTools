	/* EPIC EMR */
	
	SELECT Distinct
	, (CASE WHEN (cast((DATEDIFF(m, "PATIENT"."BIRTH_DATE", GETDATE())/12) as varchar)> 2)
		  THEN (cast((DATEDIFF(m, "PATIENT"."BIRTH_DATE", GETDATE())/12) as varchar) + ' Years')
		  WHEN (cast((DATEDIFF(m, "PATIENT"."BIRTH_DATE", GETDATE())/12) as varchar)< 2) 
		  THEN (cast((DATEDIFF(m, "PATIENT"."BIRTH_DATE", GETDATE())) as varchar) + ' Months')
		  ELSE NULL
		  END) AS "Age"
