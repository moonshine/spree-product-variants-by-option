# Product Variants By Option

This Spree extension allows you to override the default behaviour of Spree when displaying a product.
When the customer selects a product, by default Spree will display the details of the selected product
including all of it's variants.

This extension allows you to override the default behaviour by introducing another level. When the customer
selects the product, another page is displayed showing all variants of the product grouped by a specified
option type, for example color. If I had a product called 'TeesTanks' with a number of color variations say
red, white, grey the new page will show 

## usage

set promotions by calling "Promotions.create :product => some_prod" in the
console etc (no nice admin interface yet)

call Promotions.random_subset(n) to get n products

call Promotions.best_sellers(n, start = 1.week.ago, finish = Time.now) to get
the n best sellers in the selected time period (default: the past week)




## implementation etc

at present: just a table of ids, with no uniqueness checking



## TODO list

  0. admin interface
     flag on each product? or drop-down list?

  2. filter this by taxons??

  3. maybe extend to "also bought"?

