/*
 * simple.c
 *
 *  Created on: Feb 12, 2011
 *      Author: george.eichinger
 */

#include <stdio.h>
#include <stdlib.h>
#include "xio.h"
#include "xbasic_types.h"
#include "xparameters.h"
#include "xuartlite_l.h"

#define RECORD_SIZE 4096
#define NUM_ITER 10
#define BUFFER_SIZE 80

int input;
unsigned char inputBuffer[BUFFER_SIZE];
unsigned long address;
unsigned long data;
int temp;
unsigned int dataStore;
unsigned int remote_frequency,transform_width, mode,threshold_scale,threshold,freq_cmd;

//int checkInputDelay();
int isHexChar(int inByte);
int isEndOfCmd(int inByte);
int validateCmd();
int printMenu();
int printHeader();
int cmdMenu();
int sendWord(unsigned int word);
int initEthernetHeader();

int main () {
	int ptr=0;
	int i,j;
	int wait;
	int fft_length;
	unsigned int timer;
	int numData;

  // xil_printf("Set mode 3, counter\r\n");
 
  // while(1)
  // {
    // XIo_Out32(0x1000000C, 0x3);
  // }
  
  // while(1);
  

	//init variables
	temp=0;
	remote_frequency = 10e6;
	transform_width = 9; //log(8-1024)/log(2)
	mode = 0; //0=adc data, 1=NCO data, 2=fixed, 3=counter
	threshold_scale = 9; //number of bits to shift away
	threshold = 1024; //threshold value

	//set the defaults
	XIo_Out32(0x10000018,threshold_scale); //set initial threshold scale
	XIo_Out32(0x1000001C,transform_width); //set the initial transform width
	XIo_Out32(0x10000020,threshold); //set initial threshold
	freq_cmd=(remote_frequency)/3052;
	if(freq_cmd > 32767) freq_cmd=32767;
	if(freq_cmd < 0) freq_cmd = 0;
	freq_cmd=freq_cmd|(mode<<14);
	XIo_Out32(0x1000000C, freq_cmd); //set the frequency / mode

	initEthernetHeader();
	cmdMenu();
	while(1)
	{
		input = XUartLite_RecvByte(STDOUT_BASEADDRESS);

		// Check if a full cmd has been received
		//if (isEndOfCmd(input))
		if (ptr==5)
		{
			switch(inputBuffer[0])
			{
			case 1: //remote frequency / mode
				remote_frequency = (inputBuffer[4]) + (inputBuffer[3]<<8) + (inputBuffer[2]<<16) + (inputBuffer[1]<<24); //convert from 8 bits to 32 bits
				freq_cmd = (remote_frequency)/3052;
				if(freq_cmd > 32767) freq_cmd=32767;
				if(freq_cmd < 0) freq_cmd = 0;
				freq_cmd=freq_cmd|mode<<14;; //append the top two bits as the mode
				//freq_cmd=0x9998; //20 MHz?
				XIo_Out32(0x1000000C, freq_cmd);
				//sendWord(remote_frequency);
				sendWord(freq_cmd);
				//sendWord(0xabadbabe);
				break;
			case 2: //transform width (note that the value is 2^x where x is the desired number)
				transform_width = (inputBuffer[4]) + (inputBuffer[3]<<8) + (inputBuffer[2]<<16) + (inputBuffer[1]<<24); //convert from 8 bits to 32 bits
				XIo_Out32(0x1000001C, transform_width);
				sendWord(transform_width);
				break;
			case 3: //mode
				mode = (inputBuffer[4]) + (inputBuffer[3]<<8) + (inputBuffer[2]<<16) + (inputBuffer[1]<<24); //convert from 8 bits to 32 bits
				sendWord(mode);
				break;
			case 4: //threshold_scale
				threshold_scale = (inputBuffer[4]) + (inputBuffer[3]<<8) + (inputBuffer[2]<<16) + (inputBuffer[1]<<24); //convert from 8 bits to 32 bits
				XIo_Out32(0x10000018,threshold_scale); //set initial threshold scale
				sendWord(threshold_scale);
				break;
			case 5: //threshold
				threshold = (inputBuffer[4]) + (inputBuffer[3]<<8) + (inputBuffer[2]<<16) + (inputBuffer[1]<<24); //convert from 8 bits to 32 bits
				XIo_Out32(0x10000020,threshold); //set initial threshold
				sendWord(threshold);
				break;
			case 6:
				XIo_Out32(0x10000008, 0x1); //tell the test to start
				XIo_Out32(0x10000008, 0x0); //takes the hold off the reset
				for (wait=0; wait<80; wait++);
				fft_length = (2<<(transform_width-1));
				for (i=0;i<fft_length;i++)
				{
					XIo_Out32(0x10000014, i); //request a specific address
					dataStore=XIo_In32(0x10000018);
					sendWord(dataStore);
					//sendWord(0xDEADBEEF);
					//sendWord(XIo_In32(0x10000018));
				}
				break;
			case 7: //grab data directly from input fifo
				numData = (inputBuffer[4]) + (inputBuffer[3]<<8) + (inputBuffer[2]<<16) + (inputBuffer[1]<<24); //convert from 8 bits to 32 bits
				if(numData > 32768) numData = 32768;
				XIo_Out32(0x10000008, 0x1); //tell the test to start
				XIo_Out32(0x10000008, 0x0); //takes the hold off the reset
				for (wait=0; wait<80; wait++);
				for (i=0;i<numData;i++)
				{
					sendWord(XIo_In32(0x1000000C));
				}

				break;
			case 8:
				cmdMenu();
				break;
			case 9: //read timers
				timer = (inputBuffer[4]) + (inputBuffer[3]<<8) + (inputBuffer[2]<<16) + (inputBuffer[1]<<24); //convert from 8 bits to 32 bits
				switch(timer)
				{
				case 0: //send timers to user
					//sendWord(0xDEADBEEF); //timer 0
					sendWord(XIo_In32(0x1000001C)); //timer 0
					sendWord(XIo_In32(0x10000020)); //timer 1
					sendWord(XIo_In32(0x10000024)); //timer 2
					sendWord(XIo_In32(0x10000028)); //timer 3
					sendWord(XIo_In32(0x1000002C)); //timer 4
					sendWord(XIo_In32(0x10000030)); //timer 5
					sendWord(XIo_In32(0x10000034)); //timer 6
					sendWord(XIo_In32(0x10000038)); //timer 7
					break;
				case 1: //stop remote timer
					XIo_Out32(0x10000024, 0x1); //stop the timer
					XIo_Out32(0x10000024, 0x0);
					break;
				case 2: //start test timer
					XIo_Out32(0x1000002C, 0x1); //start the test timer
					XIo_Out32(0x1000002C, 0x0);
					break;
				case 3: //stop test timer
					XIo_Out32(0x10000028, 0x1); //stop the test timer
					XIo_Out32(0x10000028, 0x0);
					break;

				default:
					break;

				}
				break;
			case 10: //grab data directly from input fifo
				numData = (inputBuffer[4]) + (inputBuffer[3]<<8) + (inputBuffer[2]<<16) + (inputBuffer[1]<<24); //convert from 8 bits to 32 bits
				if(numData > 32768) numData = 32768;
				XIo_Out32(0x10000008, 0x1); //tell the test to start
				XIo_Out32(0x10000008, 0x0); //takes the hold off the reset
				for (wait=0; wait<80; wait++);
				for (i=0;i<numData;i++)
				{
					sendWord(XIo_In32(0x1000003C));
				}
				break;
			default:
				break;
			}

			ptr = 0;
			for(i=0; i<BUFFER_SIZE; i++) {
				inputBuffer[i] = 0;
			}
		}
		else
		{
			if(ptr < BUFFER_SIZE)
			{
				inputBuffer[ptr++] = input;
			}
		}
	}
}

