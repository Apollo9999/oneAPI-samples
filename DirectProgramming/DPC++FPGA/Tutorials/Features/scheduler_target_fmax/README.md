# Scheduler Target FMAX

This tutorial explains the `scheduler_target_fmax_mhz` attribute and its effect on the performance of Intel&reg; FPGA kernels.

| Optimized for                     | Description
|:---                               |:---
| OS                                | Linux* Ubuntu* 18.04/20.04 <br> RHEL*/CentOS* 8 <br> SUSE* 15 <br> Windows* 10
| Hardware                          | Intel&reg; Programmable Acceleration Card (PAC) with Intel Arria&reg; 10 GX FPGA <br> Intel&reg; FPGA Programmable Acceleration Card (PAC) D5005 (with Intel Stratix&reg; 10 SX) <br> Intel&reg; FPGA 3rd party / custom platforms with oneAPI support <br> *__Note__: Intel&reg; FPGA PAC hardware is only compatible with Ubuntu 18.04*
| Software                          | Intel&reg; oneAPI DPC++/C++ Compiler <br> Intel&reg; FPGA Add-On for oneAPI Base Toolkit
| What you will learn               |  The behavior of the `scheduler_target_fmax_mhz` attribute and when to use it. <br> The effect this attribute can have on kernel performance on FPGA.
| Time to complete                  | 15 minutes

## Purpose

This tutorial demonstrates how to use the `[[intel::scheduler_target_fmax_mhz(N)]]` attribute to set the fMAX target for a single kernel. The purpose this attribute serves is to direct the compiler to prioritize a high fMAX over a low initiation interval (II). If you are not yet familiar with the `[[intel::initiation_interval(N)]]` attribute which can change the II of a loop to improve performance, refer to the prerequisite tutorial "Loop initiation_interval attribute".

### Specifying Schedule fMAX Target for Kernels

The compiler provides two methods to specify fMAX target for kernels:

* By using the `[[intel::scheduler_target_fmax_mhz(N)]]` source-level attribute on a given kernel. This is the focus of this tutorial.
* By using the `-Xsclock=<clock target in Hz/KHz/MHz/GHz or s/ms/us/ns/ps>` option in the icpx command to direct the compiler to globally compile all kernels at a specific fMAX target.

If you use both the command-line option `-Xsclock` and the source-level attribute `[[intel::scheduler_target_fmax_mhz(N)]]`, the attribute takes priority.

### Use Cases of `intel::scheduler_target_fmax_mhz(N)`

A bottleneck in a loop is one or more loop-carried dependencies that cause the loop to have either an II greater than one, or a lower fMAX to achieve II of one. By default, the compiler optimizes for the best fMAX-II ratio.

You should use the `[[intel::scheduler_target_fmax_mhz(N)]]` attribute if you want to tweak your kernel's throughput and area utilization, as well as the tradeoff between fMAX and II. When you use the `[[intel::scheduler_target_fmax_mhz(N)]]` attribute (or the `-Xsclock` icpx command option) to specify a desired fMAX, the compiler schedules the design at that specified fMAX value with minimal achievable II. When you use the `[[intel::initiation_interval(N)]]` attribute (refer to the prerequisite tutorial "Loop initiation_interval attribute") to specify a desired II, the compiler lowers fMAX until it achieves the specified II.

It is recommended that you use `[[intel::initiation_interval(N)]]` attribute on performance critical loops when using the `[[intel::scheduler_target_fmax_mhz(N)]]` attribute. The `[[intel::initiation_interval(N)]]` attribute takes priority over the `[[intel::scheduler_target_fmax_mhz(N)]]` attribute when they are both used on the same kernel.

### Understanding the Tutorial Design

In the tutorial, all four kernels implement the same function (BKDR Hash). The only difference is how the `[[intel::scheduler_target_fmax_mhz(N)]]` attribute and the `[[intel::initiation_interval(N)]]` attribute are applied. All specific numbers mentioned below are expected observations on Intel Arria&reg; 10 GX FPGA. Even so, the tradeoff between fMAX and II is also expected on other devices.

In kernel `Default`, no fMAX or II constraints are provided. By default, the compiler tries to optimize throughput using heuristics to balance high fMAX and small II. The block `B1` is scheduled at less than 240 MHz, so this block is limiting this kernel's fMAX but is able to achieve II=1.

