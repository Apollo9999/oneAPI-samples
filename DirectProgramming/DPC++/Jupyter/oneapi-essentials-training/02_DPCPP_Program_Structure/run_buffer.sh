#!/bin/bash
source /opt/intel/oneapi/setvars.sh > /dev/null 2>&1
/bin/echo "##" $(whoami) is compiling DPCPP_Essentials Module2 -- SYCL Program Structure sample - 2 of 7 buffer_sample.cpp
dpcpp lab/buffer_sample.cpp
if [ $? -eq 0 ]; then ./a.out; fi

