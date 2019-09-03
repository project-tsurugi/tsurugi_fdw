/*
 * Copyright 2019-2019 tsurugi project.
 *
 * Licensed under the Apache License, Version 2.0 ( the "License" );
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
#ifndef SHARED_MEMORY_H_
#define SHARED_MEMORY_H_

#include <iostream>

namespace ogawayama::common {

struct param {

static constexpr std::size_t SEGMENT_SIZE = 100<<20; // 100 MiB ( tantative )

static constexpr std::size_t BUFFER_SIZE = 4096;     // 4K byte ( tantative )
static constexpr std::size_t MAX_NAME_LENGTH = 32;   // 64 chars ( tantative, but probably enough )

static constexpr std::size_t QUEUE_SIZE = 32;        // 32 rows ( tantative ) must be greater than or equal to 2

static constexpr char const * SHARED_MEMORY_NAME = "ogawayama";

static constexpr char const * server = "server";
static constexpr char const * request = "request";
static constexpr char const * result = "result";
static constexpr char const * resultset = "resultset";

};

/**
 * @brief Shared memory manager in charge of creation and destruction of a boost managed shared memory
 */
class SharedMemory
{
public:
    /**
     * @brief Construct a new object.
     */
     SharedMemory( std::string_view database_name, bool create_shm ) 
        : database_name_( database_name ), owner_( create_shm )  {    
        if ( create_shm ) {
            boost::interprocess::shared_memory_object::remove( database_name_.c_str() );
            managed_shared_memory_ = new boost::interprocess::managed_shared_memory( 
                boost::interprocess::create_only, database_name_.c_str(), param::SEGMENT_SIZE );
        } else {
            try {
                managed_shared_memory_ = new boost::interprocess::managed_shared_memory( 
                    boost::interprocess::open_only, database_name_.c_str() );
            }
            catch( const boost::interprocess::interprocess_exception& ex ) {
                std::cerr << "failed with exception \"" << ex.what() << "\"" << std::endl;
                exit( -1 );
            }
        }
    }
    SharedMemory( std::string_view database_name ) : SharedMemory( database_name, false ) {}
    /**
     * @brief Destruct this object.
     */
    ~SharedMemory()
    {
        if ( owner_ ) {
            boost::interprocess::shared_memory_object::remove( database_name_.c_str() );
        }
    }
    /**
     * @brief Return the boost shared memory manager.
     */
    auto get_managed_shared_memory_ptr() { return managed_shared_memory_; }

    std::string shm_name( char const *prefix, std::size_t i )
    {
        std::stringstream ss;
        ss << prefix << "-" << i;
        return ss.str();
    }

    std::string shm_name( char const *prefix, std::size_t i, std::size_t j )
    {
        std::stringstream ss;
        ss << prefix << "-" << i << "-" << j;
        return ss.str();
    }

private:
    boost::interprocess::managed_shared_memory *managed_shared_memory_;
    std::string database_name_;
    bool owner_;
};

};  // namespace ogawayama::common

#endif //  SHARED_MEMORY_H_
