==================
== INTRODUCTION ==
==================

The XMC Peripheral Library (XMC Lib) consists of low-level drivers for the XMC product family peripherals.
It addition the Cortex Microcontroller Software Interface Standard (CMSIS) is included. 
CMSIS provides a hardware abstraction layer for the Cortex-M processor series.
XMC Lib is built on top of CMSIS and MISRA-C 2004 compliant. 

The following tool chains are supported:
- GNU GCC for ARM (gcc)
- MDK-ARM Microcontroller Development Kit v5 (armcc)
- IAR Embedded Workbench for ARM (iccarm)
- TASKING VX-toolset for ARM v5.(carm)

The following 32-Bit Industrial Microcontrollers based on ARM Cortex are supported:
- XMC4800 series
- XMC4700 series
- XMC4500 series
- XMC4400 series
- XMC4300 series
- XMC4200 series
- XMC4100 series
- XMC1400 series
- XMC1300 series
- XMC1200 series
- XMC1100 series

==============
== CONTENTS ==
==============

  Readme.txt
  License.txt
  XMClib/
    doc/
    examples/
    /inc
    /src 
  CMSIS/
    Include/
    Infineon/
      SVD/
      XMC1100_series/
      XMC1200_series/
      XMC1300_series/
      XMC1400_series/
      XMC4100_series/
      XMC4200_series/
      XMC4300_series/
      XMC4400_series/
      XMC4500_series/
      XMC4700_series/
      XMC4800_series/
    Lib/
  Newlib

Now let's explain the purpose of each directory:
 - XMClib: The XMC Peripheral Library   
 - XMClib/doc: Holds complete documentation
 - XMClib/examples: Contains examples using the XMClib for the supported devices and tool chains.
 - XMClib/inc: Include files per peripheral
 - XMClib/src: Implementation files per peripheral
 - CMSIS: The Cortex Microcontroller Software Interface Standard abstraction layer
 - CMSIS/Include: Hardware Abstraction Layer (HAL) for Cortex-M processor registers with standardized definitions for the SysTick, 
                  NVIC, System Control Block registers, MPU registers, FPU registers, and core access functions
 - CMSIS/Infineon: Includes System View Description files (SVD) for use with debuggers, device header files with the register description, 
                   system files and startup files defined by CMSIS
 - CMSIS/Lib: Precompiled CMSIS DSP libraries for XMC4 (ARM Cortex M4F) and XMC1 (ARM Cortex M0) families.
 - Newlib: stubs for system calls. Only relevant for GNU GCC for ARM
      
===========
== USAGE ==
===========

Several examples for the supported toolchains are provided that can serve as starting point.

To start a project from scratch follow the steps:
1. Copy the CMSIS, XMClib and Newlib folders into your project.
3. Add the following folders into the include paths of your project:
   - ${ProjName}/XMCLib/inc
   - ${ProjName}/CMSIS/Include
   - ${ProjName}/CMSIS/Infineon/XMC4400_series/Include
4. Select the device for which your compiling defining a preprocessor symbol, i.e. XMC4500_F144x1024
5. Include into your source the header files of the peripherals you want to use, i.e. #include <xmc_vadc.h>
6. Configure the peripheral and make use of the APIs described in the documentation.

======================
== REVISION HISTORY ==
======================

XMC Peripheral Library v2.1.4p1 (06-04-2016)
--------------------------------------------
  - Updated CMSIS component to v4.5.0p1. See release notes in CMSIS/Readme.txt


XMC Peripheral Library v2.1.6   (29-04-2016)
--------------------------------------------
  - Updated CMSIS component to v4.5.0p2. See release notes in CMSIS/Readme.txt
  - See changelog section in the documentation files for individual peripheral driver changes
  - Added Newlib folder
  - Following examples has been updated:
    - XMC4500/EBU/EBU_SDRAM
       - Fix CAS latency corrected to 3
       - Change writing/reading of variables from 16bit to 32bit

    - XMC4500/ETH/HTTPSERVER_RAW
       - Stability and speed improvements

    - XMC4500/ETH/HTTPSERVER_NETCONN
       - Stability and speed improvements

    - XMC4800/ETH/HTTPSERVER_RAW
       - Stability and speed improvements

    - XMC4800/ETH/HTTPSERVER_NETCONN
       - Stability and speed improvements


XMC Peripheral Library v2.1.6p1   (17-05-2016)
--------------------------------------------
  - Updated of XMC4300 header file (v1.0.4) in CMSIS folder to solve issues with wrong base address of some peripheral modules.

XMC Peripheral Library v2.1.6p2   (14-07-2016)
--------------------------------------------
  - Updated CMSIS component to v4.5.0p3. See release notes in CMSIS/Readme.txt

