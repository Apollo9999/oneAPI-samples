# Data Transfers Using Pipes
This FPGA tutorial shows how to use pipes to transfer data between kernels.

| Optimized for                     | Description
---                                 |---
| OS                                | Linux* Ubuntu* 18.04/20.04 <br> RHEL*/CentOS* 8 <br> SUSE* 15 <br> Windows* 10
| Hardware                          | Intel&reg; Programmable Acceleration Card (PAC) with Intel Arria&reg; 10 GX FPGA <br> Intel&reg; FPGA Programmable Acceleration Card (PAC) D5005 (with Intel Stratix&reg; 10 SX) <br> Intel&reg; FPGA 3rd party / custom platforms with oneAPI support <br> ***Note**: Intel&reg; FPGA PAC hardware is only compatible with Ubuntu 18.04*
| Software                          | Intel&reg; oneAPI DPC++/C++ Compiler <br> Intel&reg; FPGA Add-On for oneAPI Base Toolkit
| What you will learn               | The basics of using SYCL*-compliant pipes extension for FPGA<br> How to declare and use pipes
| Time to complete                  | 15 minutes

## Purpose
This tutorial demonstrates how a kernel in a SYCL*-compliant FPGA program transfers
data to or from another kernel using the pipe abstraction.

### Definition of a Pipe
The primary goal of pipes is to allow concurrent execution of kernels that need
to exchange data.

A pipe is a FIFO data structure connecting two endpoints that communicate
using the pipe's `read` and `write` operations. An endpoint can be either a kernel
or an external I/O on the FPGA. Therefore, there are three types of pipes:
* kernel-kernel
* kernel-I/O
* I/O-kernel

This tutorial focuses on kernel-kernel pipes, but
the concepts discussed here apply to other kinds of pipes as well.

The `read` and `write` operations have two variants:
* Blocking variant: Blocking operations may not return immediately but are always successful.
* Non-blocking variant: Non-blocking operations take an extra boolean parameter
that is set to `true` if the operation happened successfully.

Data flows in a single direction inside pipes. In other words, for a pipe `P`
and two kernels using `P`, one of the kernels is exclusively going to perform
`write` to `P` while the other kernel is exclusively going to perform `read` from
`P`. Bidirectional communication can be achieved using two pipes.

Each pipe has a configurable `capacity` parameter describing the number of `write`
operations that may be performed without any `read` operations being performed. For example,
consider a pipe `P` with capacity 3, and two kernels `K1` and `K2` using
`P`. Assume that `K1` performed the following sequence of operations:

 `write(1)`, `write(2)`, `write(3)`

In this situation, the pipe is full because three (the `capacity` of
`P`) `write` operations were performed without any `read` operation. In this
situation, a `read` must occur before any other `write` is allowed.

If a `write` is attempted to a full pipe, one of two behaviors occurs:

  * If the operation is non-blocking, it returns immediately, and its
  boolean parameter is set to `false`. The `write` does not have any effect.
  * If the operation is blocking, it does not return until a `read` is
  performed by the other endpoint. Once the `read` is performed, the `write`
  takes place.

The blocking and non-blocking `read` operations have analogous behaviors when
the pipe is empty.

### Defining a Pipe

SYCL*-compliant pipes are defined as a class with static members. To declare a pipe that
transfers integer data and has  `capacity=4`, use a type alias:

```c++
using ProducerToConsumerPipe = pipe<  // Defined in the SYCL headers.
  class ProducerConsumerPipe,         // An identifier for the pipe.
  int,                                // The type of data in the pipe.
  4>;                                 // The capacity of the pipe.
```

The `class ProducerToConsumerPipe` template parameter is important to the
uniqueness of the pipe. This class need not be defined but must be distinct
for each pipe. Consider another type alias with the exact same parameters:

```c++
using ProducerToConsumerPipe2 = pipe<  // Defined in the SYCL headers.
  class ProducerConsumerPipe,          // An identifier for the pipe.
  int,                                 // The type of data in the pipe.
  4>;                                  // The capacity of the pipe.
```

