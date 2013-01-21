CRUSH  
Cognitive Radio Universal Software Hardware  
http://www.coe.neu.edu/Research/rcl//projects/CRUSH.php  

Jonathon Pendlum (jon.pendlum@gmail.com)  
George Eichinger  
Miriam Leeser  
Kaushik Chowdhury  

The FPGA is an integral component of a software defined radio (SDR) that provides the needed reconfigurability for dynamically adapting its transceiver and data processing functions. Because of the desire to process data faster and with less latency, researchers are looking at FPGA-based SDR. Our architecture, called CRUSH (Cognitive Radio Universal Software Hardware), is composed of a Xilinx ML605 connected to an Ettus USRP through a custom interface board, allowing flexible data transfer between them. In addition, we provide a framework that supports ease of use, independent programming on both devices, and integration with software running on the host. To demonstrate our platform we implemented spectrum sensing, a key step in determining channel availability before transmission in dynamic spectrum access networks. Spectrum sensing is implemented on CRUSH using FFTs for a 100x speedup; the complete sensing cycles is 10x faster than the same design without CRUSH. By reducing the load on the host and allowing a powerful FPGA extension for off-the-shelf devices, CRUSH enables advances in both protocol design and reconfigurable hardware targeting radio applications.

Publications:

- George Eichinger, Kaushik Chowdhury, Miriam Leeser. " CRUSH: Cognitive Radio Universal Software Hardware ". 22nd International Conference on Field Programmable Logic and Applications, Oslo, Norway. August, 2012.
- CRUSH: Cognitive Radio Universal Software Hardware George Eichinger, MS Thesis, Northeastern University Dept. of ECE, April 2012. (PDF: http://www.coe.neu.edu/Research/rcl//theses/eichinger-msthesis2012.pdf)

Copyright:  
CRUSH is licensed under GPLv2: http://www.gnu.org/licenses/gpl-2.0.html

Directory Structure:

- fpga-ml605: CRUSH platform ported to the Xilinx ML605 (Virtex 6) Development Board
- fpga-ml707: CRUSH platform ported to the Xilinx ML707 (Virtex 7) Development Board
- host: MATLAB code to receive / plot data from CRUSH and C code to initialize the USRP hardware
- usrp-n210: Modified firmware for the USRP N210 to enable the debug port and interface with the CRUSH platform
- pcb: Schematic, bill of materials, gerber, and drill files for the custom printed circuit board used to interface the USRP with the ML605 / ML707 board
