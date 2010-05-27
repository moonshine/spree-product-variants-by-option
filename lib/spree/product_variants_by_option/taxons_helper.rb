module Spree::ProductVariantsByOption::TaxonsHelper
  def self.included(base)
    base.class_eval do
      alias_method :spree_breadcrumbs, :breadcrumbs unless method_defined?(:spree_breadcrumbs)
      alias_method :breadcrumbs, :site_breadcrumbs
    end
  end

  private
  
  # Override breadcrumbs so that we can add the selected product
  # to the breadcrumbs when displaying product variants, also
  # make the taxon a link
  def site_breadcrumbs(taxon, separator="&nbsp;&raquo;&nbsp;")
    if @product_variants_by_option
      return "" if current_page?("/")
      crumbs = [content_tag(:li, link_to(t(:home) , root_path) + separator)]
      if taxon
        crumbs << content_tag(:li, link_to(t('products') , products_path) + separator)
        crumbs << taxon.ancestors.collect { |ancestor| content_tag(:li, link_to(ancestor.name , seo_url(ancestor)) + separator) } unless taxon.ancestors.empty?
        crumbs << content_tag(:li, link_to(taxon.name, seo_url(taxon)) + separator)
        crumbs << content_tag(:li, content_tag(:span, @product.name))
      else
        crumbs << content_tag(:li, content_tag(:span, t('products')))
      end
      crumb_list = content_tag(:ul, crumbs.flatten.map{|li| li.mb_chars}.join)
      content_tag(:div, crumb_list + tag(:br, {:class => 'clear'}, false, true), :class => 'breadcrumbs')
    else
      spree_breadcrumbs(taxon, separator)
    end
  end
end