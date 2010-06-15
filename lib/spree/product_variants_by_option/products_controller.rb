module Spree::ProductVariantsByOption::ProductsController

  def self.included(target)
    target.class_eval do
      # Override spree product show method
      alias :spree_show :show unless method_defined?(:spree_show)
      def show; site_show; end
      def show_variant; site_show_variant; end
      def show_all_variants; site_show_all_variants; end
    end
  end

  private

  # Show all variants on the products/index page
  def site_show_all_variants
    variants = Array.new
    # Find all active products in the system
    Product.not_deleted.each do |product|
      # Check if it has variants other than the master
      if product.variants.any?
        # Check if this product should be groups
        if !product.display_variants_by_option.blank? &&
          (option_type = OptionType.find_by_name(product.display_variants_by_option))
          # Find all variants and group by specified option type value
          product.variants.group_by_option_type(option_type).each {|v| variants << v}
        else
          # Not grouped so find all variants
          product.variants.each {|v| variants << v}
        end
      else
        # Product only has a master
        variants << product.master
      end
    end
    
    # Paginate variants
    @variants = variants.paginate(
      :per_page  => Spree::Config[:admin_products_per_page],
      :page      => params[:page])
    
    render :template => 'products/variants_by_option'
  end

  # Show all variants for the selected product filtered
  # by the specified option
  def site_show
    # Check if we should display variants grouped by a particular
    # option type. This is done via a new product field display_variants_by_option
    # with the value being the name of the option type to group by. If this
    # field is not specified for the product then the normal show action will be called.
    @product = Product.find_by_permalink(params[:id])
    if !@product.display_variants_by_option.blank?
      # Find the option type we will group the variants by as specified in
      # the display_variants_by_option product field
      option_type = OptionType.find_by_name(@product.display_variants_by_option)
      if option_type
        # Find all variants and group by the specified option type value, example
        # if we had red, blue, and green tshirt variants of different sizes and we
        # nominated to group by color. The following code will find all variants
        # and group them by color, so we will end up with one record for each color.
        variants = Array.new
        @product.variants.group_by_option_type(option_type).each {|v| variants << v}

        # For breadcrumbs we have to find the taxonomy selected to
        # find this product, we store this in a cookie.
        if cookies[:product_variants_by_option_taxon]
          @taxon = Taxon.find_by_permalink(cookies[:product_variants_by_option_taxon])
          # Construct a hash with additional breadcrumbs
          @product_variants_by_option = ActiveSupport::OrderedHash.new
          @product_variants_by_option[@product.name] = product_url(@product)
        end

        # Paginate variants
        @variants = variants.paginate(
          :per_page  => Spree::Config[:admin_products_per_page],
          :page      => params[:page])

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
      if @variants && !@variants.empty?
        if cookies[:product_variants_by_option_taxon] &&
          @taxon = @product.taxons.find_by_permalink(cookies[:product_variants_by_option_taxon])
          # Add additional breadcrumbs
          @product_variants_by_option = ActiveSupport::OrderedHash.new
          @product_variants_by_option[@product.name] = product_url(@product)
          @product_variants_by_option[!@variants.first.short_description.blank? ? @variants.first.short_description : @variants.first.product.name+' '+params[:option]] =
            show_variant_url(:id => @product.permalink, :option => params[:option])
        end
        @selected_variant = @variants.first
      end
    else
      @variants = Array.new
    end
  end

end
