module Spree::ProductVariantsByOption::OptionValue

  def self.included(target)
    target.class_eval do
      before_save :generate_seo_option_name
    end
  end

  private

  # Convert the option name to seo
  def generate_seo_option_name
    self.name = self.name.to_url
  end

end
