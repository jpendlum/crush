/******************************************************************************
**  CRUSH
**  Cognitive Radio Universal Software Hardware
**  http://www.coe.neu.edu/Research/rcl//projects/CRUSH.php
**  
**  CRUSH is free software: you can redistribute it and/or modify
**  it under the terms of the GNU General Public License as published by
**  the Free Software Foundation, either version 3 of the License, or
**  (at your option) any later version.
**  
**  CRUSH is distributed in the hope that it will be useful,
**  but WITHOUT ANY WARRANTY; without even the implied warranty of
**  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**  GNU General Public License for more details.
**  
**  You should have received a copy of the GNU General Public License
**  along with CRUSH.  If not, see <http://www.gnu.org/licenses/>.
**  
**  
**  
**  File: main.c
**  Author: Jonathon Pendlum (jon.pendlum@gmail.com)
**  Description: 
******************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include "xio.h"
#include "xbasic_types.h"
#include "xparameters.h"
#include "xuartlite_l.h"
#include "fsl.h"

// Function prototypes
void GetUartBytes(int num_chars, char* string);
u16 ReadReg(u16 address);
void WriteReg(u16 address, u16 value);
int HexToDec(int num_chars, char* string);

#define USRP_UART_BASEADDR          XPAR_AXI_UARTLITE_USRP_BASEADDR

// GPIO 1 In
#define MASK_RX_DATA_CLK_LOCKED     0x1
#define OFFSET_RX_DATA_CLK_LOCKED   0
#define MASK_PHASE_CNT              0x7F
#define OFFSET_PHASE_CNT            26

// GPIO 1 Out
#define OFFSET_PHASE_INC            0x1
#define OFFSET_PHASE_DEC            0x2

// Register map
#define RW_MAC_ADDR_DEST_BYTES_5_4  0x00
#define RW_MAC_ADDR_DEST_BYTES_3_2  0x01
#define RW_MAC_ADDR_DEST_BYTES_1_0  0x02
#define RW_MAC_ADDR_SRC_BYTES_5_4   0x03
#define RW_MAC_ADDR_SRC_BYTES_3_2   0x04
#define RW_MAC_ADDR_SRC_BYTES_1_0   0x05
#define RW_IP_ADDR_DEST_BYTES_3_2   0x06
#define RW_IP_ADDR_DEST_BYTES_1_0   0x07
#define RW_IP_ADDR_SRC_BYTES_3_2    0x08
#define RW_IP_ADDR_SRC_BYTES_1_0    0x09
#define RW_PORT_DEST                0x0A
#define RW_PORT_SRC                 0x0B
#define RW_PAYLOAD_SIZE             0x0C
#define RW_FFT_SIZE                 0x0D
#define RW_THRESHOLD_BYTES_3_2      0x0E
#define RW_THRESHOLD_BYTES_1_0      0x0F
#define RW_CTRL_FLAGS               0x10
#define SEND_THRESHOLD_BIT          0x1
#define SEND_FFT_BIT                0x2
#define SEND_MAG_SQUARED_BIT        0x4
#define SEND_CNT_PATTERN_BIT        0x8
#define OVERRIDE_BIT                0x4000
#define START_SPECTRUM_SENSE        0x8000


int main ()
{
  u32 gpio_1_in = 0;
  u32 gpio_1_out = 0;
  char menu_selection = 0;
  char string[4] = "0000";
  // Configuration options
  u16 mac_addr_dest_byte_5_4 = 0;
  u16 mac_addr_dest_byte_3_2 = 0;
  u16 mac_addr_dest_byte_1_0 = 0;
  u16 mac_addr_src_byte_5_4 = 0;
  u16 mac_addr_src_byte_3_2 = 0;
  u16 mac_addr_src_byte_1_0 = 0;
  u16 ip_addr_dest_byte_3_2 = 0;
  u16 ip_addr_dest_byte_1_0 = 0;
  u16 ip_addr_src_byte_3_2 = 0;
  u16 ip_addr_src_byte_1_0 = 0;
  u16 port_dest = 0;
  u16 port_src = 0;
  u16 payload_size = 0;
  u16 fft_size = 0;
  u16 threshold_byte_3_2 = 0;
  u16 threshold_byte_1_0 = 0;
  u16 ctrl_flags = 0;
  u8 override = 0;
  u8 send_fft = 0;
  u8 send_threshold = 0;
  u8 send_mag_squared = 0;
  u8 send_cnt_pattern = 0;

  // User interface
  while(TRUE) 
  {
    xil_printf("\r\n");
    xil_printf("\r\n");
    xil_printf("-----------------------------------------------------------\r\n");
    xil_printf("--                         CRUSH                         --\r\n");
    xil_printf("--      Cognitive Radio Universal Software Hardware      --\r\n");
    xil_printf("--                    Jonathon Pendlum                   --\r\n");
    xil_printf("-----------------------------------------------------------\r\n");
    xil_printf("\r\n");
    gpio_1_in = XIo_In32(XPAR_AXI_GPIO_0_BASEADDR);
    xil_printf("USRP Connected:\t\t\t");
    if ((gpio_1_in & MASK_RX_DATA_CLK_LOCKED) == TRUE) xil_printf("TRUE\r\n");
    else xil_printf("FALSE\r\n");
    xil_printf("RX Data PLL Phase Offset:\t%d\r\n",(gpio_1_in >> OFFSET_PHASE_CNT) & MASK_PHASE_CNT);
    xil_printf("Source MAC Address:\t\t%02x:%02x:%02x:%02x:%02x:%02x\r\n", 
      mac_addr_src_byte_5_4 >> 8, mac_addr_src_byte_5_4 & 0x00FF, mac_addr_src_byte_3_2 >> 8, 
      mac_addr_src_byte_3_2 & 0x00FF, mac_addr_src_byte_1_0 >> 8, mac_addr_src_byte_1_0 & 0x00FF);
    xil_printf("Destination MAC Address:\t%02x:%02x:%02x:%02x:%02x:%02x\r\n", 
      mac_addr_dest_byte_5_4 >> 8, mac_addr_dest_byte_5_4 & 0x00FF, mac_addr_dest_byte_3_2 >> 8, 
      mac_addr_dest_byte_3_2 & 0x00FF, mac_addr_dest_byte_1_0 >> 8, mac_addr_dest_byte_1_0 & 0x00FF);
    xil_printf("Source IP Address:\t\t%d.%d.%d.%d\r\n",
      ip_addr_src_byte_3_2 >> 8, ip_addr_src_byte_3_2 & 0x00FF, 
      ip_addr_src_byte_1_0 >> 8, ip_addr_src_byte_1_0 & 0x00FF);
    xil_printf("Destination IP Address:\t\t%d.%d.%d.%d\r\n",
      ip_addr_dest_byte_3_2 >> 8, ip_addr_dest_byte_3_2 & 0x00FF,
      ip_addr_dest_byte_1_0 >> 8, ip_addr_dest_byte_1_0 & 0x00FF);
    xil_printf("Source Port Address:\t\t%d\r\n",port_src);
    xil_printf("Destination Port Address:\t%d\r\n", port_dest);
    xil_printf("Payload Size:\t\t\t%d\r\n", payload_size);
    xil_printf("FFT Size:\t\t\t%d\r\n", fft_size);
    xil_printf("Threshold:\t\t\t%d\r\n", (threshold_byte_3_2 << 8) + threshold_byte_1_0);
    xil_printf("Flags Enabled: ");
    if (override == 1) xil_printf("Override ");
    if (send_fft == 1) xil_printf("Send FFT ");
    if (send_threshold == 1) xil_printf("Send Threshold ");
    if (send_mag_squared == 1) xil_printf("Send Mag Squared ");
    if (send_cnt_pattern == 1) xil_printf("Send Counting Pattern");
    xil_printf("\r\n");
    xil_printf("\r\n");
    xil_printf("\r\n");
    xil_printf("Menu:\r\n");
    if (override == 0) xil_printf("[1] Set Override\r\n");
    else               xil_printf("[1] Clear Override\r\n");
    xil_printf("[2] Start Spectrum Sensing (Override)\r\n");
    xil_printf("[3] Increment RX Data PLL Phase Offset\r\n");
    xil_printf("[4] Decrement RX Data PLL Phase Offset\r\n");
    xil_printf("[5] Set USRP Mode\r\n");
    xil_printf("[6] Set Network Configuration\r\n");
    xil_printf("[7] Set Spectrum Sensing Options (Override)\r\n");
    xil_printf("[8] Write All Registers\r\n");
    xil_printf("[9] Read All Registers\r\n");
    xil_printf("\r\n");
    xil_printf("Selection: ");
    GetUartBytes(1,&menu_selection);
    xil_printf("\r\n");
    switch(menu_selection)
    {
      // Set / Clear override
      case '1':
        if (override == 0) 
        {
          ctrl_flags += OVERRIDE_BIT;
          override = 1;
        }
        else
        {
          ctrl_flags -= OVERRIDE_BIT;
          override = 0;
        }
        WriteReg(RW_CTRL_FLAGS,ctrl_flags);
        break;

      // Start spectrum sensing
      case '2':
        // Force rising edge
        ctrl_flags += START_SPECTRUM_SENSE;
        WriteReg(RW_CTRL_FLAGS,ctrl_flags);
        ctrl_flags -= START_SPECTRUM_SENSE;
        WriteReg(RW_CTRL_FLAGS,ctrl_flags);
        break;

      case '3':
        // Force rising edge
        gpio_1_out += OFFSET_PHASE_INC;
        XIo_Out32(XPAR_AXI_GPIO_0_BASEADDR,gpio_1_out);
        gpio_1_out -= OFFSET_PHASE_INC;
        XIo_Out32(XPAR_AXI_GPIO_0_BASEADDR,gpio_1_out);
        break;

      case '4':
        // Force rising edge
        gpio_1_out += OFFSET_PHASE_DEC;
        XIo_Out32(XPAR_AXI_GPIO_0_BASEADDR,gpio_1_out);
        gpio_1_out -= OFFSET_PHASE_DEC;
        XIo_Out32(XPAR_AXI_GPIO_0_BASEADDR,gpio_1_out);
        break;

      case '5':
        xil_printf("Set mode:\r\n");
        xil_printf("[0] ADC Data\r\n");
        xil_printf("[1] ADC Data (DC offset compensation)\r\n");
        xil_printf("[2] Sine Wave Test Pattern\r\n");
        xil_printf("[3] Repeating Test Pattern\r\n");
        xil_printf("[4] All 1s Output\r\n");
        xil_printf("[5] All 0s Output\r\n");
        xil_printf("[6] All 1s on Channel A, All 0s on Channel B\r\n");
        xil_printf("[7] All 0s on Channel A, All 1s on Channel B\r\n");
        xil_printf("\r\n");
        xil_printf("Selection: ");
        GetUartBytes(1,&menu_selection);
        xil_printf("\r\n");
        // Is selection 0 - 7?
        if (menu_selection > 47 && menu_selection < 56)
        {
          XUartLite_SendByte(USRP_UART_BASEADDR,menu_selection - 48);
        }
        else
        {
          xil_printf("\'%c\' is an invalid selection.\r\n",menu_selection);  
        }
        break;

      case '6':
        xil_printf("[1] Set Source MAC Address\r\n");
        xil_printf("[2] Set Destination MAC Address\r\n");
        xil_printf("[3] Set Source IP Address\r\n");
        xil_printf("[4] Set Destination IP Address\r\n");
        xil_printf("[5] Set Source Port\r\n");
        xil_printf("[6] Set Destination Port\r\n");
        xil_printf("[7] Set UDP Payload Size\r\n");
        xil_printf("\r\n");
        xil_printf("Selection: ");
        GetUartBytes(1,&menu_selection);
        xil_printf("\r\n");
        switch(menu_selection)
        {
          // Set Source MAC Address
          case '1':
            xil_printf("Source MAC Address (Hex, 12 digits, ex. 001122334455): ");
            GetUartBytes(4,&string[0]);
            mac_addr_src_byte_5_4 = HexToDec(4,&string[0]);
            GetUartBytes(4,&string[0]);
            mac_addr_src_byte_3_2 = HexToDec(4,&string[0]);
            GetUartBytes(4,&string[0]);
            mac_addr_src_byte_1_0 = HexToDec(4,&string[0]);
            WriteReg(RW_MAC_ADDR_SRC_BYTES_5_4,mac_addr_src_byte_5_4);
            WriteReg(RW_MAC_ADDR_SRC_BYTES_3_2,mac_addr_src_byte_3_2);
            WriteReg(RW_MAC_ADDR_SRC_BYTES_1_0,mac_addr_src_byte_1_0);
            break;

          // Set Destination MAC Address
          case '2':
            xil_printf("Destination MAC Address (Hex, 12 digits, ex. 001122334455): ");
            GetUartBytes(4,&string[0]);
            mac_addr_dest_byte_5_4 = HexToDec(4,&string[0]);
            GetUartBytes(4,&string[0]);
            mac_addr_dest_byte_3_2 = HexToDec(4,&string[0]);
            GetUartBytes(4,&string[0]);
            mac_addr_dest_byte_1_0 = HexToDec(4,&string[0]);
            WriteReg(RW_MAC_ADDR_DEST_BYTES_5_4,mac_addr_dest_byte_5_4);
            WriteReg(RW_MAC_ADDR_DEST_BYTES_3_2,mac_addr_dest_byte_3_2);
            WriteReg(RW_MAC_ADDR_DEST_BYTES_1_0,mac_addr_dest_byte_1_0);
            break;

          // Set Source IP Address
          case '3':
            xil_printf("Source IP Address (Hex, 8 digits, ex. C0A80A0A): ");
            GetUartBytes(4,&string[0]);
            ip_addr_src_byte_3_2 = HexToDec(4,&string[0]);
            GetUartBytes(4,&string[0]);
            ip_addr_src_byte_1_0 = HexToDec(4,&string[0]);
            WriteReg(RW_IP_ADDR_SRC_BYTES_3_2,ip_addr_src_byte_3_2);
            WriteReg(RW_IP_ADDR_SRC_BYTES_1_0,ip_addr_src_byte_1_0);
            break;

          // Set Destination IP Address
          case '4':
            xil_printf("Destination IP Address (Hex, 8 digits, ex. C0A80AFF): ");
            GetUartBytes(4,&string[0]);
            ip_addr_dest_byte_3_2 = HexToDec(4,&string[0]);
            GetUartBytes(4,&string[0]);
            ip_addr_dest_byte_1_0 = HexToDec(4,&string[0]);
            WriteReg(RW_IP_ADDR_DEST_BYTES_3_2,ip_addr_dest_byte_3_2);
            WriteReg(RW_IP_ADDR_DEST_BYTES_1_0,ip_addr_dest_byte_1_0);
            break;

          // Set Source Port
          case '5':
            xil_printf("Source Port (Hex, 4 digits, ex. 2382): ");
            GetUartBytes(4,&string[0]);
            port_src = HexToDec(4,&string[0]);
            WriteReg(RW_PORT_SRC,port_src);
            break;

          // Set Destination Port
          case '6':
            xil_printf("Destination Port (Hex, 4 digits, ex. 2383): ");
            GetUartBytes(4,&string[0]);
            port_dest = HexToDec(4,&string[0]);
            WriteReg(RW_PORT_DEST,port_dest);
            break;

          // Set Payload size
          case '7':
            xil_printf("Payload Size (Hex, 3 digits, Max 5C0 (1472): ");
            GetUartBytes(3,&string[0]);
            payload_size = HexToDec(3,&string[0]);
            WriteReg(RW_PAYLOAD_SIZE,payload_size);
            break;

          default:
            xil_printf("\'%c\' is an invalid selection.\r\n",menu_selection);
            break;
        }
        break;

      case '7':      
        if (send_fft == 0) xil_printf("[1] Set Send FFT Data\r\n");
        else               xil_printf("[1] Clear Send FFT Data\r\n");
        if (send_threshold == 0) xil_printf("[2] Set Send Threshold Data\r\n");
        else                     xil_printf("[2] Clear Send Threshold Data\r\n");
        if (send_mag_squared == 0) xil_printf("[3] Set Send Magnitude Squared Data\r\n");
        else                       xil_printf("[3] Clear Send Magnitude Squared Data\r\n");
        if (send_cnt_pattern == 0) xil_printf("[4] Set Send Counting Pattern\r\n");
        else                       xil_printf("[4] Clear Send Counting Pattern\r\n");
        xil_printf("[5] Set FFT Size\r\n");
        xil_printf("[6] Set Threshold\r\n");
        xil_printf("\r\n");
        xil_printf("Selection: ");
        GetUartBytes(1,&menu_selection);
        xil_printf("\r\n");
        switch(menu_selection)
        {
          // Set Send FFT Data
          case '1':
            if (send_fft == 0) 
            {
              ctrl_flags += SEND_FFT_BIT;
              send_fft = 1;
            }
            else
            {
              ctrl_flags -= SEND_FFT_BIT;
              send_fft = 0;
            }
            WriteReg(RW_CTRL_FLAGS,ctrl_flags);
            break;

          // Set Send Threshold Data
          case '2': 
            if (send_threshold == 0) 
            {
              ctrl_flags += SEND_THRESHOLD_BIT;
              send_threshold = 1;
            }
            else
            {
              ctrl_flags -= SEND_THRESHOLD_BIT;
              send_threshold = 0;
            }
            WriteReg(RW_CTRL_FLAGS,ctrl_flags);
            break;

          // Set Send Magnitude Squared Data
          case '3':
            if (send_mag_squared == 0) 
            {
              ctrl_flags += SEND_MAG_SQUARED_BIT;
              send_mag_squared = 1;
            }
            else
            {
              ctrl_flags -= SEND_MAG_SQUARED_BIT;
              send_mag_squared = 0;
            }
            WriteReg(RW_CTRL_FLAGS,ctrl_flags);
            break;

          // Set Send Counting Pattern
          case '4':
            if (send_cnt_pattern == 0) 
            {
              ctrl_flags += SEND_CNT_PATTERN_BIT;
              send_cnt_pattern = 1;
            }
            else
            {
              ctrl_flags -= SEND_CNT_PATTERN_BIT;
              send_cnt_pattern = 0;
            }
            WriteReg(RW_CTRL_FLAGS,ctrl_flags);
            break;

          // Set FFT Size
          case '5':
            xil_printf("FFT Size (Hex, 1 digit, ex. 8192 = D, 4096 = C, ..., 64 = 6): ");
            GetUartBytes(1,&string[0]);
            fft_size = HexToDec(1,&string[0]);
            WriteReg(RW_FFT_SIZE,fft_size);
            break;

          // Set Threshold
          case '6':
            xil_printf("Threshold Size (Hex, 8 digits, ex. 12345678): ");
            GetUartBytes(4,&string[0]);
            threshold_byte_3_2 = HexToDec(4,&string[0]);
            GetUartBytes(4,&string[0]);
            threshold_byte_1_0 = HexToDec(4,&string[0]);
            WriteReg(RW_THRESHOLD_BYTES_3_2,threshold_byte_3_2);
            WriteReg(RW_THRESHOLD_BYTES_1_0,threshold_byte_1_0);
            break;

          default:
            xil_printf("\'%c\' is an invalid selection.\r\n",menu_selection);
            break;          
        }
        break;

      // Refresh all registers. This is useful if the USRP is disconnected
      // which resets values to their defaults.
      case '8':
        WriteReg(RW_MAC_ADDR_DEST_BYTES_5_4, mac_addr_dest_byte_5_4);
        WriteReg(RW_MAC_ADDR_DEST_BYTES_3_2, mac_addr_dest_byte_3_2);
        WriteReg(RW_MAC_ADDR_DEST_BYTES_1_0, mac_addr_dest_byte_1_0);
        WriteReg(RW_MAC_ADDR_SRC_BYTES_5_4, mac_addr_src_byte_5_4);
        WriteReg(RW_MAC_ADDR_SRC_BYTES_3_2, mac_addr_src_byte_3_2);
        WriteReg(RW_MAC_ADDR_SRC_BYTES_1_0, mac_addr_src_byte_1_0);
        WriteReg(RW_IP_ADDR_DEST_BYTES_3_2, ip_addr_dest_byte_3_2);
        WriteReg(RW_IP_ADDR_DEST_BYTES_1_0, ip_addr_dest_byte_1_0);
        WriteReg(RW_IP_ADDR_SRC_BYTES_3_2, ip_addr_src_byte_3_2);
        WriteReg(RW_IP_ADDR_SRC_BYTES_1_0, ip_addr_src_byte_1_0);
        WriteReg(RW_PORT_DEST, port_dest);
        WriteReg(RW_PORT_SRC, port_src);
        WriteReg(RW_PAYLOAD_SIZE, payload_size);
        WriteReg(RW_FFT_SIZE, fft_size);
        WriteReg(RW_THRESHOLD_BYTES_3_2, threshold_byte_3_2);
        WriteReg(RW_THRESHOLD_BYTES_1_0, threshold_byte_1_0);
        WriteReg(RW_CTRL_FLAGS, ctrl_flags);
        break;

      // Read all registers, as the HDL code sets the defaults
      case '9':
        mac_addr_dest_byte_5_4 = ReadReg(RW_MAC_ADDR_DEST_BYTES_5_4);
        mac_addr_dest_byte_3_2 = ReadReg(RW_MAC_ADDR_DEST_BYTES_3_2);
        mac_addr_dest_byte_1_0 = ReadReg(RW_MAC_ADDR_DEST_BYTES_1_0);
        mac_addr_src_byte_5_4 = ReadReg(RW_MAC_ADDR_SRC_BYTES_5_4);
        mac_addr_src_byte_3_2 = ReadReg(RW_MAC_ADDR_SRC_BYTES_3_2);
        mac_addr_src_byte_1_0 = ReadReg(RW_MAC_ADDR_SRC_BYTES_1_0);
        ip_addr_dest_byte_3_2 = ReadReg(RW_IP_ADDR_DEST_BYTES_3_2);
        ip_addr_dest_byte_1_0 = ReadReg(RW_IP_ADDR_DEST_BYTES_1_0);
        ip_addr_src_byte_3_2 = ReadReg(RW_IP_ADDR_SRC_BYTES_3_2);
        ip_addr_src_byte_1_0 = ReadReg(RW_IP_ADDR_SRC_BYTES_1_0);
        port_dest = ReadReg(RW_PORT_DEST);
        port_src = ReadReg(RW_PORT_SRC);
        payload_size = ReadReg(RW_PAYLOAD_SIZE);
        fft_size = ReadReg(RW_FFT_SIZE);
        threshold_byte_3_2 = ReadReg(RW_THRESHOLD_BYTES_3_2);
        threshold_byte_1_0 = ReadReg(RW_THRESHOLD_BYTES_1_0);
        ctrl_flags = ReadReg(RW_CTRL_FLAGS);
        if ((ctrl_flags & OVERRIDE_BIT) > 0) override = 1;
        else override = 0;
        if ((ctrl_flags & SEND_FFT_BIT) > 0) send_fft = 1;
        else send_fft = 0;
        if ((ctrl_flags & SEND_MAG_SQUARED_BIT) > 0) send_mag_squared = 1;
        else send_mag_squared = 0;
        if ((ctrl_flags & SEND_THRESHOLD_BIT) > 0) send_threshold = 1;
        else send_threshold = 0;
        if ((ctrl_flags & SEND_CNT_PATTERN_BIT) > 0) send_cnt_pattern = 1;
        else send_cnt_pattern = 0;
        break;

      default:
        xil_printf("\'%c\' is an invalid selection.\r\n",menu_selection);
        break;
    }
    xil_printf("\r\n");
    xil_printf("\r\n");
  }
}

/******************************************************************************
** Function: GetUartBytes
**
** Inputs: int   num_chars    Number of characters to receive
**         char* string       Buffer for received characters
**
** Returns: void
**
** Description: Receive bytes from UART. Checks if the receiver buffer has
**              has data and handles backspace.
**
******************************************************************************/
void GetUartBytes(int num_chars, char* string)
{
  int   i = 0;
  char  rx_byte = 0;

  for (i = 0; i < num_chars; i++)
  {
    // Wait for byte
    while(XUartLite_IsReceiveEmpty(STDOUT_BASEADDRESS) == FALSE);
    // Receive byte
    rx_byte = XUartLite_RecvByte(STDOUT_BASEADDRESS);
    // Print byte for user feedback
    xil_printf("%c",rx_byte);
    // Received delete character
    if ((rx_byte == 0x8 || rx_byte == 0xFF) && (i > 0))
    {
      --i;
    }
    else
    {
      string[i] = rx_byte;
    }
  }
}