In kernel `Fmax480Attr`, the `[[intel::scheduler_target_fmax_mhz(480)]]` attribute tells the compiler to target 480 MHz. Since the II is unconstrained, the compiler inserts extra pipelining to schedule the kernel at 480 MHz instead of trying to balance fMAX and II. Now, all blocks are scheduled at the target fMAX, but block `B1` has a higher II than kernel `Default`.

In kernel `Fmax240Attr`, the `[[intel::scheduler_target_fmax_mhz(240)]]` attribute tells the compiler to target 240 MHz. Once again, all blocks are scheduled at the target fMAX, but block `B1` has a lower II than kernel `Fmax480Attr`. Since we reduce the fMAX target, the compiler inserts fewer pipeline registers in `B1` of this kernel.

In kernel `Fmax240IIAttr`, the `[[intel::scheduler_target_fmax_mhz(240)]]` attribute tells the compiler to target 240 MHz, and the `[[intel::initiation_interval(1)]]` attribute forces block `B1` to be scheduled with II=1. Since the `[[intel::initiation_interval(1)]]` attribute takes priority over the `[[intel::scheduler_target_fmax_mhz(240)]]` attribute, the compiler is not able to schedule block `B1` at the requested target fMAX but is able to achieve II=1. This achieves a similar latency as kernel `Default` but provides you the control over how much pipelining the compiler generates while still achieving the desired II on critical loops.

### Additional Documentation

