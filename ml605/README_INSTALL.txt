CRUSH (alpha release) installation and setup instructions for Windows 7

Created by JONATHON PENDLUM - pendlum.j@husky.neu.edu



Required Hardware:
- Ettus Research USRP N210 with WBX daughter card
- Xilinx ML605 Virtex 6 FPGA Development Board
- MICTOR 38 Pin Male to Male Cable*
- FMC to Mictor Custom PCB**

* This can be bought from Emulation Technology, Inc 
  http://www.emulation.com/catalog/off-the-shelf_solutions/mictor/mictor.cfm
  Part# MIC-38-CABLE-MM-18
** This is a custom designed PCB. The schematics, layout, and BOM are included for 
   PCB manufacturing and assembly.



Required PC Software:
Note: These files will become out of date, so refer to the UHD build guide
http://files.ettus.com/uhd_docs/manual/html/build.html if any links are broken.

- Xilinx ISE 12.4 (including EDK and SDK)

- Visual Studio 2010 PROFESSIONAL
  - The Professional version is important, because the .NET version lacks a required
    library called ATL (Active Template Library). Supposedly, you can get it in 
    Windows Driver Kit but I never tried this.

- CMake 2.8.10.2 http://www.cmake.org/files/v2.8/cmake-2.8.10.2.zip
  
- Boost 1.47 Windows Binary http://boostpro.com/download/boost_1_47_setup.exe
  - When installing, select Visual C++ 10.0 (Visual Studio 2010) as the compiler.
  - When installing, all variants (Multithreaded, Single threaded, etc) should be installed,
    including the debug versions.

- Python 2.6 http://www.python.org/ftp/python/2.6/python-2.6.amd64.msi

- Cheetha 2.2.2 http://feisley.com/python/cheetah/Cheetah-2.2.2.win32-py2.6.exe

- UHD 003.002.001 http://files.ettus.com/binaries/uhd_stable/releases/uhd_003.002.001-release/UHD-003.002.001-win32.exe

- (Optional) Doxygen http://ftp.stack.nl/pub/users/dimitri/doxygen-1.8.2-setup.exe

- (Optional) Docutils http://docutils.sourceforge.net/



Setup Instructions:

1. Make sure PATH has the following in it:
   a. C:\Program Files (x86)\CMake 2.8\bin;C:\Program Files (x86)\UHD\bin;C:\Program Files (x86)\boost\boost_1_47\lib;
   b. Note, the directories are the default installation locations.
2. Use CMake to build the UHD Visual Studio Project. We are going to build UHD from scatch so all the dependencies and libraries
   are worked out to compile custom UHD applications.
   a. Use CMake to build the Visual Studio Project.
   b. Open CMake and set "Where is the source code:" to the locations of the UHD source code.
      For example, on my system it is: C:/home/test_build_uhd/usrpn210_r7/uhd/host
   c. Set the build directory to anywhere convient. I used C:/home/test_build_uhd/usrpn210_r7/uhd/host/build
   d. Click configure on the bottom.
   e. Depending on what you installed, the log should say atleast the following:
	######################################################
	# UHD enabled components                              
	######################################################
	  * LibUHD
	  * Examples
	  * Utils
	  * Tests
	  * USRP2
   f. Click Generate
3. Build the Visual Studio "ALL_BUILD" project file
   a. The project file is located in the build directory defined in CMake
   b. Make sure to include the directories for both the compiler and linker 
      "C:\Program Files(x86)\boost\boost_1_47\lib;C:\Program Files(x86)\UHD\include;C:\Program Files(x86)\boost\boost_1_47"
   c. Disable using Precompiled Headers
   d. This process can take a long time

   At thise point, UHD is successfully installed and compiled.

5. Setup the hardware.
   a. The ML605 and the USRP should be on the same network 192.168.10.xxx through a switch**.
      The USRP is configured for static IP 192.168.10.2. The ML605 is configured for static IP 192.168.1.100.
      Make sure your firewall does not filter these IPs.
   b. The FMC to Mictor Custom PCB should be attached to the ML605's High Density FMC connector J64. The MICTOR cable 
      should connect to J3 on the custom PCB and J301 on the USRP.

   ** CRUSH does not implement a TCP/IP stack. CRUSH sends UDP packets to a hard coded IP address and MAC address. 
      It inspects all received UDP packets, regardless of source, for a validation sequence in the payload to 
      determine if that packet was intended for CRUSH. The next revision will use a real TCP/IP stack.

5. Next, we need to install an updated FPGA image to the USRP N210. This is done via the USRP firmware burner GUI:
   C:\Program Files (x86)\UHD\share\uhd\utils\usrp_n2xx_net_burner_gui.py. The FPGA image is called 
   usrp_n210_r3_fpga.bin in \usrp\uhd\fpga\usrp2\top\N2x0\build-N210R3. The firmware image is called usrp_n210_fw.bin
   in C:\Program Files (x86)\UHD\share\uhd\images

   Note: The USRP firmware burner GUI requires a particular naming convention for the FPGA image files to be valid. 
         That is why the modified firmware file is called usrp_n210_r3_fpga.bin. The original FPGA image is in 
         C:\Program Files (x86)\UHD\share\uhd\images. Do not confuse the files!

