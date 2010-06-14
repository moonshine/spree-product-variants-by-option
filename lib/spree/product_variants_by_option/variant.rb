module Spree::ProductVariantsByOption::Variant

  def self.included(target)
    target.class_eval do
      # Add named_scope to find all active variants, it can also remove duplicates so 
      # that only variants that are not a master OR is a master but belongs to a product
      # that have no other variants. To find active variants use Variant.active to remove
      # duplicates use Variant.active.no_duplicates
      named_scope :active,
        :conditions => "variants.deleted_at is null",
        :order => 'product_id, id' do
        def no_duplicates
          collect {|v| v if (!v.product.variants.any? && v.is_master?) || !v.is_master?}.compact
        end
      end
    end
  end

end
