#ifndef VEC_DTYPES_CUH_
#define VEC_DTYPES_CUH_

#include <cuda_bf16.h>
#include <cuda_fp16.h>
#ifdef FLASHINFER_USE_FP8
#include <cuda_fp8.h>
#endif
#include <cuda_runtime.h>

#include <type_traits>

namespace flashinfer {

#define FLASHINFER_INLINE inline __attribute__((always_inline)) __device__ __host__

template <typename float_t, size_t vec_size>
struct vec_t {
  FLASHINFER_INLINE float_t &operator[](size_t i);
  FLASHINFER_INLINE const float_t &operator[](size_t i) const;
  FLASHINFER_INLINE void fill(float_t val);
  FLASHINFER_INLINE void load(const float_t *ptr);
  FLASHINFER_INLINE void store(float_t *ptr) const;
  template <typename T>
  FLASHINFER_INLINE void cast_from(const vec_t<T, vec_size> &src);
  template <typename T>
  FLASHINFER_INLINE void cast_load(const T *ptr);
  template <typename T>
  FLASHINFER_INLINE void cast_store(T *ptr) const;
  FLASHINFER_INLINE static void memcpy(float_t *dst, const float_t *src);
};

template <typename src_float_t, typename tgt_float_t, size_t vec_size>
FLASHINFER_INLINE void cast_from_impl(const vec_t<src_float_t, vec_size> &src,
                                      vec_t<tgt_float_t, vec_size> &dst) {
#pragma unroll
  for (size_t i = 0; i < vec_size; ++i) {
    dst[i] = tgt_float_t(src[i]);
  }
}

template <typename src_float_t, typename tgt_float_t, size_t vec_size>
FLASHINFER_INLINE void cast_load_impl(const src_float_t *src_ptr,
                                      vec_t<tgt_float_t, vec_size> &dst) {
  if constexpr (std::is_same<src_float_t, tgt_float_t>::value) {
    dst.load(src_ptr);
  } else {
    vec_t<src_float_t, vec_size> tmp;
    tmp.load(src_ptr);
    dst.cast_from(tmp);
  }
}

template <typename src_float_t, typename tgt_float_t, size_t vec_size>
FLASHINFER_INLINE void cast_store_impl(const vec_t<src_float_t, vec_size> &src,
                                       tgt_float_t *dst_ptr) {
  if constexpr (std::is_same<src_float_t, tgt_float_t>::value) {
    src.store(dst_ptr);
  } else {
    vec_t<tgt_float_t, vec_size> tmp;
    tmp.cast_from(src);
    tmp.store(dst_ptr);
  }
}

#ifdef FLASHINFER_USE_FP8
/******************* vec_t<__nv_fp8_e4m3> *******************/

// __nv_fp8_e4m3 x 1
template <>
struct vec_t<__nv_fp8_e4m3, 1> {
  __nv_fp8_e4m3 data;

