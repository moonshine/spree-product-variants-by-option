module Spree::ProductVariantsByOption::TaxonsController

  def self.included(target)
    target.class_eval do
      append_before_filter :store_nav_info , :only => :show
    end
  end

  private

  def store_nav_info
    taxon = Taxon.find_by_permalink(params[:id].join("/") + "/")
    cookies[:product_variants_by_option_taxon] = taxon.permalink if taxon
  end
  
end
