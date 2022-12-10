-- średnie zarobki w regionach 
select
	ngi.nom_région,
	round((avg(snhm14)),2) średnia_reg
from net_salary_per_town_categories nsptc 
join name_geographic_information ngi 
on codgeo = code_insee
group by ngi.nom_région 

--slajd 7 Gender pay gap - ogólne - w regionach
-- różnica w wynagrodzeniu k/m 
select 
	ngi.nom_région, 
	round((avg(snhm14)),2) średnia_reg,
	round(avg (snhmh14),2) średnia_m,
	round(avg (snhmf14),2) średnia_f,
		round(avg(snhmh14) - avg(snhmf14), 2) AS woman_salary_diff,
		round(((avg(snhmh14) - avg(snhmf14)) * 100 / avg(snhmh14)), 2) AS percentage_woman_salary_difF
	from net_salary_per_town_categories nsptc 
join name_geographic_information ngi 
on codgeo = code_insee 
group by ngi.nom_région
order by percentage_woman_salary_diff desc

-- średnia pensja i luka płacowa we Francji, z uwzględnieniem populacji regionów
WITH average_salary AS 
(
	SELECT 
		darf.nom_région,
		sum(p.nb) AS region_population,
		round(avg(snhm14), 3) AS average_salary_region,
		round(avg(snhmh14) - avg(snhmf14), 2) AS absolute_pay_gap,
		round((avg(snhmh14) - avg(snhmf14)) * 100 / avg(snhmh14) , 2) AS percentage_pay_gap
	FROM net_salary_per_town_categories nsptc 
	JOIN departments_and_regions_france darf 
	ON nsptc.codgeo = darf.code_insee 
	JOIN population p 
	ON nsptc.codgeo = p.codgeo 
	GROUP BY darf.nom_région 
) SELECT 
	round(sum(average_salary_region * region_population) / (SELECT sum(region_population) FROM average_salary), 3) AS average_salary,
	round(sum(absolute_pay_gap * region_population) / (SELECT sum(region_population) FROM average_salary), 3) AS avg_absolute_pay_gap,
	round(sum(percentage_pay_gap * region_population) / (SELECT sum(region_population) FROM average_salary), 3) AS avg_perc_pay_gap
FROM average_salary 

--korelacja średniej pensji z luką płacową

WITH pay_gap_com AS 
	(
	select libgeo, 
		snhm14 as avg_salary, 
		(snhmh14-snhmf14) *100 /snhm14 as pay_gap
	from net_salary_per_town_categories nsptc 
	join departments_and_regions_france darf 
	on nsptc.codgeo = darf.code_insee
	) 
	SELECT CORR(pay_gap, avg_salary) as kor_śred_pensja_pay_gap
	FROM pay_gap_com

