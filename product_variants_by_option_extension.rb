class ProductVariantsByOptionExtension < Spree::Extension
  version "1.0"
  description "Display product variants by a nominated option (e.g. color)"
  url "http://github.com/whytehouse/spree-product-variants-by-option"

  def activate
    # Override spree products controller
    ProductsController.send(:include, Spree::ProductVariantsByOption::ProductsController)
    # Override spree breadcrumbs
    TaxonsHelper.send(:include, Spree::ProductVariantsByOption::TaxonsHelper)
    # Capture navigation information and store in a cookie
    Spree::BaseController.send(:include, Spree::ProductVariantsByOption::TaxonsController)
    # Add short_description field to variants table
    Variant.additional_fields += [ 
      {:name => 'short_description', :only => [:variant]} 
      ]
  end
end
