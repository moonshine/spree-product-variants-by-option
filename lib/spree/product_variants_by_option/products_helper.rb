module Spree::ProductVariantsByOption::ProductsHelper
  def self.included(base)
    base.class_eval do
      def get_variant_option(variant)
        option = ''
        unless variant.product.display_variants_by_option.blank?
          option_type = OptionType.find_by_name(variant.product.display_variants_by_option)
          if option_type
            option_value = variant.option_values.first(:conditions => {:option_type_id => option_type.id})
            option = option_value.name if option_value
          end
        end
      end

      def get_variant_path(variant, option)
        if variant.is_master? || option.blank?
          variant.product
        else
          show_variant_path(:id => variant.product.permalink, :option => option)
        end
      end
    end
  end

end