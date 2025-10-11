USE rwfd;
DROP TABLE vehicle_data;
CREATE TABLE vehicle_data (
state VARCHAR(20),	electric_EV INT,	plug_in_hybrid_electric_PHEV INT,	hybrid_electric_HEV	 INT,
Biodiesel INT,	ethanol__flex_E85 INT,	compressed_natural_gas_CNG INT, propane INT,	hydrogen INT,	
methanol INT,	gasoline INT,	diesel INT,	unknown_fuel INT);


LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Vehicle Data.csv"
INTO TABLE vehicle_data
FIELDS TERMINATED BY ","
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(state, @electric_EV, @plug_in_hybrid_electric_PHEV, @hybrid_electric_HEV, @Biodiesel,
 @ethanol__flex_E85, @compressed_natural_gas_CNG, @propane, @hydrogen, @methanol, 
 @gasoline, @diesel, @unknown_fuel)
SET
electric_EV = REPLACE(@electric_EV, ',', ''),
plug_in_hybrid_electric_PHEV = REPLACE(@plug_in_hybrid_electric_PHEV, ',', ''),
hybrid_electric_HEV = REPLACE(@hybrid_electric_HEV, ',', ''),
Biodiesel = REPLACE(@Biodiesel, ',', ''),
ethanol__flex_E85 = REPLACE(@ethanol__flex_E85, ',', ''),
compressed_natural_gas_CNG = REPLACE(@compressed_natural_gas_CNG, ',', ''),
propane = REPLACE(@propane, ',', ''),
hydrogen = REPLACE(@hydrogen, ',', ''),
methanol = REPLACE(@methanol, ',', ''),
gasoline = REPLACE(@gasoline, ',', ''),
diesel = REPLACE(@diesel, ',', ''),
unknown_fuel = REPLACE(@unknown_fuel, ',', '');

-- Calculate the percentage of EVs, PHEVs, HEvs, and Gasoline vehicles for each state.
-- 1. Total vehicles in Alabama
SELECT -- 2 write subquery to calculate the percentage.
 state, (electric_EV/Alabama_total_vehicle)*100 AS EV_adoption_rate, 
(plug_in_hybrid_electric_PHEV/Alabama_total_vehicle)*100 AS PHEV_adoption_rate, 
(hybrid_electric_HEV/Alabama_total_vehicle)*100 AS HEV_adoption_rate, (gasoline/Alabama_total_vehicle)*100 AS Gasoline_adoption_rate
FROM (
-- 1 calculate the total vehicle in the state
SELECT state, electric_EV, plug_in_hybrid_electric_PHEV, hybrid_electric_HEV, gasoline,
(electric_EV + plug_in_hybrid_electric_PHEV + hybrid_electric_HEV + Biodiesel + ethanol__flex_E85 + 
compressed_natural_gas_CNG + propane + hydrogen + methanol + gasoline + diesel + unknown_fuel) AS Alabama_total_vehicle
FROM vehicle_data
)t;

-- The top 5 States with highest EV adoption rate
SELECT state,EV_adoption_rate
 -- 3 Write another subquery to get the top five states
FROM ( 
SELECT -- 2 write subquery to calculate the percentage.
 state, (electric_EV/Alabama_total_vehicle)*100 AS EV_adoption_rate, 
(plug_in_hybrid_electric_PHEV/Alabama_total_vehicle)*100 AS PHEV_adoption_rate, 
(hybrid_electric_HEV/Alabama_total_vehicle)*100 AS HEV_adoption_rate, (gasoline/Alabama_total_vehicle)*100 AS Gasoline_adoption_rate
FROM (
-- 1 calculate the total vehicle in the state
SELECT state, electric_EV, plug_in_hybrid_electric_PHEV, hybrid_electric_HEV, gasoline,
(electric_EV + plug_in_hybrid_electric_PHEV + hybrid_electric_HEV + Biodiesel + ethanol__flex_E85 + 
compressed_natural_gas_CNG + propane + hydrogen + methanol + gasoline + diesel + unknown_fuel) AS Alabama_total_vehicle
FROM vehicle_data
)t )TT
ORDER BY EV_adoption_rate DESC
LIMIT 5;

-- Compare EV adoption rate in California and Texas, Florida & New York
SELECT state,EV_adoption_rate
 -- 3 Write another subquery to get the top five states
FROM ( 
SELECT -- 2 write subquery to calculate the percentage.
 state, (electric_EV/Alabama_total_vehicle)*100 AS EV_adoption_rate, 
(plug_in_hybrid_electric_PHEV/Alabama_total_vehicle)*100 AS PHEV_adoption_rate, 
(hybrid_electric_HEV/Alabama_total_vehicle)*100 AS HEV_adoption_rate, (gasoline/Alabama_total_vehicle)*100 AS Gasoline_adoption_rate
FROM (
-- 1 calculate the total vehicle in the state
SELECT state, electric_EV, plug_in_hybrid_electric_PHEV, hybrid_electric_HEV, gasoline,
(electric_EV + plug_in_hybrid_electric_PHEV + hybrid_electric_HEV + Biodiesel + ethanol__flex_E85 + 
compressed_natural_gas_CNG + propane + hydrogen + methanol + gasoline + diesel + unknown_fuel) AS Alabama_total_vehicle
FROM vehicle_data
)t )TT
WHERE State IN ('California', 'Texas', 'Florida', 'New York');

-- Alternative Fuel Usage and Adoption
WITH alternative_adp AS (
SELECT state, Biodiesel, ethanol__flex_E85, compressed_natural_gas_CNG, propane,
hydrogen, methanol, gasoline, diesel, unknown_fuel,
(electric_EV + plug_in_hybrid_electric_PHEV + hybrid_electric_HEV + Biodiesel + ethanol__flex_E85 + 
compressed_natural_gas_CNG + propane + hydrogen + methanol + gasoline + diesel + unknown_fuel) AS total_vehicle
FROM vehicle_data vt )
	, alternative_adp_rate AS (SELECT state, Biodiesel/total_vehicle AS biodiesel_adoption, ethanol__flex_E85/total_vehicle AS ethanol_adoption, 
    compressed_natural_gas_CNG/total_vehicle AS CNG_adoption, propane/total_vehicle AS propane_adoption,
    hydrogen/total_vehicle AS hydrogen_adoption, methanol/total_vehicle AS methanol_adoption, gasoline/total_vehicle AS gasoline_adoption,
    diesel/total_vehicle AS diesel_adoption, unknown_fuel/total_vehicle AS unknown_adoption
    FROM alternative_adp)
    SELECT state, biodiesel_adoption * 100 biodiesel_adoption, ethanol_adoption*100 ethanol_adoption, CNG_adoption*100 CNG_adoption, 
    propane_adoption*100 propane_adoption, hydrogen_adoption*100 hydrogen_adoption, methanol_adoption*100 methanol_adoption, 
    gasoline_adoption*100 gasoline_adoption, diesel_adoption*100 diesel_adoption, unknown_adoption*100 unknown_adoption
    FROM alternative_adp_rate;
    