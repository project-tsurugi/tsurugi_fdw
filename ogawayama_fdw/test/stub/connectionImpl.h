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
#ifndef CONNECTIONIMPL_H_
#define CONNECTIONIMPL_H_

#include "transactionImpl.h"
#include "stubImpl.h"

namespace ogawayama::stub {

/**
 * @brief constructor of Connection::Impl class
 */
class Connection::Impl
{
public:
    Impl( Connection *, std::size_t );
    ~Impl();
    void confirm();

    ErrorCode begin( TransactionPtr &transaction );

    std::size_t get_id() { return pgprocno_; }
    
private:
    Connection *envelope_;

    std::size_t pgprocno_;
    std::unique_ptr<std::string> request_;
    std::unique_ptr<std::string> result_;
};

}  // namespace ogawayama::stub

#endif  // CONNECTIONIMPL_H_