  FLASHINFER_INLINE __nv_fp8_e4m3 &operator[](size_t i) { return ((__nv_fp8_e4m3 *)(&data))[i]; }
  FLASHINFER_INLINE const __nv_fp8_e4m3 &operator[](size_t i) const {
    return ((const __nv_fp8_e4m3 *)(&data))[i];
  }
  FLASHINFER_INLINE void fill(__nv_fp8_e4m3 val);
  FLASHINFER_INLINE void load(const __nv_fp8_e4m3 *ptr);
  FLASHINFER_INLINE void store(__nv_fp8_e4m3 *ptr) const;
  template <typename T>
  FLASHINFER_INLINE void cast_from(const vec_t<T, 1> &src) {
    cast_from_impl(src, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_load(const T *ptr) {
    cast_load_impl(ptr, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_store(T *ptr) const {
    cast_store_impl(*this, ptr);
  }

  FLASHINFER_INLINE static void memcpy(__nv_fp8_e4m3 *dst, const __nv_fp8_e4m3 *src);
};

FLASHINFER_INLINE void vec_t<__nv_fp8_e4m3, 1>::fill(__nv_fp8_e4m3 val) { data = val; }

FLASHINFER_INLINE void vec_t<__nv_fp8_e4m3, 1>::load(const __nv_fp8_e4m3 *ptr) { data = *ptr; }

FLASHINFER_INLINE void vec_t<__nv_fp8_e4m3, 1>::store(__nv_fp8_e4m3 *ptr) const { *ptr = data; }

FLASHINFER_INLINE void vec_t<__nv_fp8_e4m3, 1>::memcpy(__nv_fp8_e4m3 *dst,
                                                       const __nv_fp8_e4m3 *src) {
  *dst = *src;
}

// __nv_fp8_e4m3 x 2
template <>
struct vec_t<__nv_fp8_e4m3, 2> {
  __nv_fp8x2_e4m3 data;

  FLASHINFER_INLINE __nv_fp8_e4m3 &operator[](size_t i) { return ((__nv_fp8_e4m3 *)(&data))[i]; }
  FLASHINFER_INLINE const __nv_fp8_e4m3 &operator[](size_t i) const {
    return ((const __nv_fp8_e4m3 *)(&data))[i];
  }
  FLASHINFER_INLINE void fill(__nv_fp8_e4m3 val);
  FLASHINFER_INLINE void load(const __nv_fp8_e4m3 *ptr);
  FLASHINFER_INLINE void store(__nv_fp8_e4m3 *ptr) const;
  template <typename T>
  FLASHINFER_INLINE void cast_from(const vec_t<T, 2> &src) {
    cast_from_impl(src, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_load(const T *ptr) {
    cast_load_impl(ptr, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_store(T *ptr) const {
    cast_store_impl(*this, ptr);
  }

  FLASHINFER_INLINE static void memcpy(__nv_fp8_e4m3 *dst, const __nv_fp8_e4m3 *src);
};

FLASHINFER_INLINE void vec_t<__nv_fp8_e4m3, 2>::fill(__nv_fp8_e4m3 val) {
  data.__x = (__nv_fp8x2_storage_t(val.__x) << 8) | __nv_fp8x2_storage_t(val.__x);
}

FLASHINFER_INLINE void vec_t<__nv_fp8_e4m3, 2>::load(const __nv_fp8_e4m3 *ptr) {
  data = *((__nv_fp8x2_e4m3 *)ptr);
}

FLASHINFER_INLINE void vec_t<__nv_fp8_e4m3, 2>::store(__nv_fp8_e4m3 *ptr) const {
  *((__nv_fp8x2_e4m3 *)ptr) = data;
}

FLASHINFER_INLINE void vec_t<__nv_fp8_e4m3, 2>::memcpy(__nv_fp8_e4m3 *dst,
                                                       const __nv_fp8_e4m3 *src) {
  *((__nv_fp8x2_e4m3 *)dst) = *((__nv_fp8x2_e4m3 *)src);
}

// __nv_fp8_e4m3 x 4

template <>
struct vec_t<__nv_fp8_e4m3, 4> {
  __nv_fp8x4_e4m3 data;

  FLASHINFER_INLINE __nv_fp8_e4m3 &operator[](size_t i) { return ((__nv_fp8_e4m3 *)(&data))[i]; }
  FLASHINFER_INLINE const __nv_fp8_e4m3 &operator[](size_t i) const {
    return ((const __nv_fp8_e4m3 *)(&data))[i];
  }
  FLASHINFER_INLINE void fill(__nv_fp8_e4m3 val);
  FLASHINFER_INLINE void load(const __nv_fp8_e4m3 *ptr);
  FLASHINFER_INLINE void store(__nv_fp8_e4m3 *ptr) const;
  template <typename T>
  FLASHINFER_INLINE void cast_from(const vec_t<T, 4> &src) {
    cast_from_impl(src, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_load(const T *ptr) {
    cast_load_impl(ptr, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_store(T *ptr) const {
    cast_store_impl(*this, ptr);
  }

  FLASHINFER_INLINE static void memcpy(__nv_fp8_e4m3 *dst, const __nv_fp8_e4m3 *src);
};

FLASHINFER_INLINE void vec_t<__nv_fp8_e4m3, 4>::fill(__nv_fp8_e4m3 val) {
  data.__x = (__nv_fp8x4_storage_t(val.__x) << 24) | (__nv_fp8x4_storage_t(val.__x) << 16) |
             (__nv_fp8x4_storage_t(val.__x) << 8) | __nv_fp8x4_storage_t(val.__x);
}

FLASHINFER_INLINE void vec_t<__nv_fp8_e4m3, 4>::load(const __nv_fp8_e4m3 *ptr) {
  data = *((__nv_fp8x4_e4m3 *)ptr);
}

FLASHINFER_INLINE void vec_t<__nv_fp8_e4m3, 4>::store(__nv_fp8_e4m3 *ptr) const {
  *((__nv_fp8x4_e4m3 *)ptr) = data;
}

FLASHINFER_INLINE void vec_t<__nv_fp8_e4m3, 4>::memcpy(__nv_fp8_e4m3 *dst,
                                                       const __nv_fp8_e4m3 *src) {
  *((__nv_fp8x4_e4m3 *)dst) = *((__nv_fp8x4_e4m3 *)src);
}

// __nv_fp8_e4m3 x 8

template <>
struct vec_t<__nv_fp8_e4m3, 8> {
  uint2 data;

  FLASHINFER_INLINE __nv_fp8_e4m3 &operator[](size_t i) { return ((__nv_fp8_e4m3 *)(&data))[i]; }
  FLASHINFER_INLINE const __nv_fp8_e4m3 &operator[](size_t i) const {
    return ((const __nv_fp8_e4m3 *)(&data))[i];
  }
  FLASHINFER_INLINE void fill(__nv_fp8_e4m3 val);
  FLASHINFER_INLINE void load(const __nv_fp8_e4m3 *ptr);
  FLASHINFER_INLINE void store(__nv_fp8_e4m3 *ptr) const;
  template <typename T>
  FLASHINFER_INLINE void cast_from(const vec_t<T, 8> &src) {
    cast_from_impl(src, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_load(const T *ptr) {
    cast_load_impl(ptr, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_store(T *ptr) const {
    cast_store_impl(*this, ptr);
  }

  FLASHINFER_INLINE static void memcpy(__nv_fp8_e4m3 *dst, const __nv_fp8_e4m3 *src);
};

FLASHINFER_INLINE void vec_t<__nv_fp8_e4m3, 8>::fill(__nv_fp8_e4m3 val) {
  ((__nv_fp8x4_e4m3 *)(&data.x))->__x =
      (__nv_fp8x4_storage_t(val.__x) << 24) | (__nv_fp8x4_storage_t(val.__x) << 16) |
      (__nv_fp8x4_storage_t(val.__x) << 8) | __nv_fp8x4_storage_t(val.__x);
  ((__nv_fp8x4_e4m3 *)(&data.y))->__x =
      (__nv_fp8x4_storage_t(val.__x) << 24) | (__nv_fp8x4_storage_t(val.__x) << 16) |
      (__nv_fp8x4_storage_t(val.__x) << 8) | __nv_fp8x4_storage_t(val.__x);
}

FLASHINFER_INLINE void vec_t<__nv_fp8_e4m3, 8>::load(const __nv_fp8_e4m3 *ptr) {
  data = *((uint2 *)ptr);
}

FLASHINFER_INLINE void vec_t<__nv_fp8_e4m3, 8>::store(__nv_fp8_e4m3 *ptr) const {
  *((uint2 *)ptr) = data;
}

FLASHINFER_INLINE void vec_t<__nv_fp8_e4m3, 8>::memcpy(__nv_fp8_e4m3 *dst,
                                                       const __nv_fp8_e4m3 *src) {
  *((__nv_fp8_e4m3 *)dst) = *((__nv_fp8_e4m3 *)src);
}

/******************* vec_t<__nv_fp8_e5m2> *******************/

// __nv_fp8_e5m2 x 1
template <>
struct vec_t<__nv_fp8_e5m2, 1> {
  __nv_fp8_e5m2 data;

  FLASHINFER_INLINE __nv_fp8_e5m2 &operator[](size_t i) { return ((__nv_fp8_e5m2 *)(&data))[i]; }
  FLASHINFER_INLINE const __nv_fp8_e5m2 &operator[](size_t i) const {
    return ((const __nv_fp8_e5m2 *)(&data))[i];
  }
  FLASHINFER_INLINE void fill(__nv_fp8_e5m2 val);
  FLASHINFER_INLINE void load(const __nv_fp8_e5m2 *ptr);
  FLASHINFER_INLINE void store(__nv_fp8_e5m2 *ptr) const;
  template <typename T>
  FLASHINFER_INLINE void cast_from(const vec_t<T, 1> &src) {
    cast_from_impl(src, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_load(const T *ptr) {
    cast_load_impl(ptr, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_store(T *ptr) const {
    cast_store_impl(*this, ptr);
  }

  FLASHINFER_INLINE static void memcpy(__nv_fp8_e5m2 *dst, const __nv_fp8_e5m2 *src);
};

FLASHINFER_INLINE void vec_t<__nv_fp8_e5m2, 1>::fill(__nv_fp8_e5m2 val) { data = val; }

FLASHINFER_INLINE void vec_t<__nv_fp8_e5m2, 1>::load(const __nv_fp8_e5m2 *ptr) { data = *ptr; }

FLASHINFER_INLINE void vec_t<__nv_fp8_e5m2, 1>::store(__nv_fp8_e5m2 *ptr) const { *ptr = data; }

FLASHINFER_INLINE void vec_t<__nv_fp8_e5m2, 1>::memcpy(__nv_fp8_e5m2 *dst,
                                                       const __nv_fp8_e5m2 *src) {
  *dst = *src;
}

// __nv_fp8_e5m2 x 2
template <>
struct vec_t<__nv_fp8_e5m2, 2> {
  __nv_fp8x2_e5m2 data;

  FLASHINFER_INLINE __nv_fp8_e5m2 &operator[](size_t i) { return ((__nv_fp8_e5m2 *)(&data))[i]; }
  FLASHINFER_INLINE const __nv_fp8_e5m2 &operator[](size_t i) const {
    return ((const __nv_fp8_e5m2 *)(&data))[i];
  }
  FLASHINFER_INLINE void fill(__nv_fp8_e5m2 val);
  FLASHINFER_INLINE void load(const __nv_fp8_e5m2 *ptr);
  FLASHINFER_INLINE void store(__nv_fp8_e5m2 *ptr) const;
  template <typename T>
  FLASHINFER_INLINE void cast_from(const vec_t<T, 2> &src) {
    cast_from_impl(src, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_load(const T *ptr) {
    cast_load_impl(ptr, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_store(T *ptr) const {
    cast_store_impl(*this, ptr);
  }

  FLASHINFER_INLINE static void memcpy(__nv_fp8_e5m2 *dst, const __nv_fp8_e5m2 *src);
};

FLASHINFER_INLINE void vec_t<__nv_fp8_e5m2, 2>::fill(__nv_fp8_e5m2 val) {
  data.__x = (__nv_fp8x2_storage_t(val.__x) << 8) | __nv_fp8x2_storage_t(val.__x);
}

FLASHINFER_INLINE void vec_t<__nv_fp8_e5m2, 2>::load(const __nv_fp8_e5m2 *ptr) {
  data = *((__nv_fp8x2_e5m2 *)ptr);
}

FLASHINFER_INLINE void vec_t<__nv_fp8_e5m2, 2>::store(__nv_fp8_e5m2 *ptr) const {
  *((__nv_fp8x2_e5m2 *)ptr) = data;
}

FLASHINFER_INLINE void vec_t<__nv_fp8_e5m2, 2>::memcpy(__nv_fp8_e5m2 *dst,
                                                       const __nv_fp8_e5m2 *src) {
  *((__nv_fp8x2_e5m2 *)dst) = *((__nv_fp8x2_e5m2 *)src);
}

// __nv_fp8_e5m2 x 4

template <>
struct vec_t<__nv_fp8_e5m2, 4> {
  __nv_fp8x4_e5m2 data;

  FLASHINFER_INLINE __nv_fp8_e5m2 &operator[](size_t i) { return ((__nv_fp8_e5m2 *)(&data))[i]; }
  FLASHINFER_INLINE const __nv_fp8_e5m2 &operator[](size_t i) const {
    return ((const __nv_fp8_e5m2 *)(&data))[i];
  }
  FLASHINFER_INLINE void fill(__nv_fp8_e5m2 val);
  FLASHINFER_INLINE void load(const __nv_fp8_e5m2 *ptr);
  FLASHINFER_INLINE void store(__nv_fp8_e5m2 *ptr) const;
  template <typename T>
  FLASHINFER_INLINE void cast_from(const vec_t<T, 4> &src) {
    cast_from_impl(src, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_load(const T *ptr) {
    cast_load_impl(ptr, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_store(T *ptr) const {
    cast_store_impl(*this, ptr);
  }

  FLASHINFER_INLINE static void memcpy(__nv_fp8_e5m2 *dst, const __nv_fp8_e5m2 *src);
};

FLASHINFER_INLINE void vec_t<__nv_fp8_e5m2, 4>::fill(__nv_fp8_e5m2 val) {
  data.__x = (__nv_fp8x4_storage_t(val.__x) << 24) | (__nv_fp8x4_storage_t(val.__x) << 16) |
             (__nv_fp8x4_storage_t(val.__x) << 8) | __nv_fp8x4_storage_t(val.__x);
}

FLASHINFER_INLINE void vec_t<__nv_fp8_e5m2, 4>::load(const __nv_fp8_e5m2 *ptr) {
  data = *((__nv_fp8x4_e5m2 *)ptr);
}

FLASHINFER_INLINE void vec_t<__nv_fp8_e5m2, 4>::store(__nv_fp8_e5m2 *ptr) const {
  *((__nv_fp8x4_e5m2 *)ptr) = data;
}

FLASHINFER_INLINE void vec_t<__nv_fp8_e5m2, 4>::memcpy(__nv_fp8_e5m2 *dst,
                                                       const __nv_fp8_e5m2 *src) {
  *((__nv_fp8x4_e5m2 *)dst) = *((__nv_fp8x4_e5m2 *)src);
}

// __nv_fp8_e5m2 x 8

template <>
struct vec_t<__nv_fp8_e5m2, 8> {
  uint2 data;

  FLASHINFER_INLINE __nv_fp8_e5m2 &operator[](size_t i) { return ((__nv_fp8_e5m2 *)(&data))[i]; }
  FLASHINFER_INLINE const __nv_fp8_e5m2 &operator[](size_t i) const {
    return ((const __nv_fp8_e5m2 *)(&data))[i];
  }
  FLASHINFER_INLINE void fill(__nv_fp8_e5m2 val);
  FLASHINFER_INLINE void load(const __nv_fp8_e5m2 *ptr);
  FLASHINFER_INLINE void store(__nv_fp8_e5m2 *ptr) const;
  template <typename T>
  FLASHINFER_INLINE void cast_from(const vec_t<T, 8> &src) {
    cast_from_impl(src, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_load(const T *ptr) {
    cast_load_impl(ptr, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_store(T *ptr) const {
    cast_store_impl(*this, ptr);
  }

  FLASHINFER_INLINE static void memcpy(__nv_fp8_e5m2 *dst, const __nv_fp8_e5m2 *src);
};

FLASHINFER_INLINE void vec_t<__nv_fp8_e5m2, 8>::fill(__nv_fp8_e5m2 val) {
  ((__nv_fp8x4_e5m2 *)(&data.x))->__x =
      (__nv_fp8x4_storage_t(val.__x) << 24) | (__nv_fp8x4_storage_t(val.__x) << 16) |
      (__nv_fp8x4_storage_t(val.__x) << 8) | __nv_fp8x4_storage_t(val.__x);
  ((__nv_fp8x4_e5m2 *)(&data.y))->__x =
      (__nv_fp8x4_storage_t(val.__x) << 24) | (__nv_fp8x4_storage_t(val.__x) << 16) |
      (__nv_fp8x4_storage_t(val.__x) << 8) | __nv_fp8x4_storage_t(val.__x);
}

FLASHINFER_INLINE void vec_t<__nv_fp8_e5m2, 8>::load(const __nv_fp8_e5m2 *ptr) {
  data = *((uint2 *)ptr);
}

FLASHINFER_INLINE void vec_t<__nv_fp8_e5m2, 8>::store(__nv_fp8_e5m2 *ptr) const {
  *((uint2 *)ptr) = data;
}

FLASHINFER_INLINE void vec_t<__nv_fp8_e5m2, 8>::memcpy(__nv_fp8_e5m2 *dst,
                                                       const __nv_fp8_e5m2 *src) {
  *((__nv_fp8_e5m2 *)dst) = *((__nv_fp8_e5m2 *)src);
}

#endif

/******************* vec_t<half> *******************/

// half x 1
template <>
struct vec_t<half, 1> {
  half data;

  FLASHINFER_INLINE half &operator[](size_t i) { return ((half *)(&data))[i]; }
  FLASHINFER_INLINE const half &operator[](size_t i) const { return ((const half *)(&data))[i]; }
  FLASHINFER_INLINE void fill(half val);
  FLASHINFER_INLINE void load(const half *ptr);
  FLASHINFER_INLINE void store(half *ptr) const;
  template <typename T>
  FLASHINFER_INLINE void cast_from(const vec_t<T, 1> &src) {
    cast_from_impl(src, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_load(const T *ptr) {
    cast_load_impl(ptr, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_store(T *ptr) const {
    cast_store_impl(*this, ptr);
  }

  FLASHINFER_INLINE static void memcpy(half *dst, const half *src);
};

FLASHINFER_INLINE void vec_t<half, 1>::fill(half val) { data = val; }

FLASHINFER_INLINE void vec_t<half, 1>::load(const half *ptr) { data = *ptr; }

FLASHINFER_INLINE void vec_t<half, 1>::store(half *ptr) const { *ptr = data; }

FLASHINFER_INLINE void vec_t<half, 1>::memcpy(half *dst, const half *src) { *dst = *src; }

// half x 2
template <>
struct vec_t<half, 2> {
  half2 data;

  FLASHINFER_INLINE half &operator[](size_t i) { return ((half *)(&data))[i]; }
  FLASHINFER_INLINE const half &operator[](size_t i) const { return ((const half *)(&data))[i]; }
  FLASHINFER_INLINE void fill(half val);
  FLASHINFER_INLINE void load(const half *ptr);
  FLASHINFER_INLINE void store(half *ptr) const;
  template <typename T>
  FLASHINFER_INLINE void cast_from(const vec_t<T, 2> &src) {
    cast_from_impl(src, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_load(const T *ptr) {
    cast_load_impl(ptr, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_store(T *ptr) const {
    cast_store_impl(*this, ptr);
  }

  FLASHINFER_INLINE static void memcpy(half *dst, const half *src);
};

FLASHINFER_INLINE void vec_t<half, 2>::fill(half val) { data = make_half2(val, val); }

FLASHINFER_INLINE void vec_t<half, 2>::load(const half *ptr) { data = *((half2 *)ptr); }

FLASHINFER_INLINE void vec_t<half, 2>::store(half *ptr) const { *((half2 *)ptr) = data; }

FLASHINFER_INLINE void vec_t<half, 2>::memcpy(half *dst, const half *src) {
  *((half2 *)dst) = *((half2 *)src);
}

// half x 4

template <>
struct vec_t<half, 4> {
  uint2 data;

  FLASHINFER_INLINE half &operator[](size_t i) { return ((half *)(&data))[i]; }
  FLASHINFER_INLINE const half &operator[](size_t i) const { return ((const half *)(&data))[i]; }
  FLASHINFER_INLINE void fill(half val);
  FLASHINFER_INLINE void load(const half *ptr);
  FLASHINFER_INLINE void store(half *ptr) const;
  template <typename T>
  FLASHINFER_INLINE void cast_from(const vec_t<T, 4> &src) {
    cast_from_impl(src, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_load(const T *ptr) {
    cast_load_impl(ptr, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_store(T *ptr) const {
    cast_store_impl(*this, ptr);
  }

  FLASHINFER_INLINE static void memcpy(half *dst, const half *src);
};

FLASHINFER_INLINE void vec_t<half, 4>::fill(half val) {
  *(half2 *)(&data.x) = make_half2(val, val);
  *(half2 *)(&data.y) = make_half2(val, val);
}

FLASHINFER_INLINE void vec_t<half, 4>::load(const half *ptr) { data = *((uint2 *)ptr); }

FLASHINFER_INLINE void vec_t<half, 4>::store(half *ptr) const { *((uint2 *)ptr) = data; }

FLASHINFER_INLINE void vec_t<half, 4>::memcpy(half *dst, const half *src) {
  *((uint2 *)dst) = *((uint2 *)src);
}

// half x 8

template <>
struct vec_t<half, 8> {
  uint4 data;

  FLASHINFER_INLINE half &operator[](size_t i) { return ((half *)(&data))[i]; }
  FLASHINFER_INLINE const half &operator[](size_t i) const { return ((const half *)(&data))[i]; }
  FLASHINFER_INLINE void fill(half val);
  FLASHINFER_INLINE void load(const half *ptr);
  FLASHINFER_INLINE void store(half *ptr) const;
  template <typename T>
  FLASHINFER_INLINE void cast_from(const vec_t<T, 8> &src) {
    cast_from_impl(src, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_load(const T *ptr) {
    cast_load_impl(ptr, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_store(T *ptr) const {
    cast_store_impl(*this, ptr);
  }

  FLASHINFER_INLINE static void memcpy(half *dst, const half *src);
};

FLASHINFER_INLINE void vec_t<half, 8>::fill(half val) {
  *(half2 *)(&data.x) = make_half2(val, val);
  *(half2 *)(&data.y) = make_half2(val, val);
  *(half2 *)(&data.z) = make_half2(val, val);
  *(half2 *)(&data.w) = make_half2(val, val);
}

FLASHINFER_INLINE void vec_t<half, 8>::load(const half *ptr) { data = *((uint4 *)ptr); }

FLASHINFER_INLINE void vec_t<half, 8>::store(half *ptr) const { *((uint4 *)ptr) = data; }

FLASHINFER_INLINE void vec_t<half, 8>::memcpy(half *dst, const half *src) {
  *((uint4 *)dst) = *((uint4 *)src);
}

/******************* vec_t<nv_bfloat16> *******************/

// nv_bfloat16 x 1
template <>
struct vec_t<nv_bfloat16, 1> {
  nv_bfloat16 data;

  FLASHINFER_INLINE nv_bfloat16 &operator[](size_t i) { return ((nv_bfloat16 *)(&data))[i]; }
  FLASHINFER_INLINE const nv_bfloat16 &operator[](size_t i) const {
    return ((const nv_bfloat16 *)(&data))[i];
  }
  FLASHINFER_INLINE void fill(nv_bfloat16 val);
  FLASHINFER_INLINE void load(const nv_bfloat16 *ptr);
  FLASHINFER_INLINE void store(nv_bfloat16 *ptr) const;
  template <typename T>
  FLASHINFER_INLINE void cast_from(const vec_t<T, 1> &src) {
    cast_from_impl(src, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_load(const T *ptr) {
    cast_load_impl(ptr, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_store(T *ptr) const {
    cast_store_impl(*this, ptr);
  }

  FLASHINFER_INLINE static void memcpy(nv_bfloat16 *dst, const nv_bfloat16 *src);
};

FLASHINFER_INLINE void vec_t<nv_bfloat16, 1>::fill(nv_bfloat16 val) { data = val; }

FLASHINFER_INLINE void vec_t<nv_bfloat16, 1>::load(const nv_bfloat16 *ptr) { data = *ptr; }

FLASHINFER_INLINE void vec_t<nv_bfloat16, 1>::store(nv_bfloat16 *ptr) const { *ptr = data; }

FLASHINFER_INLINE void vec_t<nv_bfloat16, 1>::memcpy(nv_bfloat16 *dst, const nv_bfloat16 *src) {
  *dst = *src;
}

// nv_bfloat16 x 2
template <>
struct vec_t<nv_bfloat16, 2> {
  nv_bfloat162 data;

  FLASHINFER_INLINE nv_bfloat16 &operator[](size_t i) { return ((nv_bfloat16 *)(&data))[i]; }
  FLASHINFER_INLINE const nv_bfloat16 &operator[](size_t i) const {
    return ((const nv_bfloat16 *)(&data))[i];
  }
  FLASHINFER_INLINE void fill(nv_bfloat16 val);
  FLASHINFER_INLINE void load(const nv_bfloat16 *ptr);
  FLASHINFER_INLINE void store(nv_bfloat16 *ptr) const;
  template <typename T>
  FLASHINFER_INLINE void cast_from(const vec_t<T, 2> &src) {
    cast_from_impl(src, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_load(const T *ptr) {
    cast_load_impl(ptr, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_store(T *ptr) const {
    cast_store_impl(*this, ptr);
  }

  FLASHINFER_INLINE static void memcpy(nv_bfloat16 *dst, const nv_bfloat16 *src);
};

FLASHINFER_INLINE void vec_t<nv_bfloat16, 2>::fill(nv_bfloat16 val) {
  data = make_bfloat162(val, val);
}

FLASHINFER_INLINE void vec_t<nv_bfloat16, 2>::load(const nv_bfloat16 *ptr) {
  data = *((nv_bfloat162 *)ptr);
}

FLASHINFER_INLINE void vec_t<nv_bfloat16, 2>::store(nv_bfloat16 *ptr) const {
  *((nv_bfloat162 *)ptr) = data;
}

FLASHINFER_INLINE void vec_t<nv_bfloat16, 2>::memcpy(nv_bfloat16 *dst, const nv_bfloat16 *src) {
  *((nv_bfloat162 *)dst) = *((nv_bfloat162 *)src);
}

// nv_bfloat16 x 4

template <>
struct vec_t<nv_bfloat16, 4> {
  uint2 data;

  FLASHINFER_INLINE nv_bfloat16 &operator[](size_t i) { return ((nv_bfloat16 *)(&data))[i]; }
  FLASHINFER_INLINE const nv_bfloat16 &operator[](size_t i) const {
    return ((const nv_bfloat16 *)(&data))[i];
  }
  FLASHINFER_INLINE void fill(nv_bfloat16 val);
  FLASHINFER_INLINE void load(const nv_bfloat16 *ptr);
  FLASHINFER_INLINE void store(nv_bfloat16 *ptr) const;
  template <typename T>
  FLASHINFER_INLINE void cast_from(const vec_t<T, 4> &src) {
    cast_from_impl(src, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_load(const T *ptr) {
    cast_load_impl(ptr, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_store(T *ptr) const {
    cast_store_impl(*this, ptr);
  }

  FLASHINFER_INLINE static void memcpy(nv_bfloat16 *dst, const nv_bfloat16 *src);
};

FLASHINFER_INLINE void vec_t<nv_bfloat16, 4>::fill(nv_bfloat16 val) {
  *(nv_bfloat162 *)(&data.x) = make_bfloat162(val, val);
  *(nv_bfloat162 *)(&data.y) = make_bfloat162(val, val);
}

FLASHINFER_INLINE void vec_t<nv_bfloat16, 4>::load(const nv_bfloat16 *ptr) {
  data = *((uint2 *)ptr);
}

FLASHINFER_INLINE void vec_t<nv_bfloat16, 4>::store(nv_bfloat16 *ptr) const {
  *((uint2 *)ptr) = data;
}

FLASHINFER_INLINE void vec_t<nv_bfloat16, 4>::memcpy(nv_bfloat16 *dst, const nv_bfloat16 *src) {
  *((uint2 *)dst) = *((uint2 *)src);
}

// nv_bfloat16 x 8

template <>
struct vec_t<nv_bfloat16, 8> {
  uint4 data;

  FLASHINFER_INLINE nv_bfloat16 &operator[](size_t i) { return ((nv_bfloat16 *)(&data))[i]; }
  FLASHINFER_INLINE const nv_bfloat16 &operator[](size_t i) const {
    return ((const nv_bfloat16 *)(&data))[i];
  }
  FLASHINFER_INLINE void fill(nv_bfloat16 val);
  FLASHINFER_INLINE void load(const nv_bfloat16 *ptr);
  FLASHINFER_INLINE void store(nv_bfloat16 *ptr) const;
  template <typename T>
  FLASHINFER_INLINE void cast_from(const vec_t<T, 8> &src) {
    cast_from_impl(src, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_load(const T *ptr) {
    cast_load_impl(ptr, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_store(T *ptr) const {
    cast_store_impl(*this, ptr);
  }

  FLASHINFER_INLINE static void memcpy(nv_bfloat16 *dst, const nv_bfloat16 *src);
};

FLASHINFER_INLINE void vec_t<nv_bfloat16, 8>::fill(nv_bfloat16 val) {
  *(nv_bfloat162 *)(&data.x) = make_bfloat162(val, val);
  *(nv_bfloat162 *)(&data.y) = make_bfloat162(val, val);
  *(nv_bfloat162 *)(&data.z) = make_bfloat162(val, val);
  *(nv_bfloat162 *)(&data.w) = make_bfloat162(val, val);
}

FLASHINFER_INLINE void vec_t<nv_bfloat16, 8>::load(const nv_bfloat16 *ptr) {
  data = *((uint4 *)ptr);
}

FLASHINFER_INLINE void vec_t<nv_bfloat16, 8>::store(nv_bfloat16 *ptr) const {
  *((uint4 *)ptr) = data;
}

FLASHINFER_INLINE void vec_t<nv_bfloat16, 8>::memcpy(nv_bfloat16 *dst, const nv_bfloat16 *src) {
  *((uint4 *)dst) = *((uint4 *)src);
}

/******************* vec_t<float> *******************/

// float x 1

template <>
struct vec_t<float, 1> {
  float data;

  FLASHINFER_INLINE float &operator[](size_t i) { return ((float *)(&data))[i]; }
  FLASHINFER_INLINE const float &operator[](size_t i) const { return ((const float *)(&data))[i]; }
  FLASHINFER_INLINE void fill(float val);
  FLASHINFER_INLINE void load(const float *ptr);
  FLASHINFER_INLINE void store(float *ptr) const;
  template <typename T>
  FLASHINFER_INLINE void cast_from(const vec_t<T, 1> &src) {
    cast_from_impl(src, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_load(const T *ptr) {
    cast_load_impl(ptr, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_store(T *ptr) const {
    cast_store_impl(*this, ptr);
  }

  FLASHINFER_INLINE static void memcpy(float *dst, const float *src);
};

FLASHINFER_INLINE void vec_t<float, 1>::fill(float val) { data = val; }

FLASHINFER_INLINE void vec_t<float, 1>::load(const float *ptr) { data = *ptr; }

FLASHINFER_INLINE void vec_t<float, 1>::store(float *ptr) const { *ptr = data; }

FLASHINFER_INLINE void vec_t<float, 1>::memcpy(float *dst, const float *src) { *dst = *src; }

// float x 2

template <>
struct vec_t<float, 2> {
  float2 data;

  FLASHINFER_INLINE float &operator[](size_t i) { return ((float *)(&data))[i]; }
  FLASHINFER_INLINE const float &operator[](size_t i) const { return ((const float *)(&data))[i]; }
  FLASHINFER_INLINE void fill(float val);
  FLASHINFER_INLINE void load(const float *ptr);
  FLASHINFER_INLINE void store(float *ptr) const;
  template <typename T>
  FLASHINFER_INLINE void cast_from(const vec_t<T, 2> &src) {
    cast_from_impl(src, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_load(const T *ptr) {
    cast_load_impl(ptr, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_store(T *ptr) const {
    cast_store_impl(*this, ptr);
  }
  FLASHINFER_INLINE static void memcpy(float *dst, const float *src);
};

FLASHINFER_INLINE void vec_t<float, 2>::fill(float val) { data = make_float2(val, val); }

FLASHINFER_INLINE void vec_t<float, 2>::load(const float *ptr) { data = *((float2 *)ptr); }

FLASHINFER_INLINE void vec_t<float, 2>::store(float *ptr) const { *((float2 *)ptr) = data; }

FLASHINFER_INLINE void vec_t<float, 2>::memcpy(float *dst, const float *src) {
  *((float2 *)dst) = *((float2 *)src);
}

// float x 4

template <>
struct vec_t<float, 4> {
  float4 data;

  FLASHINFER_INLINE float &operator[](size_t i) { return ((float *)(&data))[i]; }
  FLASHINFER_INLINE const float &operator[](size_t i) const { return ((const float *)(&data))[i]; }
  FLASHINFER_INLINE void fill(float val);
  FLASHINFER_INLINE void load(const float *ptr);
  FLASHINFER_INLINE void store(float *ptr) const;
  template <typename T>
  FLASHINFER_INLINE void cast_from(const vec_t<T, 4> &src) {
    cast_from_impl(src, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_load(const T *ptr) {
    cast_load_impl(ptr, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_store(T *ptr) const {
    cast_store_impl(*this, ptr);
  }
  FLASHINFER_INLINE static void memcpy(float *dst, const float *src);
};

FLASHINFER_INLINE void vec_t<float, 4>::fill(float val) { data = make_float4(val, val, val, val); }

FLASHINFER_INLINE void vec_t<float, 4>::load(const float *ptr) { data = *((float4 *)ptr); }

FLASHINFER_INLINE void vec_t<float, 4>::store(float *ptr) const { *((float4 *)ptr) = data; }

FLASHINFER_INLINE void vec_t<float, 4>::memcpy(float *dst, const float *src) {
  *((float4 *)dst) = *((float4 *)src);
}

template <>
struct vec_t<float, 8> {
  ulonglong4 data;

  FLASHINFER_INLINE float &operator[](size_t i) { return ((float *)(&data))[i]; }
  FLASHINFER_INLINE const float &operator[](size_t i) const { return ((const float *)(&data))[i]; }
  FLASHINFER_INLINE void fill(float val);
  FLASHINFER_INLINE void load(const float *ptr);
  FLASHINFER_INLINE void store(float *ptr) const;
  template <typename T>
  FLASHINFER_INLINE void cast_from(const vec_t<T, 8> &src) {
    cast_from_impl(src, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_load(const T *ptr) {
    cast_load_impl(ptr, *this);
  }
  template <typename T>
  FLASHINFER_INLINE void cast_store(T *ptr) const {
    cast_store_impl(*this, ptr);
  }
  FLASHINFER_INLINE static void memcpy(float *dst, const float *src);
};

FLASHINFER_INLINE void vec_t<float, 8>::fill(float val) {
  *(float2 *)(&data.x) = make_float2(val, val);
  *(float2 *)(&data.y) = make_float2(val, val);
  *(float2 *)(&data.z) = make_float2(val, val);
  *(float2 *)(&data.w) = make_float2(val, val);
}

FLASHINFER_INLINE void vec_t<float, 8>::load(const float *ptr) { data = *((ulonglong4 *)ptr); }

FLASHINFER_INLINE void vec_t<float, 8>::store(float *ptr) const { *((ulonglong4 *)ptr) = data; }

FLASHINFER_INLINE void vec_t<float, 8>::memcpy(float *dst, const float *src) {
  *((ulonglong4 *)dst) = *((ulonglong4 *)src);
}

/******************* vec_t type cast *******************/

template <size_t vec_size>
FLASHINFER_INLINE void cast_from_impl(const vec_t<half, vec_size> &src,
                                      vec_t<float, vec_size> &dst) {
  if constexpr (vec_size == 1) {
    dst.data = float(src.data);
  } else {
#pragma unroll
    for (size_t i = 0; i < vec_size / 2; ++i) {
      ((float2 *)(&dst.data))[i] = __half22float2(((half2 *)(&src.data))[i]);
    }
  }
}

template <size_t vec_size>
FLASHINFER_INLINE void cast_from_impl(const vec_t<float, vec_size> &src,
                                      vec_t<half, vec_size> &dst) {
  if constexpr (vec_size == 1) {
    dst.data = half(src.data);
  } else {
#pragma unroll
    for (size_t i = 0; i < vec_size / 2; ++i) {
      ((half2 *)(&dst.data))[i] = __float22half2_rn(((float2 *)(&src.data))[i]);
    }
  }
}

template <size_t vec_size>
FLASHINFER_INLINE void cast_from_impl(const vec_t<nv_bfloat16, vec_size> &src,
                                      vec_t<float, vec_size> &dst) {
  if constexpr (vec_size == 1) {
    dst.data = float(src.data);
  } else {
#pragma unroll
    for (size_t i = 0; i < vec_size / 2; ++i) {
      ((float2 *)(&dst.data))[i] = __bfloat1622float2(((nv_bfloat162 *)(&src.data))[i]);
    }
  }
}

template <size_t vec_size>
FLASHINFER_INLINE void cast_from_impl(const vec_t<float, vec_size> &src,
                                      vec_t<nv_bfloat16, vec_size> &dst) {
  if constexpr (vec_size == 1) {
    dst.data = nv_bfloat16(src.data);
  } else {
#pragma unroll
    for (size_t i = 0; i < vec_size / 2; ++i) {
      ((nv_bfloat162 *)(&dst.data))[i] = __float22bfloat162_rn(((float2 *)(&src.data))[i]);
    }
  }
}

}  // namespace flashinfer

#endif  // VEC_DTYPES_CUH_