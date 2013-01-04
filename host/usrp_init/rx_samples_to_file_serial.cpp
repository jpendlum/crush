//
// Copyright 2010-2011 Ettus Research LLC
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#include <uhd/utils/thread_priority.hpp>
#include <uhd/utils/safe_main.hpp>
#include <uhd/usrp/multi_usrp.hpp>
#include <boost/program_options.hpp>
#include <boost/format.hpp>
#include <boost/thread.hpp>
#include <boost/asio.hpp>
#include <iostream>
#include <fstream>
#include <csignal>
#include <complex>
#include <algorithm>
#include "BufferedAsyncSerial.h"



namespace po = boost::program_options;


typedef union {
        unsigned char a[4];
        unsigned int b;
} convert;

static bool stop_signal_called = false;
int PRINT_DEBUG = 0;

void sig_int_handler(int){stop_signal_called = true;}

BufferedAsyncSerial serial("COM2",115200);

void init_ml605(unsigned int transform_length_log2)
{
	std::vector< char> cmd(6);
	unsigned char response[1024];
	int retVal;

	
	cmd[0]= (char)2; //set transform width
	cmd[1]=(char)0;
	cmd[2]=(char)0;
	cmd[3]=(char)0;
	cmd[4]=(char)transform_length_log2;
	cmd[5]=(char)13; //end
	serial.write(cmd);
	boost::this_thread::sleep(boost::posix_time::milliseconds(1));
	retVal = serial.read((char *)response,4);

	cmd[0]= 3; //set mode
	cmd[1]=0;
	cmd[2]=0;
	cmd[3]=0;
	cmd[4]=0;
	cmd[5]=13; //end
	serial.write(cmd);
	boost::this_thread::sleep(boost::posix_time::milliseconds(1));
	retVal = serial.read((char *)response,4);

	cmd[0]= 1; //set remote_freq
	cmd[1]=0;
	cmd[2]=11;
	cmd[3]=236;
	cmd[4]=0;
	cmd[5]=13; //end
	serial.write(cmd);
	boost::this_thread::sleep(boost::posix_time::milliseconds(1));
	retVal = serial.read((char *)response,4);

	//serial.close();
	
}

