# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class ProductVariantsByOptionExtension < Spree::Extension
  version "1.0"
  description "Display product variants by a nominated option (e.g. color)"
  url "http://github.com/whytehouse/spree-product-variants-by-option"

  def activate
    # Override spree products controller
    ProductsController.send(:include, Spree::ProductVariantsByOption::ProductsController)
    TaxonsHelper.send(:include, Spree::ProductVariantsByOption::TaxonsHelper)
  end
end
