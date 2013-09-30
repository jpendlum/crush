CRUSH  
Cognitive Radio Universal Software Hardware  

Jonathon Pendlum (jon.pendlum@gmail.com)  
Miriam Leeser  
Kaushik Chowdhury  

Cognitive radio algorithms require low latency, high performance signal processing to make real time decisions for spectrum sharing. Researchers have turned to software defined radios (SDR) to implement their algorithms due to SDR’s dynamic configurability and ease of programming. However, state of the art software defined radios, such as Ettus Research’s Universal Software Radio Peripheral (USRP), rely on a host computer to perform the signal processing at the cost of data transfer latency.

Our architecture, called CRUSH (Cognitive Radio Universal Software Hardware), reduces the data transfer latency by coupling a field programmable gate array (FPGA) with the USRP. The USRP forwards sampled data at full rate over a high-speed serial interface to the FPGA on a Xilinx ML605 board. This creates a hybrid software defined radio where the time critical signal processing is offloaded to the FPGA while the host computer implements higher level decisions. To demonstrate our platform we implemented spectrum sensing, a key step in cognitive radio algorithms that determines spectrum availability before transmitting. Spectrum sensing is inheriently sensitive to data delay; less latency reduces the chance for transmitting in an occupied channel. CRUSH’s implementation improves latency enabling faster response to changing wireless channel conditions.

http://www.coe.neu.edu/Research/rcl//projects/CRUSH.php

Directory Structure:

- fpga-ml605: CRUSH platform ported to the Xilinx ML605 (Virtex 6) Development Board
- host: MATLAB code to receive / plot data from CRUSH and C code to initialize the USRP hardware
- usrp-n210: Modified firmware for the USRP N210 to enable the debug port and interface with the CRUSH platform

Copyright:  
CRUSH is licensed under GPLv2: http://www.gnu.org/licenses/gpl-2.0.html