The uniqueness of a pipe is derived from a combination of all three template
parameters. Since `ProducerToConsumerPipe` and `ProducerToConsumerPipe2` have
the same template parameters, they define the same pipe.

### Using a Pipe

This code sample defines a `Consumer` and a `Producer` kernel connected
by the pipe `ProducerToConsumerPipe`. Kernels use the
`ProducerToConsumerPipe::write` and `ProducerToConsumerPipe::read` methods for
communication.

The `Producer` kernel reads integers from the global memory and writes those integers
into `ProducerToConsumerPipe`, as shown in the following code snippet:

```c++
void Producer(queue &q, buffer<int, 1> &input_buffer) {
  std::cout << "Enqueuing producer...\n";

  auto e = q.submit([&](handler &h) {
    accessor input_accessor(input_buffer, h, read_only);
    auto num_elements = input_buffer.get_count();

    h.single_task<ProducerTutorial>([=]() {
      for (size_t i = 0; i < num_elements; ++i) {
        ProducerToConsumerPipe::write(input_accessor[i]);
      }
    });
  });
}
```

The `Consumer` kernel reads integers from `ProducerToConsumerPipe`, processes
the integers (`ConsumerWork(i)`), and writes the result into the global memory.

```c++
void Consumer(queue &q, buffer<int, 1> &output_buffer) {
  std::cout << "Enqueuing consumer...\n";

  auto e = q.submit([&](handler &h) {
    accessor out_accessor(out_buf, h, write_only, no_init);
    size_t num_elements = output_buffer.get_count();

    h.single_task<ConsumerTutorial>([=]() {
      for (size_t i = 0; i < num_elements; ++i) {
        int input = ProducerToConsumerPipe::read();
        int answer = ConsumerWork(input);
        output_accessor[i] = answer;
      }
    });
  });
}
```

> **Note**: The `read` and `write` operations used are blocking. If
`ConsumerWork` is an expensive operation, then `Producer` might fill
`ProducerToConsumerPipe` faster than `Consumer` can read from it, causing
`Producer` to block occasionally.

