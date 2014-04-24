#include "priority_set.h"

PrioritySet::PrioritySet() {
  timeval time;
  gettimeofday(&time, NULL);
  long millis = (time.tv_sec * 1000.0) + (time.tv_usec / 1000.0);
  this->rng.seed((uint)millis);
}

void PrioritySet::add(int id, double priority) {
  static boost::uniform_01<boost::random::mt19937> dist(this->rng);
  this->heap.push(element(id, priority, dist()));
}

void PrioritySet::remove(int id) {
  
}

bool PrioritySet::includes(int id) {
  return false;
}

Array PrioritySet::subtract(PrioritySet &other, size_t limit) {
  Array diff;
  return diff;
}

Array PrioritySet::to_a() {
  Array array;
  fibonacci_heap::ordered_iterator it;
  for(it = this->heap.ordered_begin(); it != this->heap.ordered_end(); it++) {
    array.push(it->id);
  }
  return array;
}

Hash PrioritySet::to_h() {
  Hash hash;
  fibonacci_heap::ordered_iterator it;
  for(it = this->heap.ordered_begin(); it != this->heap.ordered_end(); it++) {
    hash[it->id] = it->priority;
  }
  return hash;
}

size_t PrioritySet::size() {
  return 0u;
}
