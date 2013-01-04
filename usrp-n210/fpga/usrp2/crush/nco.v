////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: P.49d
//  \   \         Application: netgen
//  /   /         Filename: nco.v
// /___/   /\     Timestamp: Thu Jan  3 22:14:45 2013
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -w -sim -ofmt verilog /home/parallels/crush/usrp-n210/fpga/usrp2/crush/tmp/_cg/nco.ngc /home/parallels/crush/usrp-n210/fpga/usrp2/crush/tmp/_cg/nco.v 
// Device	: 3sd3400afg676-5
// Input file	: /home/parallels/crush/usrp-n210/fpga/usrp2/crush/tmp/_cg/nco.ngc
// Output file	: /home/parallels/crush/usrp-n210/fpga/usrp2/crush/tmp/_cg/nco.v
// # of Modules	: 1
// Design Name	: nco
// Xilinx        : /opt/Xilinx/14.4/ISE_DS/ISE/
//             
// Purpose:    
//     This verilog netlist is a verification model and uses simulation 
//     primitives which may not represent the true implementation of the 
//     device, however the netlist is functionally correct and should not 
//     be modified. This file cannot be synthesized and should only be used 
//     with supported simulation tools.
//             
// Reference:  
//     Command Line Tools User Guide, Chapter 23 and Synthesis and Simulation Design Guide, Chapter 6
//             
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/1 ps

