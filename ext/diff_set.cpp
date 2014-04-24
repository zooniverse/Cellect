#include "rice/Class.hpp"
#include "rice/Module.hpp"
#include "rice/ruby_try_catch.hpp"
#include "rice/Data_Type.hpp"
#include "rice/Constructor.hpp"
using namespace Rice;

#include "random_set.h"

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
      .define_method("to_a", &RandomSet::to_a);
  }
  RUBY_CATCH
}
