/*
-- =========================================================================== A
-- Création des procédures
-- -----------------------------------------------------------------------------
Projet   : PNS-Cat
Version  : 0.0.0a
Statut   : en vigueur
-- =========================================================================== A
*/
--
-- Normaliser les unités de mesures.
create or replace procedure catalogue.normalize_unit_of_measure()
  language SQL as
$$
  -- Dosage
  update catalogue.product_dosage
    set quantity_unit = catalogue.normalize_unit_of_measure(quantity_unit),
        frequency_unit = catalogue.normalize_unit_of_measure(frequency_unit);
  -- Quantité d'ingrédients
  update catalogue.product_medicinal_ingredient
    set quantity_unit = catalogue.normalize_unit_of_measure(quantity_unit);
$$;
--
-- Construire une procédure pour la création d'un produit avec son dosage.
create or replace procedure catalogue.product_with_dosage_ins
    (
      _company integer,
      _name varchar(120),
      _form varchar(26),
      _status integer,
      _quantity numeric(5,2),
      _quantity_unit varchar(42),
      _frequency integer,
      _frequency_unit varchar(42)
    )
  language SQL as
$$
with product_ins as(
  insert into catalogue.product (company_id, name, form, status_id)
    values (_company, _name, _form, _status)
    returning product_id
  )
insert into catalogue.product_dosage(product_id, quantity, quantity_unit, frequency, frequency_unit)
  select product_id,
         _quantity,
         catalogue.normalize_unit_of_measure(_quantity_unit),
         _frequency,
         catalogue.normalize_unit_of_measure(_frequency_unit)
  from product_ins
$$;
--
-- Archiver un produit
create or replace procedure catalogue.archiver_product()
  language SQL as
$$
  insert into catalogue.Product_valid(product_id)
    select product_id
    from catalogue.product
    where status_id in (1,2,3);

  insert into catalogue.Product_discontinued(product_id, reason, discontinued_date)
    select product_id, 'S.O.', current_date
    from catalogue.product
    where status_id in (0);
$$;
--
-- Archiver un produit spécifique
create or replace procedure catalogue.archiver_product
  (
  _product_id integer,
  _reason varchar
  )
  language SQL as
$$
  update catalogue.product
    set status_id = 0
    where product_id = _product_id;

  insert into catalogue.Product_discontinued(product_id, reason, discontinued_date)
    values (_product_id, _reason, current_date);
$$;
--
-- Archiver les produits d'une organisation
--   Créer une procédure pour archiver les produits d'une organisation
--   Archiver les produits de Viva Pharmaceutical Inc.
create or replace procedure catalogue.archiver_product_company
  (
  _company_name varchar,
  _reason varchar
  )
  language plpgsql as
$$
declare
  rec record;
begin
  for rec in select product_id
             from catalogue.product
             where company_id = (select company_id
                                from catalogue.company
                                where company_name = _company_name)
  loop
    call catalogue.archiver_product(rec.product_id, _reason);
  end loop;
end
$$;
--
-- Retirer les produits qui ont une forme parmi la liste suivante :
--   'aerosol', 'dental', 'exfoliant', 'film', 'gargle', 'kit', 'mouthwash', 'pouch', 'shampoo',
-- 'soap', 'sponge', 'spray', 'stick', 'swab', 'wipe'.
--
create or replace procedure retrait_produit_forme()
    language SQL as
$$
with form_filter as (
  select name
  from ( values ('aerosol'),
                  ('dental'),
                  ('exfoliant'),
                  ('film'),
                  ('gargle'),
                  ('kit'),
                  ('mouthwash'),
                  ('pouch'),
                  ('shampoo'),
                  ('soap'),
                  ('sponge'),
                  ('spray'),
                  ('stick'),
                  ('swab'),
                  ('wipe')
      ) AS t (name)
  ),
  produit as (
    select product_id
    from catalogue.product
    where exists( select 1
              from form_filter
              where lower(form) similar to ('%' || name || '%'))
  ),
  retrait_non_med_ing as (
    delete from catalogue.product_non_medicinal_ingredient
    where product_id in (select product_id from  produit)
  ),
  retrait_med_ing as (
    delete from catalogue.product_medicinal_ingredient
      where product_id in (select product_id from produit)
  ),
  retrait_risk as (
    delete from catalogue.product_risk
      where product_id in (select product_id from produit)
  ),
  retrait_purpose as (
    delete from catalogue.product_purpose
      where product_id in (select product_id from produit)
  ),
  retrait_dosage as (
    delete from catalogue.product_dosage
      where product_id in (select product_id from produit)
  ),
  retrait_licence as (
    delete from catalogue.product_licence
      where product_id in (select product_id from produit)
  ),
  retrait_product_valid as (
    delete from catalogue.product_valid
      where product_id in (select product_id from produit)
  ),
  retrait_product_disc as (
    delete from catalogue.product_discontinued
      where product_id in (select product_id from produit)
  ),
  retrait_product as (
    delete from catalogue.product
      where product_id in (select product_id from produit)
  )
select count(*)
from produit;
$$;
--
/*
-- =========================================================================== Z
Contributeurs :
  (CK) Christina.Khnaisser@USherbrooke.ca

Tâches projetées :

Tâches réalisées :
  2025-02-7 (CK) : Création
-- -----------------------------------------------------------------------------
-- Fin de procedure_cre.sql
-- =========================================================================== Z
*/