/******************************************************************************
** Function: HexToDec
**
** Inputs: int   num_chars    Number of hex characters to convert to decimal
**         char* string       Buffer for received characters
**
** Returns: int
**
** Description: Convert input hexadecimal string to a integer. Note that
**              the output is a 32 bit integer, so only 8 characters can
**              be parsed at a time.
**
******************************************************************************/
int HexToDec(int num_chars, char* string)
{
  int value = 0;
  int i = 0;
  int j = (4 * (num_chars-1));

  for (i = 0; i < num_chars; i++)
  {
    if (string[i] >= 48 && string[i] <= 57)
    {
      value += (string[i] - 48) << j;
    }
    else if (string[i] >= 97 && string[i] <= 102)
    {
      value += (string[i] - 97 + 10) << j;
    }
    else if (string[i] >= 65 && string[i] <= 70)
    {
      value += (string[i] - 65 + 10) << j;
    }
    j -= 4;
  }

  return(value);
}

/******************************************************************************
** Function: WriteReg
**
** Inputs:  u16 address   Register map address
**          u16 value     Value to write to register
**          
**
** Returns: void
**
** Description: Sets a register at the defined address.
**
******************************************************************************/
void WriteReg(u16 address, u16 value)
{
  // Set control bit to indicate a write. Use non-blocking because if the USRP
  // is not connected, the FSL bus will not be active and we could get stuck
  // waiting forever.
  putfslx((address << 16) + value,0,FSL_NONBLOCKING_CONTROL);
}

/******************************************************************************
** Function: ReadReg
**
** Inputs:  u16 address   Register map address
**          
**
** Returns: u16   Value of the register.
**
** Description: Reads a register at the defined address.
**
******************************************************************************/
u16 ReadReg(u16 address)
{
  int i = 0;
  u32 value = 0;

  // Clear control bit to indicate a read. Use non-blocking because if the USRP
  // is not connected, the FSL bus will not be active and we could get stuck
  // waiting forever.
  value = address << 16;
  putfslx(value,0,FSL_NONBLOCKING);
  // Read must transverse FSL FIFO, so give it plenty of time.
  for (i = 0; i < 50; i++) asm("nop");
  getfslx(value,0,FSL_NONBLOCKING);
  return((u16)value);
}