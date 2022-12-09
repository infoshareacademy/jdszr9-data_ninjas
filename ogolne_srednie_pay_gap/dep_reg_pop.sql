--Widok zestawienie departamentu i regionu dla danego miasta (codgeo/code_insee)

CREATE VIEW departments_and_regions_france as
	SELECT 
	DISTINCT code_insee, 
	numéro_région, 
	nom_région, 
	code_région, 
	nom_région
FROM name_geographic_information ngi 
ORDER BY code_insee 

SELECT * FROM departments_and_regions_france darf 

--Widok zestawienia populacji dla danego miasta

CREATE VIEW population_in_towns as
SELECT
	p.codgeo,
	sum(p.nb) AS city_population,
	darf.nom_région
FROM population p 
JOIN departments_and_regions_france darf 
ON p.codgeo = darf.code_insee 
GROUP BY p.codgeo, darf.nom_région 
ORDER BY sum(p.nb) desc

SELECT * FROM population_in_towns pit 

--Widok zestawienia populacji w regionach

CREATE VIEW population_in_regions as
SELECT
	sum(p.nb) AS region_population,
	darf.nom_région
FROM population p 
JOIN departments_and_regions_france darf 
ON p.codgeo = darf.code_insee 
GROUP BY darf.nom_région 

SELECT * FROM population_in_regions pir 