module nco (
  clk, we, cosine, sine, data
)/* synthesis syn_black_box syn_noprune=1 */;
  input clk;
  input we;
  output [13 : 0] cosine;
  output [13 : 0] sine;
  input [15 : 0] data;
  
  // synthesis translate_off
  
  wire sig00000001;
  wire sig00000002;
  wire sig00000003;
  wire sig00000004;
  wire sig00000005;
  wire sig00000006;
  wire sig00000007;
  wire sig00000008;
  wire sig00000009;
  wire sig0000000a;
  wire sig0000000b;
  wire sig0000000c;
  wire sig0000000d;
  wire sig0000000e;
  wire sig0000000f;
  wire sig00000010;
  wire sig00000011;
  wire sig00000012;
  wire sig00000013;
  wire sig00000014;
  wire sig00000015;
  wire sig00000016;
  wire sig00000017;
  wire sig00000018;
  wire sig00000019;
  wire sig0000001a;
  wire sig0000001b;
  wire sig0000001c;
  wire sig0000001d;
  wire sig0000001e;
  wire sig0000001f;
  wire sig00000020;
  wire sig00000021;
  wire sig00000022;
  wire sig00000023;
  wire sig00000024;
  wire sig00000025;
  wire sig00000026;
  wire sig00000027;
  wire sig00000028;
  wire sig00000029;
  wire sig0000002a;
  wire sig0000002b;
  wire sig0000002c;
  wire sig0000002d;
  wire sig0000002e;
  wire sig0000002f;
  wire sig00000030;
  wire sig00000031;
  wire sig00000032;
  wire sig00000033;
  wire sig00000034;
  wire sig00000035;
  wire sig00000036;
  wire sig00000037;
  wire sig00000038;
  wire sig00000039;
  wire sig0000003a;
  wire sig0000003b;
  wire sig0000003c;
  wire sig0000003d;
  wire sig0000003e;
  wire sig0000003f;
  wire sig00000040;
  wire sig00000041;
  wire sig00000042;
  wire sig00000043;
  wire sig00000044;
  wire sig00000045;
  wire sig00000046;
  wire sig00000047;
  wire sig00000048;
  wire sig00000049;
  wire sig0000004a;
  wire sig0000004b;
  wire sig0000004c;
  wire sig0000004d;
  wire sig0000004e;
  wire sig0000004f;
  wire sig00000050;
  wire sig00000051;
  wire sig00000052;
  wire sig00000053;
  wire sig00000054;
  wire sig00000055;
  wire sig00000056;
  wire sig00000057;
  wire sig00000058;
  wire sig00000059;
  wire sig0000005a;
  wire sig0000005b;
  wire sig0000005c;
  wire sig0000005d;
  wire sig0000005e;
  wire sig0000005f;
  wire sig00000060;
  wire sig00000061;
  wire sig00000062;
  wire sig00000063;
  wire sig00000064;
  wire sig00000065;
  wire sig00000066;
  wire sig00000067;
  wire sig00000068;
  wire sig00000069;
  wire sig0000006a;
  wire sig0000006b;
  wire sig0000006c;
  wire sig0000006d;
  wire sig0000006e;
  wire sig0000006f;
  wire sig00000070;
  wire sig00000071;
  wire sig00000072;
  wire sig00000073;
  wire sig00000074;
  wire sig00000075;
  wire sig00000076;
  wire sig00000077;
  wire sig00000078;
  wire sig00000079;
  wire sig0000007a;
  wire sig0000007b;
  wire sig0000007c;
  wire sig0000007d;
  wire sig0000007e;
  wire sig0000007f;
  wire sig00000080;
  wire sig00000081;
  wire sig00000082;
  wire sig00000083;
  wire sig00000084;
  wire sig00000085;
  wire sig00000086;
  wire sig00000087;
  wire sig00000088;
  wire sig00000089;
  wire sig0000008a;
  wire sig0000008b;
  wire sig0000008c;
  wire sig0000008d;
  wire sig0000008e;
  wire sig0000008f;
  wire sig00000090;
  wire sig00000091;
  wire sig00000092;
  wire sig00000093;
  wire sig00000094;
  wire sig00000095;
  wire sig00000096;
  wire sig00000097;
  wire sig00000098;
  wire sig00000099;
  wire sig0000009a;
  wire sig0000009b;
  wire sig0000009c;
  wire sig0000009d;
  wire sig0000009e;
  wire sig0000009f;
  wire sig000000a0;
  wire sig000000a1;
  wire sig000000a2;
  wire sig000000a3;
  wire sig000000a4;
  wire sig000000a5;
  wire sig000000a6;
  wire sig000000a7;
  wire sig000000a8;
  wire sig000000a9;
  wire sig000000aa;
  wire sig000000ab;
  wire sig000000ac;
  wire sig000000ad;
  wire sig000000ae;
  wire sig000000af;
  wire sig000000b0;
  wire sig000000b1;
  wire sig000000b2;
  wire sig000000b3;
  wire sig000000b4;
  wire sig000000b5;
  wire sig000000b6;
  wire sig000000b7;
  wire sig000000b8;
  wire sig000000b9;
  wire sig000000ba;
  wire sig000000bb;
  wire sig000000bc;
  wire sig000000bd;
  wire sig000000be;
  wire sig000000bf;
  wire sig000000c0;
  wire sig000000c1;
  wire sig000000c2;
  wire sig000000c3;
  wire sig000000c4;
  wire sig000000c5;
  wire sig000000c6;
  wire sig000000c7;
  wire sig000000c8;
  wire sig000000c9;
  wire sig000000ca;
  wire sig000000cb;
  wire sig000000cc;
  wire sig000000cd;
  wire sig000000ce;
  wire sig000000cf;
  wire sig000000d0;
  wire sig000000d1;
  wire sig000000d2;
  wire sig000000d3;
  wire sig000000d4;
  wire sig000000d5;
  wire sig000000d6;
  wire sig000000d7;
  wire sig000000d8;
  wire sig000000d9;
  wire sig000000da;
  wire sig000000db;
  wire sig000000dc;
  wire sig000000dd;
  wire sig000000de;
  wire sig000000df;
  wire sig000000e0;
  wire sig000000e1;
  wire sig000000e2;
  wire sig000000e3;
  wire sig000000e4;
  wire sig000000e5;
  wire sig000000e6;
  wire sig000000e7;
  wire sig000000e8;
  wire sig000000e9;
  wire sig000000ea;
  wire sig000000eb;
  wire sig000000ec;
  wire sig000000ed;
  wire sig000000ee;
  wire sig000000ef;
  wire sig000000f0;
  wire sig000000f1;
  wire sig000000f2;
  wire sig000000f3;
  wire sig000000f4;
  wire sig000000f5;
  wire sig000000f6;
  wire sig000000f7;
  wire sig000000f8;
  wire sig000000f9;
  wire sig000000fa;
  wire sig000000fb;
  wire sig000000fc;
  wire sig000000fd;
  wire sig000000fe;
  wire sig000000ff;
  wire sig00000100;
  wire sig00000101;
  wire sig00000102;
  wire sig00000103;
  wire sig00000104;
  wire sig00000105;
  wire sig00000106;
  wire sig00000107;
  wire sig00000108;
  wire sig00000109;
  wire sig0000010a;
  wire sig0000010b;
  wire sig0000010c;
  wire sig0000010d;
  wire sig0000010e;
  wire sig0000010f;
  wire sig00000110;
  wire sig00000111;
  wire sig00000112;
  wire sig00000113;
  wire sig00000114;
  wire sig00000115;
  wire sig00000116;
  wire sig00000117;
  wire sig00000118;
  wire sig00000119;
  wire sig0000011a;
  wire sig0000011b;
  wire sig0000011c;
  wire sig0000011d;
  wire sig0000011e;
  wire sig0000011f;
  wire sig00000120;
  wire sig00000121;
  wire sig00000122;
  wire sig00000123;
  wire sig00000124;
  wire sig00000125;
  wire sig00000126;
  wire sig00000127;
  wire sig00000128;
  wire sig00000129;
  wire \NLW_blk00000124_ADDRA<1>_UNCONNECTED ;
  wire \NLW_blk00000124_ADDRA<0>_UNCONNECTED ;
  wire \NLW_blk00000124_ADDRB<1>_UNCONNECTED ;
  wire \NLW_blk00000124_ADDRB<0>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<31>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<30>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<29>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<28>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<27>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<26>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<25>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<24>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<23>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<22>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<21>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<20>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<19>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<18>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<17>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<16>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<15>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<14>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<13>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<12>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<11>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<10>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<9>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<8>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<7>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<6>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<5>_UNCONNECTED ;
  wire \NLW_blk00000124_DIA<4>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<31>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<30>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<29>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<28>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<27>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<26>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<25>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<24>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<23>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<22>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<21>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<20>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<19>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<18>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<17>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<16>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<15>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<14>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<13>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<12>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<11>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<10>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<9>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<8>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<7>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<6>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<5>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<4>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<3>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<2>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<1>_UNCONNECTED ;
  wire \NLW_blk00000124_DIB<0>_UNCONNECTED ;
  wire \NLW_blk00000124_DIPA<3>_UNCONNECTED ;
  wire \NLW_blk00000124_DIPA<2>_UNCONNECTED ;
  wire \NLW_blk00000124_DIPA<1>_UNCONNECTED ;
  wire \NLW_blk00000124_DIPA<0>_UNCONNECTED ;
  wire \NLW_blk00000124_DIPB<3>_UNCONNECTED ;
  wire \NLW_blk00000124_DIPB<2>_UNCONNECTED ;
  wire \NLW_blk00000124_DIPB<1>_UNCONNECTED ;
  wire \NLW_blk00000124_DIPB<0>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<31>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<30>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<29>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<28>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<27>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<26>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<25>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<24>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<23>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<22>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<21>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<20>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<19>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<18>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<17>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<16>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<15>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<14>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<13>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<12>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<11>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<10>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<9>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<8>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<7>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<6>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<5>_UNCONNECTED ;
  wire \NLW_blk00000124_DOA<4>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<31>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<30>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<29>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<28>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<27>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<26>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<25>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<24>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<23>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<22>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<21>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<20>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<19>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<18>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<17>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<16>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<15>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<14>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<13>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<12>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<11>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<10>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<9>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<8>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<7>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<6>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<5>_UNCONNECTED ;
  wire \NLW_blk00000124_DOB<4>_UNCONNECTED ;
  wire \NLW_blk00000124_DOPA<3>_UNCONNECTED ;
  wire \NLW_blk00000124_DOPA<2>_UNCONNECTED ;
  wire \NLW_blk00000124_DOPA<1>_UNCONNECTED ;
  wire \NLW_blk00000124_DOPA<0>_UNCONNECTED ;
  wire \NLW_blk00000124_DOPB<3>_UNCONNECTED ;
  wire \NLW_blk00000124_DOPB<2>_UNCONNECTED ;
  wire \NLW_blk00000124_DOPB<1>_UNCONNECTED ;
  wire \NLW_blk00000124_DOPB<0>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<31>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<30>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<29>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<28>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<27>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<26>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<25>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<24>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<23>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<22>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<21>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<20>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<19>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<18>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<17>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<16>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<15>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<14>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<13>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<12>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<11>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<10>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<9>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<8>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<7>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<6>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<5>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<4>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<3>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<2>_UNCONNECTED ;
  wire \NLW_blk00000125_DIA<1>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<31>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<30>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<29>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<28>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<27>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<26>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<25>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<24>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<23>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<22>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<21>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<20>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<19>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<18>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<17>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<16>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<15>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<14>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<13>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<12>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<11>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<10>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<9>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<8>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<7>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<6>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<5>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<4>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<3>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<2>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<1>_UNCONNECTED ;
  wire \NLW_blk00000125_DIB<0>_UNCONNECTED ;
  wire \NLW_blk00000125_DIPA<3>_UNCONNECTED ;
  wire \NLW_blk00000125_DIPA<2>_UNCONNECTED ;
  wire \NLW_blk00000125_DIPA<1>_UNCONNECTED ;
  wire \NLW_blk00000125_DIPA<0>_UNCONNECTED ;
  wire \NLW_blk00000125_DIPB<3>_UNCONNECTED ;
  wire \NLW_blk00000125_DIPB<2>_UNCONNECTED ;
  wire \NLW_blk00000125_DIPB<1>_UNCONNECTED ;
  wire \NLW_blk00000125_DIPB<0>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<31>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<30>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<29>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<28>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<27>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<26>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<25>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<24>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<23>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<22>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<21>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<20>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<19>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<18>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<17>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<16>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<15>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<14>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<13>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<12>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<11>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<10>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<9>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<8>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<7>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<6>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<5>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<4>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<3>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<2>_UNCONNECTED ;
  wire \NLW_blk00000125_DOA<1>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<31>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<30>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<29>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<28>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<27>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<26>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<25>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<24>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<23>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<22>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<21>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<20>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<19>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<18>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<17>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<16>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<15>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<14>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<13>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<12>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<11>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<10>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<9>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<8>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<7>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<6>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<5>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<4>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<3>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<2>_UNCONNECTED ;
  wire \NLW_blk00000125_DOB<1>_UNCONNECTED ;
  wire \NLW_blk00000125_DOPA<3>_UNCONNECTED ;
  wire \NLW_blk00000125_DOPA<2>_UNCONNECTED ;
  wire \NLW_blk00000125_DOPA<1>_UNCONNECTED ;
  wire \NLW_blk00000125_DOPA<0>_UNCONNECTED ;
  wire \NLW_blk00000125_DOPB<3>_UNCONNECTED ;
  wire \NLW_blk00000125_DOPB<2>_UNCONNECTED ;
  wire \NLW_blk00000125_DOPB<1>_UNCONNECTED ;
  wire \NLW_blk00000125_DOPB<0>_UNCONNECTED ;
  wire \NLW_blk00000126_ADDRA<1>_UNCONNECTED ;
  wire \NLW_blk00000126_ADDRA<0>_UNCONNECTED ;
  wire \NLW_blk00000126_ADDRB<1>_UNCONNECTED ;
  wire \NLW_blk00000126_ADDRB<0>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<31>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<30>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<29>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<28>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<27>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<26>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<25>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<24>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<23>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<22>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<21>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<20>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<19>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<18>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<17>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<16>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<15>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<14>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<13>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<12>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<11>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<10>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<9>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<8>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<7>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<6>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<5>_UNCONNECTED ;
  wire \NLW_blk00000126_DIA<4>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<31>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<30>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<29>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<28>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<27>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<26>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<25>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<24>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<23>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<22>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<21>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<20>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<19>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<18>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<17>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<16>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<15>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<14>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<13>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<12>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<11>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<10>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<9>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<8>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<7>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<6>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<5>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<4>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<3>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<2>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<1>_UNCONNECTED ;
  wire \NLW_blk00000126_DIB<0>_UNCONNECTED ;
  wire \NLW_blk00000126_DIPA<3>_UNCONNECTED ;
  wire \NLW_blk00000126_DIPA<2>_UNCONNECTED ;
  wire \NLW_blk00000126_DIPA<1>_UNCONNECTED ;
  wire \NLW_blk00000126_DIPA<0>_UNCONNECTED ;
  wire \NLW_blk00000126_DIPB<3>_UNCONNECTED ;
  wire \NLW_blk00000126_DIPB<2>_UNCONNECTED ;
  wire \NLW_blk00000126_DIPB<1>_UNCONNECTED ;
  wire \NLW_blk00000126_DIPB<0>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<31>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<30>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<29>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<28>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<27>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<26>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<25>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<24>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<23>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<22>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<21>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<20>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<19>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<18>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<17>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<16>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<15>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<14>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<13>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<12>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<11>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<10>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<9>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<8>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<7>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<6>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<5>_UNCONNECTED ;
  wire \NLW_blk00000126_DOA<4>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<31>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<30>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<29>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<28>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<27>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<26>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<25>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<24>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<23>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<22>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<21>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<20>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<19>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<18>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<17>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<16>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<15>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<14>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<13>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<12>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<11>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<10>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<9>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<8>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<7>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<6>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<5>_UNCONNECTED ;
  wire \NLW_blk00000126_DOB<4>_UNCONNECTED ;
  wire \NLW_blk00000126_DOPA<3>_UNCONNECTED ;
  wire \NLW_blk00000126_DOPA<2>_UNCONNECTED ;
  wire \NLW_blk00000126_DOPA<1>_UNCONNECTED ;
  wire \NLW_blk00000126_DOPA<0>_UNCONNECTED ;
  wire \NLW_blk00000126_DOPB<3>_UNCONNECTED ;
  wire \NLW_blk00000126_DOPB<2>_UNCONNECTED ;
  wire \NLW_blk00000126_DOPB<1>_UNCONNECTED ;
  wire \NLW_blk00000126_DOPB<0>_UNCONNECTED ;
  wire \NLW_blk00000127_ADDRA<1>_UNCONNECTED ;
  wire \NLW_blk00000127_ADDRA<0>_UNCONNECTED ;
  wire \NLW_blk00000127_ADDRB<1>_UNCONNECTED ;
  wire \NLW_blk00000127_ADDRB<0>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<31>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<30>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<29>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<28>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<27>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<26>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<25>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<24>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<23>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<22>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<21>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<20>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<19>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<18>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<17>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<16>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<15>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<14>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<13>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<12>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<11>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<10>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<9>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<8>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<7>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<6>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<5>_UNCONNECTED ;
  wire \NLW_blk00000127_DIA<4>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<31>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<30>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<29>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<28>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<27>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<26>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<25>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<24>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<23>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<22>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<21>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<20>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<19>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<18>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<17>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<16>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<15>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<14>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<13>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<12>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<11>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<10>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<9>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<8>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<7>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<6>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<5>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<4>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<3>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<2>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<1>_UNCONNECTED ;
  wire \NLW_blk00000127_DIB<0>_UNCONNECTED ;
  wire \NLW_blk00000127_DIPA<3>_UNCONNECTED ;
  wire \NLW_blk00000127_DIPA<2>_UNCONNECTED ;
  wire \NLW_blk00000127_DIPA<1>_UNCONNECTED ;
  wire \NLW_blk00000127_DIPA<0>_UNCONNECTED ;
  wire \NLW_blk00000127_DIPB<3>_UNCONNECTED ;
  wire \NLW_blk00000127_DIPB<2>_UNCONNECTED ;
  wire \NLW_blk00000127_DIPB<1>_UNCONNECTED ;
  wire \NLW_blk00000127_DIPB<0>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<31>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<30>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<29>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<28>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<27>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<26>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<25>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<24>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<23>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<22>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<21>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<20>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<19>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<18>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<17>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<16>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<15>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<14>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<13>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<12>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<11>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<10>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<9>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<8>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<7>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<6>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<5>_UNCONNECTED ;
  wire \NLW_blk00000127_DOA<4>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<31>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<30>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<29>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<28>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<27>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<26>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<25>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<24>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<23>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<22>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<21>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<20>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<19>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<18>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<17>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<16>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<15>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<14>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<13>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<12>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<11>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<10>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<9>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<8>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<7>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<6>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<5>_UNCONNECTED ;
  wire \NLW_blk00000127_DOB<4>_UNCONNECTED ;
  wire \NLW_blk00000127_DOPA<3>_UNCONNECTED ;
  wire \NLW_blk00000127_DOPA<2>_UNCONNECTED ;
  wire \NLW_blk00000127_DOPA<1>_UNCONNECTED ;
  wire \NLW_blk00000127_DOPA<0>_UNCONNECTED ;
  wire \NLW_blk00000127_DOPB<3>_UNCONNECTED ;
  wire \NLW_blk00000127_DOPB<2>_UNCONNECTED ;
  wire \NLW_blk00000127_DOPB<1>_UNCONNECTED ;
  wire \NLW_blk00000127_DOPB<0>_UNCONNECTED ;
  wire [6 : 0] \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ls/first_q ;
  wire [6 : 0] \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ms/first_q ;
  wire [6 : 0] \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ls/first_q ;
  wire [6 : 0] \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ms/first_q ;
  assign
    cosine[13] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ms/first_q [6],
    cosine[12] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ms/first_q [5],
    cosine[11] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ms/first_q [4],
    cosine[10] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ms/first_q [3],
    cosine[9] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ms/first_q [2],
    cosine[8] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ms/first_q [1],
    cosine[7] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ms/first_q [0],
    cosine[6] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ls/first_q [6],
    cosine[5] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ls/first_q [5],
    cosine[4] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ls/first_q [4],
    cosine[3] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ls/first_q [3],
    cosine[2] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ls/first_q [2],
    cosine[1] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ls/first_q [1],
    cosine[0] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ls/first_q [0],
    sine[13] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ms/first_q [6],
    sine[12] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ms/first_q [5],
    sine[11] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ms/first_q [4],
    sine[10] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ms/first_q [3],
    sine[9] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ms/first_q [2],
    sine[8] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ms/first_q [1],
    sine[7] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ms/first_q [0],
    sine[6] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ls/first_q [6],
    sine[5] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ls/first_q [5],
    sine[4] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ls/first_q [4],
    sine[3] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ls/first_q [3],
    sine[2] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ls/first_q [2],
    sine[1] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ls/first_q [1],
    sine[0] = \U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ls/first_q [0];
  GND   blk00000001 (
    .G(sig00000001)
  );
  VCC   blk00000002 (
    .P(sig00000002)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000003 (
    .C(clk),
    .D(sig00000093),
    .Q(sig00000112)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000004 (
    .C(clk),
    .D(sig00000096),
    .Q(sig00000113)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000005 (
    .C(clk),
    .D(sig00000097),
    .Q(sig00000116)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000006 (
    .C(clk),
    .D(sig00000098),
    .Q(sig00000117)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000007 (
    .C(clk),
    .D(sig00000099),
    .Q(sig00000118)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000008 (
    .C(clk),
    .D(sig0000009a),
    .Q(sig00000119)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000009 (
    .C(clk),
    .D(sig0000009b),
    .Q(sig0000011a)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000000a (
    .C(clk),
    .D(sig0000009c),
    .Q(sig0000011b)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000000b (
    .C(clk),
    .D(sig0000009d),
    .Q(sig0000011c)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000000c (
    .C(clk),
    .D(sig0000009e),
    .Q(sig0000011d)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000000d (
    .C(clk),
    .D(sig00000094),
    .Q(sig00000114)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000000e (
    .C(clk),
    .D(sig00000095),
    .Q(sig00000115)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000000f (
    .C(clk),
    .D(sig0000009f),
    .Q(sig0000011e)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000010 (
    .C(clk),
    .D(sig000000a2),
    .Q(sig0000011f)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000011 (
    .C(clk),
    .D(sig000000a3),
    .Q(sig00000122)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000012 (
    .C(clk),
    .D(sig000000a4),
    .Q(sig00000123)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000013 (
    .C(clk),
    .D(sig000000a5),
    .Q(sig00000124)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000014 (
    .C(clk),
    .D(sig000000a6),
    .Q(sig00000125)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000015 (
    .C(clk),
    .D(sig000000a7),
    .Q(sig00000126)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000016 (
    .C(clk),
    .D(sig000000a8),
    .Q(sig00000127)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000017 (
    .C(clk),
    .D(sig000000a9),
    .Q(sig00000128)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000018 (
    .C(clk),
    .D(sig000000aa),
    .Q(sig00000129)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000019 (
    .C(clk),
    .D(sig000000a0),
    .Q(sig00000120)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000001a (
    .C(clk),
    .D(sig000000a1),
    .Q(sig00000121)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000001b (
    .C(clk),
    .D(sig000000e0),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ls/first_q [6])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000001c (
    .C(clk),
    .D(sig000000df),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ls/first_q [5])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000001d (
    .C(clk),
    .D(sig000000de),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ls/first_q [4])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000001e (
    .C(clk),
    .D(sig000000dd),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ls/first_q [3])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000001f (
    .C(clk),
    .D(sig000000dc),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ls/first_q [2])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000020 (
    .C(clk),
    .D(sig000000db),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ls/first_q [1])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000021 (
    .C(clk),
    .D(sig000000da),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ls/first_q [0])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000022 (
    .C(clk),
    .D(sig00000092),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ms/first_q [6])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000023 (
    .C(clk),
    .D(sig00000091),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ms/first_q [5])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000024 (
    .C(clk),
    .D(sig00000090),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ms/first_q [4])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000025 (
    .C(clk),
    .D(sig0000008f),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ms/first_q [3])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000026 (
    .C(clk),
    .D(sig0000008e),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ms/first_q [2])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000027 (
    .C(clk),
    .D(sig0000008d),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ms/first_q [1])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000028 (
    .C(clk),
    .D(sig0000005e),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_cos_ms/first_q [0])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000029 (
    .C(clk),
    .D(sig000000ef),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ls/first_q [6])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000002a (
    .C(clk),
    .D(sig000000ee),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ls/first_q [5])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000002b (
    .C(clk),
    .D(sig000000ed),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ls/first_q [4])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000002c (
    .C(clk),
    .D(sig000000ec),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ls/first_q [3])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000002d (
    .C(clk),
    .D(sig000000eb),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ls/first_q [2])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000002e (
    .C(clk),
    .D(sig000000ea),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ls/first_q [1])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000002f (
    .C(clk),
    .D(sig000000e9),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ls/first_q [0])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000030 (
    .C(clk),
    .D(sig000000d0),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ms/first_q [6])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000031 (
    .C(clk),
    .D(sig000000cf),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ms/first_q [5])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000032 (
    .C(clk),
    .D(sig000000ce),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ms/first_q [4])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000033 (
    .C(clk),
    .D(sig000000cd),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ms/first_q [3])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000034 (
    .C(clk),
    .D(sig000000cc),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ms/first_q [2])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000035 (
    .C(clk),
    .D(sig000000cb),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ms/first_q [1])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000036 (
    .C(clk),
    .D(sig00000069),
    .Q(\U0/i_synth/I_SINCOS.i_rom/i_rtl.i_quarter_table.i_piped_map.i_cardinal_sin_ms/first_q [0])
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000037 (
    .C(clk),
    .D(sig0000008c),
    .Q(sig000000e8)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000038 (
    .C(clk),
    .D(sig0000008b),
    .Q(sig000000e7)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000039 (
    .C(clk),
    .D(sig0000008a),
    .Q(sig000000e6)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000003a (
    .C(clk),
    .D(sig00000089),
    .Q(sig000000e5)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000003b (
    .C(clk),
    .D(sig00000088),
    .Q(sig000000e4)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000003c (
    .C(clk),
    .D(sig00000087),
    .Q(sig000000e3)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000003d (
    .C(clk),
    .D(sig00000086),
    .Q(sig000000e2)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000003e (
    .C(clk),
    .D(sig000000d7),
    .Q(sig000000f7)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000003f (
    .C(clk),
    .D(sig000000ca),
    .Q(sig000000f6)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000040 (
    .C(clk),
    .D(sig000000c9),
    .Q(sig000000f5)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000041 (
    .C(clk),
    .D(sig000000c8),
    .Q(sig000000f4)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000042 (
    .C(clk),
    .D(sig000000c7),
    .Q(sig000000f3)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000043 (
    .C(clk),
    .D(sig000000c6),
    .Q(sig000000f2)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000044 (
    .C(clk),
    .D(sig000000c5),
    .Q(sig000000f1)
  );
  MUXCY   blk00000045 (
    .CI(sig00000001),
    .DI(sig00000002),
    .S(sig0000005c),
    .O(sig00000054)
  );
  MUXCY   blk00000046 (
    .CI(sig00000054),
    .DI(sig00000001),
    .S(sig0000007f),
    .O(sig00000055)
  );
  XORCY   blk00000047 (
    .CI(sig00000054),
    .LI(sig0000007f),
    .O(sig00000078)
  );
  MUXCY   blk00000048 (
    .CI(sig00000055),
    .DI(sig00000001),
    .S(sig00000080),
    .O(sig00000056)
  );
  XORCY   blk00000049 (
    .CI(sig00000055),
    .LI(sig00000080),
    .O(sig00000079)
  );
  MUXCY   blk0000004a (
    .CI(sig00000056),
    .DI(sig00000001),
    .S(sig00000081),
    .O(sig00000057)
  );
  XORCY   blk0000004b (
    .CI(sig00000056),
    .LI(sig00000081),
    .O(sig0000007a)
  );
  MUXCY   blk0000004c (
    .CI(sig00000057),
    .DI(sig00000001),
    .S(sig00000082),
    .O(sig00000058)
  );
  XORCY   blk0000004d (
    .CI(sig00000057),
    .LI(sig00000082),
    .O(sig0000007b)
  );
  MUXCY   blk0000004e (
    .CI(sig00000058),
    .DI(sig00000001),
    .S(sig00000083),
    .O(sig00000059)
  );
  XORCY   blk0000004f (
    .CI(sig00000058),
    .LI(sig00000083),
    .O(sig0000007c)
  );
  MUXCY   blk00000050 (
    .CI(sig00000059),
    .DI(sig00000001),
    .S(sig00000084),
    .O(sig0000005a)
  );
  XORCY   blk00000051 (
    .CI(sig00000059),
    .LI(sig00000084),
    .O(sig0000007d)
  );
  MUXCY   blk00000052 (
    .CI(sig0000005a),
    .DI(sig00000001),
    .S(sig00000085),
    .O(sig0000005b)
  );
  XORCY   blk00000053 (
    .CI(sig0000005a),
    .LI(sig00000085),
    .O(sig0000007e)
  );
  MUXCY   blk00000054 (
    .CI(sig00000001),
    .DI(sig000000d7),
    .S(sig00000061),
    .O(sig00000060)
  );
  XORCY   blk00000055 (
    .CI(sig00000001),
    .LI(sig00000061),
    .O(sig000000b8)
  );
  MUXCY   blk00000056 (
    .CI(sig00000060),
    .DI(sig00000001),
    .S(sig000000bf),
    .O(sig00000062)
  );
  XORCY   blk00000057 (
    .CI(sig00000060),
    .LI(sig000000bf),
    .O(sig000000b9)
  );
  MUXCY   blk00000058 (
    .CI(sig00000062),
    .DI(sig00000001),
    .S(sig000000c0),
    .O(sig00000063)
  );
  XORCY   blk00000059 (
    .CI(sig00000062),
    .LI(sig000000c0),
    .O(sig000000ba)
  );
  MUXCY   blk0000005a (
    .CI(sig00000063),
    .DI(sig00000001),
    .S(sig000000c1),
    .O(sig00000064)
  );
  XORCY   blk0000005b (
    .CI(sig00000063),
    .LI(sig000000c1),
    .O(sig000000bb)
  );
  MUXCY   blk0000005c (
    .CI(sig00000064),
    .DI(sig00000001),
    .S(sig000000c2),
    .O(sig00000065)
  );
  XORCY   blk0000005d (
    .CI(sig00000064),
    .LI(sig000000c2),
    .O(sig000000bc)
  );
  MUXCY   blk0000005e (
    .CI(sig00000065),
    .DI(sig00000001),
    .S(sig000000c3),
    .O(sig00000066)
  );
  XORCY   blk0000005f (
    .CI(sig00000065),
    .LI(sig000000c3),
    .O(sig000000bd)
  );
  MUXCY   blk00000060 (
    .CI(sig00000066),
    .DI(sig00000001),
    .S(sig000000c4),
    .O(sig00000067)
  );
  XORCY   blk00000061 (
    .CI(sig00000066),
    .LI(sig000000c4),
    .O(sig000000be)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000062 (
    .C(clk),
    .D(sig000000d5),
    .Q(sig000000d7)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000063 (
    .C(clk),
    .D(sig00000029),
    .Q(sig000000d4)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000064 (
    .C(clk),
    .D(sig00000028),
    .Q(sig000000d3)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000065 (
    .C(clk),
    .D(sig0000006e),
    .Q(sig00000108)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000066 (
    .C(clk),
    .D(sig0000006d),
    .Q(sig00000107)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000067 (
    .C(clk),
    .D(sig0000006c),
    .Q(sig00000106)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000068 (
    .C(clk),
    .D(sig00000077),
    .Q(sig00000111)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000069 (
    .C(clk),
    .D(sig00000076),
    .Q(sig00000110)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000006a (
    .C(clk),
    .D(sig00000075),
    .Q(sig0000010f)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000006b (
    .C(clk),
    .D(sig00000074),
    .Q(sig0000010e)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000006c (
    .C(clk),
    .D(sig00000073),
    .Q(sig0000010d)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000006d (
    .C(clk),
    .D(sig00000072),
    .Q(sig0000010c)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000006e (
    .C(clk),
    .D(sig00000071),
    .Q(sig0000010b)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000006f (
    .C(clk),
    .D(sig00000070),
    .Q(sig0000010a)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000070 (
    .C(clk),
    .D(sig0000006f),
    .Q(sig00000109)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000071 (
    .C(clk),
    .D(sig0000006b),
    .Q(sig00000105)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000072 (
    .C(clk),
    .D(sig000000ae),
    .Q(sig000000fb)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000073 (
    .C(clk),
    .D(sig000000ad),
    .Q(sig000000fa)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000074 (
    .C(clk),
    .D(sig000000ac),
    .Q(sig000000f9)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000075 (
    .C(clk),
    .D(sig000000b7),
    .Q(sig00000104)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000076 (
    .C(clk),
    .D(sig000000b6),
    .Q(sig00000103)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000077 (
    .C(clk),
    .D(sig000000b5),
    .Q(sig00000102)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000078 (
    .C(clk),
    .D(sig000000b4),
    .Q(sig00000101)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000079 (
    .C(clk),
    .D(sig000000b3),
    .Q(sig00000100)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000007a (
    .C(clk),
    .D(sig000000b2),
    .Q(sig000000ff)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000007b (
    .C(clk),
    .D(sig000000b1),
    .Q(sig000000fe)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000007c (
    .C(clk),
    .D(sig000000b0),
    .Q(sig000000fd)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000007d (
    .C(clk),
    .D(sig000000af),
    .Q(sig000000fc)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000007e (
    .C(clk),
    .D(sig000000ab),
    .Q(sig000000f8)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000007f (
    .C(clk),
    .D(sig0000005b),
    .Q(sig000000e1)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000080 (
    .C(clk),
    .D(sig0000007e),
    .Q(sig000000e0)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000081 (
    .C(clk),
    .D(sig0000007d),
    .Q(sig000000df)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000082 (
    .C(clk),
    .D(sig0000007c),
    .Q(sig000000de)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000083 (
    .C(clk),
    .D(sig0000007b),
    .Q(sig000000dd)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000084 (
    .C(clk),
    .D(sig0000007a),
    .Q(sig000000dc)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000085 (
    .C(clk),
    .D(sig00000079),
    .Q(sig000000db)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000086 (
    .C(clk),
    .D(sig00000078),
    .Q(sig000000da)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000087 (
    .C(clk),
    .D(sig00000067),
    .Q(sig000000f0)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000088 (
    .C(clk),
    .D(sig000000be),
    .Q(sig000000ef)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000089 (
    .C(clk),
    .D(sig000000bd),
    .Q(sig000000ee)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000008a (
    .C(clk),
    .D(sig000000bc),
    .Q(sig000000ed)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000008b (
    .C(clk),
    .D(sig000000bb),
    .Q(sig000000ec)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000008c (
    .C(clk),
    .D(sig000000ba),
    .Q(sig000000eb)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000008d (
    .C(clk),
    .D(sig000000b9),
    .Q(sig000000ea)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000008e (
    .C(clk),
    .D(sig000000b8),
    .Q(sig000000e9)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000008f (
    .C(clk),
    .D(sig00000003),
    .Q(sig00000023)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000090 (
    .C(clk),
    .D(sig0000000a),
    .Q(sig0000002b)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000091 (
    .C(clk),
    .D(sig0000000b),
    .Q(sig0000002c)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000092 (
    .C(clk),
    .D(sig0000000c),
    .Q(sig0000002d)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000093 (
    .C(clk),
    .D(sig0000000d),
    .Q(sig0000002e)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000094 (
    .C(clk),
    .D(sig0000000e),
    .Q(sig0000002f)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000095 (
    .C(clk),
    .D(sig0000000f),
    .Q(sig00000030)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000096 (
    .C(clk),
    .D(sig00000010),
    .Q(sig00000031)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000097 (
    .C(clk),
    .D(sig00000011),
    .Q(sig00000032)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000098 (
    .C(clk),
    .D(sig00000012),
    .Q(sig00000033)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000099 (
    .C(clk),
    .D(sig00000004),
    .Q(sig00000024)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000009a (
    .C(clk),
    .D(sig00000005),
    .Q(sig00000025)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000009b (
    .C(clk),
    .D(sig00000006),
    .Q(sig00000026)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000009c (
    .C(clk),
    .D(sig00000007),
    .Q(sig00000027)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000009d (
    .C(clk),
    .D(sig00000008),
    .Q(sig00000028)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000009e (
    .C(clk),
    .D(sig00000009),
    .Q(sig00000029)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000009f (
    .C(clk),
    .D(sig0000003a),
    .Q(sig0000002a)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000a0 (
    .C(clk),
    .CE(we),
    .D(data[0]),
    .Q(sig00000013)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000a1 (
    .C(clk),
    .CE(we),
    .D(data[1]),
    .Q(sig0000001a)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000a2 (
    .C(clk),
    .CE(we),
    .D(data[2]),
    .Q(sig0000001b)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000a3 (
    .C(clk),
    .CE(we),
    .D(data[3]),
    .Q(sig0000001c)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000a4 (
    .C(clk),
    .CE(we),
    .D(data[4]),
    .Q(sig0000001d)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000a5 (
    .C(clk),
    .CE(we),
    .D(data[5]),
    .Q(sig0000001e)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000a6 (
    .C(clk),
    .CE(we),
    .D(data[6]),
    .Q(sig0000001f)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000a7 (
    .C(clk),
    .CE(we),
    .D(data[7]),
    .Q(sig00000020)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000a8 (
    .C(clk),
    .CE(we),
    .D(data[8]),
    .Q(sig00000021)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000a9 (
    .C(clk),
    .CE(we),
    .D(data[9]),
    .Q(sig00000022)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000aa (
    .C(clk),
    .CE(we),
    .D(data[10]),
    .Q(sig00000014)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000ab (
    .C(clk),
    .CE(we),
    .D(data[11]),
    .Q(sig00000015)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000ac (
    .C(clk),
    .CE(we),
    .D(data[12]),
    .Q(sig00000016)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000ad (
    .C(clk),
    .CE(we),
    .D(data[13]),
    .Q(sig00000017)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000ae (
    .C(clk),
    .CE(we),
    .D(data[14]),
    .Q(sig00000018)
  );
  FDE #(
    .INIT ( 1'b0 ))
  blk000000af (
    .C(clk),
    .CE(we),
    .D(data[15]),
    .Q(sig00000019)
  );
  XORCY   blk000000b0 (
    .CI(sig00000039),
    .LI(sig0000004a),
    .O(sig00000009)
  );
  MUXCY   blk000000b1 (
    .CI(sig00000039),
    .DI(sig00000029),
    .S(sig0000004a),
    .O(sig0000003a)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000b2 (
    .I0(sig00000029),
    .I1(sig00000019),
    .O(sig0000004a)
  );
  XORCY   blk000000b3 (
    .CI(sig00000038),
    .LI(sig00000049),
    .O(sig00000008)
  );
  MUXCY   blk000000b4 (
    .CI(sig00000038),
    .DI(sig00000028),
    .S(sig00000049),
    .O(sig00000039)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000b5 (
    .I0(sig00000018),
    .I1(sig00000028),
    .O(sig00000049)
  );
  XORCY   blk000000b6 (
    .CI(sig00000037),
    .LI(sig00000048),
    .O(sig00000007)
  );
  MUXCY   blk000000b7 (
    .CI(sig00000037),
    .DI(sig00000027),
    .S(sig00000048),
    .O(sig00000038)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000b8 (
    .I0(sig00000017),
    .I1(sig00000027),
    .O(sig00000048)
  );
  XORCY   blk000000b9 (
    .CI(sig00000036),
    .LI(sig00000047),
    .O(sig00000006)
  );
  MUXCY   blk000000ba (
    .CI(sig00000036),
    .DI(sig00000026),
    .S(sig00000047),
    .O(sig00000037)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000bb (
    .I0(sig00000016),
    .I1(sig00000026),
    .O(sig00000047)
  );
  XORCY   blk000000bc (
    .CI(sig00000035),
    .LI(sig00000046),
    .O(sig00000005)
  );
  MUXCY   blk000000bd (
    .CI(sig00000035),
    .DI(sig00000025),
    .S(sig00000046),
    .O(sig00000036)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000be (
    .I0(sig00000015),
    .I1(sig00000025),
    .O(sig00000046)
  );
  XORCY   blk000000bf (
    .CI(sig00000043),
    .LI(sig00000045),
    .O(sig00000004)
  );
  MUXCY   blk000000c0 (
    .CI(sig00000043),
    .DI(sig00000024),
    .S(sig00000045),
    .O(sig00000035)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000c1 (
    .I0(sig00000014),
    .I1(sig00000024),
    .O(sig00000045)
  );
  XORCY   blk000000c2 (
    .CI(sig00000042),
    .LI(sig00000053),
    .O(sig00000012)
  );
  MUXCY   blk000000c3 (
    .CI(sig00000042),
    .DI(sig00000033),
    .S(sig00000053),
    .O(sig00000043)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000c4 (
    .I0(sig00000022),
    .I1(sig00000033),
    .O(sig00000053)
  );
  XORCY   blk000000c5 (
    .CI(sig00000041),
    .LI(sig00000052),
    .O(sig00000011)
  );
  MUXCY   blk000000c6 (
    .CI(sig00000041),
    .DI(sig00000032),
    .S(sig00000052),
    .O(sig00000042)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000c7 (
    .I0(sig00000021),
    .I1(sig00000032),
    .O(sig00000052)
  );
  XORCY   blk000000c8 (
    .CI(sig00000040),
    .LI(sig00000051),
    .O(sig00000010)
  );
  MUXCY   blk000000c9 (
    .CI(sig00000040),
    .DI(sig00000031),
    .S(sig00000051),
    .O(sig00000041)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000ca (
    .I0(sig00000020),
    .I1(sig00000031),
    .O(sig00000051)
  );
  XORCY   blk000000cb (
    .CI(sig0000003f),
    .LI(sig00000050),
    .O(sig0000000f)
  );
  MUXCY   blk000000cc (
    .CI(sig0000003f),
    .DI(sig00000030),
    .S(sig00000050),
    .O(sig00000040)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000cd (
    .I0(sig0000001f),
    .I1(sig00000030),
    .O(sig00000050)
  );
  XORCY   blk000000ce (
    .CI(sig0000003e),
    .LI(sig0000004f),
    .O(sig0000000e)
  );
  MUXCY   blk000000cf (
    .CI(sig0000003e),
    .DI(sig0000002f),
    .S(sig0000004f),
    .O(sig0000003f)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000d0 (
    .I0(sig0000001e),
    .I1(sig0000002f),
    .O(sig0000004f)
  );
  XORCY   blk000000d1 (
    .CI(sig0000003d),
    .LI(sig0000004e),
    .O(sig0000000d)
  );
  MUXCY   blk000000d2 (
    .CI(sig0000003d),
    .DI(sig0000002e),
    .S(sig0000004e),
    .O(sig0000003e)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000d3 (
    .I0(sig0000001d),
    .I1(sig0000002e),
    .O(sig0000004e)
  );
  XORCY   blk000000d4 (
    .CI(sig0000003c),
    .LI(sig0000004d),
    .O(sig0000000c)
  );
  MUXCY   blk000000d5 (
    .CI(sig0000003c),
    .DI(sig0000002d),
    .S(sig0000004d),
    .O(sig0000003d)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000d6 (
    .I0(sig0000001c),
    .I1(sig0000002d),
    .O(sig0000004d)
  );
  XORCY   blk000000d7 (
    .CI(sig0000003b),
    .LI(sig0000004c),
    .O(sig0000000b)
  );
  MUXCY   blk000000d8 (
    .CI(sig0000003b),
    .DI(sig0000002c),
    .S(sig0000004c),
    .O(sig0000003c)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000d9 (
    .I0(sig0000001b),
    .I1(sig0000002c),
    .O(sig0000004c)
  );
  XORCY   blk000000da (
    .CI(sig00000034),
    .LI(sig0000004b),
    .O(sig0000000a)
  );
  MUXCY   blk000000db (
    .CI(sig00000034),
    .DI(sig0000002b),
    .S(sig0000004b),
    .O(sig0000003b)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000dc (
    .I0(sig0000002b),
    .I1(sig0000001a),
    .O(sig0000004b)
  );
  XORCY   blk000000dd (
    .CI(sig00000001),
    .LI(sig00000044),
    .O(sig00000003)
  );
  MUXCY   blk000000de (
    .CI(sig00000001),
    .DI(sig00000023),
    .S(sig00000044),
    .O(sig00000034)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000df (
    .I0(sig00000023),
    .I1(sig00000013),
    .O(sig00000044)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000e0 (
    .I0(sig00000028),
    .I1(sig00000025),
    .O(sig000000aa)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000e1 (
    .I0(sig00000028),
    .I1(sig00000024),
    .O(sig000000a9)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000e2 (
    .I0(sig00000028),
    .I1(sig00000033),
    .O(sig000000a8)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000e3 (
    .I0(sig00000028),
    .I1(sig00000032),
    .O(sig000000a7)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000e4 (
    .I0(sig00000028),
    .I1(sig00000031),
    .O(sig000000a6)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000e5 (
    .I0(sig00000028),
    .I1(sig00000030),
    .O(sig000000a5)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000e6 (
    .I0(sig00000028),
    .I1(sig0000002f),
    .O(sig000000a4)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000e7 (
    .I0(sig00000028),
    .I1(sig0000002e),
    .O(sig000000a3)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000e8 (
    .I0(sig0000002d),
    .I1(sig00000028),
    .O(sig000000a2)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000e9 (
    .I0(sig00000027),
    .I1(sig00000028),
    .O(sig000000a1)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000ea (
    .I0(sig00000026),
    .I1(sig00000028),
    .O(sig000000a0)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000eb (
    .I0(sig0000002c),
    .I1(sig00000028),
    .O(sig0000009f)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  blk000000ec (
    .I0(sig00000028),
    .I1(sig00000025),
    .O(sig0000009e)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  blk000000ed (
    .I0(sig00000028),
    .I1(sig00000024),
    .O(sig0000009d)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  blk000000ee (
    .I0(sig00000028),
    .I1(sig00000033),
    .O(sig0000009c)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  blk000000ef (
    .I0(sig00000028),
    .I1(sig00000032),
    .O(sig0000009b)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  blk000000f0 (
    .I0(sig00000028),
    .I1(sig00000031),
    .O(sig0000009a)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  blk000000f1 (
    .I0(sig00000028),
    .I1(sig00000030),
    .O(sig00000099)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  blk000000f2 (
    .I0(sig00000028),
    .I1(sig0000002f),
    .O(sig00000098)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  blk000000f3 (
    .I0(sig00000028),
    .I1(sig0000002e),
    .O(sig00000097)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  blk000000f4 (
    .I0(sig0000002d),
    .I1(sig00000028),
    .O(sig00000096)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  blk000000f5 (
    .I0(sig00000027),
    .I1(sig00000028),
    .O(sig00000095)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  blk000000f6 (
    .I0(sig00000026),
    .I1(sig00000028),
    .O(sig00000094)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  blk000000f7 (
    .I0(sig0000002c),
    .I1(sig00000028),
    .O(sig00000093)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000f8 (
    .I0(sig000000d7),
    .I1(sig000000fb),
    .O(sig000000ca)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000f9 (
    .I0(sig000000d7),
    .I1(sig000000fa),
    .O(sig000000c9)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000fa (
    .I0(sig000000d7),
    .I1(sig000000f9),
    .O(sig000000c8)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000fb (
    .I0(sig000000d7),
    .I1(sig00000104),
    .O(sig000000c7)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000fc (
    .I0(sig000000d7),
    .I1(sig00000103),
    .O(sig000000c6)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk000000fd (
    .I0(sig000000d7),
    .I1(sig00000102),
    .O(sig000000c5)
  );
  LUT3 #(
    .INIT ( 8'h96 ))
  blk000000fe (
    .I0(sig00000108),
    .I1(sig000000d7),
    .I2(sig000000d6),
    .O(sig0000008b)
  );
  LUT3 #(
    .INIT ( 8'h96 ))
  blk000000ff (
    .I0(sig00000107),
    .I1(sig000000d7),
    .I2(sig000000d6),
    .O(sig0000008a)
  );
  LUT3 #(
    .INIT ( 8'h96 ))
  blk00000100 (
    .I0(sig00000106),
    .I1(sig000000d7),
    .I2(sig000000d6),
    .O(sig00000089)
  );
  LUT3 #(
    .INIT ( 8'h96 ))
  blk00000101 (
    .I0(sig00000111),
    .I1(sig000000d7),
    .I2(sig000000d6),
    .O(sig00000088)
  );
  LUT3 #(
    .INIT ( 8'h96 ))
  blk00000102 (
    .I0(sig000000d6),
    .I1(sig000000d7),
    .I2(sig00000110),
    .O(sig00000087)
  );
  LUT3 #(
    .INIT ( 8'h96 ))
  blk00000103 (
    .I0(sig000000d6),
    .I1(sig000000d7),
    .I2(sig0000010f),
    .O(sig00000086)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000104 (
    .I0(sig000000d7),
    .I1(sig00000101),
    .O(sig000000c4)
  );
  LUT3 #(
    .INIT ( 8'h96 ))
  blk00000105 (
    .I0(sig000000d6),
    .I1(sig000000d7),
    .I2(sig0000010e),
    .O(sig00000085)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000106 (
    .I0(sig00000100),
    .I1(sig000000d9),
    .O(sig000000c3)
  );
  LUT3 #(
    .INIT ( 8'h96 ))
  blk00000107 (
    .I0(sig0000010d),
    .I1(sig000000d6),
    .I2(sig000000d7),
    .O(sig00000084)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000108 (
    .I0(sig000000ff),
    .I1(sig000000d9),
    .O(sig000000c2)
  );
  LUT3 #(
    .INIT ( 8'h96 ))
  blk00000109 (
    .I0(sig0000010c),
    .I1(sig000000d9),
    .I2(sig000000d6),
    .O(sig00000083)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk0000010a (
    .I0(sig000000fe),
    .I1(sig000000d9),
    .O(sig000000c1)
  );
  LUT3 #(
    .INIT ( 8'h96 ))
  blk0000010b (
    .I0(sig0000010b),
    .I1(sig000000d9),
    .I2(sig000000d6),
    .O(sig00000082)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk0000010c (
    .I0(sig000000f4),
    .I1(sig00000068),
    .O(sig000000cd)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk0000010d (
    .I0(sig000000e5),
    .I1(sig0000005d),
    .O(sig0000008f)
  );
  LUT3 #(
    .INIT ( 8'h6C ))
  blk0000010e (
    .I0(sig000000f4),
    .I1(sig000000f5),
    .I2(sig00000068),
    .O(sig000000ce)
  );
  LUT3 #(
    .INIT ( 8'h6C ))
  blk0000010f (
    .I0(sig000000e5),
    .I1(sig000000e6),
    .I2(sig0000005d),
    .O(sig00000090)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000110 (
    .I0(sig000000fd),
    .I1(sig000000d8),
    .O(sig000000c0)
  );
  LUT3 #(
    .INIT ( 8'h96 ))
  blk00000111 (
    .I0(sig0000010a),
    .I1(sig000000d9),
    .I2(sig000000d6),
    .O(sig00000081)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000112 (
    .I0(sig000000fc),
    .I1(sig000000d8),
    .O(sig000000bf)
  );
  LUT3 #(
    .INIT ( 8'h96 ))
  blk00000113 (
    .I0(sig00000109),
    .I1(sig000000d8),
    .I2(sig000000d6),
    .O(sig00000080)
  );
  LUT3 #(
    .INIT ( 8'h96 ))
  blk00000114 (
    .I0(sig00000105),
    .I1(sig000000d8),
    .I2(sig000000d6),
    .O(sig0000007f)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000115 (
    .I0(sig000000f1),
    .I1(sig000000f0),
    .O(sig00000069)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000116 (
    .I0(sig000000e2),
    .I1(sig000000e1),
    .O(sig0000005e)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  blk00000117 (
    .I0(sig000000d6),
    .I1(sig000000d7),
    .O(sig0000008c)
  );
  LUT4 #(
    .INIT ( 16'h6AAA ))
  blk00000118 (
    .I0(sig000000f6),
    .I1(sig000000f5),
    .I2(sig000000f4),
    .I3(sig00000068),
    .O(sig000000cf)
  );
  LUT4 #(
    .INIT ( 16'h6AAA ))
  blk00000119 (
    .I0(sig000000e7),
    .I1(sig000000e6),
    .I2(sig000000e5),
    .I3(sig0000005d),
    .O(sig00000091)
  );
  LUT4 #(
    .INIT ( 16'h8000 ))
  blk0000011a (
    .I0(sig000000f3),
    .I1(sig000000f2),
    .I2(sig000000f1),
    .I3(sig000000f0),
    .O(sig00000068)
  );
  LUT4 #(
    .INIT ( 16'h8000 ))
  blk0000011b (
    .I0(sig000000e4),
    .I1(sig000000e3),
    .I2(sig000000e2),
    .I3(sig000000e1),
    .O(sig0000005d)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  blk0000011c (
    .I0(sig000000d8),
    .I1(sig000000d6),
    .O(sig0000005c)
  );
  LUT3 #(
    .INIT ( 8'h6C ))
  blk0000011d (
    .I0(sig000000f1),
    .I1(sig000000f2),
    .I2(sig000000f0),
    .O(sig000000cb)
  );
  LUT3 #(
    .INIT ( 8'h6C ))
  blk0000011e (
    .I0(sig000000e2),
    .I1(sig000000e3),
    .I2(sig000000e1),
    .O(sig0000008d)
  );
  LUT4 #(
    .INIT ( 16'h6AAA ))
  blk0000011f (
    .I0(sig000000f3),
    .I1(sig000000f1),
    .I2(sig000000f0),
    .I3(sig000000f2),
    .O(sig000000cc)
  );
  LUT4 #(
    .INIT ( 16'h6AAA ))
  blk00000120 (
    .I0(sig000000e4),
    .I1(sig000000e2),
    .I2(sig000000e1),
    .I3(sig000000e3),
    .O(sig0000008e)
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  blk00000121 (
    .I0(sig000000f8),
    .O(sig00000061)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000122 (
    .C(clk),
    .D(sig000000d5),
    .Q(sig000000d8)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk00000123 (
    .C(clk),
    .D(sig000000d5),
    .Q(sig000000d9)
  );
  RAMB16BWER #(
    .SIM_COLLISION_CHECK ( "ALL" ),
    .SRVAL_A ( 36'h000000000 ),
    .INIT_00 ( 256'h741EB851EB852FB852FC952FC963FC9630DA630DA740DA741EA741EB841EB852 ),
    .INIT_01 ( 256'h0DA741DA741EB841EB852EB852FC852FC962FC9630C9630DA730DA741DA741EB ),
    .INIT_02 ( 256'h9630C9630DA630DA741DA741EB741EB852EB852FC852FC962FC9630D9630DA73 ),
    .INIT_03 ( 256'h1EB852EB852FC952FC9630C9630DA730DA741DA741EB841EB852FB852FC952FC ),
    .INIT_04 ( 256'h9630D9630DA740DA741EB741EB852FB852FC962FC9630D9630DA740DA741EB74 ),
    .INIT_05 ( 256'h0DA741EA741EB852EB852FC962FC9630DA630DA741EA741EB851EB852FC952FC ),
    .INIT_06 ( 256'h740DA741EB851EB852FC962FC9630DA730DA741EB841EB852FC952FC9630D963 ),
    .INIT_07 ( 256'hC9630DA741DA741EB852FC852FC9630DA630DA741EB841EB852FC962FC9630DA ),
    .INIT_08 ( 256'h1EB852FB852FC9630DA740DA741EB852FC952FC9630DA741EA741EB852FC952F ),
    .INIT_09 ( 256'h41EB852FC9630DA741EB741EB852FC9630DA740DA741EB852FC9630C9630DA74 ),
    .INIT_0A ( 256'h741EB852FC963FC9630DA741EB852FC9630DA741EA741EB852FC9630DA741EB8 ),
    .INIT_0B ( 256'h852FC9630DA741EB852FC9630DA741EB852FB852FC9630DA741EB852FC9630DA ),
    .INIT_0C ( 256'h852FC9630DA741EB852FC9630DA741EB852FC9630DA741EB852FC9630DA741EB ),
    .INIT_0D ( 256'h630DA741EB852FC9630DA742FC9630DA741EB852FC9630DA741EB852FC9631EB ),
    .INIT_0E ( 256'h2FC9630EB852FC9630DA741FC9630DA741EB852FDA741EB852FC9630DA741FC9 ),
    .INIT_0F ( 256'hDA741EB8530DA741EB8630DA741EB8530DA741EB8520DA741EB852FCA741EB85 ),
    .INIT_10 ( 256'h530DA741FC9630DA752FC9630EB852FC9641EB852FCA741EB8520DA741EB8530 ),
    .INIT_11 ( 256'hC9741EB8630DA742FC9631EB852FDA741EB9630DA752FC9631EB852FCA741EB8 ),
    .INIT_12 ( 256'h1EB8630DA852FCA741EC9630DB852FDA741EC9630DB852FCA741EB9630DA852F ),
    .INIT_13 ( 256'h31EB8530DA852FDA741FC9631EB8630DA852FCA741FC9631EB8530DA752FC974 ),
    .INIT_14 ( 256'h31EB9630EB8530DA852FDA742FC9741EC9631EB8630DB8520DA752FC9741EC96 ),
    .INIT_15 ( 256'h1EC9641EC9631EB9631EB8630EB8530DB8520DA852FDA752FCA741FC9741EC96 ),
    .INIT_16 ( 256'hCA742FCA742FCA742FCA742FCA742FCA742FCA742FCA742FC9741FC9741FC974 ),
    .INIT_17 ( 256'h520DA8530DB8530EB8630EB9631EB9641EC9641EC9741FC9741FC9742FCA742F ),
    .INIT_18 ( 256'hB8530EB9631EC9741FCA742FDA8520DB8530EB8631EC9641FC9742FCA742FDA7 ),
    .INIT_19 ( 256'hEB8631EC9742FDA8530DB8631EC9742FCA7520DB8530EB9641EC9742FDA7520D ),
    .INIT_1A ( 256'hEB9641FCA7520DB8631EC9742FDA8530EB9641FCA7520DB8631EC9742FDA8530 ),
    .INIT_1B ( 256'hA8631EC97520DB8641FCA7520EB9641FCA7530EB9641FCA8530EB9641FCA7520 ),
    .INIT_1C ( 256'h420DB8641FCA8531EC97520DB9641FDA8531EC97520DB8641FCA8530EB9742FD ),
    .INIT_1D ( 256'hB9642FDB8641FDA8631FCA8530EC97520EB97420DB8641FDA8631ECA7530EB97 ),
    .INIT_1E ( 256'hECA7531ECA7531ECA7531ECA7530ECA7530EC97530EC97520EB97420DB97420D ),
    .INIT_1F ( 256'hECA7531FCA8631FDA8641FDB96420DB97420EB97520EC97520EC97530ECA7530 ),
    .INIT_20 ( 256'hB86420DB97530ECA8631FDB86420EB97530ECA8531FDA8642FDB96420EB97530 ),
    .INIT_21 ( 256'h31FDB97520ECA8641FDB97530ECA8642FDB97530ECA8631FDB97420ECA7531FD ),
    .INIT_22 ( 256'h96420ECA86420ECA8531FDB97531FDB86420ECA8642FDB97531FDA86420ECA85 ),
    .INIT_23 ( 256'hA86420ECA86420ECA86420ECA86420ECA86420EC97531FDB97531FDB97531FDB ),
    .INIT_24 ( 256'h86420ECA86420ECA97531FDB97531FDB97531FDBA86420ECA86420ECA86420EC ),
    .INIT_25 ( 256'h1FECA86420FDB97531FECA86420EDB97531FDBA86420ECA86431FDB97531FDBA ),
    .INIT_26 ( 256'h75320ECA975310ECA86531FDBA86420FDB975420ECA87531FDBA86420EDB9753 ),
    .INIT_27 ( 256'h975420EDB976420FDB986420FDB986420FDB986420FDB986420FDB976420EDB9 ),
    .INIT_28 ( 256'h75310ECB976421FDBA865310ECA975420EDB986421FDCA86531FECA975320ECB ),
    .INIT_29 ( 256'h0EDBA865310EDB986431FECB976421FDCA875420FDBA865310ECB976421FDCA8 ),
    .INIT_2A ( 256'h5421FDCA976431FECB9864310EDB9865320EDBA865320EDBA875320EDBA86532 ),
    .INIT_2B ( 256'h65320FDCA9764310EDBA875421FECB9865320FDCA976421FECB9865320FDBA87 ),
    .INIT_2C ( 256'h310FDCA9765320FDCB9865321FECB9865421FECB9875421FECB9865321FECB98 ),
    .INIT_2D ( 256'hBA8764320FECB98754310FDCA9865421FEDBA9764320FDCB9865421FEDBA8764 ),
    .INIT_2E ( 256'hFDCBA8765321FEDCA98654210FDCB98754320FECBA8764320FECBA8764320FEC ),
    .INIT_2F ( 256'hEDCA98764321FEDCB987643210EDCB98764321FEDCA98754320FEDBA98654310 ),
    .INIT_30 ( 256'h986543210EDCBA98654321FEDCBA97654320FEDCB987653210FECBA98654320F ),
    .INIT_31 ( 256'hFEDCA9876543210FEDBA9876543210EDCBA987653210FEDCB987654321FEDCBA ),
    .INIT_32 ( 256'h0FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210EDCBA9876543210 ),
    .INIT_33 ( 256'hDCBA98766543210FEDCBA99876543210FEDCBA98776543210FEDCBA987654321 ),
    .INIT_34 ( 256'h5432210FEDCCBA987665432100FEDCBA998765432210FEDCBAA98765432110FE ),
    .INIT_35 ( 256'h877654432100FEDDCBA9987665432210FEEDCBAA987655432110FEDCCBA98776 ),
    .INIT_36 ( 256'h76554332100FEEDCBBA99877654432110FFEDCCBA99876654332110FEDDCBAA9 ),
    .INIT_37 ( 256'h00FEEDDCBBAA988766544332110FFEDDCBBA9988766544322100FEDDCBBA9987 ),
    .INIT_38 ( 256'h55443221100FFEEDCCBBAA98877665443322100FFEEDCCBBA998876655433221 ),
    .INIT_39 ( 256'h5544332211000FFEEDDCCBBAA99887766554433221100FFEEDDCCBAA99887766 ),
    .INIT_3A ( 256'h00FFFEEDDDCCCBBAA999887776655544332221100FFFEEDDCCBBBAA998877766 ),
    .INIT_3B ( 256'h6665555444333222111000FFFEEEDDDCCCBBBAA9998887776655544433322111 ),
    .INIT_3C ( 256'h877777666655554444333322221110000FFFFEEEDDDDCCCBBBBAAA9999888777 ),
    .INIT_3D ( 256'h444433333322222211111100000FFFFFEEEEEEDDDDCCCCCBBBBBAAAAA9999888 ),
    .INIT_3E ( 256'hBBBBBBBBBBBBAAAAAAAAAA999999999988888888777777776666666555555544 ),
    .INIT_3F ( 256'hEEEEEEEEEEEEEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDDDDDDDCCCCCCCCCCCCCC ),
    .WRITE_MODE_A ( "READ_FIRST" ),
    .WRITE_MODE_B ( "WRITE_FIRST" ),
    .DATA_WIDTH_A ( 4 ),
    .DATA_WIDTH_B ( 4 ),
    .DOA_REG ( 1 ),
    .DOB_REG ( 1 ),
    .INIT_FILE ( "NONE" ),
    .RSTTYPE ( "SYNC" ),
    .INIT_A ( 36'h000000000 ),
    .INIT_B ( 36'h000000000 ),
    .INITP_00 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_01 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_02 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_03 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_04 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_05 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_06 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_07 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .SRVAL_B ( 36'h000000000 ))
  blk00000124 (
    .CLKA(clk),
    .CLKB(clk),
    .ENA(sig00000002),
    .ENB(sig00000002),
    .RSTA(sig00000001),
    .RSTB(sig00000001),
    .REGCEA(sig00000002),
    .REGCEB(sig00000002),
    .ADDRA({sig00000121, sig00000120, sig00000129, sig00000128, sig00000127, sig00000126, sig00000125, sig00000124, sig00000123, sig00000122, 
sig0000011f, sig0000011e, \NLW_blk00000124_ADDRA<1>_UNCONNECTED , \NLW_blk00000124_ADDRA<0>_UNCONNECTED }),
    .ADDRB({sig00000115, sig00000114, sig0000011d, sig0000011c, sig0000011b, sig0000011a, sig00000119, sig00000118, sig00000117, sig00000116, 
sig00000113, sig00000112, \NLW_blk00000124_ADDRB<1>_UNCONNECTED , \NLW_blk00000124_ADDRB<0>_UNCONNECTED }),
    .DIA({\NLW_blk00000124_DIA<31>_UNCONNECTED , \NLW_blk00000124_DIA<30>_UNCONNECTED , \NLW_blk00000124_DIA<29>_UNCONNECTED , 
\NLW_blk00000124_DIA<28>_UNCONNECTED , \NLW_blk00000124_DIA<27>_UNCONNECTED , \NLW_blk00000124_DIA<26>_UNCONNECTED , 
\NLW_blk00000124_DIA<25>_UNCONNECTED , \NLW_blk00000124_DIA<24>_UNCONNECTED , \NLW_blk00000124_DIA<23>_UNCONNECTED , 
\NLW_blk00000124_DIA<22>_UNCONNECTED , \NLW_blk00000124_DIA<21>_UNCONNECTED , \NLW_blk00000124_DIA<20>_UNCONNECTED , 
\NLW_blk00000124_DIA<19>_UNCONNECTED , \NLW_blk00000124_DIA<18>_UNCONNECTED , \NLW_blk00000124_DIA<17>_UNCONNECTED , 
\NLW_blk00000124_DIA<16>_UNCONNECTED , \NLW_blk00000124_DIA<15>_UNCONNECTED , \NLW_blk00000124_DIA<14>_UNCONNECTED , 
\NLW_blk00000124_DIA<13>_UNCONNECTED , \NLW_blk00000124_DIA<12>_UNCONNECTED , \NLW_blk00000124_DIA<11>_UNCONNECTED , 
\NLW_blk00000124_DIA<10>_UNCONNECTED , \NLW_blk00000124_DIA<9>_UNCONNECTED , \NLW_blk00000124_DIA<8>_UNCONNECTED , 
\NLW_blk00000124_DIA<7>_UNCONNECTED , \NLW_blk00000124_DIA<6>_UNCONNECTED , \NLW_blk00000124_DIA<5>_UNCONNECTED , \NLW_blk00000124_DIA<4>_UNCONNECTED 
, sig00000001, sig00000001, sig00000001, sig00000001}),
    .DIB({\NLW_blk00000124_DIB<31>_UNCONNECTED , \NLW_blk00000124_DIB<30>_UNCONNECTED , \NLW_blk00000124_DIB<29>_UNCONNECTED , 
\NLW_blk00000124_DIB<28>_UNCONNECTED , \NLW_blk00000124_DIB<27>_UNCONNECTED , \NLW_blk00000124_DIB<26>_UNCONNECTED , 
\NLW_blk00000124_DIB<25>_UNCONNECTED , \NLW_blk00000124_DIB<24>_UNCONNECTED , \NLW_blk00000124_DIB<23>_UNCONNECTED , 
\NLW_blk00000124_DIB<22>_UNCONNECTED , \NLW_blk00000124_DIB<21>_UNCONNECTED , \NLW_blk00000124_DIB<20>_UNCONNECTED , 
\NLW_blk00000124_DIB<19>_UNCONNECTED , \NLW_blk00000124_DIB<18>_UNCONNECTED , \NLW_blk00000124_DIB<17>_UNCONNECTED , 
\NLW_blk00000124_DIB<16>_UNCONNECTED , \NLW_blk00000124_DIB<15>_UNCONNECTED , \NLW_blk00000124_DIB<14>_UNCONNECTED , 
\NLW_blk00000124_DIB<13>_UNCONNECTED , \NLW_blk00000124_DIB<12>_UNCONNECTED , \NLW_blk00000124_DIB<11>_UNCONNECTED , 
\NLW_blk00000124_DIB<10>_UNCONNECTED , \NLW_blk00000124_DIB<9>_UNCONNECTED , \NLW_blk00000124_DIB<8>_UNCONNECTED , 
\NLW_blk00000124_DIB<7>_UNCONNECTED , \NLW_blk00000124_DIB<6>_UNCONNECTED , \NLW_blk00000124_DIB<5>_UNCONNECTED , \NLW_blk00000124_DIB<4>_UNCONNECTED 
, \NLW_blk00000124_DIB<3>_UNCONNECTED , \NLW_blk00000124_DIB<2>_UNCONNECTED , \NLW_blk00000124_DIB<1>_UNCONNECTED , 
\NLW_blk00000124_DIB<0>_UNCONNECTED }),
    .DIPA({\NLW_blk00000124_DIPA<3>_UNCONNECTED , \NLW_blk00000124_DIPA<2>_UNCONNECTED , \NLW_blk00000124_DIPA<1>_UNCONNECTED , 
\NLW_blk00000124_DIPA<0>_UNCONNECTED }),
    .DIPB({\NLW_blk00000124_DIPB<3>_UNCONNECTED , \NLW_blk00000124_DIPB<2>_UNCONNECTED , \NLW_blk00000124_DIPB<1>_UNCONNECTED , 
\NLW_blk00000124_DIPB<0>_UNCONNECTED }),
    .WEA({sig00000001, sig00000001, sig00000001, sig00000001}),
    .WEB({sig00000001, sig00000001, sig00000001, sig00000001}),
    .DOA({\NLW_blk00000124_DOA<31>_UNCONNECTED , \NLW_blk00000124_DOA<30>_UNCONNECTED , \NLW_blk00000124_DOA<29>_UNCONNECTED , 
\NLW_blk00000124_DOA<28>_UNCONNECTED , \NLW_blk00000124_DOA<27>_UNCONNECTED , \NLW_blk00000124_DOA<26>_UNCONNECTED , 
\NLW_blk00000124_DOA<25>_UNCONNECTED , \NLW_blk00000124_DOA<24>_UNCONNECTED , \NLW_blk00000124_DOA<23>_UNCONNECTED , 
\NLW_blk00000124_DOA<22>_UNCONNECTED , \NLW_blk00000124_DOA<21>_UNCONNECTED , \NLW_blk00000124_DOA<20>_UNCONNECTED , 
\NLW_blk00000124_DOA<19>_UNCONNECTED , \NLW_blk00000124_DOA<18>_UNCONNECTED , \NLW_blk00000124_DOA<17>_UNCONNECTED , 
\NLW_blk00000124_DOA<16>_UNCONNECTED , \NLW_blk00000124_DOA<15>_UNCONNECTED , \NLW_blk00000124_DOA<14>_UNCONNECTED , 
\NLW_blk00000124_DOA<13>_UNCONNECTED , \NLW_blk00000124_DOA<12>_UNCONNECTED , \NLW_blk00000124_DOA<11>_UNCONNECTED , 
\NLW_blk00000124_DOA<10>_UNCONNECTED , \NLW_blk00000124_DOA<9>_UNCONNECTED , \NLW_blk00000124_DOA<8>_UNCONNECTED , 
\NLW_blk00000124_DOA<7>_UNCONNECTED , \NLW_blk00000124_DOA<6>_UNCONNECTED , \NLW_blk00000124_DOA<5>_UNCONNECTED , \NLW_blk00000124_DOA<4>_UNCONNECTED 
, sig000000b1, sig000000b0, sig000000af, sig000000ab}),
    .DOB({\NLW_blk00000124_DOB<31>_UNCONNECTED , \NLW_blk00000124_DOB<30>_UNCONNECTED , \NLW_blk00000124_DOB<29>_UNCONNECTED , 
\NLW_blk00000124_DOB<28>_UNCONNECTED , \NLW_blk00000124_DOB<27>_UNCONNECTED , \NLW_blk00000124_DOB<26>_UNCONNECTED , 
\NLW_blk00000124_DOB<25>_UNCONNECTED , \NLW_blk00000124_DOB<24>_UNCONNECTED , \NLW_blk00000124_DOB<23>_UNCONNECTED , 
\NLW_blk00000124_DOB<22>_UNCONNECTED , \NLW_blk00000124_DOB<21>_UNCONNECTED , \NLW_blk00000124_DOB<20>_UNCONNECTED , 
\NLW_blk00000124_DOB<19>_UNCONNECTED , \NLW_blk00000124_DOB<18>_UNCONNECTED , \NLW_blk00000124_DOB<17>_UNCONNECTED , 
\NLW_blk00000124_DOB<16>_UNCONNECTED , \NLW_blk00000124_DOB<15>_UNCONNECTED , \NLW_blk00000124_DOB<14>_UNCONNECTED , 
\NLW_blk00000124_DOB<13>_UNCONNECTED , \NLW_blk00000124_DOB<12>_UNCONNECTED , \NLW_blk00000124_DOB<11>_UNCONNECTED , 
\NLW_blk00000124_DOB<10>_UNCONNECTED , \NLW_blk00000124_DOB<9>_UNCONNECTED , \NLW_blk00000124_DOB<8>_UNCONNECTED , 
\NLW_blk00000124_DOB<7>_UNCONNECTED , \NLW_blk00000124_DOB<6>_UNCONNECTED , \NLW_blk00000124_DOB<5>_UNCONNECTED , \NLW_blk00000124_DOB<4>_UNCONNECTED 
, sig00000071, sig00000070, sig0000006f, sig0000006b}),
    .DOPA({\NLW_blk00000124_DOPA<3>_UNCONNECTED , \NLW_blk00000124_DOPA<2>_UNCONNECTED , \NLW_blk00000124_DOPA<1>_UNCONNECTED , 
\NLW_blk00000124_DOPA<0>_UNCONNECTED }),
    .DOPB({\NLW_blk00000124_DOPB<3>_UNCONNECTED , \NLW_blk00000124_DOPB<2>_UNCONNECTED , \NLW_blk00000124_DOPB<1>_UNCONNECTED , 
\NLW_blk00000124_DOPB<0>_UNCONNECTED })
  );
  RAMB16BWER #(
    .SIM_COLLISION_CHECK ( "ALL" ),
    .SRVAL_A ( 36'h000000000 ),
    .INIT_00 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_01 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_02 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_03 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_04 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_05 ( 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC000000000000000000000 ),
    .INIT_06 ( 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ),
    .INIT_07 ( 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ),
    .INIT_08 ( 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ),
    .INIT_09 ( 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ),
    .INIT_0A ( 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ),
    .INIT_0B ( 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ),
    .INIT_0C ( 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ),
    .INIT_0D ( 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ),
    .INIT_3E ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .WRITE_MODE_A ( "READ_FIRST" ),
    .WRITE_MODE_B ( "WRITE_FIRST" ),
    .DATA_WIDTH_A ( 1 ),
    .DATA_WIDTH_B ( 1 ),
    .DOA_REG ( 1 ),
    .DOB_REG ( 1 ),
    .INIT_FILE ( "NONE" ),
    .RSTTYPE ( "SYNC" ),
    .INIT_0E ( 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ),
    .INIT_0F ( 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ),
    .INIT_10 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_11 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_12 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_13 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_14 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_15 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_16 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_17 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_18 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_19 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_1A ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_1B ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_1C ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_1D ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_1E ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_1F ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_20 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_21 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_22 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_23 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_24 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_25 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_26 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_27 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_28 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_29 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_2A ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_2B ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_2C ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_2D ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_2E ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_2F ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_30 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_31 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_32 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_33 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_34 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_35 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_36 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_37 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_38 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_39 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_3A ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_3B ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_3C ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_3D ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_3F ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_A ( 36'h000000000 ),
    .INIT_B ( 36'h000000000 ),
    .INITP_00 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_01 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_02 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_03 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_04 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_05 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_06 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_07 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .SRVAL_B ( 36'h000000000 ))
  blk00000125 (
    .CLKA(clk),
    .CLKB(clk),
    .ENA(sig00000002),
    .ENB(sig00000002),
    .RSTA(sig00000001),
    .RSTB(sig00000001),
    .REGCEA(sig00000002),
    .REGCEB(sig00000002),
    .ADDRA({sig00000001, sig00000001, sig00000121, sig00000120, sig00000129, sig00000128, sig00000127, sig00000126, sig00000125, sig00000124, 
sig00000123, sig00000122, sig0000011f, sig0000011e}),
    .ADDRB({sig00000001, sig00000001, sig00000115, sig00000114, sig0000011d, sig0000011c, sig0000011b, sig0000011a, sig00000119, sig00000118, 
sig00000117, sig00000116, sig00000113, sig00000112}),
    .DIA({\NLW_blk00000125_DIA<31>_UNCONNECTED , \NLW_blk00000125_DIA<30>_UNCONNECTED , \NLW_blk00000125_DIA<29>_UNCONNECTED , 
\NLW_blk00000125_DIA<28>_UNCONNECTED , \NLW_blk00000125_DIA<27>_UNCONNECTED , \NLW_blk00000125_DIA<26>_UNCONNECTED , 
\NLW_blk00000125_DIA<25>_UNCONNECTED , \NLW_blk00000125_DIA<24>_UNCONNECTED , \NLW_blk00000125_DIA<23>_UNCONNECTED , 
\NLW_blk00000125_DIA<22>_UNCONNECTED , \NLW_blk00000125_DIA<21>_UNCONNECTED , \NLW_blk00000125_DIA<20>_UNCONNECTED , 
\NLW_blk00000125_DIA<19>_UNCONNECTED , \NLW_blk00000125_DIA<18>_UNCONNECTED , \NLW_blk00000125_DIA<17>_UNCONNECTED , 
\NLW_blk00000125_DIA<16>_UNCONNECTED , \NLW_blk00000125_DIA<15>_UNCONNECTED , \NLW_blk00000125_DIA<14>_UNCONNECTED , 
\NLW_blk00000125_DIA<13>_UNCONNECTED , \NLW_blk00000125_DIA<12>_UNCONNECTED , \NLW_blk00000125_DIA<11>_UNCONNECTED , 
\NLW_blk00000125_DIA<10>_UNCONNECTED , \NLW_blk00000125_DIA<9>_UNCONNECTED , \NLW_blk00000125_DIA<8>_UNCONNECTED , 
\NLW_blk00000125_DIA<7>_UNCONNECTED , \NLW_blk00000125_DIA<6>_UNCONNECTED , \NLW_blk00000125_DIA<5>_UNCONNECTED , \NLW_blk00000125_DIA<4>_UNCONNECTED 
, \NLW_blk00000125_DIA<3>_UNCONNECTED , \NLW_blk00000125_DIA<2>_UNCONNECTED , \NLW_blk00000125_DIA<1>_UNCONNECTED , sig00000001}),
    .DIB({\NLW_blk00000125_DIB<31>_UNCONNECTED , \NLW_blk00000125_DIB<30>_UNCONNECTED , \NLW_blk00000125_DIB<29>_UNCONNECTED , 
\NLW_blk00000125_DIB<28>_UNCONNECTED , \NLW_blk00000125_DIB<27>_UNCONNECTED , \NLW_blk00000125_DIB<26>_UNCONNECTED , 
\NLW_blk00000125_DIB<25>_UNCONNECTED , \NLW_blk00000125_DIB<24>_UNCONNECTED , \NLW_blk00000125_DIB<23>_UNCONNECTED , 
\NLW_blk00000125_DIB<22>_UNCONNECTED , \NLW_blk00000125_DIB<21>_UNCONNECTED , \NLW_blk00000125_DIB<20>_UNCONNECTED , 
\NLW_blk00000125_DIB<19>_UNCONNECTED , \NLW_blk00000125_DIB<18>_UNCONNECTED , \NLW_blk00000125_DIB<17>_UNCONNECTED , 
\NLW_blk00000125_DIB<16>_UNCONNECTED , \NLW_blk00000125_DIB<15>_UNCONNECTED , \NLW_blk00000125_DIB<14>_UNCONNECTED , 
\NLW_blk00000125_DIB<13>_UNCONNECTED , \NLW_blk00000125_DIB<12>_UNCONNECTED , \NLW_blk00000125_DIB<11>_UNCONNECTED , 
\NLW_blk00000125_DIB<10>_UNCONNECTED , \NLW_blk00000125_DIB<9>_UNCONNECTED , \NLW_blk00000125_DIB<8>_UNCONNECTED , 
\NLW_blk00000125_DIB<7>_UNCONNECTED , \NLW_blk00000125_DIB<6>_UNCONNECTED , \NLW_blk00000125_DIB<5>_UNCONNECTED , \NLW_blk00000125_DIB<4>_UNCONNECTED 
, \NLW_blk00000125_DIB<3>_UNCONNECTED , \NLW_blk00000125_DIB<2>_UNCONNECTED , \NLW_blk00000125_DIB<1>_UNCONNECTED , 
\NLW_blk00000125_DIB<0>_UNCONNECTED }),
    .DIPA({\NLW_blk00000125_DIPA<3>_UNCONNECTED , \NLW_blk00000125_DIPA<2>_UNCONNECTED , \NLW_blk00000125_DIPA<1>_UNCONNECTED , 
\NLW_blk00000125_DIPA<0>_UNCONNECTED }),
    .DIPB({\NLW_blk00000125_DIPB<3>_UNCONNECTED , \NLW_blk00000125_DIPB<2>_UNCONNECTED , \NLW_blk00000125_DIPB<1>_UNCONNECTED , 
\NLW_blk00000125_DIPB<0>_UNCONNECTED }),
    .WEA({sig00000001, sig00000001, sig00000001, sig00000001}),
    .WEB({sig00000001, sig00000001, sig00000001, sig00000001}),
    .DOA({\NLW_blk00000125_DOA<31>_UNCONNECTED , \NLW_blk00000125_DOA<30>_UNCONNECTED , \NLW_blk00000125_DOA<29>_UNCONNECTED , 
\NLW_blk00000125_DOA<28>_UNCONNECTED , \NLW_blk00000125_DOA<27>_UNCONNECTED , \NLW_blk00000125_DOA<26>_UNCONNECTED , 
\NLW_blk00000125_DOA<25>_UNCONNECTED , \NLW_blk00000125_DOA<24>_UNCONNECTED , \NLW_blk00000125_DOA<23>_UNCONNECTED , 
\NLW_blk00000125_DOA<22>_UNCONNECTED , \NLW_blk00000125_DOA<21>_UNCONNECTED , \NLW_blk00000125_DOA<20>_UNCONNECTED , 
\NLW_blk00000125_DOA<19>_UNCONNECTED , \NLW_blk00000125_DOA<18>_UNCONNECTED , \NLW_blk00000125_DOA<17>_UNCONNECTED , 
\NLW_blk00000125_DOA<16>_UNCONNECTED , \NLW_blk00000125_DOA<15>_UNCONNECTED , \NLW_blk00000125_DOA<14>_UNCONNECTED , 
\NLW_blk00000125_DOA<13>_UNCONNECTED , \NLW_blk00000125_DOA<12>_UNCONNECTED , \NLW_blk00000125_DOA<11>_UNCONNECTED , 
\NLW_blk00000125_DOA<10>_UNCONNECTED , \NLW_blk00000125_DOA<9>_UNCONNECTED , \NLW_blk00000125_DOA<8>_UNCONNECTED , 
\NLW_blk00000125_DOA<7>_UNCONNECTED , \NLW_blk00000125_DOA<6>_UNCONNECTED , \NLW_blk00000125_DOA<5>_UNCONNECTED , \NLW_blk00000125_DOA<4>_UNCONNECTED 
, \NLW_blk00000125_DOA<3>_UNCONNECTED , \NLW_blk00000125_DOA<2>_UNCONNECTED , \NLW_blk00000125_DOA<1>_UNCONNECTED , sig000000ae}),
    .DOB({\NLW_blk00000125_DOB<31>_UNCONNECTED , \NLW_blk00000125_DOB<30>_UNCONNECTED , \NLW_blk00000125_DOB<29>_UNCONNECTED , 
\NLW_blk00000125_DOB<28>_UNCONNECTED , \NLW_blk00000125_DOB<27>_UNCONNECTED , \NLW_blk00000125_DOB<26>_UNCONNECTED , 
\NLW_blk00000125_DOB<25>_UNCONNECTED , \NLW_blk00000125_DOB<24>_UNCONNECTED , \NLW_blk00000125_DOB<23>_UNCONNECTED , 
\NLW_blk00000125_DOB<22>_UNCONNECTED , \NLW_blk00000125_DOB<21>_UNCONNECTED , \NLW_blk00000125_DOB<20>_UNCONNECTED , 
\NLW_blk00000125_DOB<19>_UNCONNECTED , \NLW_blk00000125_DOB<18>_UNCONNECTED , \NLW_blk00000125_DOB<17>_UNCONNECTED , 
\NLW_blk00000125_DOB<16>_UNCONNECTED , \NLW_blk00000125_DOB<15>_UNCONNECTED , \NLW_blk00000125_DOB<14>_UNCONNECTED , 
\NLW_blk00000125_DOB<13>_UNCONNECTED , \NLW_blk00000125_DOB<12>_UNCONNECTED , \NLW_blk00000125_DOB<11>_UNCONNECTED , 
\NLW_blk00000125_DOB<10>_UNCONNECTED , \NLW_blk00000125_DOB<9>_UNCONNECTED , \NLW_blk00000125_DOB<8>_UNCONNECTED , 
\NLW_blk00000125_DOB<7>_UNCONNECTED , \NLW_blk00000125_DOB<6>_UNCONNECTED , \NLW_blk00000125_DOB<5>_UNCONNECTED , \NLW_blk00000125_DOB<4>_UNCONNECTED 
, \NLW_blk00000125_DOB<3>_UNCONNECTED , \NLW_blk00000125_DOB<2>_UNCONNECTED , \NLW_blk00000125_DOB<1>_UNCONNECTED , sig0000006e}),
    .DOPA({\NLW_blk00000125_DOPA<3>_UNCONNECTED , \NLW_blk00000125_DOPA<2>_UNCONNECTED , \NLW_blk00000125_DOPA<1>_UNCONNECTED , 
\NLW_blk00000125_DOPA<0>_UNCONNECTED }),
    .DOPB({\NLW_blk00000125_DOPB<3>_UNCONNECTED , \NLW_blk00000125_DOPB<2>_UNCONNECTED , \NLW_blk00000125_DOPB<1>_UNCONNECTED , 
\NLW_blk00000125_DOPB<0>_UNCONNECTED })
  );
  RAMB16BWER #(
    .SIM_COLLISION_CHECK ( "ALL" ),
    .SRVAL_A ( 36'h000000000 ),
    .INIT_00 ( 256'hCCCBBBBBAAAAA999998888877777666666555554444433333222221111100000 ),
    .INIT_01 ( 256'h98888877777666665555544444333332222211111100000FFFFFEEEEEDDDDDCC ),
    .INIT_02 ( 256'h55554444433333222221111100000FFFFFEEEEEDDDDDCCCCCBBBBBBAAAAA9999 ),
    .INIT_03 ( 256'h21111100000FFFFFEEEEEEDDDDDCCCCCBBBBBAAAAA9999988888777776666655 ),
    .INIT_04 ( 256'hEEEEDDDDDCCCCCBBBBBAAAAA9999988888777776666665555544444333332222 ),
    .INIT_05 ( 256'hBAAAAA999998888877777666665555554444433333222221111100000FFFFFEE ),
    .INIT_06 ( 256'h777666665555544444333332222221111100000FFFFFEEEEEDDDDDCCCCCCBBBB ),
    .INIT_07 ( 256'h33333222221111100000FFFFFEEEEEEDDDDDCCCCCBBBBBAAAAA9999988888877 ),
    .INIT_08 ( 256'h0FFFFFEEEEEDDDDDDCCCCCBBBBBAAAAA99999888888777776666655555444443 ),
    .INIT_09 ( 256'hCCBBBBBAAAAAA999998888877777666666555554444433333222222111110000 ),
    .INIT_0A ( 256'h888777776666655555544444333332222221111100000FFFFFEEEEEEDDDDDCCC ),
    .INIT_0B ( 256'h4443333332222211111000000FFFFFEEEEEDDDDDCCCCCCBBBBBAAAAA99999988 ),
    .INIT_0C ( 256'h000FFFFFFEEEEEDDDDDCCCCCCBBBBBAAAAA99999988888777776666665555544 ),
    .INIT_0D ( 256'hCCCBBBBBAAAAA999999888887777776666655555444444333332222211111100 ),
    .INIT_0E ( 256'h877777766666555555444443333332222211111000000FFFFFEEEEEEDDDDDCCC ),
    .INIT_0F ( 256'h3333322222211111000000FFFFFEEEEEEDDDDDCCCCCCBBBBBAAAAA9999998888 ),
    .INIT_10 ( 256'hFFFEEEEEDDDDDDCCCCCBBBBBBAAAAA9999998888877777766666655555444444 ),
    .INIT_11 ( 256'hAAAAA99999988888777777666665555554444443333322222211111000000FFF ),
    .INIT_12 ( 256'h65555554444433333322222211111000000FFFFFFEEEEEDDDDDDCCCCCCBBBBBA ),
    .INIT_13 ( 256'h11000000FFFFFEEEEEEDDDDDDCCCCCCBBBBBAAAAAA9999998888887777766666 ),
    .INIT_14 ( 256'hCCBBBBBBAAAAAA99999888888777777666666555555444444333332222221111 ),
    .INIT_15 ( 256'h766666655555544444433333322222211111100000FFFFFFEEEEEEDDDDDDCCCC ),
    .INIT_16 ( 256'h11111000000FFFFFFEEEEEEDDDDDDCCCCCCBBBBBBAAAAAA99999988888877777 ),
    .INIT_17 ( 256'hCCCBBBBBBAAAAAA9999998888887777776666665555554444443333332222221 ),
    .INIT_18 ( 256'h666665555554444443333332222222111111000000FFFFFFEEEEEEDDDDDDCCCC ),
    .INIT_19 ( 256'h000000FFFFFFEEEEEEEDDDDDDCCCCCCBBBBBBBAAAAAA99999988888877777776 ),
    .INIT_1A ( 256'hAAAAAA9999999888888777777666666655555544444443333332222221111111 ),
    .INIT_1B ( 256'h4444433333332222221111111000000FFFFFFFEEEEEEDDDDDDDCCCCCCBBBBBBB ),
    .INIT_1C ( 256'hEEEDDDDDDCCCCCCCBBBBBBBAAAAAA99999998888888777777666666655555544 ),
    .INIT_1D ( 256'h77777666666655555554444444333333322222221111110000000FFFFFFFEEEE ),
    .INIT_1E ( 256'h0000000FFFFFFFEEEEEEEDDDDDDDCCCCCCCBBBBBBBAAAAAAA999999988888887 ),
    .INIT_1F ( 256'h9999999888888877777776666666655555554444444333333322222221111111 ),
    .INIT_20 ( 256'h22222211111110000000FFFFFFFFEEEEEEEDDDDDDDCCCCCCCBBBBBBBBAAAAAAA ),
    .INIT_21 ( 256'hBBAAAAAAAA999999988888888777777766666666555555544444444333333322 ),
    .INIT_22 ( 256'h3333322222222111111100000000FFFFFFFFEEEEEEEDDDDDDDDCCCCCCCCBBBBB ),
    .INIT_23 ( 256'hBBBBBBAAAAAAAA99999999888888887777777766666665555555544444444333 ),
    .INIT_24 ( 256'h33333222222221111111100000000FFFFFFFFEEEEEEEEEDDDDDDDDCCCCCCCCBB ),
    .INIT_25 ( 256'hBAAAAAAAAA999999998888888887777777766666666655555555444444443333 ),
    .INIT_26 ( 256'h2222211111111100000000FFFFFFFFFEEEEEEEEEDDDDDDDDCCCCCCCCCBBBBBBB ),
    .INIT_27 ( 256'h9999998888888887777777776666666665555555554444444443333333332222 ),
    .INIT_28 ( 256'h00000FFFFFFFFFEEEEEEEEEEDDDDDDDDDCCCCCCCCCBBBBBBBBBAAAAAAAAAA999 ),
    .INIT_29 ( 256'h7666666666655555555544444444443333333333222222222211111111100000 ),
    .INIT_2A ( 256'hDDDDCCCCCCCCCCBBBBBBBBBBBAAAAAAAAAA99999999998888888888777777777 ),
    .INIT_2B ( 256'h3333322222222222111111111100000000000FFFFFFFFFFEEEEEEEEEEEDDDDDD ),
    .INIT_2C ( 256'h9998888888888877777777777666666666665555555555544444444444333333 ),
    .INIT_2D ( 256'hEEEEEEEEEDDDDDDDDDDDDCCCCCCCCCCCBBBBBBBBBBBBAAAAAAAAAAA999999999 ),
    .INIT_2E ( 256'h3333333333332222222222222111111111111000000000000FFFFFFFFFFFFEEE ),
    .INIT_2F ( 256'h8888888888887777777777777766666666666655555555555554444444444444 ),
    .INIT_30 ( 256'hDDDDDDDDDCCCCCCCCCCCCCBBBBBBBBBBBBBBAAAAAAAAAAAAAA99999999999998 ),
    .INIT_31 ( 256'h111111111111111000000000000000FFFFFFFFFFFFFFEEEEEEEEEEEEEEDDDDDD ),
    .INIT_32 ( 256'h6555555555555555544444444444444443333333333333333222222222222222 ),
    .INIT_33 ( 256'h9999999999999998888888888888888877777777777777777666666666666666 ),
    .INIT_34 ( 256'hDDDDDDDCCCCCCCCCCCCCCCCCCCBBBBBBBBBBBBBBBBBBAAAAAAAAAAAAAAAAAA99 ),
    .INIT_35 ( 256'h000000000000FFFFFFFFFFFFFFFFFFFFEEEEEEEEEEEEEEEEEEEEDDDDDDDDDDDD ),
    .INIT_36 ( 256'h3333333333322222222222222222222221111111111111111111111000000000 ),
    .INIT_37 ( 256'h6655555555555555555555555554444444444444444444444444333333333333 ),
    .INIT_38 ( 256'h8888888888877777777777777777777777777776666666666666666666666666 ),
    .INIT_39 ( 256'hAAAAAAAAAAAAA999999999999999999999999999999998888888888888888888 ),
    .INIT_3A ( 256'hCCBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBAAAAAAAAAAAAAAAAAAAAAAA ),
    .INIT_3B ( 256'hDDDDDDDDDDDDDDDDDDDDDDCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC ),
    .INIT_3C ( 256'hEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD ),
    .INIT_3D ( 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE ),
    .INIT_3E ( 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ),
    .INIT_3F ( 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ),
    .WRITE_MODE_A ( "READ_FIRST" ),
    .WRITE_MODE_B ( "WRITE_FIRST" ),
    .DATA_WIDTH_A ( 4 ),
    .DATA_WIDTH_B ( 4 ),
    .DOA_REG ( 1 ),
    .DOB_REG ( 1 ),
    .INIT_FILE ( "NONE" ),
    .RSTTYPE ( "SYNC" ),
    .INIT_A ( 36'h000000000 ),
    .INIT_B ( 36'h000000000 ),
    .INITP_00 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_01 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_02 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_03 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_04 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_05 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_06 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_07 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .SRVAL_B ( 36'h000000000 ))
  blk00000126 (
    .CLKA(clk),
    .CLKB(clk),
    .ENA(sig00000002),
    .ENB(sig00000002),
    .RSTA(sig00000001),
    .RSTB(sig00000001),
    .REGCEA(sig00000002),
    .REGCEB(sig00000002),
    .ADDRA({sig00000121, sig00000120, sig00000129, sig00000128, sig00000127, sig00000126, sig00000125, sig00000124, sig00000123, sig00000122, 
sig0000011f, sig0000011e, \NLW_blk00000126_ADDRA<1>_UNCONNECTED , \NLW_blk00000126_ADDRA<0>_UNCONNECTED }),
    .ADDRB({sig00000115, sig00000114, sig0000011d, sig0000011c, sig0000011b, sig0000011a, sig00000119, sig00000118, sig00000117, sig00000116, 
sig00000113, sig00000112, \NLW_blk00000126_ADDRB<1>_UNCONNECTED , \NLW_blk00000126_ADDRB<0>_UNCONNECTED }),
    .DIA({\NLW_blk00000126_DIA<31>_UNCONNECTED , \NLW_blk00000126_DIA<30>_UNCONNECTED , \NLW_blk00000126_DIA<29>_UNCONNECTED , 
\NLW_blk00000126_DIA<28>_UNCONNECTED , \NLW_blk00000126_DIA<27>_UNCONNECTED , \NLW_blk00000126_DIA<26>_UNCONNECTED , 
\NLW_blk00000126_DIA<25>_UNCONNECTED , \NLW_blk00000126_DIA<24>_UNCONNECTED , \NLW_blk00000126_DIA<23>_UNCONNECTED , 
\NLW_blk00000126_DIA<22>_UNCONNECTED , \NLW_blk00000126_DIA<21>_UNCONNECTED , \NLW_blk00000126_DIA<20>_UNCONNECTED , 
\NLW_blk00000126_DIA<19>_UNCONNECTED , \NLW_blk00000126_DIA<18>_UNCONNECTED , \NLW_blk00000126_DIA<17>_UNCONNECTED , 
\NLW_blk00000126_DIA<16>_UNCONNECTED , \NLW_blk00000126_DIA<15>_UNCONNECTED , \NLW_blk00000126_DIA<14>_UNCONNECTED , 
\NLW_blk00000126_DIA<13>_UNCONNECTED , \NLW_blk00000126_DIA<12>_UNCONNECTED , \NLW_blk00000126_DIA<11>_UNCONNECTED , 
\NLW_blk00000126_DIA<10>_UNCONNECTED , \NLW_blk00000126_DIA<9>_UNCONNECTED , \NLW_blk00000126_DIA<8>_UNCONNECTED , 
\NLW_blk00000126_DIA<7>_UNCONNECTED , \NLW_blk00000126_DIA<6>_UNCONNECTED , \NLW_blk00000126_DIA<5>_UNCONNECTED , \NLW_blk00000126_DIA<4>_UNCONNECTED 
, sig00000001, sig00000001, sig00000001, sig00000001}),
    .DIB({\NLW_blk00000126_DIB<31>_UNCONNECTED , \NLW_blk00000126_DIB<30>_UNCONNECTED , \NLW_blk00000126_DIB<29>_UNCONNECTED , 
\NLW_blk00000126_DIB<28>_UNCONNECTED , \NLW_blk00000126_DIB<27>_UNCONNECTED , \NLW_blk00000126_DIB<26>_UNCONNECTED , 
\NLW_blk00000126_DIB<25>_UNCONNECTED , \NLW_blk00000126_DIB<24>_UNCONNECTED , \NLW_blk00000126_DIB<23>_UNCONNECTED , 
\NLW_blk00000126_DIB<22>_UNCONNECTED , \NLW_blk00000126_DIB<21>_UNCONNECTED , \NLW_blk00000126_DIB<20>_UNCONNECTED , 
\NLW_blk00000126_DIB<19>_UNCONNECTED , \NLW_blk00000126_DIB<18>_UNCONNECTED , \NLW_blk00000126_DIB<17>_UNCONNECTED , 
\NLW_blk00000126_DIB<16>_UNCONNECTED , \NLW_blk00000126_DIB<15>_UNCONNECTED , \NLW_blk00000126_DIB<14>_UNCONNECTED , 
\NLW_blk00000126_DIB<13>_UNCONNECTED , \NLW_blk00000126_DIB<12>_UNCONNECTED , \NLW_blk00000126_DIB<11>_UNCONNECTED , 
\NLW_blk00000126_DIB<10>_UNCONNECTED , \NLW_blk00000126_DIB<9>_UNCONNECTED , \NLW_blk00000126_DIB<8>_UNCONNECTED , 
\NLW_blk00000126_DIB<7>_UNCONNECTED , \NLW_blk00000126_DIB<6>_UNCONNECTED , \NLW_blk00000126_DIB<5>_UNCONNECTED , \NLW_blk00000126_DIB<4>_UNCONNECTED 
, \NLW_blk00000126_DIB<3>_UNCONNECTED , \NLW_blk00000126_DIB<2>_UNCONNECTED , \NLW_blk00000126_DIB<1>_UNCONNECTED , 
\NLW_blk00000126_DIB<0>_UNCONNECTED }),
    .DIPA({\NLW_blk00000126_DIPA<3>_UNCONNECTED , \NLW_blk00000126_DIPA<2>_UNCONNECTED , \NLW_blk00000126_DIPA<1>_UNCONNECTED , 
\NLW_blk00000126_DIPA<0>_UNCONNECTED }),
    .DIPB({\NLW_blk00000126_DIPB<3>_UNCONNECTED , \NLW_blk00000126_DIPB<2>_UNCONNECTED , \NLW_blk00000126_DIPB<1>_UNCONNECTED , 
\NLW_blk00000126_DIPB<0>_UNCONNECTED }),
    .WEA({sig00000001, sig00000001, sig00000001, sig00000001}),
    .WEB({sig00000001, sig00000001, sig00000001, sig00000001}),
    .DOA({\NLW_blk00000126_DOA<31>_UNCONNECTED , \NLW_blk00000126_DOA<30>_UNCONNECTED , \NLW_blk00000126_DOA<29>_UNCONNECTED , 
\NLW_blk00000126_DOA<28>_UNCONNECTED , \NLW_blk00000126_DOA<27>_UNCONNECTED , \NLW_blk00000126_DOA<26>_UNCONNECTED , 
\NLW_blk00000126_DOA<25>_UNCONNECTED , \NLW_blk00000126_DOA<24>_UNCONNECTED , \NLW_blk00000126_DOA<23>_UNCONNECTED , 
\NLW_blk00000126_DOA<22>_UNCONNECTED , \NLW_blk00000126_DOA<21>_UNCONNECTED , \NLW_blk00000126_DOA<20>_UNCONNECTED , 
\NLW_blk00000126_DOA<19>_UNCONNECTED , \NLW_blk00000126_DOA<18>_UNCONNECTED , \NLW_blk00000126_DOA<17>_UNCONNECTED , 
\NLW_blk00000126_DOA<16>_UNCONNECTED , \NLW_blk00000126_DOA<15>_UNCONNECTED , \NLW_blk00000126_DOA<14>_UNCONNECTED , 
\NLW_blk00000126_DOA<13>_UNCONNECTED , \NLW_blk00000126_DOA<12>_UNCONNECTED , \NLW_blk00000126_DOA<11>_UNCONNECTED , 
\NLW_blk00000126_DOA<10>_UNCONNECTED , \NLW_blk00000126_DOA<9>_UNCONNECTED , \NLW_blk00000126_DOA<8>_UNCONNECTED , 
\NLW_blk00000126_DOA<7>_UNCONNECTED , \NLW_blk00000126_DOA<6>_UNCONNECTED , \NLW_blk00000126_DOA<5>_UNCONNECTED , \NLW_blk00000126_DOA<4>_UNCONNECTED 
, sig000000b5, sig000000b4, sig000000b3, sig000000b2}),
    .DOB({\NLW_blk00000126_DOB<31>_UNCONNECTED , \NLW_blk00000126_DOB<30>_UNCONNECTED , \NLW_blk00000126_DOB<29>_UNCONNECTED , 
\NLW_blk00000126_DOB<28>_UNCONNECTED , \NLW_blk00000126_DOB<27>_UNCONNECTED , \NLW_blk00000126_DOB<26>_UNCONNECTED , 
\NLW_blk00000126_DOB<25>_UNCONNECTED , \NLW_blk00000126_DOB<24>_UNCONNECTED , \NLW_blk00000126_DOB<23>_UNCONNECTED , 
\NLW_blk00000126_DOB<22>_UNCONNECTED , \NLW_blk00000126_DOB<21>_UNCONNECTED , \NLW_blk00000126_DOB<20>_UNCONNECTED , 
\NLW_blk00000126_DOB<19>_UNCONNECTED , \NLW_blk00000126_DOB<18>_UNCONNECTED , \NLW_blk00000126_DOB<17>_UNCONNECTED , 
\NLW_blk00000126_DOB<16>_UNCONNECTED , \NLW_blk00000126_DOB<15>_UNCONNECTED , \NLW_blk00000126_DOB<14>_UNCONNECTED , 
\NLW_blk00000126_DOB<13>_UNCONNECTED , \NLW_blk00000126_DOB<12>_UNCONNECTED , \NLW_blk00000126_DOB<11>_UNCONNECTED , 
\NLW_blk00000126_DOB<10>_UNCONNECTED , \NLW_blk00000126_DOB<9>_UNCONNECTED , \NLW_blk00000126_DOB<8>_UNCONNECTED , 
\NLW_blk00000126_DOB<7>_UNCONNECTED , \NLW_blk00000126_DOB<6>_UNCONNECTED , \NLW_blk00000126_DOB<5>_UNCONNECTED , \NLW_blk00000126_DOB<4>_UNCONNECTED 
, sig00000075, sig00000074, sig00000073, sig00000072}),
    .DOPA({\NLW_blk00000126_DOPA<3>_UNCONNECTED , \NLW_blk00000126_DOPA<2>_UNCONNECTED , \NLW_blk00000126_DOPA<1>_UNCONNECTED , 
\NLW_blk00000126_DOPA<0>_UNCONNECTED }),
    .DOPB({\NLW_blk00000126_DOPB<3>_UNCONNECTED , \NLW_blk00000126_DOPB<2>_UNCONNECTED , \NLW_blk00000126_DOPB<1>_UNCONNECTED , 
\NLW_blk00000126_DOPB<0>_UNCONNECTED })
  );
  RAMB16BWER #(
    .SIM_COLLISION_CHECK ( "ALL" ),
    .SRVAL_A ( 36'h000000000 ),
    .INIT_00 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_01 ( 256'h1111111111111111111111111111111111111111111111100000000000000000 ),
    .INIT_02 ( 256'h2222222222222222222222222222211111111111111111111111111111111111 ),
    .INIT_03 ( 256'h3333333333322222222222222222222222222222222222222222222222222222 ),
    .INIT_04 ( 256'h3333333333333333333333333333333333333333333333333333333333333333 ),
    .INIT_05 ( 256'h4444444444444444444444444444444444444444444444444444444443333333 ),
    .INIT_06 ( 256'h5555555555555555555555555555555555555554444444444444444444444444 ),
    .INIT_07 ( 256'h6666666666666666666655555555555555555555555555555555555555555555 ),
    .INIT_08 ( 256'h7666666666666666666666666666666666666666666666666666666666666666 ),
    .INIT_09 ( 256'h7777777777777777777777777777777777777777777777777777777777777777 ),
    .INIT_0A ( 256'h8888888888888888888888888888888888888888888887777777777777777777 ),
    .INIT_0B ( 256'h9999999999999999999999999888888888888888888888888888888888888888 ),
    .INIT_0C ( 256'hAAA9999999999999999999999999999999999999999999999999999999999999 ),
    .INIT_0D ( 256'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA ),
    .INIT_0E ( 256'hBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBAAAAAAAAAAAAAAAAAAA ),
    .INIT_0F ( 256'hCCCCCCCCCCCCCCCCCCCCCCBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB ),
    .INIT_10 ( 256'hCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC ),
    .INIT_11 ( 256'hDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDCCC ),
    .INIT_12 ( 256'hEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDDDDDDDDDDDDDDD ),
    .INIT_13 ( 256'hFFFFFFFFEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE ),
    .INIT_14 ( 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ),
    .INIT_15 ( 256'h000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFF ),
    .INIT_16 ( 256'h1111111111100000000000000000000000000000000000000000000000000000 ),
    .INIT_17 ( 256'h1111111111111111111111111111111111111111111111111111111111111111 ),
    .INIT_18 ( 256'h2222222222222222222222222222222222222222221111111111111111111111 ),
    .INIT_19 ( 256'h3333332222222222222222222222222222222222222222222222222222222222 ),
    .INIT_1A ( 256'h3333333333333333333333333333333333333333333333333333333333333333 ),
    .INIT_1B ( 256'h4444444444444444444444444444444333333333333333333333333333333333 ),
    .INIT_1C ( 256'h4444444444444444444444444444444444444444444444444444444444444444 ),
    .INIT_1D ( 256'h5555555555555555555555555555555555555555555555555555544444444444 ),
    .INIT_1E ( 256'h6666666555555555555555555555555555555555555555555555555555555555 ),
    .INIT_1F ( 256'h6666666666666666666666666666666666666666666666666666666666666666 ),
    .INIT_20 ( 256'h7777777777777777777766666666666666666666666666666666666666666666 ),
    .INIT_21 ( 256'h7777777777777777777777777777777777777777777777777777777777777777 ),
    .INIT_22 ( 256'h8888888888888888888888888888777777777777777777777777777777777777 ),
    .INIT_23 ( 256'h8888888888888888888888888888888888888888888888888888888888888888 ),
    .INIT_24 ( 256'h9999999999999999999999999999988888888888888888888888888888888888 ),
    .INIT_25 ( 256'h9999999999999999999999999999999999999999999999999999999999999999 ),
    .INIT_26 ( 256'hAAAAAAAAAAAAAAAAAAAAAA999999999999999999999999999999999999999999 ),
    .INIT_27 ( 256'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA ),
    .INIT_28 ( 256'hBBBBBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA ),
    .INIT_29 ( 256'hBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB ),
    .INIT_2A ( 256'hBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB ),
    .INIT_2B ( 256'hCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCBBBBBBBBBBBBBBBBBBBBBBBBBBB ),
    .INIT_2C ( 256'hCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC ),
    .INIT_2D ( 256'hCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC ),
    .INIT_2E ( 256'hDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDCCCCCCCCCCCCCCC ),
    .INIT_2F ( 256'hDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD ),
    .INIT_30 ( 256'hDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD ),
    .INIT_31 ( 256'hEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD ),
    .INIT_32 ( 256'hEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE ),
    .INIT_33 ( 256'hEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE ),
    .INIT_34 ( 256'hEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE ),
    .INIT_35 ( 256'hFFFFFFFFFFFFEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE ),
    .INIT_36 ( 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ),
    .INIT_37 ( 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ),
    .INIT_38 ( 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ),
    .INIT_39 ( 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ),
    .INIT_3A ( 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ),
    .INIT_3B ( 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ),
    .INIT_3C ( 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ),
    .INIT_3D ( 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ),
    .INIT_3E ( 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ),
    .INIT_3F ( 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ),
    .WRITE_MODE_A ( "READ_FIRST" ),
    .WRITE_MODE_B ( "WRITE_FIRST" ),
    .DATA_WIDTH_A ( 4 ),
    .DATA_WIDTH_B ( 4 ),
    .DOA_REG ( 1 ),
    .DOB_REG ( 1 ),
    .INIT_FILE ( "NONE" ),
    .RSTTYPE ( "SYNC" ),
    .INIT_A ( 36'h000000000 ),
    .INIT_B ( 36'h000000000 ),
    .INITP_00 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_01 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_02 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_03 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_04 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_05 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_06 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_07 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .SRVAL_B ( 36'h000000000 ))
  blk00000127 (
    .CLKA(clk),
    .CLKB(clk),
    .ENA(sig00000002),
    .ENB(sig00000002),
    .RSTA(sig00000001),
    .RSTB(sig00000001),
    .REGCEA(sig00000002),
    .REGCEB(sig00000002),
    .ADDRA({sig00000121, sig00000120, sig00000129, sig00000128, sig00000127, sig00000126, sig00000125, sig00000124, sig00000123, sig00000122, 
sig0000011f, sig0000011e, \NLW_blk00000127_ADDRA<1>_UNCONNECTED , \NLW_blk00000127_ADDRA<0>_UNCONNECTED }),
    .ADDRB({sig00000115, sig00000114, sig0000011d, sig0000011c, sig0000011b, sig0000011a, sig00000119, sig00000118, sig00000117, sig00000116, 
sig00000113, sig00000112, \NLW_blk00000127_ADDRB<1>_UNCONNECTED , \NLW_blk00000127_ADDRB<0>_UNCONNECTED }),
    .DIA({\NLW_blk00000127_DIA<31>_UNCONNECTED , \NLW_blk00000127_DIA<30>_UNCONNECTED , \NLW_blk00000127_DIA<29>_UNCONNECTED , 
\NLW_blk00000127_DIA<28>_UNCONNECTED , \NLW_blk00000127_DIA<27>_UNCONNECTED , \NLW_blk00000127_DIA<26>_UNCONNECTED , 
\NLW_blk00000127_DIA<25>_UNCONNECTED , \NLW_blk00000127_DIA<24>_UNCONNECTED , \NLW_blk00000127_DIA<23>_UNCONNECTED , 
\NLW_blk00000127_DIA<22>_UNCONNECTED , \NLW_blk00000127_DIA<21>_UNCONNECTED , \NLW_blk00000127_DIA<20>_UNCONNECTED , 
\NLW_blk00000127_DIA<19>_UNCONNECTED , \NLW_blk00000127_DIA<18>_UNCONNECTED , \NLW_blk00000127_DIA<17>_UNCONNECTED , 
\NLW_blk00000127_DIA<16>_UNCONNECTED , \NLW_blk00000127_DIA<15>_UNCONNECTED , \NLW_blk00000127_DIA<14>_UNCONNECTED , 
\NLW_blk00000127_DIA<13>_UNCONNECTED , \NLW_blk00000127_DIA<12>_UNCONNECTED , \NLW_blk00000127_DIA<11>_UNCONNECTED , 
\NLW_blk00000127_DIA<10>_UNCONNECTED , \NLW_blk00000127_DIA<9>_UNCONNECTED , \NLW_blk00000127_DIA<8>_UNCONNECTED , 
\NLW_blk00000127_DIA<7>_UNCONNECTED , \NLW_blk00000127_DIA<6>_UNCONNECTED , \NLW_blk00000127_DIA<5>_UNCONNECTED , \NLW_blk00000127_DIA<4>_UNCONNECTED 
, sig00000001, sig00000001, sig00000001, sig00000001}),
    .DIB({\NLW_blk00000127_DIB<31>_UNCONNECTED , \NLW_blk00000127_DIB<30>_UNCONNECTED , \NLW_blk00000127_DIB<29>_UNCONNECTED , 
\NLW_blk00000127_DIB<28>_UNCONNECTED , \NLW_blk00000127_DIB<27>_UNCONNECTED , \NLW_blk00000127_DIB<26>_UNCONNECTED , 
\NLW_blk00000127_DIB<25>_UNCONNECTED , \NLW_blk00000127_DIB<24>_UNCONNECTED , \NLW_blk00000127_DIB<23>_UNCONNECTED , 
\NLW_blk00000127_DIB<22>_UNCONNECTED , \NLW_blk00000127_DIB<21>_UNCONNECTED , \NLW_blk00000127_DIB<20>_UNCONNECTED , 
\NLW_blk00000127_DIB<19>_UNCONNECTED , \NLW_blk00000127_DIB<18>_UNCONNECTED , \NLW_blk00000127_DIB<17>_UNCONNECTED , 
\NLW_blk00000127_DIB<16>_UNCONNECTED , \NLW_blk00000127_DIB<15>_UNCONNECTED , \NLW_blk00000127_DIB<14>_UNCONNECTED , 
\NLW_blk00000127_DIB<13>_UNCONNECTED , \NLW_blk00000127_DIB<12>_UNCONNECTED , \NLW_blk00000127_DIB<11>_UNCONNECTED , 
\NLW_blk00000127_DIB<10>_UNCONNECTED , \NLW_blk00000127_DIB<9>_UNCONNECTED , \NLW_blk00000127_DIB<8>_UNCONNECTED , 
\NLW_blk00000127_DIB<7>_UNCONNECTED , \NLW_blk00000127_DIB<6>_UNCONNECTED , \NLW_blk00000127_DIB<5>_UNCONNECTED , \NLW_blk00000127_DIB<4>_UNCONNECTED 
, \NLW_blk00000127_DIB<3>_UNCONNECTED , \NLW_blk00000127_DIB<2>_UNCONNECTED , \NLW_blk00000127_DIB<1>_UNCONNECTED , 
\NLW_blk00000127_DIB<0>_UNCONNECTED }),
    .DIPA({\NLW_blk00000127_DIPA<3>_UNCONNECTED , \NLW_blk00000127_DIPA<2>_UNCONNECTED , \NLW_blk00000127_DIPA<1>_UNCONNECTED , 
\NLW_blk00000127_DIPA<0>_UNCONNECTED }),
    .DIPB({\NLW_blk00000127_DIPB<3>_UNCONNECTED , \NLW_blk00000127_DIPB<2>_UNCONNECTED , \NLW_blk00000127_DIPB<1>_UNCONNECTED , 
\NLW_blk00000127_DIPB<0>_UNCONNECTED }),
    .WEA({sig00000001, sig00000001, sig00000001, sig00000001}),
    .WEB({sig00000001, sig00000001, sig00000001, sig00000001}),
    .DOA({\NLW_blk00000127_DOA<31>_UNCONNECTED , \NLW_blk00000127_DOA<30>_UNCONNECTED , \NLW_blk00000127_DOA<29>_UNCONNECTED , 
\NLW_blk00000127_DOA<28>_UNCONNECTED , \NLW_blk00000127_DOA<27>_UNCONNECTED , \NLW_blk00000127_DOA<26>_UNCONNECTED , 
\NLW_blk00000127_DOA<25>_UNCONNECTED , \NLW_blk00000127_DOA<24>_UNCONNECTED , \NLW_blk00000127_DOA<23>_UNCONNECTED , 
\NLW_blk00000127_DOA<22>_UNCONNECTED , \NLW_blk00000127_DOA<21>_UNCONNECTED , \NLW_blk00000127_DOA<20>_UNCONNECTED , 
\NLW_blk00000127_DOA<19>_UNCONNECTED , \NLW_blk00000127_DOA<18>_UNCONNECTED , \NLW_blk00000127_DOA<17>_UNCONNECTED , 
\NLW_blk00000127_DOA<16>_UNCONNECTED , \NLW_blk00000127_DOA<15>_UNCONNECTED , \NLW_blk00000127_DOA<14>_UNCONNECTED , 
\NLW_blk00000127_DOA<13>_UNCONNECTED , \NLW_blk00000127_DOA<12>_UNCONNECTED , \NLW_blk00000127_DOA<11>_UNCONNECTED , 
\NLW_blk00000127_DOA<10>_UNCONNECTED , \NLW_blk00000127_DOA<9>_UNCONNECTED , \NLW_blk00000127_DOA<8>_UNCONNECTED , 
\NLW_blk00000127_DOA<7>_UNCONNECTED , \NLW_blk00000127_DOA<6>_UNCONNECTED , \NLW_blk00000127_DOA<5>_UNCONNECTED , \NLW_blk00000127_DOA<4>_UNCONNECTED 
, sig000000ad, sig000000ac, sig000000b7, sig000000b6}),
    .DOB({\NLW_blk00000127_DOB<31>_UNCONNECTED , \NLW_blk00000127_DOB<30>_UNCONNECTED , \NLW_blk00000127_DOB<29>_UNCONNECTED , 
\NLW_blk00000127_DOB<28>_UNCONNECTED , \NLW_blk00000127_DOB<27>_UNCONNECTED , \NLW_blk00000127_DOB<26>_UNCONNECTED , 
\NLW_blk00000127_DOB<25>_UNCONNECTED , \NLW_blk00000127_DOB<24>_UNCONNECTED , \NLW_blk00000127_DOB<23>_UNCONNECTED , 
\NLW_blk00000127_DOB<22>_UNCONNECTED , \NLW_blk00000127_DOB<21>_UNCONNECTED , \NLW_blk00000127_DOB<20>_UNCONNECTED , 
\NLW_blk00000127_DOB<19>_UNCONNECTED , \NLW_blk00000127_DOB<18>_UNCONNECTED , \NLW_blk00000127_DOB<17>_UNCONNECTED , 
\NLW_blk00000127_DOB<16>_UNCONNECTED , \NLW_blk00000127_DOB<15>_UNCONNECTED , \NLW_blk00000127_DOB<14>_UNCONNECTED , 
\NLW_blk00000127_DOB<13>_UNCONNECTED , \NLW_blk00000127_DOB<12>_UNCONNECTED , \NLW_blk00000127_DOB<11>_UNCONNECTED , 
\NLW_blk00000127_DOB<10>_UNCONNECTED , \NLW_blk00000127_DOB<9>_UNCONNECTED , \NLW_blk00000127_DOB<8>_UNCONNECTED , 
\NLW_blk00000127_DOB<7>_UNCONNECTED , \NLW_blk00000127_DOB<6>_UNCONNECTED , \NLW_blk00000127_DOB<5>_UNCONNECTED , \NLW_blk00000127_DOB<4>_UNCONNECTED 
, sig0000006d, sig0000006c, sig00000077, sig00000076}),
    .DOPA({\NLW_blk00000127_DOPA<3>_UNCONNECTED , \NLW_blk00000127_DOPA<2>_UNCONNECTED , \NLW_blk00000127_DOPA<1>_UNCONNECTED , 
\NLW_blk00000127_DOPA<0>_UNCONNECTED }),
    .DOPB({\NLW_blk00000127_DOPB<3>_UNCONNECTED , \NLW_blk00000127_DOPB<2>_UNCONNECTED , \NLW_blk00000127_DOPB<1>_UNCONNECTED , 
\NLW_blk00000127_DOPB<0>_UNCONNECTED })
  );
  LUT4 #(
    .INIT ( 16'h6AAA ))
  blk00000128 (
    .I0(sig000000f7),
    .I1(sig000000f6),
    .I2(sig000000f5),
    .I3(sig000000f4),
    .O(sig0000006a)
  );
  MUXF5   blk00000129 (
    .I0(sig000000f7),
    .I1(sig0000006a),
    .S(sig00000068),
    .O(sig000000d0)
  );
  LUT4 #(
    .INIT ( 16'h6AAA ))
  blk0000012a (
    .I0(sig000000e8),
    .I1(sig000000e7),
    .I2(sig000000e6),
    .I3(sig000000e5),
    .O(sig0000005f)
  );
  MUXF5   blk0000012b (
    .I0(sig000000e8),
    .I1(sig0000005f),
    .S(sig0000005d),
    .O(sig00000092)
  );
  SRL16 #(
    .INIT ( 16'h0000 ))
  blk0000012c (
    .A0(sig00000002),
    .A1(sig00000001),
    .A2(sig00000001),
    .A3(sig00000001),
    .CLK(clk),
    .D(sig000000d3),
    .Q(sig000000d2)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000012d (
    .C(clk),
    .D(sig000000d2),
    .Q(sig000000d6)
  );
  SRL16 #(
    .INIT ( 16'h0000 ))
  blk0000012e (
    .A0(sig00000001),
    .A1(sig00000001),
    .A2(sig00000001),
    .A3(sig00000001),
    .CLK(clk),
    .D(sig000000d4),
    .Q(sig000000d1)
  );
  FD #(
    .INIT ( 1'b0 ))
  blk0000012f (
    .C(clk),
    .D(sig000000d1),
    .Q(sig000000d5)
  );

// synthesis translate_on

endmodule

// synthesis translate_off

`ifndef GLBL
`define GLBL

`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;

    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (weak1, weak0) GSR = GSR_int;
    assign (weak1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule

`endif

// synthesis translate_on
