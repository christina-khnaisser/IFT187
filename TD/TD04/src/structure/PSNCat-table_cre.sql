/*
-- =========================================================================== A
-- Création des tables du schéma catalogue
-- -----------------------------------------------------------------------------
Projet   : PNS-Cat
Version  : 0.0.0a
Statut   : en vigueur
-- =========================================================================== A
*/
--
create table catalogue.company
(
  company_id   serial      not null,
  company_name varchar(120) not null,
  constraint company_cc00 primary key (company_id),
  constraint company_cc01 unique (company_name)
);
comment on table catalogue.company is
  $$Une organisation qui commercialise des produits de santé naturels.$$;
--
--
create table catalogue.product_status
(
  status_id          integer      not null,
  status_name        varchar(26)  not null,
  status_description varchar(252) not null,
  constraint product_status_cc00 primary key (status_id),
  constraint product_status_cc01 unique (status_name)
);
comment on table catalogue.product_status is
  $$Un status indiquant l'état de la license du produit.$$;
--
--
create table catalogue.product
(
  product_id serial,
  company_id integer      not null,
  name       varchar(120) not null,
  form       varchar(26)  not null,
  status_id  integer      not null,
  constraint product_cc00 primary key (product_id),
  constraint product_cr00 foreign key (company_id) references catalogue.company (company_id),
  constraint product_cr01 foreign key (status_id) references catalogue.product_status (status_id)
);
comment on table catalogue.product is
  $$Un produit de santé naturel.$$;
--
--
create domain catalogue.npn as char(8)
  check (value similar to '[0-9]{8}');
comment on domain catalogue.npn is
  $$Un code numérique de huit (8) chiffres assigné à chaque produit de santé naturel approuvé
    pour être commercialisé en vertu du règlement sur les produits de santé naturels.$$;
--
-- NOTE 2026-01-23 CK : cette table n'est pas en 1 FN, revised_date est null !!
--  exercice pour le module de normalisation.
create table catalogue.product_licence
(
  npn          catalogue.npn not null,
  product_id   integer       not null,
  receipt_date date          not null,
  start_date   date          not null,
  release_date date          not null,
  revised_date date          null,
  constraint product_licence_cc00 primary key (npn),
  constraint product_licence_cr00 foreign key (product_id) references catalogue.product (product_id),
  constraint product_licence_npn check (npn ~ '^\d{8}$'::text),
  constraint product_licence_start_date check (start_date >= receipt_date),
  constraint product_licence_release_date check (release_date >= start_date),
  constraint product_licence_revised_date check (revised_date >= start_date)
);
comment on table catalogue.product_licence is
  $$Une licence d'un produit de santé naturel.$$;
comment on column catalogue.product_licence.npn is
  $$Un numéro de licence d'un produit de santé naturel.$$;
comment on column catalogue.product_licence.receipt_date is
  $$Date de soumission reçue à la Direction des produits de santé naturels et sans ordonnance.$$;
comment on column catalogue.product_licence.start_date is
  $$Date à laquelle le processus a débuté.$$;
comment on column catalogue.product_licence.release_date is
  $$Date d''émission initiale.$$;
comment on column catalogue.product_licence.revised_date is
  $$Date de la dernière révision.$$;
--
--
create table catalogue.product_dosage
(
  product_id     integer       not null,
  quantity       numeric(5, 2) not null,
  quantity_unit  varchar(42)   not null,
  frequency      integer       not null,
  frequency_unit varchar(42)   not null,
  constraint product_dosage_cc00 primary key (product_id),
  constraint product_dosage_cr01 foreign key (product_id) references catalogue.product (product_id),
  constraint product_dosage_quantity check (quantity > 0)
);
comment on table catalogue.product_dosage is
  $$La dose du produit fini représentée par la quantité d'unités posologiques et
    la fréquence d'utilisation aux fins recommandées.$$;
