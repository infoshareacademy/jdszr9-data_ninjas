--tworzenie widoku ze średnią pensją dla każdej grupy wiekowej + z podziałem na płeć w grupach wiekowych - departamenty
CREATE VIEW salary_per_age AS 
SELECT 
	avg(snhm1814) avg_sal_under26,
	avg(snhmh1814) avg_sal_man_under26,
	avg(snhmf1814) avg_sal_woman_under26,
	round(avg(snhmh1814) - avg(snhmf1814),2) sal_diff_gender_under26,
	avg(snhm2614) avg_sal_2650,
	avg(snhmh2614) avg_sal_man_2650,
	avg(snhmf2614) avg_sal_woman_2650,
	round(avg(snhmh2614) - avg(snhmf2614),2) sal_diff_gender_2650,
	avg(snhm5014) avg_sal_over50,
	avg(snhmh5014) avg_sal_man_over50,
	avg(snhmf5014) avg_sal_woman_over50,
	round(avg(snhmh5014) - avg(snhmf5014),2) sal_diff_gender_over50,
	ngi.nom_département
FROM net_salary_per_town_categories nsptc
JOIN name_geographic_information ngi
ON nsptc.codgeo = ngi.code_insee
GROUP BY ngi.nom_département
ORDER BY avg_sal_under26 DESC

-- różnica zarobków mężczyzn i kobiet w każdej grupie w liczbach absolutnych i wyrażona procentowo - departamenty
SELECT
sal_diff_gender_under26,
round(sal_diff_gender_under26/avg_sal_man_under26 *100,3) sal_diff_gender_under26_percentage,
sal_diff_gender_2650,
round(sal_diff_gender_2650/avg_sal_man_2650 *100,3) sal_diff_gender_2650_percentage,
sal_diff_gender_over50,
round(sal_diff_gender_over50/avg_sal_man_over50 *100,3) sal_diff_gender_over50_percentage,
nom_département
from salary_per_age
order by sal_diff_gender_over50_percentage DESC 

--tworzenie widoku ze średnią pensją dla każdej grupy wiekowej + z podziałem na płeć w grupach wiekowych - regiony
CREATE VIEW salary_per_age_regio AS 
SELECT 
	round(avg(snhm1814),3) avg_sal_under26,
	round(avg(snhmh1814),3) avg_sal_man_under26,
	round(avg(snhmf1814),3) avg_sal_woman_under26,
	round(avg(snhmh1814) - avg(snhmf1814),3) sal_diff_gender_under26,
	round(avg(snhm2614),3) avg_sal_2650,
	round(avg(snhmh2614),3) avg_sal_man_2650,
	round(avg(snhmf2614),3) avg_sal_woman_2650,
	round(avg(snhmh2614) - avg(snhmf2614),3) sal_diff_gender_2650,
	round(avg(snhm5014),3) avg_sal_over50,
	round(avg(snhmh5014),3) avg_sal_man_over50,
	round(avg(snhmf5014),3) avg_sal_woman_over50,
	round(avg(snhmh5014) - avg(snhmf5014),3) sal_diff_gender_over50,
	ngi.nom_région
FROM net_salary_per_town_categories nsptc
JOIN name_geographic_information ngi
ON nsptc.codgeo = ngi.code_insee
GROUP BY ngi.nom_région 
ORDER BY avg_sal_under26 DESC


-- różnica zarobków mężczyzn i kobiet w każdej grupie w liczbach absolutnych i wyrażona procentowo - regiony
SELECT
sal_diff_gender_under26,
round(sal_diff_gender_under26/avg_sal_man_under26 *100,3) sal_diff_gender_under26_percentage,
sal_diff_gender_2650,
round(sal_diff_gender_2650/avg_sal_man_2650 *100,3) sal_diff_gender_2650_percentage,
sal_diff_gender_over50,
round(sal_diff_gender_over50/avg_sal_man_over50 *100,3) sal_diff_gender_over50_percentage,
nom_région
from salary_per_age_regio
order by sal_diff_gender_over50_percentage DESC 


--Różnice w średnich zarobkach kobiet i mężczyzn w grupach wiekowych, średnia krajowa
WITH age_pay_gap AS 
(
	SELECT 
		darf.nom_région,
		sum(p.nb) AS region_population,
		round(avg(snhmh1814) - avg(snhmf1814), 2) AS absolute_under26_pay_gap,
		round((avg(snhmh1814) - avg(snhmf1814)) * 100 / avg(snhmh1814) , 2) AS percentage_under26_pay_gap,
		round(avg(snhmh2614) - avg(snhmf2614), 2) AS absolute_2650_pay_gap,
		round((avg(snhmh2614) - avg(snhmf2614)) * 100 / avg(snhmh2614) , 2) AS percentage_2650_pay_gap,
		round(avg(snhmh5014) - avg(snhmf5014), 2) AS absolute_over50_pay_gap,
		round((avg(snhmh5014) - avg(snhmf5014)) * 100 / avg(snhmh5014) , 2) AS percentage_over50_pay_gap
	FROM net_salary_per_town_categories nsptc 
	JOIN departments_and_regions_france darf 
	ON nsptc.codgeo = darf.code_insee 
	JOIN population p 
	ON nsptc.codgeo = p.codgeo 
	GROUP BY darf.nom_région 
) SELECT 
	round(sum(percentage_under26_pay_gap * region_population) / (SELECT sum(region_population) FROM age_pay_gap), 2) AS average_percentage_under26_pay_gap,
	round(sum(percentage_2650_pay_gap * region_population) / (SELECT sum(region_population) FROM age_pay_gap), 2) AS average_percentage_2650_pay_gap,
	round(sum(percentage_over50_pay_gap * region_population) / (SELECT sum(region_population) FROM age_pay_gap), 2) AS average_percentage_over50_pay_gap
FROM age_pay_gap


 