int sendWord(unsigned int word)
{
	XUartLite_SendByte(STDOUT_BASEADDRESS,((word>>24)&0xff));
	XUartLite_SendByte(STDOUT_BASEADDRESS,((word>>16)&0xff));
	XUartLite_SendByte(STDOUT_BASEADDRESS,((word>>8)&0xff));
	XUartLite_SendByte(STDOUT_BASEADDRESS,((word>>0)&0xff));
	return 0;
}

int initEthernetHeader()
{
	XIo_Out32(0x10000044,0x00000018); // Dest MAC Address
	XIo_Out32(0x10000044,0x00010003);
	XIo_Out32(0x10000044,0x00020073);
	XIo_Out32(0x10000044,0x00030029);
	XIo_Out32(0x10000044,0x000400AE);
	XIo_Out32(0x10000044,0x00050042); 
	XIo_Out32(0x10000044,0x00060000); // Src MAC Address
	XIo_Out32(0x10000044,0x0007000A);
	XIo_Out32(0x10000044,0x00080035);
	XIo_Out32(0x10000044,0x00090002);
	XIo_Out32(0x10000044,0x000a0050);
	XIo_Out32(0x10000044,0x000b00A3);
	XIo_Out32(0x10000044,0x000c0008);
	XIo_Out32(0x10000044,0x000d0000);
	XIo_Out32(0x10000044,0x000e0045);
	XIo_Out32(0x10000044,0x000f0000);
	XIo_Out32(0x10000044,0x00100004); //total length top
	XIo_Out32(0x10000044,0x00110022); //total length bottom
	XIo_Out32(0x10000044,0x00120000);
	XIo_Out32(0x10000044,0x00130000);
	XIo_Out32(0x10000044,0x00140040);
	XIo_Out32(0x10000044,0x00150000);
	XIo_Out32(0x10000044,0x001600ff); // TTL
	XIo_Out32(0x10000044,0x00170011); // Protocol UDP = 17
	XIo_Out32(0x10000044,0x001800e2); //checksum lower
	XIo_Out32(0x10000044,0x00190014); //checksum upper
	XIo_Out32(0x10000044,0x001a00c0); // 192 Source Addr
	XIo_Out32(0x10000044,0x001b00a8); // 168
	XIo_Out32(0x10000044,0x001c000a); // 10
	XIo_Out32(0x10000044,0x001d0064); // 100
	XIo_Out32(0x10000044,0x001e00c0); // 192 Dest Addr
	XIo_Out32(0x10000044,0x001f00a8); // 168
	XIo_Out32(0x10000044,0x0020000a); // 10
	XIo_Out32(0x10000044,0x00210001); // 1
	XIo_Out32(0x10000044,0x00220023);
	XIo_Out32(0x10000044,0x00230083);
	XIo_Out32(0x10000044,0x00240023);
	XIo_Out32(0x10000044,0x00250082);
	XIo_Out32(0x10000044,0x00260004); //upper byte of length
	XIo_Out32(0x10000044,0x0027000a); //lower byte of length //default to 1024+8 + 2
	XIo_Out32(0x10000044,0x00280000);
	XIo_Out32(0x10000044,0x00290000);
	XIo_Out32(0x10000044,0x002a0055);
	XIo_Out32(0x10000044,0x002b0066);
	XIo_Out32(0x10000044,0x002c00F1); //shouldn't read these
	XIo_Out32(0x10000044,0x002d00F2); //shouldn't read these

	return 0;
}

