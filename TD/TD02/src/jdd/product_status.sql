insert into catalogue.product_status (status_id, status_name, status_description)
values  (1, 'Actif', 'Le produit a été homologué et dispose d''un NPN ou un DIN-HM valable.'),
        (0, 'Discontinué', 'Le produit disposait d''un NPN valable, mais le titulaire de licence a retiré le produit de la vente et a renoncé à son NPN, c''est-à-dire que le produit/le NPN a été invalidé par le titulaire de licence lui-même.'),
        (2, 'Cessation de vente', 'Le NPN reste valable et le produit est toujours disponible à la vente au détail, mais il ne doit pas être vendu en gros.'),
        (3, 'Suspendu', 'Le NPN reste valable, mais le produit ne doit plus être vendu au détail ou en gros.'),
        (4, 'Annulé', 'Le NPN n''est plus valable.');