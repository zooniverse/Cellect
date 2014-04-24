#include "rice/Class.hpp"
#include "rice/Module.hpp"
#include "rice/ruby_try_catch.hpp"
#include "rice/Data_Type.hpp"
#include "rice/Constructor.hpp"
using namespace Rice;

#include "random_set.h"
#include "priority_set.h"

extern "C"
void Init_diff_set() {
  RUBY_TRY
  {
    Module rb_mDiffSet = define_module("DiffSet");
    
    Data_Type<RandomSet> rb_cRandomSet = define_class_under<RandomSet>(rb_mDiffSet, "RandomSet")
      .define_constructor(Constructor<RandomSet>())
      .define_method("add", &RandomSet::add)
      .define_method("remove", &RandomSet::remove)
      .define_method("subtract", &RandomSet::subtract)
      .define_method("include?", &RandomSet::includes)
      .define_method("to_a", &RandomSet::to_a)
      .define_method("size", &RandomSet::size);
    
    Data_Type<PrioritySet> rb_cPrioritySet = define_class_under<PrioritySet>(rb_mDiffSet, "PrioritySet")
      .define_constructor(Constructor<PrioritySet>())
      .define_method("add", &PrioritySet::add)
      .define_method("remove", &PrioritySet::remove)
      .define_method("subtract", &PrioritySet::subtract)
      .define_method("include?", &PrioritySet::includes)
      .define_method("to_a", &PrioritySet::to_a)
      .define_method("size", &PrioritySet::size);
  }
  RUBY_CATCH
}
