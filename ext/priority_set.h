#ifndef PRIORITY_SET_H
#define PRIORITY_SET_H

#include "rice/Object.hpp"
#include "rice/Array.hpp"
#include "rice/Hash.hpp"
using namespace Rice;

#include <boost/random.hpp>
#include <boost/heap/fibonacci_heap.hpp>

#include <sys/time.h>

class PrioritySet {
public:
  struct element {
    int id;
    double priority;
    double random;
    
    element(int id, double priority, double random) {
      this->id = id;
      this->priority = priority;
      this->random = random;
    }
  };
  
  struct comparator {
    bool operator()(const element &a, const element &b) const {
      return (a.priority < b.priority) || (a.random < b.random);
    }
  };
  
  PrioritySet();
  void add(int id, double priority = 0.0);
  void remove(int id);
  bool includes(int id);
  Array subtract(PrioritySet &other, size_t limit);
  Array to_a();
  Hash to_h();
  size_t size();
protected:
  typedef boost::heap::fibonacci_heap<element, boost::heap::compare<comparator> > fibonacci_heap;
  fibonacci_heap heap;
  boost::random::mt19937 rng;
};

#endif
