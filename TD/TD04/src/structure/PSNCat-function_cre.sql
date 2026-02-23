/*
-- =========================================================================== A
-- Création des fonctions
-- -----------------------------------------------------------------------------
Projet   : PNS-Cat
Version  : 0.0.0a
Statut   : en vigueur
-- =========================================================================== A
*/
--
--
-- Normaliser les valeurs des colonnes qui représentent des unités de mesures.
-- Rendre les valeurs en minuscule et au singulier (ex. Drop(s) -> drop).
create or replace function catalogue.normalize_unit_of_measure(_unit varchar)
  returns varchar(42)
  language SQL as
$$
select lower(regexp_replace(_unit, '\(s\)$', ''));
$$;
-- >> test
select catalogue.normalize_unit_of_measure('Drop(s)');
select catalogue.normalize_unit_of_measure('MG');
--
-- Identifier les produits qui ne possèdent pas une instruction de dosage.
create or replace function catalogue.getProductDosage(_product_id integer)
  returns catalogue.product_dosage
  language SQL as
$$
  select *
  from catalogue.product_dosage
  where product_id = _product_id
$$;
-- >> test
select catalogue.getProductDosage('2299');
--
--
/*
-- =========================================================================== Z
Contributeurs :
  (CK) Christina.Khnaisser@USherbrooke.ca

Tâches projetées :

Tâches réalisées :
  2025-02-7 (CK) : Création
-- -----------------------------------------------------------------------------
-- Fin de function_cre.sql
-- =========================================================================== Z
*/