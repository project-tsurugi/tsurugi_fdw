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
#ifndef CHANNEL_STREAM_H_
#define CHANNEL_STREAM_H_

#include "boost/bind.hpp"
#include "boost/interprocess/managed_shared_memory.hpp"
#include "boost/interprocess/sync/interprocess_condition.hpp"
#include "boost/interprocess/sync/interprocess_mutex.hpp"
#include "boost/archive/binary_oarchive.hpp"
#include "boost/archive/binary_iarchive.hpp"

#include "ogawayama/common/shared_memory.h"

namespace ogawayama::common {

/**
 * @brief one to one communication channel, intended for communication between server and stub through boost binary_archive.
 */
class ChannelStream : public std::streambuf
{
public:
    /**
     * @brief core class in the communication channel, using boost::circular_buffer.
     */
    class RingBuffer {
        using AllocatorType = boost::interprocess::allocator<char, boost::interprocess::managed_shared_memory::segment_manager>;

    public:
        /**
         * @brief Construct a new object.
         */
        RingBuffer() {}
        /**
         * @brief Copy and move constructers are deleted.
         */
        RingBuffer(RingBuffer const&) = delete;
        RingBuffer(RingBuffer&&) = delete;
        RingBuffer& operator = (RingBuffer const&) = delete;
        RingBuffer& operator = (RingBuffer&&) = delete;

        /**
         * @brief push one char data into the circular_buffer.
         * @param item char data to be pushed.
         */
        void push(char item)
        {
            bool was_empty = !is_not_empty();
            
            if(!is_not_full()) {
                boost::interprocess::scoped_lock lock(m_full_mutex_);
                if(!is_not_full()) {
                    m_not_full_.wait(lock, boost::bind(&RingBuffer::is_not_full, this));
                }
                lock.unlock();
            }
            m_container_[index(pushed_++)] = item;
            ack = false;
            if(was_empty) {
                boost::interprocess::scoped_lock lock(m_empty_mutex_);
                lock.unlock();
                m_not_empty_.notify_one();
            }
        }
        
        /**
         * @brief pop one char data from the circular_buffer.
         * @param pItem points where poped char data to be stored.
         */
        void pop(char* pItem) {
            bool was_full = !is_not_full();
            
            if(!is_not_empty()) {
                boost::interprocess::scoped_lock lock(m_empty_mutex_);
                if(!is_not_empty()) {
                    m_not_empty_.wait(lock, boost::bind(&RingBuffer::is_not_empty, this));
                }
                lock.unlock();
            }
            *pItem = m_container_[index(poped_++)];
            if(was_full) {
                boost::interprocess::scoped_lock lock(m_full_mutex_);
                lock.unlock();
                m_not_full_.notify_one();
            }
        }
        
#if 0
        /**
         * @brief waiting acknowledge from the other side.
         */
        void recieve_ack() {
            boost::interprocess::scoped_lock lock(m_ack_mutex_);
            m_not_ack_.wait(lock, boost::bind(&RingBuffer::is_acked, this));
            lock.unlock();
        }

        /**
         * @brief send acknowledge to the other side.
         */
        void send_ack() {
            boost::interprocess::scoped_lock lock(m_ack_mutex_);
            ack = true;
            lock.unlock();
            m_not_ack_.notify_one();
        }
#endif

    private:
        std::size_t index(std::size_t i) { return i % param::BUFFER_SIZE; }
        
        bool is_not_empty() const { return poped_ < pushed_; }
        bool is_not_full() const { return (pushed_ - poped_) < param::BUFFER_SIZE; }
        bool is_acked() const { return ack; }
        std::size_t pushed_{0};
        std::size_t poped_{0};

