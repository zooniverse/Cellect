#ifndef RANDOM_SET_H
#define RANDOM_SET_H

#include "rice/Object.hpp"
#include "rice/Array.hpp"
using namespace Rice;

#include <boost/random/mersenne_twister.hpp>
#include <boost/random/uniform_int_distribution.hpp>
#include <boost/unordered_set.hpp>

#include <vector>
#include <sys/time.h>

class RandomSet {
public:
  RandomSet();
  void add(int element);
  void remove(int element);
  bool includes(int element);
  Array subtract(RandomSet &other, size_t limit);
  Array to_a();
  size_t size();
protected:
  std::vector<int> elements;
  boost::unordered_set<int> element_set;
  boost::random::mt19937 rng;
  
  std::vector<int>::iterator iterator_to(int element);
};

#endif
