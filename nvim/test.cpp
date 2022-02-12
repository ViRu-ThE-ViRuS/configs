// hello my name is viraat chandra and i love to program

#include <algorithm>
#include <iostream>
#include <iterator>
#include <utility>
#include <vector>

int main() {
  std::atomic<int> test;
  std::cout << test.is_lock_free() << std::endl;
  std::ios_base::sync_with_stdio(false);

  return 0;
}
