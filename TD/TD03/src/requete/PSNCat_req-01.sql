/*
-- =========================================================================== A
-- Programme de requêtes élémentaire pour la base de données PSN
-- -----------------------------------------------------------------------------
Projet   : PNS-Cat
Version  : 0.0.0a
Statut   : en vigueur
-- =========================================================================== A
*/
-- =========================================================================== TD02
--
--
-- Combien y a-t-il d'ingrédients médicaux ?
select count(ingredient_id)
from catalogue.medicinal_ingredient;
--
-- Quels sont les vitamins en forme liquide en vente ?
select *
from catalogue.product
where lower(name) similar to '%vitamin%'
  and lower(form) = 'liquid'
  and (status_id = 1 or status_id = 2);
-- OU
select *
from catalogue.product
  join catalogue.product_medicinal_ingredient using (product_id)
  join catalogue.medicinal_ingredient using (product_id)
where lower(medicinal_ingredient.name) similar to '%vitamin%'
  and lower(form) = 'liquid'
  and (status_id = 1 or status_id = 2);
--
-- Quels sont les produits en vente les 5 dernières années ?
--  Donner le NPN, le nom et la date d'émission.
select npn, name, release_date
from catalogue.product
  join catalogue.product_licence using (product_id)
where age(current_date, release_date) <= INTERVAL '5 years';

select npn, release_date
from catalogue.product_licence
where age(current_date, release_date) <= INTERVAL '5 years';
--
-- Combien y a-t-il de produits actifs entre 2015 et 2025?
-- v1
select count(product_id)
from catalogue.product
  join catalogue.product_licence using (product_id)
where status_id = 1
  and extract(year from release_date) between 2015 and 2025;
--
-- Quels sont les produits ayant des ingrédients médicinaux et des ingrédients non-médicinaux ?
-- v1
select distinct product_id, name
from catalogue.product
  join catalogue.product_medicinal_ingredient using (product_id)
intersect
select distinct product_id, name
from catalogue.product
  join catalogue.product_non_medicinal_ingredient using (product_id);
-- v2
select distinct product_id, name
from catalogue.product
  join catalogue.product_medicinal_ingredient using (product_id)
  join catalogue.product_non_medicinal_ingredient using (product_id);
--
-- Quels sont les produits qui ne contiennent pas d'ingrédients médicinaux ?
-- v1
select product_id
from catalogue.product
except
select product_id
from catalogue.product_medicinal_ingredient;
-- v2
select product_id
from catalogue.product
  left join catalogue.product_medicinal_ingredient using (product_id)
where ingredient_id is null;
-- 
-- Pour les ingrédients médicinaux ayant une quantité en milligramme
-- ou en microgramme convertir la valeur en gramme.
-- Donner l'identifiant du produit, le nom du produit, le nom de l'ingrédient et la quantité en gramme.
select product_id,
       p.name,
       i.name,
       case when lower(quantity_unit) in ('mg', 'milligram', 'milligrams')
              then quantity_amount/1000
            when lower(quantity_unit) in ('µg', 'mcg', 'microgram', 'micrograms')
              then quantity_amount/1000000
       end as mg_quantity
from catalogue.product_medicinal_ingredient
  join catalogue.medicinal_ingredient as i using(ingredient_id)
  join catalogue.product as p using(product_id)
where lower(quantity_unit) in ('mg', 'milligram', 'milligrams', 'µg', 'mcg', 'microgram', 'micrograms');
--
-- Quels sont les produits qui n’ont aucun risque déclaré ?
select product_id, name
from catalogue.product
  left join catalogue.product_risk using (product_id)
where risk is null;
--
-- Quels sont les produits ayant plus de risques que de bénéfices ?
--
select product_id, name
from catalogue.product
where (select count(risk_id) from catalogue.product_risk) >
      (select count(purpose_id) from catalogue.product_purpose);
-- TEST
select count(risk_id) from catalogue.product_risk
where product_id = 2299;
select count(purpose_id) from catalogue.product_purpose
where product_id = 2299;
--
-- Quels sont les produits bénéfiques pour le sommeil ?
--  Donner le NPN, le nom du produit, la dose et la fréquence recommandée.
-- Mots à rechercher : sleep, slumber, nap, drowsy, doze
select product_id, name, quantity, quantity_unit, frequency, frequency_unit
     , to_tsvector('english', purpose)
from catalogue.product_purpose
  join catalogue.product p using(product_id)
  join catalogue.product_dosage using (product_id)
where purpose @@ to_tsquery('english', 'sleep | slumber | nap | drowsy');
--
-- Ajouter l'objectif principal du produit.
select npn, p.name, form
     , case when lower(mi.name) similar to '%melatonin%' then 'Sommeil'
            when lower(mi.name) similar to '%benzodiazepine%' then 'Anxiété'
            when lower(mi.name) similar to '%curcumin%' then 'Digestion'
            when lower(mi.name) similar to '%phytosterol%' then 'Cholestérol'
            when lower(mi.name) similar to '%creatine%' then 'Performance cognitive'
            else 'À déterminer'
       end as objectif
from catalogue.product p
  join catalogue.product_licence pl on pl.product_id = p.product_id
  join catalogue.product_medicinal_ingredient pmi on p.product_id = pmi.product_id
  join catalogue.medicinal_ingredient mi on mi.ingredient_id = pmi.ingredient_id
;
--
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