* [Explore SYCL* Through Intel&reg; FPGA Code Samples](https://software.intel.com/content/www/us/en/develop/articles/explore-dpcpp-through-intel-fpga-code-samples.html) helps you to navigate the samples and build your knowledge of FPGAs and SYCL.

* [FPGA Optimization Guide for Intel&reg; oneAPI Toolkits](https://software.intel.com/content/www/us/en/develop/documentation/oneapi-fpga-optimization-guide) helps you understand how to target FPGAs using SYCL and Intel&reg; oneAPI Toolkits.
* [Intel&reg; oneAPI Programming Guide](https://software.intel.com/en-us/oneapi-programming-guide) helps you understand target-independent, SYCL-compliant programming using Intel&reg; oneAPI Toolkits.

## Key Concepts

* The behavior of the `scheduler_target_fmax_mhz` attribute and when to use it on your kernel
* The effect this attribute can have on your kernel's performance on FPGA

## Using Visual Studio Code*  (Optional)

You can use Visual Studio Code (VS Code) extensions to set your environment, create launch configurations,
and browse and download samples.

The basic steps to build and run a sample using VS Code include:

* Download a sample using the extension **Code Sample Browser for Intel&reg; oneAPI Toolkits**.
* Configure the oneAPI environment with the extension **Environment Configurator for Intel&reg; oneAPI Toolkits**.
* Open a Terminal in VS Code (__Terminal>New Terminal__).
* Run the sample in the VS Code terminal using the instructions below.
* (Linux only) Debug your GPU application with GDB for Intel&reg; oneAPI toolkits using the __Generate Launch Configurations__ extension.

To learn more about the extensions, see the
[Using Visual Studio Code with Intel&reg; oneAPI Toolkits User Guide](https://www.intel.com/content/www/us/en/develop/documentation/using-vs-code-with-intel-oneapi/top.html).

## Building the `scheduler_target_fmax` Tutorial

> __Note__: If you have not already done so, set up your CLI
> environment by sourcing  the `setvars` script located in
> the root of your oneAPI installation.
>
> Linux*:
>
> * For system wide installations: `. /opt/intel/oneapi/setvars.sh`
> * For private installations: `. ~/intel/oneapi/setvars.sh`
>
> Windows*:
>
> * `C:\Program Files(x86)\Intel\oneAPI\setvars.bat`
>
>For more information on environment variables, see __Use the setvars Script__ for [Linux or macOS](https://www.intel.com/content/www/us/en/develop/documentation/oneapi-programming-guide/top/oneapi-development-environment-setup/use-the-setvars-script-with-linux-or-macos.html), or [Windows](https://www.intel.com/content/www/us/en/develop/documentation/oneapi-programming-guide/top/oneapi-development-environment-setup/use-the-setvars-script-with-windows.html).

### Running Samples in Intel&reg; DevCloud

If running a sample in the Intel&reg; DevCloud, remember that you must specify the type of compute node and whether to run in batch or interactive mode. Compiles to FPGA are only supported on fpga_compile nodes. Executing programs on FPGA hardware is only supported on fpga_runtime nodes of the appropriate type, such as fpga_runtime:arria10 or fpga_runtime:stratix10.  Neither compiling nor executing programs on FPGA hardware are supported on the login nodes. For more information, see the Intel&reg; oneAPI Base Toolkit Get Started Guide ([https://devcloud.intel.com/oneapi/documentation/base-toolkit/](https://devcloud.intel.com/oneapi/documentation/base-toolkit/)).

When compiling for FPGA hardware, it is recommended to increase the job timeout to 12h.

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

   * Compile for simulation (fast compile time, targets simulated FPGA device)

     ```bash
     make fpga_sim
     ```

   * Compile for FPGA hardware (longer compile time, targets FPGA device):

     ```
     make fpga
     ```

3. (Optional) As the above hardware compile may take several hours to complete, FPGA precompiled binaries (compatible with Linux* Ubuntu* 18.04) can be downloaded <a href="https://iotdk.intel.com/fpga-precompiled-binaries/latest/scheduler_target_fmax.fpga.tar.gz" download>here</a>.

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

   * Compile for simulation (fast compile time, targets simulated FPGA device, reduced problem size):

     ```
     nmake fpga_sim
     ```

   * Compile for FPGA hardware (longer compile time, targets FPGA device):

     ```
     nmake fpga
     ```

> __Note__: The Intel&reg; PAC with Intel Arria&reg; 10 GX FPGA and Intel&reg; FPGA PAC D5005 (with Intel Stratix&reg; 10 SX) do not support Windows*. Compiling to FPGA hardware on Windows* requires a third-party or custom Board Support Package (BSP) with Windows* support.

> __Note__: If you encounter any issues with long paths when compiling under Windows*, you may have to create your ‘build’ directory in a shorter path, for example c:\samples\build.  You can then run cmake from that directory, and provide cmake with the full path to your sample directory.

### Troubleshooting

If an error occurs, you can get more details by running `make` with
the `VERBOSE=1` argument:
``make VERBOSE=1``
For more comprehensive troubleshooting, use the Diagnostics Utility for
Intel&reg; oneAPI Toolkits, which provides system checks to find missing
dependencies and permissions errors.
[Learn more](https://www.intel.com/content/www/us/en/develop/documentation/diagnostic-utility-user-guide/top.html).

### In Third-Party Integrated Development Environments (IDEs)

You can compile and run this tutorial in the Eclipse*IDE (in Linux*) and the Visual Studio*IDE (in Windows*). For instructions, refer to the following link: [FPGA Workflows on Third-Party IDEs for Intel&reg; oneAPI Toolkits](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-oneapi-dpcpp-fpga-workflow-on-ide.html).

## Examining the Reports

Locate `report.html` in the `scheduler_target_fmax_report.prj/reports/` directory. Open the report in Chrome*, Firefox*, Edge*, or Internet Explorer*.

Navigate to the Loop Analysis table (Throughput Analysis > Loop Analysis). In kernel `Default`, block `B1` is scheduled at less than 240 MHz but has II=1. In kernel `Fmax240Attr` and `Fmax480Attr`, all blocks are scheduled at the target fMAX, but they have II>1. In kernel `Fmax240IIAttr`, similar to kernel `Default`, block `B1` is scheduled at less than 240 MHz but has II=1.

Navigate to the Area Analysis of System (Area Analysis > Area Analysis of System). By comparing the results in resource usage for different fMAX and II targets, you can see that the compiler inserts more pipeline stages and therefore increases area usage if the component is scheduled for a higher fMAX.

## Running the Sample

1. Run the sample on the FPGA emulator (the kernel executes on the CPU):

     ```
     ./scheduler_target_fmax.fpga_emu     (Linux)
     scheduler_target_fmax.fpga_emu.exe   (Windows)
     ```

2. Run the sample on the FPGA simulator device:

     ```
     ./scheduler_target_fmax.fpga_sim         (Linux)
     scheduler_target_fmax.fpga_sim.exe       (Windows)
     ```

3. Run the sample on the FPGA device:

     ```
     ./scheduler_target_fmax.fpga         (Linux)
     scheduler_target_fmax.fpga.exe       (Windows)
     ```

### Example of Output

```
PASSED: all kernel results are correct.
```

## License

Code samples are licensed under the MIT license. See
[License.txt](https://github.com/oneapi-src/oneAPI-samples/blob/master/License.txt) for details.

Third party program Licenses can be found here: [third-party-programs.txt](https://github.com/oneapi-src/oneAPI-samples/blob/master/third-party-programs.txt).