--
-- TODO 2026-01-10 CK : définir extract_type_desc ?
-- TODO 2026-01-10 CK :	source_material. Il peut y avoir plusieurs sources pour un seul ingrédient médicinal.
create table catalogue.medicinal_ingredient
(
  ingredient_id     serial       not null,
  name   varchar(180) not null,
  extract_type_desc varchar(62)  not null,
  source_material   varchar(62)  not null,
  constraint medicinal_ingredient_cc00 primary key (ingredient_id)
);
comment on table catalogue.medicinal_ingredient is
  $$Un ingrédient médicinal est une substances qui est censée produire un effet
    pharmacologique ou tout autre effet directement recherché.$$;
comment on column catalogue.medicinal_ingredient.source_material is
  $$La substance à partir de laquelle l'ingrédient médicinal a été dérivé.$$;
--
--
create table catalogue.product_medicinal_ingredient
(
  product_id      integer        not null,
  ingredient_id   integer        not null,
  quantity_amount numeric(10, 2) not null,
  quantity_unit   varchar(42)    not null,
  constraint product_medicinal_ingredient_cc00 primary key (product_id, ingredient_id),
  constraint product_medicinal_ingredient_cr00 foreign key (product_id) references catalogue.product (product_id),
  constraint product_medicinal_ingredient_cr01 foreign key (ingredient_id) references catalogue.medicinal_ingredient (ingredient_id),
  constraint product_product_medicinal_ingredient_quantity check (quantity_amount > 0)
);
comment on table catalogue.product_medicinal_ingredient is
  $$Un produit contient un ingrédient médicinal.$$;
--
--
create table catalogue.non_medicinal_ingredient
(
  ingredient_id   serial       not null,
  name varchar(180) not null,
  constraint non_medicinal_ingredient_cc00 primary key (ingredient_id),
  constraint non_medicinal_ingredient_cc01 unique (name)
);
comment on table catalogue.non_medicinal_ingredient is
  $$Un ingrédient non médicinal est une substance ajoutée à un produit de santé naturel pour
   conférer la consistance ou la forme voulue aux ingrédients médicinaux n'entraîneront pas par
   eux-mêmes d'effets pharmacologiques.$$;
--
--
create table catalogue.product_non_medicinal_ingredient
(
  product_id    integer not null,
  ingredient_id integer not null,
  constraint product_non_medicinal_ingredient_cc00 primary key (product_id, ingredient_id),
  constraint product_non_medicinal_ingredient_cr00 foreign key (product_id) references catalogue.product (product_id),
  constraint product_non_medicinal_ingredient_cr01 foreign key (ingredient_id) references catalogue.non_medicinal_ingredient (ingredient_id)
);
comment on table catalogue.product_non_medicinal_ingredient is
  $$Un produit contient un ingrédient non médicinal.$$;
--
--
create domain catalogue.risk_type as
  varchar(62)
  constraint risk_type_check
    check (value in ('Mises en garde', 'Contre-indications', 'Réactions indésirables'));
--check (value in ('Mises en garde', 'Contre-indications', 'Réactions indésirables'));

create table catalogue.product_risk
(
  risk_id        serial              not null,
  product_id     integer             not null,
  risk_type_desc catalogue.risk_type not null,
  risk           text                not null,
  constraint product_risk_cc00 primary key (risk_id, product_id),
  constraint product_risk_cr00 foreign key (product_id) references catalogue.product (product_id)
);
comment on table catalogue.product_risk is
  $$Un risque est toutes mises en garde, réactions indésirables et information contradictoire
  associées à l'utilisation du produit de santé naturel.$$;
--
--
create table catalogue.product_purpose
(
  purpose_id serial  not null,
  product_id integer not null,
  purpose    text    not null,
  constraint product_purpose_cc00 primary key (purpose_id, product_id),
  constraint product_purpose_cr00 foreign key (product_id) references catalogue.product (product_id)
);
comment on table catalogue.product_purpose is
  $$Un objectif est une déclaration indiquant l'effet bénéfique prévu d'un produit de santé naturel
    lorsqu'il est utilisé selon la dose recommandée, la durée d'utilisation et la voie d'administration.$$;
--
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
-- Fin de table_cre.sql
-- =========================================================================== Z
*/