void test_ml605(unsigned int transform_length)
{
	std::vector< char> cmd(6);
	unsigned char response[1024];
	int retVal;
	unsigned int transform_length_scaled;

	transform_length_scaled=transform_length*3052;
	//BufferedAsyncSerial serial("COM2",115200);
	

	cmd[0]= 3; //set mode
	cmd[1]=0;
	cmd[2]=0;
	cmd[3]=0;
	cmd[4]=2;
	cmd[5]=13; //end
	serial.write(cmd);
	boost::this_thread::sleep(boost::posix_time::milliseconds(1));
	retVal = serial.read((char *)response,4);

	cmd[0]= 1; //set remote_freq
	cmd[1]=(transform_length_scaled>>24)&0xff;
	cmd[2]=(transform_length_scaled>>16)&0xff;
	cmd[3]=(transform_length_scaled>>8)&0xff;
	cmd[4]=(transform_length_scaled)&0xff;
	cmd[5]=13; //end
	if(PRINT_DEBUG) printf("running test with transform: %d\n",transform_length);
	serial.write(cmd);
	//boost::this_thread::sleep(boost::posix_time::milliseconds(1));
	//retVal = serial.read((char *)response,4);
	//serial.close();
}
void report_ml605(unsigned int transform_length,int num_reads,int num_packets)
{
	std::vector< char> cmd(6);
	unsigned char dump[1024];
	unsigned char response[32];
	int retVal;
	int timer[8];
	int temp;
	unsigned long test;
	FILE *fid;
	

	//BufferedAsyncSerial serial("COM2",115200);
	
	//stop the timer
	cmd[0]= 9; //set mode
	cmd[1]=0;
	cmd[2]=0;
	cmd[3]=0;
	cmd[4]=1;
	cmd[5]=13; //end
	serial.write(cmd);
	boost::this_thread::sleep(boost::posix_time::milliseconds(1));
	retVal = serial.read((char *)response,4);

	boost::this_thread::sleep(boost::posix_time::milliseconds(20));
	
	//start the test timer to see how long a serial message takes
	cmd[0]= 9; //set mode
	cmd[1]=0;
	cmd[2]=0;
	cmd[3]=0;
	cmd[4]=2;
	cmd[5]=13; //end
	serial.write(cmd);
	//boost::this_thread::sleep(boost::posix_time::milliseconds(1));
	//retVal = serial.read((char *)response,4);

	//stop the test timer to see how long a serial message takes
	cmd[0]= 9; //set mode
	cmd[1]=0;
	cmd[2]=0;
	cmd[3]=0;
	cmd[4]=3;
	cmd[5]=13; //end
	serial.write(cmd);
	//boost::this_thread::sleep(boost::posix_time::milliseconds(1));
	//retVal = serial.read((char *)response,4);
	boost::this_thread::sleep(boost::posix_time::milliseconds(10));
	//clear the read buffer
	retVal = serial.read((char *) dump, 1024);
	//printf("we found %d characters in the dump\n",retVal);

	//read back all the timers
	cmd[0]= 9; //set mode
	cmd[1]=0;
	cmd[2]=0;
	cmd[3]=0;
	cmd[4]=0;
	cmd[5]=13; //end
	serial.write(cmd);
	boost::this_thread::sleep(boost::posix_time::milliseconds(10));
	retVal = serial.read((char *)response,32);
	//printf("we found %d characters in the buffer\n",retVal);
	if(retVal >= 4*8)
	{
		for(int i=0;i<8;i++)
		{
			convert temp2={response[(i)*4+3],response[(i)*4+2],response[(i)*4+1],response[(i)*4+0]};
			timer[i]=temp2.b;
			if(PRINT_DEBUG)  printf("Timer %d: %d\n",i,timer[i],timer[i]);
		}
	}
	else
	{
		printf("Timer read failed\n");
	}
	if(PRINT_DEBUG)
	{
	printf("FPGA time:\t%01.10f s\n",(float)timer[4]/100e6);
	printf("Host time:\t%01.10f s\n",(float)((float)timer[6]-(float)timer[7]/2)/100e6);
	printf("Percent  :\t%f \n",(float)((float)timer[6]-(float)timer[7]/2)/(float)timer[4]);
	printf("numReads :\t%d\tnumPackers:\t%d\n",num_reads,num_packets);
	}
	fid=fopen("fftTest.dat","a");
	if(fid !=NULL)
	{
		fprintf(fid,"%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n",
			transform_length,
			timer[0],
			timer[1],
			timer[2],
			timer[3],
			timer[4],
			timer[5],
			timer[6],
			timer[7],
			num_reads,
			num_packets);

		fclose(fid);
	}
	

	//reset the device
	cmd[0]= 3; //set mode
	cmd[1]=0;
	cmd[2]=0;
	cmd[3]=0;
	cmd[4]=0;
	cmd[5]=13; //end
	serial.write(cmd);
	boost::this_thread::sleep(boost::posix_time::milliseconds(1));
	retVal = serial.read((char *)response,4);

	cmd[0]= 1; //set remote_freq
	cmd[1]=0;
	cmd[2]=11;
	cmd[3]=236;
	cmd[4]=0;
	cmd[5]=13; //end
	serial.write(cmd);
	boost::this_thread::sleep(boost::posix_time::milliseconds(1));
	retVal = serial.read((char *)response,4);
	//serial.close();

}



