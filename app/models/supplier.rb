# require 'base_class'
# class Supplier < CZ::BaseClass
  # attr_accessor :s_key,:supplierNr
#   
  # include Redis::Search
# 
  # redis_search_index(:title_field => :supplierNr,
                                         # :alias_field => :alias,
                                         # :prefix_index_enable => true,
                                         # :condition_fields => [:s_key],
                                         # # :score_field => :date,
                                         # :ext_fields => [:name, :address, :id])
#     
      # @@arrs = [ :name, :address, :id ]
      # @@arrs.each do |arr|
        # class_eval %(
          # def #{arr}
            # self.organ.#{arr}
          # end
        # )
      # end
#       
    # def alias
      # [self.name, self.address]
    # end
#     
    # def key
      # $redis.incr 'redis_search_for_supplier'
    # end
#     
    # def organ
      # orgId = $redis.zscore( self.s_key, self.supplierNr ).to_i
      # Organisation.find_by_id( orgId )
    # end
#     
    # def save_index
      # run_callbacks :save
    # end
#     
# end