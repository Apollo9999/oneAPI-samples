#!/bin/bash
source /opt/intel/oneapi/setvars.sh > /dev/null 2>&1
/bin/echo "##" $(whoami) is compiling DPCPP_Essentials Module8 -- SYCL Reduction - 4 of 8 sum_reduction_usm.cpp
dpcpp lab/sum_reduction_usm.cpp 
if [ $? -eq 0 ]; then ./a.out; fi

