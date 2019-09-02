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

#include "result_setImpl.h"
#include "ogawayama/common/row_queue.h"

namespace ogawayama::stub {

// ========================================================================
// ResultSet::Impl
// ========================================================================

ResultSet::Impl::Impl( ResultSet *result_set, std::size_t id ) 
    : envelope_( result_set ), id_( id ), c_idx_( 0 )
{
    
}
    
/**
 * @brief get metadata for the result set.
 * @param metadata returns the metadata class
 * @return error code defined in error_code.h
 */
ErrorCode ResultSet::Impl::get_metadata( MetadataPtr &metadata )
{
    metadata_.push( 
        ogawayama::stub::Metadata::ColumnType::Type::INT32, 
        sizeof( ogawayama::stub::Metadata::ColumnType::Type::INT32 ) );


    metadata = &metadata_;

    return ErrorCode::OK;
}

/**
 * @brief connect to the DB and get Result_Set class
 * @param result_set returns a result_set class
 * @return true in error, otherwise false
 */
ErrorCode ResultSet::Impl::next()
{
    return ErrorCode::OK;
}

/**
 * @brief get value in integer from the current row.
 * @param index culumn number, begins from one
 * @param value returns the value
 * @return error code defined in error_code.h
 */
template<typename T>
ErrorCode ResultSet::Impl::next_column( T &value ) 
{
    ogawayama::common::ShmColumn c( 9801 );
    value = std::get<T>( c );

    return ErrorCode::OK;
}

/**
 * @brief get value in integer from the current row.
 * @param index culumn number, begins from one
 * @param value returns the value
 * @return error code defined in error_code.h
 */
template<>
ErrorCode ResultSet::Impl::next_column( std::string_view &value ) 
{
    return ErrorCode::OK;
}

// ========================================================================
// ResultSet
// ========================================================================

/**
 * @brief get metadata for the result set.
 * @param metadata returns the metadata class
 * @return error code defined in error_code.h
 */
ErrorCode ResultSet::get_metadata( MetadataPtr &metadata )
{
    return impl_->get_metadata( metadata );
}

/**
 * @brief constructor of ResultSet class
 */
ResultSet::ResultSet( Transaction *transaction, std::size_t id ) 
    : manager_( transaction )
{
    impl_ = std::make_unique<ResultSet::Impl>( this, id );
}

/**
 * @brief destructor of ResultSet class
 */
ResultSet::~ResultSet() = default;

ErrorCode ResultSet::next() { return impl_->next(); }

template<>
ErrorCode ResultSet::next_column( std::int16_t &value ) { return impl_->next_column<std::int16_t>( value ); }
template<>
ErrorCode ResultSet::next_column( std::int32_t &value ) { return impl_->next_column<std::int32_t>( value ); }
template<>
ErrorCode ResultSet::next_column( std::int64_t &value ) { return impl_->next_column<std::int64_t>( value ); }
template<>
ErrorCode ResultSet::next_column( float &value ) { return impl_->next_column<float>( value ); }
template<>
ErrorCode ResultSet::next_column( double &value ) { return impl_->next_column<double>( value ); }
template<>
ErrorCode ResultSet::next_column( std::string_view &value ) { return impl_->next_column<std::string_view>( value ); }

}  // namespace ogawayama::stub
