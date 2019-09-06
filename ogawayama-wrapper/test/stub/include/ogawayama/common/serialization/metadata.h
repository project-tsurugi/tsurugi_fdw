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
#ifndef METADATA_H_
#define METADATA_H_

#include "boost/serialization/serialization.hpp"
#include "boost/serialization/split_free.hpp"
#include "boost/serialization/string.hpp"

#include "ogawayama/stub/metadata.h"

using MetadataType = ogawayama::stub::Metadata;
using ColumnTypeType = ogawayama::stub::Metadata::ColumnType;
using ColumnTypeTypeType = ogawayama::stub::Metadata::ColumnType::Type;

namespace boost {
namespace serialization {

/**
 * @brief Method that does serialization dedicated for ogawayama::stub::Metadata
 * @param ar archiver
 * @param d variable in MetadataType
 * @param file_version not used
 */
template<class Archive>
inline void serialize(Archive & ar,                               
                      MetadataType & d,
                      const unsigned int file_version)
{
    split_free(ar, d, file_version);              
}

/**
 * @brief Function to save MetadataType objects using serialization lib
 * @param ar archiver
 * @param d variable in MetadataType
 * @param file_version not used
 */
template<class Archive>
inline void save(Archive & ar, 
          const MetadataType & d, 
          unsigned int version)
{
    auto index = d.get_types().size();

    ar & index;
    for( auto e: d.get_types() ) {
        auto t = static_cast<std::int32_t>(e.get_type());
        ar & t;
        ar & e.get_length();
    }
}

/**
 * @brief Function to load MetadataType objects using serialization lib
 * @param ar archiver
 * @param d variable in MetadataType
 * @param file_version not used
 */
template<class Archive>
inline void load(Archive & ar, 
          MetadataType & d, 
          unsigned int version)
{
    std::size_t index;
    ar & index;
    
    for (std::size_t i = 0; i < index; i++ ) {
        std::int32_t t;
        ar & t;
        std::int32_t l;
        ar & l;
        d.push(static_cast<ColumnTypeTypeType>(t), l);
    }        
}

} // namespace serialization
} // namespace boost

#endif  // METADATA_H_
