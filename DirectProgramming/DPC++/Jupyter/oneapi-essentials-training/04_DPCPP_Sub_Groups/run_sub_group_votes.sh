#!/bin/bash
source /opt/intel/oneapi/setvars.sh > /dev/null 2>&1
/bin/echo "##" $(whoami) is compiling DPCPP_Essentials Module4 -- SYCL Sub Groups - 6 of 7 sub_group_votes.cpp
dpcpp lab/sub_group_votes.cpp 
if [ $? -eq 0 ]; then ./a.out; fi


