module DiffSet
  class PairwisePrioritySet < PrioritySet
    alias_method :_c_subtract, :subtract
    def subtract(set, limit)
      _c_subtract(set, 2 * limit).each_slice(2).to_a.reject{ |pair| pair.length != 2 }
    end
  end
end
