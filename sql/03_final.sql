-- =====================================================================
-- 03_final.sql — Tables analytiques (couche FINAL)
-- Source : STAGING.CLEAN_TRIPS  ->  Cible : 3 tables de KPIs
-- A exécuter dans un worksheet Snowsight (Run All). Idempotent.
-- =====================================================================

USE WAREHOUSE NYC_TAXI_WH;
USE SCHEMA NYC_TAXI_DB.FINAL;

-- ---------------------------------------------------------------------
-- 1. DAILY_SUMMARY — un résumé par jour
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE DAILY_SUMMARY AS
SELECT
    pickup_date,
    COUNT(*)                                          AS nb_trajets,
    ROUND(SUM(total_amount), 2)                       AS revenu_total,
    ROUND(AVG(total_amount), 2)                       AS ticket_moyen,
    ROUND(AVG(trip_distance), 2)                      AS distance_moyenne_miles,
    ROUND(AVG(trip_duration_min), 1)                  AS duree_moyenne_min,
    ROUND(AVG(tip_amount), 2)                         AS pourboire_moyen
FROM STAGING.CLEAN_TRIPS
GROUP BY pickup_date
ORDER BY pickup_date;

-- ---------------------------------------------------------------------
-- 2. ZONE_ANALYSIS — analyse par zone de départ
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE ZONE_ANALYSIS AS
SELECT
    pickup_location_id,
    COUNT(*)                                          AS nb_prises_en_charge,
    ROUND(AVG(total_amount), 2)                       AS tarif_moyen,
    ROUND(AVG(trip_distance), 2)                      AS distance_moyenne_miles,
    ROUND(AVG(trip_duration_min), 1)                  AS duree_moyenne_min,
    ROUND(AVG(tip_amount / NULLIF(fare_amount, 0)), 3) AS taux_pourboire_moyen
FROM STAGING.CLEAN_TRIPS
GROUP BY pickup_location_id
ORDER BY nb_prises_en_charge DESC;

-- ---------------------------------------------------------------------
-- 3. HOURLY_PATTERNS — patterns par heure et jour de la semaine
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE HOURLY_PATTERNS AS
SELECT
    pickup_hour,
    pickup_dayname,
    COUNT(*)                                          AS nb_trajets,
    ROUND(AVG(total_amount), 2)                       AS tarif_moyen,
    ROUND(AVG(trip_distance), 2)                      AS distance_moyenne_miles,
    ROUND(AVG(trip_duration_min), 1)                  AS duree_moyenne_min
FROM STAGING.CLEAN_TRIPS
GROUP BY pickup_hour, pickup_dayname
ORDER BY pickup_hour, pickup_dayname;
