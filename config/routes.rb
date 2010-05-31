# Put your extension routes here.

# map.namespace :admin do |admin|
#   admin.resources :whatever
# end
map.show_variant '/products/:id/option/:option', :controller => 'products', :action => 'show_variant'
