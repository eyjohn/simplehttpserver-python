cdef extern from "<chrono>" namespace "std::chrono" nogil:
    cdef cppclass duration[Rep,Period]:
        pass

    cdef cppclass system_clock:
        pass

    cdef cppclass steady_clock:
        pass

    cdef cppclass time_point[Clock]:
        pass

cdef extern from "<array>" namespace "std" nogil:
    cdef cppclass array[T,S]:
        ctypedef T value_type
        ctypedef size_t size_type
        ctypedef ptrdiff_t difference_type

        cppclass iterator:
            T& operator*()
            iterator operator++()
            iterator operator--()
            iterator operator+(size_type)
            iterator operator-(size_type)
            difference_type operator-(iterator)
            bint operator==(iterator)
            bint operator!=(iterator)
            bint operator<(iterator)
            bint operator>(iterator)
            bint operator<=(iterator)
            bint operator>=(iterator)
        cppclass reverse_iterator:
            T& operator*()
            reverse_iterator operator++()
            reverse_iterator operator--()
            reverse_iterator operator+(size_type)
            reverse_iterator operator-(size_type)
            difference_type operator-(reverse_iterator)
            bint operator==(reverse_iterator)
            bint operator!=(reverse_iterator)
            bint operator<(reverse_iterator)
            bint operator>(reverse_iterator)
            bint operator<=(reverse_iterator)
            bint operator>=(reverse_iterator)
        cppclass const_iterator(iterator):
            pass
        cppclass const_reverse_iterator(reverse_iterator):
            pass
        array() except +
        array(array&) except +
        #array[input_iterator](input_iterator, input_iterator)
        T& operator[](size_type)
        #array& operator=(array&)
        bint operator==(array&, array&)
        bint operator!=(array&, array&)
        bint operator<(array&, array&)
        bint operator>(array&, array&)
        bint operator<=(array&, array&)
        bint operator>=(array&, array&)
        T& at(size_type) except +
        T& back()
        iterator begin()
        const_iterator const_begin "begin"()
        bint empty()
        iterator end()
        const_iterator const_end "end"()
        void fill(const T&)
        T& front()
        size_type max_size()
        reverse_iterator rbegin()
        const_reverse_iterator const_rbegin "crbegin"()
        reverse_iterator rend()
        const_reverse_iterator const_rend "crend"()
        size_type size()
        void swap(array&)
        T* data()
        const T* const_data "data"()
