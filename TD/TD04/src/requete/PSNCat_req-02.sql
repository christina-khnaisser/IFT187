/*
-- =========================================================================== A
-- Programme de requêtes élémentaire pour la base de données PSN
-- -----------------------------------------------------------------------------
Projet   : PNS-Cat
Version  : 0.0.0a
Statut   : en vigueur
-- =========================================================================== A
*/
--
-- Combien y a-t-il d’ingrédients médicinaux par produit ?
--  Donner le NPN et le nombre d'ingrédients.
select npn, count(distinct ingredient_id)
from catalogue.product p
  join catalogue.product_licence pl on p.product_id = pl.product_id
  join catalogue.product_medicinal_ingredient pmi on p.product_id = pmi.product_id
group by npn;
--
-- Combien y a-t-il d’ingrédients médicinaux et d'ingrédients non-médicinaux par produit ?
--   Donner le NPN et le nombre total d'ingrédients.
with
  nb_ing_med as (
    select npn, count(distinct ingredient_id) as nb
    from catalogue.product_licence
      join catalogue.product_medicinal_ingredient using (product_id)
    group by npn
  ),
  nb_ing_non_med as (
    select npn, count(distinct ingredient_id) as nb
    from catalogue.product_licence
      join catalogue.product_non_medicinal_ingredient using (product_id)
    group by npn
  )
-- variante 1
select npn, sum(nb) as nb_total_ing
from ( select npn, nb from nb_ing_med
       union
       select npn, nb from nb_ing_non_med
     ) as ing
group by npn
order by 1;
-- variante 2
select npn, sum(nb_ing_med.nb + nb_ing_non_med.nb) as nb_total_ing
from nb_ing_med join nb_ing_non_med using (npn)
group by npn
order by 1;
--
-- Combien d'organisations commercialisent au moins deux produits ?
--  Donner le nom de l'organisation et nombre de produits.
select company_name, count(product_id)
from catalogue.product
  join catalogue.product_licence using (product_id)
  join catalogue.company using (company_id)
where status_id = 1
group by company_name
having count(product_id) > 1;
--
-- Combien y a-t-il de Contre-indications et de Réactions indésirables déclarées ?
--   Donner le type de risques et le nombre d'énoncés.
select 'Contre-indications' type, count(risk_type_desc) as nb_risques
from catalogue.product_risk
where risk_type_desc = 'Contre-indications' and risk != 'S.O.'
union
select 'Réactions indésirables' type, count(risk_type_desc) as nb_risques
from catalogue.product_risk
where risk_type_desc = 'Réactions indésirables' and risk != 'S.O.';
--
-- Combien y a-t-il de produits en 2015 et 2025 ?
--   Donner l'année et le nombre de produits
select '2015' as année, count(product_id) as nb_produit
from catalogue.product
  join catalogue.product_licence using (product_id)
where extract(year from release_date) = 2015
union
select '2025' as année, count(product_id) as nb_produit
from catalogue.product
  join catalogue.product_licence using (product_id)
where extract(year from release_date) = 2025;
--
-- Combien y a-t-il de produits émis par année entre 2015 et 2025 ?
--  Donner l'année et le nombre de produits émis.
select extract(year from release_date), count(product_id)
from catalogue.product
  join catalogue.product_licence using (product_id)
where extract(year from release_date) between 2015 and 2025
group by extract(year from release_date);
--
-- Quels sont les produits formés d'un seul ingrédient médicinal ?
--  Donner le NPN, le nom du produit et le nom de l'ingrédient.
with produit_1ing as (
  select product_id
  from catalogue.product
    join catalogue.product_medicinal_ingredient using (product_id)
  group by product_id
  having count(distinct ingredient_id) = 1
)
select npn, product.name, medicinal_ingredient.name
from produit_1ing
  join catalogue.product using(product_id)
  join catalogue.product_licence using(product_id)
  join catalogue.product_medicinal_ingredient using (product_id)
  join catalogue.medicinal_ingredient using (ingredient_id)
;
--
-- Quelles sont les formes de produits les plus fréquentes ?
--   Donner les 10 premières formes.
select form, count(product_id)
from catalogue.product
group by form
order by 2 desc
limit 10;
-- 
-- Quel est le produit ayant le moins de risques ?
--  Donner les informations des 10 premièrs produits.
select product_id, count(risk_id)
from catalogue.product_risk
group by product_id
order by 2
limit 10;
--
-- Quels sont les produits ayant plus d'ingrédients non-médicinaux que d'ingrédients médicinaux ?
--  Donner le NPN, le nom du produit et le nombre d'ingrédients non médicinaux et le d'ingrédients médicinaux.
with ing_med as
  (
    select product_id, count(distinct ingredient_id) as nb_ing_med
    from catalogue.product_medicinal_ingredient
    group by product_id
  ),
ing_non_med as
  (
    select product_id, count(distinct ingredient_id) as nb_ing_non_med
    from catalogue.product_non_medicinal_ingredient
    group by product_id
  )
select npn, name, nb_ing_non_med, nb_ing_med
from ing_med join ing_non_med using (product_id)
  join catalogue.product using (product_id)
  join catalogue.product_licence using (product_id)
where nb_ing_non_med > nb_ing_med;
--
-- Quels sont les produits dont le nombre d'ingrédients est supérieure à 10 ?
with plus10ing as (
  select product_id, name
  from catalogue.product p
  where 10 <= all (select count(distinct ingredient_id)
                   from catalogue.product_medicinal_ingredient med_ing
                   where p.product_id = med_ing.product_id)
  ),
  plus10ing_count_ingNonMed as (
    select product_id, count(distinct ingredient_id) as nb_ing_nom_med
    from plus10ing
      join catalogue.product_non_medicinal_ingredient using (product_id)
    group by product_id
  ),
  plus10ing_count_ingMed as (
    select product_id, count(distinct ingredient_id) as nb_ing_med
    from plus10ing
      join catalogue.product_medicinal_ingredient using (product_id)
    group by product_id
  )
select npn, name, nb_ing_nom_med, nb_ing_med
from catalogue.product_licence
  join plus10ing using(product_id)
  join plus10ing_count_ingMed using (product_id)
  join plus10ing_count_ingNonMed using (product_id);
/*
-- =========================================================================== Z
Contributeurs :
  (CK) Christina.Khnaisser@USherbrooke.ca

Tâches projetées :

Tâches réalisées :
  2026-01-10 (CK) : Création

Référence :
https://health-products.canada.ca/api/documentation/lnhpd-documentation-fr.html#a1
https://www.canada.ca/fr/sante-canada/services/medicaments-produits-sante/rapports-publications/produits-sante-naturels/base-donnees-produits-sante-naturels-homologues-bdpsnh-guide-termes-septembre-2008.html
-- -----------------------------------------------------------------------------
-- Fin de PSNCat_req-01.sql
-- =========================================================================== Z
*/