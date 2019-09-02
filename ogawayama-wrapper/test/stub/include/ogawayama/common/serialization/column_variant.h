/*
 * Copyright 2019-2019 tsurugi project.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#ifndef COLUMN_VARIANT_H_
#define COLUMN_VARIANT_H_

#include <variant>
#include <string>
#include "boost/serialization/serialization.hpp"
#include "boost/serialization/split_free.hpp"
#include "boost/serialization/string.hpp"

#include "ogawayama/stub/api.h"

namespace boost {
namespace serialization {

using ColumnValueType = ogawayama::stub::ColumnValueType;

/**
 * @brief Method that does serialization dedicated for ogawayama::stub::ColumnValueType
 * @param ar archiver
 * @param d variable in ColumnValueType
 * @param file_version not used
 */
template<class Archive>
inline void serialize(Archive & ar,                               
                      ColumnValueType & d,
                      const unsigned int file_version)
{
    split_free(ar, d, file_version);              
}

/**
 * @brief Function to save ColumnValueType objects using serialization lib
 * @param ar archiver
 * @param d variable in ColumnValueType
 * @param file_version not used
 */
template<class Archive>
inline void save(Archive & ar, 
          const ColumnValueType & d, 
          unsigned int version)
{
    auto index = d.index();

    ar & index;
    std::visit([&](auto&& arg){ar & arg;}, d);
}


/**
 * @brief Helper Function for load
 * @param ar archiver
 * @param d variable in ColumnValueType
 */
template<class Archive, class T>
inline void load_for_type(Archive & ar, ColumnValueType &d)
{
    T v;
    
    ar & v;
    d = v;
}
/**
 * @brief Function to load ColumnValueType objects using serialization lib
 * @param ar archiver
 * @param d variable in ColumnValueType
 * @param file_version not used
 */
template<class Archive>
inline void load(Archive & ar, 
          ColumnValueType & d, 
          unsigned int version)
{
    std::size_t index;
    
    ar & index;

    switch(index) {
    case 0:
        break;
    case 1:
        load_for_type<Archive, std::int16_t>(ar, d);
        break;
    case 2:
        load_for_type<Archive, std::int32_t>(ar, d);
        break;
    case 3:
        load_for_type<Archive, std::int64_t>(ar, d);
        break;
    case 4:
        load_for_type<Archive, float>(ar, d);
        break;
    case 5:
        load_for_type<Archive, double>(ar, d);
        break;
    case 6:
        load_for_type<Archive, std::string>(ar, d);
        break;
    }
}

/**
 * @brief Method that does serialization for std::monostate, used in ColumnValueType
 * @param ar archiver
 * @param d variable in std::monostate
 * @param file_version not used
 */
template<class Archive>
inline void serialize(Archive & ar,                               
                      std::monostate & d,
                      const unsigned int file_version) {}

} // namespace serialization
} // namespace boost

#endif  // COLUMN_VARIANT_H_
