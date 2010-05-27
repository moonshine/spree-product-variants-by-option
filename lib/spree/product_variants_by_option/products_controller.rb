module Spree::ProductVariantsByOption::ProductsController

  def self.included(target)
    target.class_eval do
      # Override spree product show method
      alias :spree_show :show
      def show; site_show; end
    end
  end

  private

  # Show all variants for the selected product filtered
  # by the specified option
  def site_show
    # Check if we should display variants grouped by a particular
    # option type. This is done via a product property named product_variants_by_option
    # with the value being the name of the option to group by. If this
    # property is not specified for the product then the normal show
    # action will be called.
    @product = Product.find_by_permalink(params[:id])
    property = @product.properties.find_by_name("product_variants_by_option")
    if property && cookies[:product_variants_by_option_taxon]
      load_object
      before :show

      # Find all variants for selected product, exclude master variant
      variants = Variant.active.find_all_by_product_id(@product.id,
        :include => [:images, :option_values], :conditions => {:is_master => false})
      # Find the option type we will group the variants by as specified in
      # the product_variants_by_option product property
      property_value = property.product_properties.first.value
      option_type = OptionType.find_by_name(property_value)
      if option_type
        # Process all product variants, check each variant for the specified
        # option type. The variant will be added to the hash if the option
        # type value has not been seen before, i.e. we only store the first variant
        # with the value all other are ignored. Example: If we have 4 red coloured t-shirts
        # sizes s,m,l,xl then only the first variant with red as it's option type value
        # will be stored in the hash.
        @variants = Hash.new
        variants.each do |variant|
          option_type_name = variant.option_values.first(:conditions => {:option_type_id => option_type.id}).name
          @variants[option_type_name] = variant unless @variants.include?(option_type_name)
        end

        # For breadcrumbs we have to find the taxonomy selected to
        # find this product, we store this in a cookie.
        @taxon = @product.taxons.find_by_permalink(cookies[:product_variants_by_option_taxon])

        # Set this variable to allow us to customise breadcrumb behaviour as currently
        # there are no hooks available to override this
        @product_variants_by_option = true

        render :template => 'products/variants_by_option'
      else
        raise "The option type '#{property_value}'
          specified in product property 'product_variants_by_option'
          could not be found for product '#{@product.name}'. Make sure the
          option type('#{property_value}') specified as the product property
          'product_variants_by_option' value has been created and exists."
      end
    else
      # Property not defined do default show action
      spree_show
    end

  rescue ActiveRecord::RecordNotFound
    response_for :show_fails
  end

end