        char m_container_[param::BUFFER_SIZE];
        boost::interprocess::interprocess_mutex m_empty_mutex_{};
        boost::interprocess::interprocess_mutex m_full_mutex_{};
        boost::interprocess::interprocess_mutex m_ack_mutex_{};
        boost::interprocess::interprocess_condition m_not_empty_{};
        boost::interprocess::interprocess_condition m_not_full_{};
        boost::interprocess::interprocess_condition m_not_ack_{};
        bool ack {false};
    };
    
public:
    public:
    /**
     * @brief Construct a new object.
     */
    ChannelStream(char const* name, boost::interprocess::managed_shared_memory *mem, bool owner) : owner_(owner), mem_(mem)
    {
        if (owner_) {
            mem_->destroy<RingBuffer>(name_);
            buffer_ = mem->construct<RingBuffer>(name)();
            memcpy(name_, name, param::MAX_NAME_LENGTH);
        } else {
            buffer_ = mem->find<RingBuffer>(name).first;
            assert(buffer_);
        }
    }
    ChannelStream(char const* name, boost::interprocess::managed_shared_memory *mem) : ChannelStream(name, mem, false) {}

    /**
     * @brief Destruct this object.
     */
    ~ChannelStream()
    {
        if (owner_) {
            mem_->destroy<RingBuffer>(name_);
        }
    }

    /**
     * @brief Implements methods inherited from std::streambuf.
     */
    virtual int overflow( int p_iChar = EOF )
    {
        buffer_->push(static_cast<char>(p_iChar));
        return true;
    }

    /**
     * @brief Implements methods inherited from std::streambuf.
     */
    virtual int uflow()
    {
        char rv;
        
        buffer_->pop(&rv);
        return static_cast<int>(rv);
    }

    /**
     * @brief get binary_iarchive associated with this object
     * @return a binary_iarchive associated with this object
     */
    boost::archive::binary_iarchive get_binary_iarchive()
    {
        return boost::archive::binary_iarchive(*this);
    }

    /**
     * @brief get binary_oarchive associated with this object
     * @return a binary_oarchive associated with this object
     */
    boost::archive::binary_oarchive get_binary_oarchive()
    {
        return boost::archive::binary_oarchive(*this);
    }

private:
    RingBuffer *buffer_;
    const bool owner_;
    boost::interprocess::managed_shared_memory *mem_;
    char name_[param::MAX_NAME_LENGTH];
};

/**
 * @brief Messages exchanged via channel
 */
struct ChannelMessage
{
public:
    /**
     * @brief represents a type.
     */
    enum class Type {

        /**
         * @brief 
         */
        OK,

        /**
         * @brief 
         */
        CONNECT,

        /**
         * @brief 
         */
        DISCONNECT,

        /**
         * @brief 
         */
        EXECUTE_STATEMENT,

        /**
         * @brief 
         */
        EXECUTE_QUERY,
            
        /**
         * @brief 
         */
        NEXT,
    };

    ChannelMessage() = default;
    ChannelMessage(const ChannelMessage&) = default;
    ChannelMessage& operator=(const ChannelMessage&) = default;
    ChannelMessage(ChannelMessage&&) = default;
    ChannelMessage& operator=(ChannelMessage&&) = default;

    ChannelMessage( Type type, std::size_t ivalue, std::string_view string ) : type_(type), ivalue_(ivalue), string_(string) {}
    ChannelMessage( Type type, std::size_t ivalue ) : ChannelMessage(type, ivalue, std::string()) {}
    ChannelMessage( Type type ) : ChannelMessage(type, 0, std::string()) {}
    
    Type get_type() const { return type_; }
    std::size_t get_ivalue() const { return ivalue_; }
    std::string_view get_string() const { return std::string_view(string_.data(), string_.size()); }

private:
    Type type_;
    std::size_t ivalue_;
    std::string string_;

    friend class boost::serialization::access;
    template <class Archive>
    void serialize(Archive& ar, unsigned int /*version*/)
    {
        ar & boost::serialization::make_nvp("type", type_);
        ar & boost::serialization::make_nvp("ivalue", ivalue_);
        ar & boost::serialization::make_nvp("string", string_);
    }    
};

};  // namespace ogawayama::common

#endif //  CHANNEL_STREAM_H_