### Additional Documentation
- [Explore SYCL* Through Intel&reg; FPGA Code Samples](https://software.intel.com/content/www/us/en/develop/articles/explore-dpcpp-through-intel-fpga-code-samples.html) helps you to navigate the samples and build your knowledge of FPGAs and SYCL.
- [FPGA Optimization Guide for Intel&reg; oneAPI Toolkits](https://software.intel.com/content/www/us/en/develop/documentation/oneapi-fpga-optimization-guide) helps you understand how to target FPGAs using SYCL and Intel&reg; oneAPI Toolkits.
- [Intel&reg; oneAPI Programming Guide](https://software.intel.com/en-us/oneapi-programming-guide) helps you understand target-independent, SYCL-compliant programming using Intel&reg; oneAPI Toolkits.

## Key Concepts
* The basics of the SYCL*-compliant pipes extension for FPGA.
* How to declare and use pipes in a program.

## Building the `pipes` Tutorial

> **Note**: If you have not already done so, set up your CLI
> environment by sourcing  the `setvars` script located in
> the root of your oneAPI installation.
>
> Linux*:
> - For system wide installations: `. /opt/intel/oneapi/setvars.sh`
> - For private installations: `. ~/intel/oneapi/setvars.sh`
>
> Windows*:
> - `C:\Program Files(x86)\Intel\oneAPI\setvars.bat`
>
>For more information on environment variables, see **Use the setvars Script** for [Linux or macOS](https://www.intel.com/content/www/us/en/develop/documentation/oneapi-programming-guide/top/oneapi-development-environment-setup/use-the-setvars-script-with-linux-or-macos.html), or [Windows](https://www.intel.com/content/www/us/en/develop/documentation/oneapi-programming-guide/top/oneapi-development-environment-setup/use-the-setvars-script-with-windows.html).


### Running Samples in Intel&reg; DevCloud
If running a sample in the Intel&reg; DevCloud, remember that you must specify the type of compute node and whether to run in batch or interactive mode. Compiles to FPGA are only supported on fpga_compile nodes. Executing programs on FPGA hardware is only supported on fpga_runtime nodes of the appropriate type, such as fpga_runtime:arria10 or fpga_runtime:stratix10.  Neither compiling nor executing programs on FPGA hardware are supported on the login nodes. For more information, see the Intel&reg; oneAPI Base Toolkit Get Started Guide ([https://devcloud.intel.com/oneapi/documentation/base-toolkit/](https://devcloud.intel.com/oneapi/documentation/base-toolkit/)).

When compiling for FPGA hardware, it is recommended to increase the job timeout to 12h.


### Using Visual Studio Code*  (Optional)

You can use Visual Studio Code (VS Code) extensions to set your environment, create launch configurations,
and browse and download samples.

The basic steps to build and run a sample using VS Code include:
 - Download a sample using the extension **Code Sample Browser for Intel&reg; oneAPI Toolkits**.
 - Configure the oneAPI environment with the extension **Environment Configurator for Intel&reg; oneAPI Toolkits**.
 - Open a Terminal in VS Code (**Terminal>New Terminal**).
 - Run the sample in the VS Code terminal using the instructions below.
 - (Linux only) Debug your GPU application with GDB for Intel&reg; oneAPI Toolkits using the **Generate Launch Configurations** extension.

To learn more about the extensions, see the
[Using Visual Studio Code with Intel&reg; oneAPI Toolkits User Guide](https://www.intel.com/content/www/us/en/develop/documentation/using-vs-code-with-intel-oneapi/top.html).

### On a Linux* System

1. Generate the `Makefile` by running `cmake`.
     ```
   mkdir build
   cd build
   ```
   To compile for the Intel&reg; PAC with Intel Arria&reg; 10 GX FPGA, run `cmake` using the command:
    ```
    cmake ..
   ```
   Alternatively, to compile for the Intel&reg; FPGA PAC D5005 (with Intel Stratix&reg; 10 SX), run `cmake` using the command:

   ```
   cmake .. -DFPGA_DEVICE=intel_s10sx_pac:pac_s10
   ```
   You can also compile for a custom FPGA platform. Ensure that the board support package is installed on your system. Then run `cmake` using the command:
   ```
   cmake .. -DFPGA_DEVICE=<board-support-package>:<board-variant>
   ```

2. Compile the design through the generated `Makefile`. The following build targets are provided, matching the recommended development flow:

   * Compile for emulation (fast compile time, targets emulated FPGA device):
      ```
      make fpga_emu
      ```
   * Generate the optimization report:
     ```
     make report
     ```
   * Compile for FPGA hardware (longer compile time, targets FPGA device):
     ```
     make fpga
     ```
3. (Optional) As the above hardware compile may take several hours to complete, FPGA precompiled binaries (compatible with Linux* Ubuntu* 18.04) can be downloaded <a href="https://iotdk.intel.com/fpga-precompiled-binaries/latest/pipes.fpga.tar.gz" download>here</a>.

### On a Windows* System

1. Generate the `Makefile` by running `cmake`.
     ```
   mkdir build
   cd build
   ```
   To compile for the Intel&reg; PAC with Intel Arria&reg; 10 GX FPGA, run `cmake` using the command:
    ```
    cmake -G "NMake Makefiles" ..
   ```
   Alternatively, to compile for the Intel&reg; FPGA PAC D5005 (with Intel Stratix&reg; 10 SX), run `cmake` using the command:

   ```
   cmake -G "NMake Makefiles" .. -DFPGA_DEVICE=intel_s10sx_pac:pac_s10
   ```
   You can also compile for a custom FPGA platform. Ensure that the board support package is installed on your system. Then run `cmake` using the command:
   ```
   cmake -G "NMake Makefiles" .. -DFPGA_DEVICE=<board-support-package>:<board-variant>
   ```

2. Compile the design through the generated `Makefile`. The following build targets are provided, matching the recommended development flow:

   * Compile for emulation (fast compile time, targets emulated FPGA device):
     ```
     nmake fpga_emu
     ```
   * Generate the optimization report:
     ```
     nmake report
     ```
   * Compile for FPGA hardware (longer compile time, targets FPGA device):
     ```
     nmake fpga
     ```

> **Note**: The Intel&reg; PAC with Intel Arria&reg; 10 GX FPGA and Intel&reg; FPGA PAC D5005 (with Intel Stratix&reg; 10 SX) do not support Windows*. Compiling to FPGA hardware on Windows* requires a third-party or custom Board Support Package (BSP) with Windows* support.

> **Note**: If you encounter any issues with long paths when compiling under Windows*, you may have to create your ‘build’ directory in a shorter path, for example c:\samples\build.  You can then run cmake from that directory, and provide cmake with the full path to your sample directory.

### Troubleshooting
If an error occurs, you can get more details by running `make` with
the `VERBOSE=1` argument:
``make VERBOSE=1``
For more comprehensive troubleshooting, use the Diagnostics Utility for
Intel&reg; oneAPI Toolkits, which provides system checks to find missing
dependencies and permissions errors.
[Learn more](https://software.intel.com/content/www/us/en/develop/documentation/diagnostic-utility-user-guide/top.html).

 ### In Third-Party Integrated Development Environments (IDEs)

You can compile and run this tutorial in the Eclipse* IDE (in Linux*) and the Visual Studio* IDE (in Windows*). For instructions, refer to the following link: [FPGA Workflows on Third-Party IDEs for Intel&reg; oneAPI Toolkits](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-oneapi-dpcpp-fpga-workflow-on-ide.html).

## Examining the Reports
Locate `report.html` in the `pipes_report.prj/reports/` directory. Open the report in Chrome*, Firefox*, Edge*, or Internet Explorer*.

Navigate to the "System Viewer" to visualize the structure of the kernel system. Identify the pipe connecting the two kernels.

## Running the Sample

 1. Run the sample on the FPGA emulator (the kernel executes on the CPU):
     ```
     ./pipes.fpga_emu     (Linux)
     pipes.fpga_emu.exe   (Windows)
     ```
2. Run the sample on the FPGA device:
     ```
     ./pipes.fpga         (Linux)
     pipes.fpga.exe       (Windows)
     ```

### Example of Output
You should see the following output in the console:

1. When running on the FPGA emulator
    ```
    Input Array Size: 8192
    Enqueuing producer...
    Enqueuing consumer...

    Profiling Info
      Producer:
        Start time: 0 ms
        End time: +8.18174 ms
        Kernel Duration: 8.18174 ms
      Consumer:
        Start time: +7.05307 ms
        End time: +8.18231 ms
        Kernel Duration: 1.12924 ms
      Design Duration: 8.18231 ms
      Design Throughput: 4.00474 MB/s

    PASSED: The results are correct
    ```
   > **Note**: The FPGA emulator does not accurately represent the performance nor the kernels' relative timing (i.e., the start and end times).

2. When running on the FPGA device
    ```
    Input Array Size: 1048576
    Enqueuing producer...
    Enqueuing consumer...

    Profiling Info
      Producer:
        Start time: 0 ms
        End time: +4.481 ms
        Kernel Duration: 4.481 ms
      Consumer:
        Start time: +0.917 ms
        End time: +4.484 ms
        Kernel Duration: 3.568 ms
      Design Duration: 4.484 ms
      Design Throughput: 935.348 MB/s

    PASSED: The results are correct
    ```

## License
Code samples are licensed under the MIT license. See
[License.txt](https://github.com/oneapi-src/oneAPI-samples/blob/master/License.txt) for details.

Third party program Licenses can be found here: [third-party-programs.txt](https://github.com/oneapi-src/oneAPI-samples/blob/master/third-party-programs.txt).
