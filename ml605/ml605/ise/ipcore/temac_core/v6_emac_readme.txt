      Core name: Xilinx LogiCORE Virtex-6 Embedded Tri-Mode Ethernet MAC Wrapper
                 Version: 1.4
                 Release Date: April 19, 2010


================================================================================

This document contains the following sections:

1. Introduction
2. New Features
3. Supported Devices
4. Resolved Issues
5. Known Issues
6. Technical Support
7. Other Information
8. Core Release History
9. Legal Disclaimer

================================================================================


1. INTRODUCTION

For the most recent updates to the IP installation instructions for this
core, please go to:

   http://www.xilinx.com/ipcenter/coregen/ip_update_install_instructions.htm

For system requirements:

   http://www.xilinx.com/ipcenter/coregen/ip_update_system_requirements.htm

This file contains release notes for the Xilinx LogiCORE IP v6_emac_v1_4
solution. For the latest core updates, see the product page at:

   http://www.xilinx.com/products/ipcenter/V6_Embedded_TEMAC_Wrapper.htm


2. NEW FEATURES

- ISE 12.1 software support
- QPro Virtex-6 Hi-Rel device support


3. SUPPORTED DEVICES

- Virtex-6 LXT
- Virtex-6 SXT
- Virtex-6 HXT
- Virtex-6 CXT
- Virtex-6 Lower Power
- QPro Virtex-6 Hi-Rel


4. RESOLVED ISSUES

- "WARNING:Par:468 - Your design did not meet timing" in some configurations
   - AR 33362, CR 529586
   - AR 33363, CR 529456
   Updated speed files and placement behavior have resolved both issues


5. KNOWN ISSUES

The following are known issues for v1.4 of this core at time of release:

   - N/A

The most recent information, including known issues, workarounds, and
resolutions for this version is provided in the IP Release Notes Guide
located at

   http://www.xilinx.com/support/documentation/user_guides/xtp025.pdf


6. TECHNICAL SUPPORT

To obtain technical support, create a WebCase at www.xilinx.com/support.
Questions are routed to a team with expertise using this product.

Xilinx provides technical support for use of this product when used
according to the guidelines described in the core documentation, and
cannot guarantee timing, functionality, or support of this product for
designs that do not follow specified guidelines.


7. OTHER INFORMATION

This core only supports Verilog LRM-IEEE 1364-2005 encryption-compliant
simulators. See the Getting Started Guide.


8. CORE RELEASE HISTORY

Date        By            Version      Description
================================================================================
04/19/2010  Xilinx, Inc.  1.4          ISE 12.1 support
03/09/2010  Xilinx, Inc.  1.3 Rev 1    11.5 support; fixes SI 508601, CR 542643
09/16/2009  Xilinx, Inc.  1.3          ISE 11.3 support
06/24/2009  Xilinx, Inc.  1.2          ISE 11.2 support
04/24/2009  Xilinx, Inc.  1.1          Initial release (Beta)
================================================================================


9. LEGAL DISCLAIMER

(c) Copyright 2009 - 2010 Xilinx, Inc. All rights reserved.

This file contains confidential and proprietary information
of Xilinx, Inc. and is protected under U.S. and
international copyright and other intellectual property
laws.

DISCLAIMER
This disclaimer is not a license and does not grant any
rights to the materials distributed herewith. Except as
otherwise provided in a valid license issued to you by
Xilinx, and to the maximum extent permitted by applicable
law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
(2) Xilinx shall not be liable (whether in contract or tort,
including negligence, or under any other theory of
liability) for any loss or damage of any kind or nature
related to, arising under or in connection with these
materials, including for any direct, or any indirect,
special, incidental, or consequential loss or damage
(including loss of data, profits, goodwill, or any type of
loss or damage suffered as a result of any action brought
by a third party) even if such damage or loss was
reasonably foreseeable or Xilinx had been advised of the
possibility of the same.

CRITICAL APPLICATIONS
Xilinx products are not designed or intended to be fail-
safe, or for use in any application requiring fail-safe
performance, such as life-support or safety devices or
systems, Class III medical devices, nuclear facilities,
applications related to the deployment of airbags, or any
other applications that could lead to death, personal
injury, or severe property or environmental damage
(individually and collectively, "Critical
Applications"). Customer assumes the sole risk and
liability of any use of Xilinx products in Critical
Applications, subject only to applicable laws and
regulations governing limitations on product liability.

THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
PART OF THIS FILE AT ALL TIMES.