int parse_int(char *str)
{
    int result = 0;
  //  str+=2; //assume 0x
    while(*str)
    {
        result = result << 4;
        if(*str <= '9')
            result += *str-'0';
        else result += toupper(*str) - ('A'-10); //assume capital characters
        str++;
    }
    return result;
}

int cmdMenu()
{
	int ptr=0;
	int i,j;
	int LEDs;
	int remote_data,cmd;
	int wait;
	int bus_mode;
	int bus_freq;
	int bus_freq_desired;
	unsigned int bus_echo;
	int bus_testLengthLog;
	int fftScale;
	int bus_threshold;
	temp=0;
	mode=1;

	//set defaults:
	bus_mode = 0;
	bus_freq_desired = 1e6;
	bus_echo = 0xDEADBEEF;
	bus_testLengthLog = 8;
	bus_threshold=10000000;

	XIo_Out32(0x10000030,bus_mode);
	bus_freq=(bus_freq_desired)/3052;
	if(bus_freq > 32767) bus_freq=32767;
	if(bus_freq < 0) bus_freq = 0;
	XIo_Out32(0x10000034,bus_freq);
	XIo_Out32(0x10000038,bus_echo);
	XIo_Out32(0x1000003C,bus_testLengthLog);
	XIo_Out32(0x1000001C,bus_testLengthLog);

	printHeader();
	printMenu();

	while(1)
	{
		input = XUartLite_RecvByte(STDOUT_BASEADDRESS);
		xil_printf("%c",input); //loop back the input so the user can see what they are typing
		// Check if a full cmd has been received
		if (isEndOfCmd(input))
		{
			switch(inputBuffer[0])
			{
			case 'i':
				xil_printf("Test starting: Internal Data\n\r");
				XIo_Out32(0x10000008, 0x1); //tell the test to start
				XIo_Out32(0x10000008, 0x0); //takes the hold off the reset
				for(i=0;i<128;i++)
				{
					xil_printf("\n\r");
					for(j=0;j<8;j++)
					{
						xil_printf("%08x ",XIo_In32(0x10000014));
					}
				}
				xil_printf("\n\r");
				break;
			case 't':
				xil_printf("Test starting: Raw Data\n\r");
				XIo_Out32(0x10000008, 0x1); //tell the test to start
				XIo_Out32(0x10000008, 0x0); //takes the hold off the reset
				for(i=0;i<128;i++)
				{
					xil_printf("\n\r");
					for(j=0;j<8;j++)
					{
						xil_printf("%08x ",XIo_In32(0x10000010));
					}
				}
				xil_printf("\n\r");
				break;
			case 'f':
				xil_printf("Test starting: Fifoed Data\n\r");
				XIo_Out32(0x10000008, 0x1); //tell the test to start
				XIo_Out32(0x10000008, 0x0); //takes the hold off the reset
				for(i=0;i<128;i++)
				{
					xil_printf("\n\r");
					for(j=0;j<8;j++)
					{
						xil_printf("%08x ",XIo_In32(0x1000000C));
					}
				}
				xil_printf("\n\r");
				break;
			case 'o':
				xil_printf("Test starting: FFT Data\n\r");
				XIo_Out32(0x10000008, 0x1); //tell the test to start
				XIo_Out32(0x10000008, 0x0); //takes the hold off the reset
				for (wait=0; wait<80; wait++);
				//for(k=0;k<1000;k++)
				//{
					for(i=0;i<128;i++)
					{
						for(j=0;j<8;j++)
						{
							XIo_Out32(0x10000014, i*8+j); //request a specific address
							xil_printf("%08x ",XIo_In32(0x10000018));

						}
						xil_printf("\n\r");
					}
					xil_printf("\n\r");
				//}
				break;
			case 'v':
				xil_printf("Firmware ID: 0x%x\n\r",XIo_In32(0x10000000));
				xil_printf("Firmware Version: 0x%x\n\r",XIo_In32(0x10000004));
				break;
			case 'L':
				LEDs=0;
				if(inputBuffer[5] == '1') LEDs+=1;
				if(inputBuffer[4] == '1') LEDs+=2;
				if(inputBuffer[3] == '1') LEDs+=4;
				if(inputBuffer[2] == '1') LEDs+=8;
				XIo_Out32(0x10000004, LEDs);	// Set the LEDs
				break;
			case 'd':
				xil_printf("Current DIP: 0x%x\n\r",XIo_In32(0x10000008));
				break;
			case 's':
				remote_data = (inputBuffer[2]-48)*100 + (inputBuffer[3]-48)*10+inputBuffer[4]-48; //convert from ascii to integer
				//remote_data = 0x00000000;
				cmd = (remote_data*500000)/1526;
				if(cmd > 32767) cmd=32767;
				if(cmd < 0) cmd = 0;
				//cmd=cmd|0x8000; //set the command to output NCO data
				cmd=cmd|mode<<14;; //append the top two bits as the mode
				//cmd=0x9998;
				XIo_Out32(0x1000000C, cmd);
				xil_printf("You set the remote frequency: %dMHz cmd:%x\n\r",remote_data,cmd);
				break;
			case 'h':
				remote_data = (inputBuffer[2]-48)*10+inputBuffer[3]-48; //convert from ascii to integer
				//remote_data = 0x00000000;
				XIo_Out32(0x10000018, remote_data);
				xil_printf("You set scaling threshold to: %d\n\r",remote_data);
				break;
			case 'w':
				remote_data = (inputBuffer[2]-48)*10+inputBuffer[3]-48; //convert from ascii to integer
				//remote_data = 0x00000000;
				XIo_Out32(0x1000001C, remote_data);
				xil_printf("You set transform log2 Width to: %d\n\r",remote_data);
				break;
			case 'F':
				xil_printf("Test starting: Filtered Data\n\r");
				XIo_Out32(0x10000008, 0x1); //tell the test to start
				XIo_Out32(0x10000008, 0x0); //takes the hold off the reset
				for(i=0;i<128;i++)
				{
					xil_printf("\n\r");
					for(j=0;j<8;j++)
					{
						xil_printf("%08x ",XIo_In32(0x1000003C));
					}
				}
				xil_printf("\n\r");
				break;
			case 'm':
				mode = (inputBuffer[2]-48);
				xil_printf("You set the mode to: %d\n\r",mode);
				break;
			case '1':
				bus_mode = (inputBuffer[2]-48);
				XIo_Out32(0x10000030,bus_mode);
				xil_printf("You set the mode to: %d\n\r",bus_mode);
				break;
			case '2':
				remote_data = (inputBuffer[2]-48)*100 + (inputBuffer[3]-48)*10+inputBuffer[4]-48; //convert from ascii to integer
				bus_freq = (remote_data*500000)/763;
				if(bus_freq > 32767*2+1) bus_freq=32767*2+1;
				if(bus_freq < 0) bus_freq = 0;
				XIo_Out32(0x10000034, bus_freq);
				xil_printf("You set the remote frequency: %dMHz cmd:%x\n\r",remote_data,bus_freq);
				break;
			case '3':
				//bus_echo = parse_int(inputBuffer[2]);
				bus_echo = (inputBuffer[2]-48)*10000 + (inputBuffer[3]-48)*1000 + (inputBuffer[4]-48)*100 + (inputBuffer[5]-48)*10+inputBuffer[6]-48; //convert from ascii to integer
				if(bus_echo >= 32767) bus_echo = 32767;
				XIo_Out32(0x10000038, bus_echo);
				xil_printf("You set the echo to: 0x%x\n\r",bus_echo);
				break;
			case '4':
				remote_data = (inputBuffer[2]-48)*10+inputBuffer[3]-48; //convert from ascii to integer
				bus_testLengthLog = remote_data;
				XIo_Out32(0x1000003C, bus_testLengthLog);
				xil_printf("You set transform log2 Width to: %d\n\r",bus_testLengthLog);
				break;
			case '5':
				xil_printf("Test starting: new Data\n\r");
				XIo_Out32(0x10000008, 0x1); //tell the test to start
				XIo_Out32(0x10000008, 0x0); //takes the hold off the reset
				for(i=0;i<128;i++)
				{
					xil_printf("\n\r");
					for(j=0;j<8;j++)
					{
						xil_printf("%08x ",XIo_In32(0x1000003c));
					}
				}
				xil_printf("\n\r");
				break;
			case '6':
				fftScale = (inputBuffer[2]-48)*10000 + (inputBuffer[3]-48)*1000 + (inputBuffer[4]-48)*100 + (inputBuffer[5]-48)*10+inputBuffer[6]-48; //convert from ascii to integer
				XIo_Out32(0x10000040, fftScale);
				xil_printf("Set scaling to: %x |%d|%d|%d|%d|%d|%d|%d|%d| \n\r",fftScale,((fftScale>>14)&&0x3),((fftScale>>12)&&0x3),((fftScale>>10)&&0x3),((fftScale>>8)&&0x3),((fftScale>>6)&&0x3),((fftScale>>4)&&0x3),((fftScale>>2)&&0x3),((fftScale>>0)&&0x3));
				break;
			case '7':
				XIo_Out32(0x10000048, 0xdeadbeef); //trigger packet to send
				xil_printf("Sent packet\n\r");
				break;
			case '8': //show thresholding results
				xil_printf("Test starting: Thresh Data\n\r");
				XIo_Out32(0x10000008, 0x1); //tell the test to start
				XIo_Out32(0x10000008, 0x0); //takes the hold off the reset
				for (wait=0; wait<80; wait++); //fake timer
				for(i=0;i<32;i++)
				{
					for(j=0;j<8;j++)
					{
						XIo_Out32(0x1000004C, i*8+j); //request a specific address
						xil_printf("%08x ",XIo_In32(0x10000040));
					}
					xil_printf("\n\r");
				}
				xil_printf("\n\r");
				break;
			case '9':
				bus_threshold = (inputBuffer[2]-48)*10000000 + (inputBuffer[3]-48)*1000000 + (inputBuffer[4]-48)*100000 + (inputBuffer[5]-48)*10000 + (inputBuffer[6]-48)*1000 + (inputBuffer[7]-48)*100 + (inputBuffer[8]-48)*10+inputBuffer[9]-48; //convert from ascii to integer
				XIo_Out32(0x10000020, bus_threshold);
				xil_printf("You set the threshold to: 0x%x\n\r",bus_threshold);
				break;
			case 'u':
				//run FFT test
				xil_printf("Test starting: FFT Data\n\r");
				XIo_Out32(0x10000008, 0x1); //tell the test to start
				XIo_Out32(0x10000008, 0x0); //takes the hold off the reset
				for (wait=0; wait<80; wait++);
				for(i=0;i<128;i++)
				{
					for(j=0;j<8;j++)
					{
						XIo_Out32(0x10000014, i*8+j); //request a specific address
						xil_printf("%08x ",XIo_In32(0x10000018));

					}
					xil_printf("\n\r");
				}
				xil_printf("\n\r");

				//test is already run, print out corresponding thresh data
				//xil_printf("Test starting: Thresh Data\n\r");
				for(i=0;i<32;i++)
				{
					for(j=0;j<8;j++)
					{
						XIo_Out32(0x1000004C, i*8+j); //request a specific address
						xil_printf("%08x ",XIo_In32(0x10000040));
					}
					xil_printf("\n\r");
				}
				xil_printf("\n\r");
				break;
			default:
				xil_printf("Response not recognized, try again.\n\r");
				break;
			}

			printMenu();

			ptr = 0;
			for(i=0; i<BUFFER_SIZE; i++) {
				inputBuffer[i] = 0;
			}
		}
		else
		{
			if(ptr < BUFFER_SIZE)
			{
				inputBuffer[ptr++] = input;
			}
		}
	}
}