template<typename samp_type> void recv_to_file(
    uhd::usrp::multi_usrp::sptr usrp,
    const uhd::io_type_t &io_type,
    const std::string &file,
    size_t samps_per_buff,
	unsigned int transform_length
){
	int location = 0;
	int found = 0;
	int found_next = 0;
	int fftCount =0;
	int num_reads = 0;
	int num_packets = 0;
	std::complex<short> value,output;
    uhd::rx_metadata_t md;
    std::vector<samp_type> buff(samps_per_buff);
    //std::ofstream outfile(file.c_str(), std::ofstream::binary);
	
	
	value.real(0xDEAD);
	value.imag(0xBEEF);
	test_ml605(transform_length);
	location=0;
	found=0;
    while((not stop_signal_called)&& (found==0)){
		
		num_packets = num_packets+1;
        size_t num_rx_samps = usrp->get_device()->recv(
            &buff.front(), buff.size(), md, io_type,
            uhd::device::RECV_MODE_FULL_BUFF
        );

        if (md.error_code == uhd::rx_metadata_t::ERROR_CODE_TIMEOUT) break;
        if (md.error_code != uhd::rx_metadata_t::ERROR_CODE_NONE){
            throw std::runtime_error(str(boost::format(
                "Unexpected error code 0x%x"
            ) % md.error_code));
        }

		if(found_next == 1)
		{
			fftCount = fftCount + num_rx_samps;
			if(fftCount < transform_length) //need the next set of samples to have enough data to perform FFT
			{
				found_next = 1;
				num_reads = num_reads+1;
			}
			else
			{
				found = 1;
			}
		}
		else
		{
			for(int i = 0;i < num_rx_samps;i++)
			{
				if((std::complex<short>) buff[i] == value)
				{
					fftCount = num_rx_samps-location;
					location=i;
					if(fftCount < transform_length) //need the next set of samples to have enough data to perform FFT
					{
						num_reads = 1;
						found_next = 1;
					}
					else
					{
						found=1;
					}
					break;
				}
			}
		}
		if(found == 1)
		{
			report_ml605(transform_length,num_reads,num_packets);
			
			//read the next packet in case it has extra data
			num_rx_samps = usrp->get_device()->recv(
				&buff.front(), buff.size(), md, io_type,
				uhd::device::RECV_MODE_FULL_BUFF
			);

			if (md.error_code == uhd::rx_metadata_t::ERROR_CODE_TIMEOUT) break;
			if (md.error_code != uhd::rx_metadata_t::ERROR_CODE_NONE){
				throw std::runtime_error(str(boost::format(
					"Unexpected error code 0x%x"
				) % md.error_code));
			}
			//read the next packet in case it has extra data
			num_rx_samps = usrp->get_device()->recv(
				&buff.front(), buff.size(), md, io_type,
				uhd::device::RECV_MODE_FULL_BUFF
			);

			if (md.error_code == uhd::rx_metadata_t::ERROR_CODE_TIMEOUT) break;
			if (md.error_code != uhd::rx_metadata_t::ERROR_CODE_NONE){
				throw std::runtime_error(str(boost::format(
					"Unexpected error code 0x%x"
				) % md.error_code));
			}
			if(PRINT_DEBUG)
			{
			std::cout << boost::format("Found the DEADBEEF! @") <<location<< std::endl;
			output = (std::complex<short>)buff[location];
			printf("deadbeef value is r: %x i: %x\n",output.real(),output.imag());
			}
		}
        //outfile.write((const char*)&buff.front(), num_rx_samps*sizeof(samp_type));
    }

    //outfile.close();
}