6. Build the ML605 FPGA image with Xilinx ISE 12.4.
   a. The project is located in \crush\ml605_baseline\ml605\ise\ml605_usrp.xise.
      WARNING: This project location / structure is highly likely to change, as this is an alpha release.
   b. The source files are located in \crush\ml605_baseline\ml605\ise\source, \crush\ml605_baseline\ml605\ise\ipcore,
      \crush\ml605_baseline\ml605\edk\SMM_custom, \crush\ml605_baseline\usrp\uhd\fpga\usrp2\top\N2x0\build-N210R3,
      and \crush\ml605_baseline\usrp\uhd\fpga\usrp2\top\N2x0\build-N210R3\ipcore_dir
   c. Synthesize, Implement, and Generate Programming File in ISE.
   d. This design has an embedded soft processor (Microblaze), so after building the FPGA .bin file, we need to
      make a new SDK project, compile the software, and create a new .bit file loaded with our ELF file.
   d. Open the EDK project called "smm_i - smm" from within ISE.
   e. Generate the Hardware XML file for SDK via Project->"Export Hardware Design to SDK..." then select 
      Export & Launch SDK.
   f. Generate a new hw_platform via File->New->"Xilinx Hardware Platform Specification". Name the project and use the 
      Target Hardware Specification \crush\ml605_baseline\ml605\edk\SMM_custom\SDK\SDK_Export\hw\smm.xml
   g. Generate a new board support package via File->New->"Xilinx Board Support Package".
      Name the project, select the previously created HW Platform in "Target Hardware".
      Use the standalone OS.
   h. Create a new empty C project called "crush_microblaze" via File->New->"Xilinx C Project".
      Select "Target an existing Board Support Package" on the next page. Make sure to use the BSP previously created.
   i. Only one file is needed, main.c. Make sure it is in the src of the project in SDK. If not, add it.
   j. IMPORTANT: Update the Source MAC Address at line 223 with the MAC address found on a sticker on your ML605 board.
                 Update the Destination MAC Address at line 229 with the MAC address of your PC.
                 Example: Source MAC Address 11:22:33:44:55:66
                          Dest. Mac Address 77:88:99:AA:BB:CC
                   Line 223 -  XIo_Out32(0x10000044,0x00000011); // Dest MAC Address
                               XIo_Out32(0x10000044,0x00010022);
                               XIo_Out32(0x10000044,0x00020033);
                               XIo_Out32(0x10000044,0x00030044);
                               XIo_Out32(0x10000044,0x00040055);
                               XIo_Out32(0x10000044,0x00050066);
                               XIo_Out32(0x10000044,0x00000077); // Src MAC Address
                               XIo_Out32(0x10000044,0x00010088);
                               XIo_Out32(0x10000044,0x00020099);
                               XIo_Out32(0x10000044,0x000300AA);
                               XIo_Out32(0x10000044,0x000400BB);
                               XIo_Out32(0x10000044,0x000500CC);
      You are editing the IP header that the ML605 uses to send UDP packets.
   k. Compile the project via Project->Build All.
   l. Make sure you are connected via JTAG to the ML605. You can program it via "Xilinx Tools"->"Program FPGA". 
      Select the Bitstream: \crush\ml605_baseline\ml605\ise\top.bit
      Select the BMM File: \crush\ml605_baseline\ml605\ise\edkBmmFile_bd.bmm
      Select the ELF file you compiled (the name on your C project) instead of "bootloop".
      Note: If you power off the FPGA, it will need to be reprogrammed. It is possible to program the FPGA at
            powerup via the onboard Platform Flash or SystemACE
   
   Now the ML605 is properly programmed. The USRP must be configured to start sending data over the MICTOR cable.

7. Configure the USRP via software.
   a. Compile the C++ program in \crush\ml605_baseline\uhd\host\examples\rx_samples_to_file_demo.cpp similarly to 
      how UHD was compiled. You will need the same include directories.
   b. Run the executable, it will enable the USRP to send data via the MICTOR cable.

   Everything is setup at this point, now you can run the CRUSH Demo from MATLAB

8. Run the GUI (GUIDE command in MATLAB) \crush\ml605_baseline\matlab\crush_demo\CRUSH.fig.

At this point, you can see a FFT with thresholding of the input to the USRP.



PROBLEMS?

1. If you get any network errors in the MATLAB CRUSH Demo, this could be due to either the static IP addresses are 
   not setup correctly, the ML605 is not programmed properly, the USRP is not programmed properly, you did not run 
   the rx_samples_to_file_demo to configure the USRP, or something in the network is dropping packets. Wireshark
   can be very helpful in finding these issues. Another approach is to use the included Chipscope instance and examine
   the signals. One important signal is "packetValid", which asserts when the host PC sent a packet 
   with the correct validation sequence (DEADBEEF) and the ML605 received it properly.
2. The spectrum has some unusal noise spikes. I have been told this is due to the front end of the USRP (WBX card).
   As I continue my development, I will investigate this issue.
3. Sometimes the ML605 fails to send a packet to the MATLAB CRUSH Demo. This causes the MATLAB demo to issue a timeout
   warning. I am looking into this issue.
