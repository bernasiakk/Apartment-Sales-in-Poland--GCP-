----TABLES

--main table
CREATE OR replace TABLE housing_in_poland.apartment_sales
  (
      id string,
      city string,
      type string,
      squaremeters float64,
      rooms float64,
      floor float64,
      floorcount float64,
      buildyear float64,
      latitude float64,
      longitude float64,
      centredistance float64,
      poicount float64,
      schooldistance float64,
      clinicdistance float64,
      postofficedistance float64,
      kindergartendistance float64,
      restaurantdistance float64,
      collegedistance float64,
      pharmacydistance float64,
      ownership string,
      buildingmaterial string,
      condition string,
      hasparkingspace bool,
      hasbalcony bool,
      haselevator bool,
      hassecurity bool,
      hasstorageroom bool,
      price int64
  )


----VIEWS

-- avg_size_by_city
SELECT
  city,
  ROUND(AVG(squareMeters), 0)
FROM
  `morning-report-428716.housing_in_poland.apartment_sales`
GROUP BY
  1
ORDER BY
  2 DESC

-- apartment_sales_lodz, apartment_sales_radom, apartment_sales_warszawa
CREATE VIEW `housing_in_poland.apartment_sales_warszawa`
AS SELECT * FROM `housing_in_poland.auto_schema_not_partitioned` WHERE city = 'warszawa';

--avg_apartment_by_city
SELECT
  city,
  CAST(AVG(squareMeters) AS INT64) AS squareMeters,
  CAST(AVG(rooms) AS INT64) AS rooms,
  CAST(AVG(floor) AS INT64) AS floor,
  CAST(AVG(buildYear) AS INT64) AS buildYear,
  CAST(AVG(centreDistance) AS INT64) AS centreDistance,
  CAST(AVG(price) AS INT64) AS price,
  CAST(AVG(price / squareMeters) AS INT64) AS avg_price_per_sqm
FROM
  `housing_in_poland.apartment_sales`
GROUP BY
  1

--avg_hasAttributes_by_city
SELECT
  city,
  ROUND(SUM(CAST(hasParkingSpace as INT64)) / count(*), 2) as avg_hasParkingSpace,
  ROUND(SUM(CAST(hasBalcony as INT64)) / count(*), 2) as avg_hasBalcony,
  ROUND(SUM(CAST(hasElevator as INT64)) / count(*), 2) as avg_hasElevator,
  ROUND(SUM(CAST(hasSecurity as INT64)) / count(*), 2) as avg_hasSecurity,
  ROUND(SUM(CAST(hasStorageRoom as INT64)) / count(*), 2) as avg_hasStorageRoom
FROM
  `housing_in_poland.apartment_sales`
GROUP BY 1