int UHD_SAFE_MAIN(int argc, char *argv[]){
    uhd::set_thread_priority_safe();

    //variables to be set by po
    std::string args, file, type, ant, subdev;
    size_t total_num_samps, spb;
    double rate, freq, gain, bw;
	unsigned int transform_length;

    //setup the program options
    po::options_description desc("Allowed options");
    desc.add_options()
        ("help", "help message")
        ("args", po::value<std::string>(&args)->default_value(""), "multi uhd device address args")
        ("file", po::value<std::string>(&file)->default_value("usrp_samples.dat"), "name of the file to write binary samples to")
        ("type", po::value<std::string>(&type)->default_value("short"), "sample type: double, float, or short")
        ("nsamps", po::value<size_t>(&total_num_samps)->default_value(0), "total number of samples to receive")
        ("spb", po::value<size_t>(&spb)->default_value(10000), "samples per buffer")
        ("rate", po::value<double>(&rate)->default_value(25e6), "rate of incoming samples")
        ("freq", po::value<double>(&freq)->default_value(900e6), "RF center frequency in Hz")
        ("gain", po::value<double>(&gain)->default_value(0), "gain for the RF chain")
        ("ant", po::value<std::string>(&ant), "daughterboard antenna selection")
        ("subdev", po::value<std::string>(&subdev), "daughterboard subdevice specification")
        ("bw", po::value<double>(&bw), "daughterboard IF filter bandwidth in Hz")
    ;
    po::variables_map vm;
    po::store(po::parse_command_line(argc, argv, desc), vm);
    po::notify(vm);

    //print the help message
    if (vm.count("help")){
        std::cout << boost::format("UHD RX samples to file %s") % desc << std::endl;
        return ~0;
    }
	//George's modified copy that just sets the frequency
	std::cout << boost::format("George's modified version to time FFT") << std::endl;

    //create a usrp device
    std::cout << std::endl;
    std::cout << boost::format("Creating the usrp device with: %s...") % args << std::endl;
    uhd::usrp::multi_usrp::sptr usrp = uhd::usrp::multi_usrp::make(args);

    //always select the subdevice first, the channel mapping affects the other settings
    if (vm.count("subdev")) usrp->set_rx_subdev_spec(subdev);

    std::cout << boost::format("Using Device: %s") % usrp->get_pp_string() << std::endl;

    //set the sample rate
    if (not vm.count("rate")){
        std::cerr << "Please specify the sample rate with --rate" << std::endl;
        return ~0;
    }
    std::cout << boost::format("Setting RX Rate: %f Msps...") % (rate/1e6) << std::endl;
    usrp->set_rx_rate(rate);
    std::cout << boost::format("Actual RX Rate: %f Msps...") % (usrp->get_rx_rate()/1e6) << std::endl << std::endl;

    //set the center frequency
    if (not vm.count("freq")){
        std::cerr << "Please specify the center frequency with --freq" << std::endl;
        return ~0;
    }
    std::cout << boost::format("Setting RX Freq: %f MHz...") % (freq/1e6) << std::endl;
    usrp->set_rx_freq(freq);
    std::cout << boost::format("Actual RX Freq: %f MHz...") % (usrp->get_rx_freq()/1e6) << std::endl << std::endl;

    //set the rf gain
    if (vm.count("gain")){
        std::cout << boost::format("Setting RX Gain: %f dB...") % gain << std::endl;
        usrp->set_rx_gain(gain);
        std::cout << boost::format("Actual RX Gain: %f dB...") % usrp->get_rx_gain() << std::endl << std::endl;
    }

    //set the IF filter bandwidth
    if (vm.count("bw")){
        std::cout << boost::format("Setting RX Bandwidth: %f MHz...") % bw << std::endl;
        usrp->set_rx_bandwidth(bw);
        std::cout << boost::format("Actual RX Bandwidth: %f MHz...") % usrp->get_rx_bandwidth() << std::endl << std::endl;
    }

    //set the antenna
    if (vm.count("ant")) usrp->set_rx_antenna(ant);

    boost::this_thread::sleep(boost::posix_time::seconds(1)); //allow for some setup time

    //setup streaming
    uhd::stream_cmd_t stream_cmd((total_num_samps == 0)?
        uhd::stream_cmd_t::STREAM_MODE_START_CONTINUOUS:
        uhd::stream_cmd_t::STREAM_MODE_NUM_SAMPS_AND_DONE
    );
    stream_cmd.num_samps = total_num_samps;
    stream_cmd.stream_now = true;
    //usrp->issue_stream_cmd(stream_cmd);
    if (total_num_samps == 0){
        std::signal(SIGINT, &sig_int_handler);
        std::cout << "Press Ctrl + C to stop streaming..." << std::endl;
    }
	 //recv to file
    //if (type == "double") recv_to_file<std::complex<double> >(usrp, uhd::io_type_t::COMPLEX_FLOAT64, file, spb,transform_length);
    //else if (type == "float") recv_to_file<std::complex<float> >(usrp, uhd::io_type_t::COMPLEX_FLOAT32, file, spb,transform_length);
    //else if (type == "short") recv_to_file<std::complex<short> >(usrp, uhd::io_type_t::COMPLEX_INT16, file, spb,transform_length);
    //else throw std::runtime_error("Unknown type " + type);

	
	for(int i=3;i<16;i++) //go from 2^3 to 2^15
	{
		init_ml605(i);
		transform_length =  (unsigned int)pow((double)2,(double)i);
		printf("starting transform length: %d\n",transform_length);
		for(int j=0;j<10;j++)
		{	
			stream_cmd.stream_now = true;
			stream_cmd.stream_mode = uhd::stream_cmd_t::STREAM_MODE_START_CONTINUOUS;
			usrp->set_rx_freq(100e6);
			usrp->issue_stream_cmd(stream_cmd);
			recv_to_file<std::complex<short> >(usrp, uhd::io_type_t::COMPLEX_INT16, file, spb,transform_length);
			stream_cmd.stream_now = false;
			stream_cmd.stream_mode = uhd::stream_cmd_t::STREAM_MODE_STOP_CONTINUOUS;
			usrp->issue_stream_cmd(stream_cmd);
		}
	}



	//while(not stop_signal_called){boost::this_thread::sleep(boost::posix_time::milliseconds(10));}
    //finished
    std::cout << std::endl << "Done!" << std::endl << std::endl;

    return 0;
}

