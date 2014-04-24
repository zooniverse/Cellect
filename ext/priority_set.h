#ifndef PRIORITY_SET_H
#define PRIORITY_SET_H

#include "rice/Object.hpp"
#include "rice/Array.hpp"
using namespace Rice;

class PrioritySet {
public:
  PrioritySet();
  void add(int element);
  void remove(int element);
  bool includes(int element);
  Array subtract(PrioritySet &other, size_t limit);
  Array to_a();
  size_t size();
};

#endif
