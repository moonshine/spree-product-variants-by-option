module Spree::ProductVariantsByOption::ProductsController

  def self.included(target)
    target.class_eval do
      # Override spree product show method
      alias :spree_show :show unless method_defined?(:spree_show)
      def show; site_show; end
      def show_variant; site_show_variant; end
    end
  end

  private

  # Show all variants for the selected product filtered
  # by the specified option
  def site_show
    # Check if we should display variants grouped by a particular
    # option type. This is done via a new product field display_variants_by_option
    # with the value being the name of the option type to group by. If this
    # field is not specified for the product then the normal show action will be called.
    @product = Product.find_by_permalink(params[:id])
    if !@product.display_variants_by_option.blank?
      # Find all variants for selected product, exclude master variant, sort by variants.id
      # as we use the first variant to determine what images and short description to display.
      variants = Variant.active.find_all_by_product_id(@product.id,
        :include => [:images, :option_values],
        :conditions => ["is_master = ?", false],
        :order => 'variants.id')
      # Find the option type we will group the variants by as specified in
      # the display_variants_by_option product field
      property_value = @product.display_variants_by_option
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
        if cookies[:product_variants_by_option_taxon]
          @taxon = Taxon.find_by_permalink(cookies[:product_variants_by_option_taxon])
          # Construct a hash with additional breadcrumbs
          @product_variants_by_option = ActiveSupport::OrderedHash.new
          @product_variants_by_option[@product.name] = product_url(@product)
        end

        render :template => 'products/variants_by_option'
      else
        raise "The option type '#{property_value}'
          specified in product field 'Display variants by option'
          could not be found for product '#{@product.name}'. Make sure the
          option type('#{property_value}') has been created and exists."
      end
    else
      # Property not defined do default show action
      spree_show
    end

  rescue ActiveRecord::RecordNotFound
    response_for :show_fails
  end

  # Action is called from the variants display page, links on this page has
  # the format /products/:id/option/:option. We find the products and then the
  # variants that have the selected value for the option. So for example we may
  # have /products/teestanks/option/red, when the user selects this link we will
  # find the teestanks product and all the variants red variants.
  def site_show_variant
    # Find products
    @product = Product.find_by_permalink(params[:id])
    # Find all product properties
    @product_properties = ProductProperty.find_all_by_product_id(@product.id, :include => [:property])
    # Check if we need to display product group by an option type
    if !@product.display_variants_by_option.blank?
      # Find all variants for the selected product that has the option specified
      # in the product field display_variants_by_option (e.g. Color) and the
      # selected value for that option (e.g. Red). Sort by variants.id, we use the first
      # variant to find the images and short desctiption to display
      @variants = Variant.active.find_all_by_product_id(@product.id,
        :include => [:images, {:option_values => :option_type}],
        :conditions => ["variants.is_master = ? AND option_types.name = ? AND option_values.name = ?",
          false, @product.display_variants_by_option, params[:option]],
        :order => 'variants.id')
      # Find the taxonomy selected to find this product, we store this in a cookie.
      if cookies[:product_variants_by_option_taxon] && @variants && !@variants.empty?
        @taxon = @product.taxons.find_by_permalink(cookies[:product_variants_by_option_taxon])
        # Add additional breadcrumbs
        @product_variants_by_option = ActiveSupport::OrderedHash.new
        @product_variants_by_option[@product.name] = product_url(@product)
        @product_variants_by_option[!@variants.first.short_description.blank? ? @variants.first.short_description : @variants.first.product.name+' '+params[:option]] =
          show_variant_url(:id => @product.permalink, :option => params[:option])
      end
      @selected_variant = @variants.first if @variants
    end
  end

end