int printMenu()
{
	xil_printf("Please select an option:\n\r");
	xil_printf("\ti: start test - internal data\n\r");
	xil_printf("\tf: start test - fifoed data\n\r");
	xil_printf("\tt: start test - raw data\n\r");
	xil_printf("\tF: start test - filtered data\n\r");
	xil_printf("\to: start test - output of FFT\n\r");
	xil_printf("\tv: print firmware version\n\r");
	xil_printf("\tL: light 4 LEDs using binary aka [>>L 0101]\n\r");
	xil_printf("\td: print dip status\n\r");
	xil_printf("\ts: set the desired remote frequency 0-100M [>>s 005]\n\r");
	xil_printf("\th: set threshold [>>h 05]\n\r");
	xil_printf("\tw: set transform log2 width [>>r 09 = 2^9=512]\n\r");
	xil_printf("\tm: set mode [>>m 0]\n\r");
	xil_printf("\t1: set mode new [>>1 0]\n\r");
	xil_printf("\t2: set the desired remote frequency new 0-100M [>>2 005]\n\r");
	xil_printf("\t3: set echo in hex [>>3 deadbeef OR >>3 0101ababe]\n\r");
	xil_printf("\t4: set transform log2 width [>>4 09 = 2^9=512]\n\r");
	xil_printf("\t5: start test - raw data\n\r");
	xil_printf("\t6: set FFT scale [>>6 43691 or >>6 00156]\n\r");
	xil_printf("\t7: send test packet\n\r");
	xil_printf("\t8: start test - thresholded\n\r");
	xil_printf("\t9: set the threshold {>>9 12345678}\n\r");
	xil_printf("\tu: run double test, fft & thresh\n\r");
	xil_printf("\n\r>>");
	return 0;
}


int printHeader()
{
	/* Display the firmware information */
	xil_printf("\n\r================================================\n\r");
	xil_printf("ML605 to USRP V0.8\n\r");
	xil_printf("George Eichinger\n\n\r");
	xil_printf("Firmware ID: 0x%x\n\r",XIo_In32(0x10000000));
	xil_printf("Firmware Version: 0x%x\n\r",XIo_In32(0x10000004));
	xil_printf("================================================\n\r");
	return 0;
}

int isHexChar(int inByte) {

	if ( ((inByte >= 0x30) && (inByte <= 0x39)) || ((inByte >= 0x41) && (inByte <= 0x46)) || ((inByte >= 0x61) && (inByte <= 0x66))) {
		return(1);
	}
	else {
		return (0);
	}
}

int hexConvert(int inByte) {

	if( (inByte >= 0x30) && (inByte <= 0x39) ) {
		return (inByte - 0x30);
	}

	else if( (inByte >= 0x41) && (inByte <= 0x46) ) {
			return (inByte - 0x37);
	}

	else {
			return (inByte - 0x57);
	}

}

// Is input a carriage return -- if so assume end of command
int isEndOfCmd(int inByte) {
	return (inByte == 0x0D);
}
