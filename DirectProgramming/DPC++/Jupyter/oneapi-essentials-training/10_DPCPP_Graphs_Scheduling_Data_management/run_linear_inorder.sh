#!/bin/bash
source /opt/intel/oneapi/setvars.sh > /dev/null 2>&1
/bin/echo "##" $(whoami) is compiling DPCPP_Essentials Module10 -- SYCL Graphs and dependenices - 5 of 11 Linear_inorder_queues.cpp
dpcpp lab/Linear_inorder_queues.cpp
if [ $? -eq 0 ]; then ./a.out; fi

