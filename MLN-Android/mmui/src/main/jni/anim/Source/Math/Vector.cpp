/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#include "Vector.h"
#include <math.h>

ANIMATOR_NAMESPACE_BEGIN

ANIMATOR_INLINE AMTFloat SubRound(AMTFloat f, AMTFloat sub)
{
    return round(f * sub) / sub;
}

Vector::Vector(const size_t count)
{
  _count = count;
  _values = 0 != count ? (AMTFloat *)calloc(count, sizeof(AMTFloat)) : NULL;
}

Vector::Vector(const Vector& other)
{
  _count = other.size();
  _values = 0 != _count ? (AMTFloat *)calloc(_count, sizeof(AMTFloat)) : NULL;
  if (0 != _count) {
    memcpy(_values, other.data(), _count * sizeof(AMTFloat));
  }
}

Vector::~Vector()
{
  if (NULL != _values) {
    free(_values);
    _values = NULL;
  }
  _count = 0;
}

void Vector::swap(Vector &first, Vector &second)
{
  using std::swap;
  swap(first._count, second._count);
  swap(first._values, second._values);
}

Vector& Vector::operator=(const Vector& other)
{
  Vector temp(other);
  swap(*this, temp);
  return *this;
}

bool Vector::operator==(const Vector &other) const {
  if (_count != other.size()) {
    return false;
  }

  const AMTFloat * const values = other.data();

  for (size_t idx = 0; idx < _count; idx++) {
    if (_values[idx] != values[idx]) {
      return false;
    }
  }

  return true;
}

bool Vector::operator!=(const Vector &other) const {
  if (_count == other.size()) {
    return false;
  }

  const AMTFloat * const values = other.data();

  for (size_t idx = 0; idx < _count; idx++) {
    if (_values[idx] != values[idx]) {
      return false;
    }
  }

  return true;
}

Vector *Vector::new_vector(size_t count, const AMTFloat *values)
{
  if (0 == count) {
    return NULL;
  }

  Vector *v = new Vector(count);
  if (NULL != values) {
    memcpy(v->_values, values, count * sizeof(AMTFloat));
  }
  return v;
}

Vector *Vector::new_vector(const Vector * const other)
{
  if (NULL == other) {
    return NULL;
  }

  return Vector::new_vector(other->size(), other->data());
}

Vector *Vector::new_vector(size_t count, Vector4r vec)
{
  if (0 == count) {
    return NULL;
  }

  Vector *v = new Vector(count);

  ANIMATOR_ASSERT(count <= 4);
  for (size_t i = 0; i < fmin(count, (size_t)4); i++) {
    v->_values[i] = vec[i];
  }

  return v;
}

Vector4r Vector::vector4r() const
{
  Vector4r v = Vector4r::Zero();
  for (size_t i = 0; i < _count; i++) {
    v(i) = _values[i];
  }
  return v;
}

Vector2r Vector::vector2r() const
{
  Vector2r v = Vector2r::Zero();
  if (_count > 0) v(0) = _values[0];
  if (_count > 1) v(1) = _values[1];
  return v;
}

void Vector::subRound(AMTFloat sub)
{
  for (size_t idx = 0; idx < _count; idx++) {
    _values[idx] = SubRound(_values[idx], sub);
  }
}

AMTFloat Vector::norm() const
{
  return sqrtr(squaredNorm());
}

AMTFloat Vector::squaredNorm() const
{
  AMTFloat d = 0;
  for (size_t idx = 0; idx < _count; idx++) {
    d += (_values[idx] * _values[idx]);
  }
  return d;
}

ANIMATOR_NAMESPACE_END
