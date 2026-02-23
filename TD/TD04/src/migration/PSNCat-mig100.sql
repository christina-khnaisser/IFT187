/*
-- =========================================================================== A
-- Migration v100
-- -----------------------------------------------------------------------------
Projet   : PNS-Cat
Version  : 0.0.0a
Statut   : en vigueur
-- =========================================================================== A
*/
--
-- Renommer la colonne name à ingredient_name de la relation des ingrédients médicinaux.
alter table catalogue.medicinal_ingredient
  rename column name to ingredient_name;
--
-- Renommer la colonne name à ingredient_name de la relation des ingrédients non médicinaux.
alter table catalogue.non_medicinal_ingredient
  rename column name to ingredient_name;
--
-- Retirer la colonne extract_type_desc de la relation des ingrédients médicinaux.
alter table catalogue.medicinal_ingredient
  drop column extract_type_desc;
--
-- Normaliser les valeurs des colonnes qui représentent des unités de mesures.
-- Rendre les valeurs en minuscule et au singulier (ex. Drop(s) -> drop).
-- >> test avant
select count(*)
from catalogue.product_dosage
where regexp_match(frequency_unit, '\(s\)$', 'i') is not null;
-- >> exécution
call catalogue.normalize_unit_of_measure();
--  >> test après
select count(*)
from catalogue.product_dosage
where regexp_match(quantity_unit, '\(s\)$', '') is not null;

select count(*)
from catalogue.product_dosage
where regexp_match(frequency_unit, '\(s\)$', '') is not null;
--
-- Archiver les produits discontinués.
--  Créer une relation pour stocker
--    les produits discontinués (avec la date et la raison du retrait)
--    et une relation pour les produits non discontinués.
create table catalogue.Product_valid
  (
    product_id integer      not null,
    constraint product_valid_cc00 primary key (product_id),
    constraint product_valid_cr01 foreign key (product_id) references catalogue.product
  );
create table catalogue.Product_discontinued
  (
    product_id        integer not null,
    reason            text not null,
    discontinued_date date    not null,
    constraint product_discontinued_cc00 primary key (product_id),
    constraint product_discontinued_cr01 foreign key (product_id) references catalogue.product
  );
-- Répartir les données dans les relations appropriées.
call catalogue.archiver_product();
--
-- Archiver les produits de l'organisation Viva Pharmaceutical Inc
call catalogue.archiver_product_company('Viva Pharmaceutical Inc.', 'Fermeture');
--
-- Retirer les produits qui ont une forme parmi la liste suivante :
--   'aerosol', 'dental', 'exfoliant', 'film', 'gargle', 'kit', 'mouthwash', 'pouch', 'shampoo',
-- 'soap', 'sponge', 'spray', 'stick', 'swab', 'wipe'.
call retrait_produit_forme();
--
/*
-- =========================================================================== Z
Contributeurs :
  (CK) Christina.Khnaisser@USherbrooke.ca

Tâches projetées :

Tâches réalisées :
  2026-02-07 (CK) : Création
-- -----------------------------------------------------------------------------
-- Fin de schema_cre.sql
-- =========================================================================== Z
*/