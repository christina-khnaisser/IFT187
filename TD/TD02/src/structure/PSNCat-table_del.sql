/*
-- =========================================================================== A
-- Retrait des données des tables du schéma catalogue
-- -----------------------------------------------------------------------------
Projet   : PNS-Cat
Version  : 0.0.0a
Statut   : en vigueur
-- =========================================================================== A
*/
--
delete from catalogue.product_licence;

delete from catalogue.product_dosage;

delete from catalogue.product_medicinal_ingredient;

delete from catalogue.medicinal_ingredient;

delete from catalogue.product_non_medicinal_ingredient;

delete from catalogue.non_medicinal_ingredient;

delete from catalogue.product_risk;

delete from catalogue.product_purpose;

delete from catalogue.product;

delete from catalogue.company;

delete from catalogue.product_status;
--
--
/*
-- =========================================================================== Z
Contributeurs :
  (CK) Christina.Khnaisser@USherbrooke.ca

Tâches projetées :

Tâches réalisées :
  2026-01-10 (CK) : Création
-- -----------------------------------------------------------------------------
-- Fin de table_drp.sql
-- =========================================================================== Z
*/
