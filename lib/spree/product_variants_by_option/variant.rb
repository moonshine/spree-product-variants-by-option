module Spree::ProductVariantsByOption::Variant

  def self.included(target)
    target.class_eval do
      # Named scope to group variants by the specified option type value
      named_scope :group_by_option_type, lambda {|option_type|
        {
          :include => :option_values,
          :conditions => ["option_values.option_type_id = ?", option_type.id],
          :group => 'option_values.name'
        }
      }
    end
  end

end
