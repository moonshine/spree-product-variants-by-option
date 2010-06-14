# Product Variants By Option

This Spree extension allows you to override the default behaviour of Spree when displaying a product.
When the customer selects a product from the products index page, by default Spree will display the details
of the selected product including all of it's variants, e.g. sizes and colors.

This extension allows you to override the default behaviour, when a customer selects a product from the products
index page, a new page is displayed similar to the products index page displaying all product variants
grouped by a specified option type, for example color. If I had a product called 'TeesTanks' with a number of color
variants say red, white, and grey a new index like page is displayed with an entry for each of the color variants. Each
entry will have a link in the following format:

/products/[product name]/[option type value]

example:

Red varaint = /products/teestanks/option/red

White variant = /products/teestanks/option/white

When the a link is selected, the information for that variant is displayed including images linked to the variant
and a short description specific to that variant.

## Usage

### Specify option type to group by

To have the variants displayed and grouped by an option type a new fields has been added to the product table
called display_variants_by_option which is available in the product edit form. The "name" of the option type
that you want to group by is specified in this field. For example if you defined an option type called "TT_Color"
to hold the color variants of your product then you can set the display_variants_by_option to this value and the
extension will group all variants for the selected product by the "TT_Color" option type values.

If no value is specified in this field then the default Spree behaviour will be used.

### Variant images & short description

A new short_description field has been added to the variants table that will be displayed as the
description for each variant.

** Please note that the extension will use the images and short description from the first variant found
in each group. For example if you created Red Small, Red Meduim and Red Large varaints for a product in this order
then the images and short description of the "Red Small" variant will be used as it is the first one that was created.

### Show Page

The show page (products/show_variant.html) for the selected variant in this extension is an example only and will
need to be modified to suit. This can be done by overriding the products/show_variant.html view in your site
extension or similar.

### Override the root (products/index)

The extenstion allows you to override the default root or products/index page by displaying a paginated list
of all active variants rather than a list of all the products. It will order the display by product ID and variant ID.
It will NOT display any master variants that belong to a product that have other variants, master variants that
belong to a product that have no other variants will still be displayed.

This behaviour is switched off by default, to get this behaviour to work you will need to uncomment the following
two routes within the routes file:

map.root :controller => "products", :action => "show_all_variants"
map.show_all_variants "products/index", :controller => "products", :action => "show_all_variants"

## TODO list

Tests

