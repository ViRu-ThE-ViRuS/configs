// hello my name is viraat chandra and i love to program

#include <algorithm>
#include <iostream>
#include <iterator>
#include <utility>
#include <vector>

template <typename A, typename B>
std::ostream &operator<<(std::ostream &stream, const std::pair<A, B> &pair) {
  stream << "[ " << pair.first << " " << pair.second << " ]";
  return stream;
}

template <typename T>
std::ostream &operator<<(std::ostream &stream, const std::vector<T> &vector) {
  stream << "[ ";
  for (const auto &elem : vector)
    stream << elem << " ";
  stream << "]";

  return stream;
}

class Graph {
private:
  std::vector<std::vector<std::pair<int, int>>> adjacencyList;

public:
  Graph(const int n) { adjacencyList.resize(n); }

  void add_edge(const int source, const int destination, const int weight) {
    adjacencyList[source].emplace_back(destination, weight);
    adjacencyList[destination].emplace_back(source, weight);
  }
};

int main() {
  std::atomic<int> test;
  std::cout << test.is_lock_free() << std::endl;

  std::ios_base::sync_with_stdio(false);
  std::vector<std::vector<std::pair<int, int>>> adjacencyList;

  adjacencyList.resize(1);
  adjacencyList[0].resize(1);
  for (const std::pair<int, int> &item : adjacencyList[0])
    std::cout << item.first << " " << item.second << std::endl;

  try {
    std::cout << adjacencyList[100][1000] << std::endl;
  } catch (const std::exception &e) {
    std::cout << "try catch in c++??????" << std::endl;
  }

  return 0;
}
