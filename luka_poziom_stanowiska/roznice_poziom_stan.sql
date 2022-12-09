--Różnice w średnich zarobkach kobiet i mężczyzn na poziom zatrudnienia - średnia dla Francji
WITH job_level_pay_gap AS 
(
--Różnice w średnich zarobkach kobiet i mężczyzn na poziom zatrudnienia - podział na regiony (tylko to podzapytanie)
	SELECT 
		darf.nom_région,
		sum(p.nb) AS region_population,
		round(avg(snhmhc14) - avg(snhmfc14), 2) AS absolute_executive_pay_gap,
		round((avg(snhmhc14) - avg(snhmfc14)) * 100 / avg(snhmhc14) , 2) AS percentage_executive_pay_gap,
		round(avg(snhmhp14) - avg(snhmfp14), 2) AS absolute_manager_pay_gap,
		round((avg(snhmhp14) - avg(snhmfp14)) * 100 / avg(snhmhp14) , 2) AS percentage_manager_pay_gap,
		round(avg(snhmhe14) - avg(snhmfe14), 2) AS absolute_employee_pay_gap,
		round((avg(snhmhe14) - avg(snhmfe14)) * 100 / avg(snhmhe14) , 2) AS percentage_employee_pay_gap,
		round(avg(snhmho14) - avg(snhmfo14), 2) AS absolute_worker_pay_gap,
		round((avg(snhmho14) - avg(snhmfo14)) * 100 / avg(snhmho14) , 2) AS percentage_worker_pay_gap
	FROM net_salary_per_town_categories nsptc 
	JOIN departments_and_regions_france darf 
	ON nsptc.codgeo = darf.code_insee 
	JOIN population p 
	ON nsptc.codgeo = p.codgeo 
	GROUP BY darf.nom_région 
) SELECT 
	round(sum(percentage_executive_pay_gap * region_population) / (SELECT sum(region_population) FROM job_level_pay_gap), 2) AS average_percentage_executive_pay_gap,
	round(sum(percentage_manager_pay_gap * region_population) / (SELECT sum(region_population) FROM job_level_pay_gap), 2) AS average_percentage_manager_pay_gap,
	round(sum(percentage_employee_pay_gap * region_population) / (SELECT sum(region_population) FROM job_level_pay_gap), 2) AS average_percentage_employee_pay_gap,
	round(sum(percentage_worker_pay_gap * region_population) / (SELECT sum(region_population) FROM job_level_pay_gap), 2) AS average_percentage_worker_pay_gap
FROM job_level_pay_gap

--Średnia zmiana zarobków przy zmianie poziomu zatrudnienia w podziale na płeć - średnia dla Francji
WITH salary_diff_regions AS 
(
--Średnia zmiana zarobków przy zmianie poziomu zatrudnienia w podziale na płeć w podziale na regiony
	SELECT 
		darf.nom_région,
		pir.region_population,
		round(avg(snhmfc14) - avg(snhmfp14), 2) AS woman_salary_diff_executive_manager,
		round(((avg(snhmfc14) - avg(snhmfp14)) * 100 / avg(snhmfp14)), 2) AS percentage_woman_salary_diff_executive_manager,
		round(avg(snhmfp14) - avg(snhmfe14), 2) AS woman_salary_diff_manager_employee,
		round(((avg(snhmfp14) - avg(snhmfe14)) * 100 / avg(snhmfe14)), 2) AS percentage_woman_salary_diff_manager_employee,
		round(avg(snhmfe14) - avg(snhmfo14), 2) AS woman_salary_diff_employee_worker,
		round(((avg(snhmfe14) - avg(snhmfo14)) * 100 / avg(snhmfo14)), 2) AS percentage_woman_salary_diff_employee_worker,
		round(avg(snhmhc14) - avg(snhmhp14), 2) AS man_salary_diff_executive_manager,
		round(((avg(snhmhc14) - avg(snhmhp14)) * 100 / avg(snhmhp14)), 2) AS percentage_man_salary_diff_executive_manager,
		round(avg(snhmhp14) - avg(snhmhe14), 2) AS man_salary_diff_manager_employee,
		round(((avg(snhmhp14) - avg(snhmhe14)) * 100 / avg(snhmhe14)), 2) AS percentage_man_salary_diff_manager_employee,
		round(avg(snhmhe14) - avg(snhmho14), 2) AS man_salary_diff_employee_worker,
		round(((avg(snhmhe14) - avg(snhmho14)) * 100 / avg(snhmho14)), 2) AS percentage_man_salary_diff_employee_worker
	FROM net_salary_per_town_categories nsptc 
	JOIN departments_and_regions_france darf 
	ON nsptc.codgeo = darf.code_insee
	JOIN population_in_regions pir 
	ON darf.nom_région = pir.nom_région 
	GROUP BY darf.nom_région, pir.region_population 
)
SELECT
	round(sum(percentage_woman_salary_diff_executive_manager * region_population) / (SELECT sum(region_population) FROM salary_diff_regions), 2) AS average_percentage_woman_salary_diff_executive_manager,
	round(sum(percentage_woman_salary_diff_manager_employee * region_population) / (SELECT sum(region_population) FROM salary_diff_regions), 2) AS average_percentage_woman_salary_diff_manager_employee,
	round(sum(percentage_woman_salary_diff_employee_worker * region_population) / (SELECT sum(region_population) FROM salary_diff_regions), 2) AS average_percentage_woman_salary_diff_employee_worker,
	round(sum(percentage_man_salary_diff_executive_manager * region_population) / (SELECT sum(region_population) FROM salary_diff_regions), 2) AS average_percentage_man_salary_diff_executive_manager,
	round(sum(percentage_man_salary_diff_manager_employee * region_population) / (SELECT sum(region_population) FROM salary_diff_regions), 2) AS average_percentage_man_salary_diff_manager_employee,
	round(sum(percentage_man_salary_diff_employee_worker * region_population) / (SELECT sum(region_population) FROM salary_diff_regions), 2) AS average_percentage_man_salary_diff_employee_worker
FROM salary_diff_regions



--Ogólne zestawienie średnich zarobków i różnic względem średnich zarobków w kraju w podziale na poziom zatrudnienia i region (do dopracowania jeszcze)

SELECT 
	ngi.nom_région,
	(SELECT avg(snhm14) FROM net_salary_per_town_categories) AS france_avg_salary,
	round(avg(snhmc14) - (SELECT avg(snhm14) FROM net_salary_per_town_categories), 2) AS executive_diff,
	round(avg(snhmp14) - (SELECT avg(snhm14) FROM net_salary_per_town_categories), 2) AS manager_diff,
	round(avg(snhme14) - (SELECT avg(snhm14) FROM net_salary_per_town_categories), 2) AS employee_diff,
	round(avg(snhmo14) - (SELECT avg(snhm14) FROM net_salary_per_town_categories), 2) AS worker_diff
FROM net_salary_per_town_categories nsptc 
JOIN name_geographic_information ngi 
ON nsptc.codgeo = ngi.code_insee
GROUP BY ngi.nom_région
