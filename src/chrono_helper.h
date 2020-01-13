#pragma once

#include <chrono>

template <class T>
double time_point_as_double(const T& time_point) {
  using float_seconds = std::chrono::duration<double>;
  return std::chrono::duration_cast<float_seconds>(
             time_point.time_since_epoch())
      .count();
}