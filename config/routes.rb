map.show_variant '/products/:id/option/:option', :controller => 'products', :action => 'show_variant'

# These routes will override the standard products/index and root routes to display
# all variants in the system instead of all the products
map.root :controller => "products", :action => "show_all_variants"
map.show_all_variants "products/index", :controller => "products", :action => "show_all_variants"