XMC Peripheral Library v2.1.8     (30-08-2016)
--------------------------------------------
  - Updated CMSIS component to v4.5.0p4. See release notes in CMSIS/Readme.txt
  - See changelog section in the documentation files for individual peripheral driver changes
  - Added USBH driver
  - Added USBH and USBD driver examples

XMC Peripheral Library v2.1.12     (21-04-2017)
--------------------------------------------
  - Updated CMSIS component to v5.0.0. See release notes in CMSIS/Readme.txt
  - See changelog section in the documentation files for individual peripheral driver changes
  - Several examples added

XMC Peripheral Library v2.1.14     (30-06-2017)
--------------------------------------------
  - See changelog section in the documentation files for individual peripheral driver changes
  - Updated CMSIS component to v5.0.0p1.
    - Changes device header and system files to add support for ARM Compiler 6 (armclang)
  - Examples added

XMC Peripheral Library v2.1.16     (09-08-2017)
--------------------------------------------
  - See changelog section in the documentation files for individual peripheral driver changes
  - Examples added

XMC Peripheral Library v2.1.18     (30-11-2017)
--------------------------------------------
  - See changelog section in the documentation files for individual peripheral driver changes
  - Updated CMSIS component to v5.2.0.
    - Changed:
      - update core files to v5.2.0 (http://www.keil.com/pack/doc/CMSIS/General/html/cm_revisionHistory.html)
      - update lwIP to v2.0.3 (https://savannah.nongnu.org/forum/forum.php?forum_id=8953)
      - update fatFS to v0.13a
      - system_XMC4x00.c: Disable FPU if FPU_USED macro is zero. This is the case when using -mfloat-abi=soft.
      - startup_XMC1400.s: Added option to select wait time before ASC BSL channel selection (WAIT_ASCBSL_ENTRY_SSW)
    - Added:
      - Support for XMC1302-T028x0064, XMC1302-T028x0128, XMC1302-T028x0200

  - Examples added

XMC Peripheral Library v2.1.20     (09-10-2018)
--------------------------------------------
  - See changelog section in the documentation files for individual peripheral driver changes
  - Updated CMSIS component to v5.4.0.

XMC Peripheral Library v2.1.22     (05-06-2019)
--------------------------------------------
  - See changelog section in the documentation files for individual peripheral driver changes
  - Updated CMSIS component to v5.5.1. (http://www.keil.com/pack/doc/CMSIS/General/html/cm_revisionHistory.html)
    - CMSIS/Infineon/XMC1100_series/Source/system_XMC1100.c 
      v1.12: Fix variable location of SystemCoreClock for ARMCC compiler

    - CMSIS/Infineon/XMC1200_series/Source/system_XMC1200.c 
      v1.12: Fix variable location of SystemCoreClock for ARMCC compiler

    - CMSIS/Infineon/XMC1300_series/Source/system_XMC1300.c 
      v1.12: Fix variable location of SystemCoreClock for ARMCC compiler

    - CMSIS/Infineon/XMC1400_series/Source/system_XMC1400.c 
      v1.4: Fix variable location of SystemCoreClock for ARMCC compiler
      v1.5: Fix clock initialization if external XTAL is used (clock watchdog issue, see errata SCU_CM.023)
            Added DISABLE_WAIT_RTC_XTAL_OSC_STARTUP preprocessor guard:
              The RTC_XTAL can be used as clock source for RTC or as reference for DCO1 calibration 
              In both cases if no wait is done in the startup after enabling the RTC_XTAL oscillator,
              the RTC_Enable() or the calibration will stall the MCU until the oscillator is stable (max. 5s according datasheet)

    - CMSIS/Infineon/XMC4100_series/Source/system_XMC4100.c
      v3.2.5: Fix variable location of SystemCoreClock, g_hrpwm_char_data and g_chipid for ARMCC compiler
 
    - CMSIS/Infineon/XMC4200_series/Source/system_XMC4200.c 
      v3.1.4: Fix variable location of SystemCoreClock, g_hrpwm_char_data and g_chipid for ARMCC compiler

    - CMSIS/Infineon/XMC4300_series/Source/system_XMC4300.c 
      v1.0.6: Fix variable location of SystemCoreClock and g_chipid for ARMCC compiler

    - CMSIS/Infineon/XMC4400_series/Source/system_XMC4400.c
      v3.1.4: Fix variable location of SystemCoreClock, g_hrpwm_char_data and g_chipid for ARMCC compiler

    - CMSIS/Infineon/XMC4500_series/Source/system_XMC4500.c 
      v3.1.5: Fix variable location of SystemCoreClock and g_chipid for ARMCC compiler

    - CMSIS/Infineon/XMC4700_series/Source/system_XMC4700.c 
      v1.0.6: Fix variable location of SystemCoreClock and g_chipid for ARMCC compiler

    - CMSIS/Infineon/XMC4800_series/Source/system_XMC4800.c 
      v1.0.6: Fix variable location of SystemCoreClock and g_chipid for ARMCC compiler

    - CMSIS/Infineon/XMC1100_series/Source/ARM6/startup_XMC1100.S
      v1.5: Fix linker issues (Error: L6985E) with ARMCC6 when linking the IRQ VENEERS

    - CMSIS/Infineon/XMC1200_series/Source/ARM6/startup_XMC1200.S
      v1.5: Fix linker issues (Error: L6985E) with ARMCC6 when linking the IRQ VENEERS

    - CMSIS/Infineon/XMC1300_series/Source/ARM6/startup_XMC1300.S
      v1.5: Fix linker issues (Error: L6985E) with ARMCC6 when linking the IRQ VENEERS

    - CMSIS/Infineon/XMC1400_series/Source/ARM6/startup_XMC1400.S
      v1.3: Fix linker issues (Error: L6985E) with ARMCC6 when linking the IRQ VENEERS

    - Added scatter files for ARMCC6:    
    - CMSIS/Infineon/XMC1100_series/Source/ARM6/XMC1100x0008.sct
    - CMSIS/Infineon/XMC1100_series/Source/ARM6/XMC1100x0016.sct 
    - CMSIS/Infineon/XMC1100_series/Source/ARM6/XMC1100x0032.sct 
    - CMSIS/Infineon/XMC1100_series/Source/ARM6/XMC1100x0064.sct 
    - CMSIS/Infineon/XMC1200_series/Source/ARM6/XMC1200x0016.sct 
    - CMSIS/Infineon/XMC1200_series/Source/ARM6/XMC1200x0032.sct 
    - CMSIS/Infineon/XMC1200_series/Source/ARM6/XMC1200x0064.sct 
    - CMSIS/Infineon/XMC1200_series/Source/ARM6/XMC1200x0128.sct 
    - CMSIS/Infineon/XMC1200_series/Source/ARM6/XMC1200x0200.sct 
    - CMSIS/Infineon/XMC1300_series/Source/ARM6/XMC1300x0008.sct 
    - CMSIS/Infineon/XMC1300_series/Source/ARM6/XMC1300x0016.sct 
    - CMSIS/Infineon/XMC1300_series/Source/ARM6/XMC1300x0032.sct 
    - CMSIS/Infineon/XMC1300_series/Source/ARM6/XMC1300x0064.sct 
    - CMSIS/Infineon/XMC1300_series/Source/ARM6/XMC1300x0128.sct 
    - CMSIS/Infineon/XMC1300_series/Source/ARM6/XMC1300x0200.sct 
    - CMSIS/Infineon/XMC1300_series/Source/ARM6/XMC1300x0032.sct 
    - CMSIS/Infineon/XMC1300_series/Source/ARM6/XMC1300x0064.sct 
    - CMSIS/Infineon/XMC1300_series/Source/ARM6/XMC1300x0128.sct 
    - CMSIS/Infineon/XMC1300_series/Source/ARM6/XMC1300x0200.sct 

    - CMSIS/Infineon/XMC1100_series/Include/XMC1000_RomFunctionTable.h 
      v1.1: Extended ROM functions to incorporate AB step functionality _CalcTemperature, _NvmEraseSector, _NvmProgVerifyBlock, _CalcTSEVAR
    - CMSIS/Infineon/XMC1200_series/Include/XMC1000_RomFunctionTable.h 
      v1.1: Extended ROM functions to incorporate AB step functionality _CalcTemperature, _NvmEraseSector, _NvmProgVerifyBlock, _CalcTSEVAR
    - CMSIS/Infineon/XMC1300_series/Include/XMC1000_RomFunctionTable.h 
      v1.1: Extended ROM functions to incorporate AB step functionality _CalcTemperature, _NvmEraseSector, _NvmProgVerifyBlock, _CalcTSEVAR
    - CMSIS/Infineon/XMC1400_series/Include/XMC1000_RomFunctionTable.h 
      v1.1: Extended ROM functions to incorporate AB step functionality _CalcTemperature, _NvmEraseSector, _NvmProgVerifyBlock, _CalcTSEVAR

  - Update lwIP to v2.1.2 (https://savannah.nongnu.org/forum/forum.php?forum_id=8953)
  - Update fatFS to v0.13c
  - Updated FreeRTOS to v10.2.1
  - Added mbedTLS
  - Examples added. 
  - Project files for DAVE added.
