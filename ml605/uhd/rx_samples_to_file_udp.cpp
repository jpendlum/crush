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
#include <boost/thread/mutex.hpp>
#include <iostream>
#include <fstream>
#include <csignal>
#include <complex>
#include <intrin.h>
#include <boost/asio.hpp>
#include <boost/bind.hpp>

#pragma intrinsic(__rdtsc)

namespace po = boost::program_options;

using boost::asio::ip::udp;

boost::timed_mutex m_mutex;
//bool packetValid;

class server
{
public:
  server(boost::asio::io_service& io_service,const std::string& local_address, short port)
    : io_service_(io_service),
      socket_(io_service, udp::endpoint(boost::asio::ip::address::from_string(local_address), port)),
      messages_sent_(0u),
      should_run_(true)
  {
    boost::thread   t(boost::bind(&server::thread_func, this));
    t_.swap(t);
	// Allow broadcasting
	socket_.set_option(boost::asio::socket_base::broadcast(true));
	//socket_.bind(udp::endpoint(boost::asio::ip::address_v4::any(),port));

    socket_.async_receive_from(
 //       boost::asio::buffer(data_, max_length), sender_endpoint_,
        boost::asio::buffer(data_, max_length), udp::endpoint(boost::asio::ip::address::from_string("192.168.10.100"),9091),
        boost::bind(&server::handle_receive_from, this,
          boost::asio::placeholders::error,
          boost::asio::placeholders::bytes_transferred));
  }

  ~server() {
      should_run_ = false;
      t_.join();
  }

  void handle_receive_from(const boost::system::error_code& error,
      size_t bytes_recvd)
  {
    if (error) {
        std::cout << "receive error!" << std::endl;
        return;
    }
	m_mutex.unlock();
	//printf("****** Received %d bytes\n\r",bytes_recvd);

      //std::string  message(data_, bytes_recvd);

      // start receiving again
      socket_.async_receive_from(
          boost::asio::buffer(data_, max_length), sender_endpoint_,
          boost::bind(&server::handle_receive_from, this,
            boost::asio::placeholders::error,
            boost::asio::placeholders::bytes_transferred));
		/*
      // store the received message in a vector
      boost::lock_guard<boost::recursive_mutex>    lock(mutex_);
      messages_.push_back(message);
	  */
      messages_received_++;
	  
  }

  bool send(udp::endpoint other_end, const std::string &message) {
      bool packetValid;
	  unsigned int sent = socket_.send_to(
                        boost::asio::buffer(message.c_str(), message.size()),
                        other_end);

      if (sent < message.size()) {
          std::cout << "only " << sent << " bytes sent from " << message.size()
                    << std::endl;
      }
	  boost::system_time timeout = boost::get_system_time() + boost::posix_time::milliseconds(50);
      ++messages_sent_;
	  //use a timed mutex
	  packetValid = m_mutex.timed_lock(timeout);
	  //if(packetValid) puts("***** packet made it!!");
	  //if(!packetValid) puts("***** packet DIED");
	  return packetValid;
  }

  void thread_func() {
      while (should_run_) {
          boost::this_thread::yield();
          boost::this_thread::sleep(boost::posix_time::milliseconds(100u));

          // work on the messages received
          boost::lock_guard<boost::recursive_mutex>    lock(mutex_);
          BOOST_FOREACH(const std::string & str, messages_) {
            boost::this_thread::sleep(boost::posix_time::milliseconds(1u));
          }
          messages_.clear();
      }
  }


  std::vector<std::string>  messages_;
  unsigned int messages_sent_;
  unsigned int messages_received_;

private:
  boost::asio::io_service& io_service_;
  udp::socket socket_;
  udp::endpoint sender_endpoint_;
  enum { max_length = 1024 };
  char data_[max_length];
  boost::recursive_mutex  mutex_;
  bool should_run_;
  boost::thread t_;
};

static boost::asio::io_service io_service;
static bool                    should_run;


void service_thread(void) {
    while (should_run) {
        io_service.run();

        io_service.reset();
    }
}

static bool stop_signal_called = false;
void sig_int_handler(int){stop_signal_called = true;}

template<typename samp_type> void recv_to_file(
    uhd::usrp::multi_usrp::sptr usrp,
    const uhd::io_type_t &io_type,
    const std::string &file,
    size_t samps_per_buff
){
    uhd::rx_metadata_t md;
    std::vector<samp_type> buff(samps_per_buff);
    std::ofstream outfile(file.c_str(), std::ofstream::binary);

    while(not stop_signal_called){
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

        outfile.write((const char*)&buff.front(), num_rx_samps*sizeof(samp_type));
    }

    outfile.close();
}

int UHD_SAFE_MAIN(int argc, char *argv[]){
    uhd::set_thread_priority_safe();

    //variables to be set by po
    std::string args, file, type, ant, subdev;
    size_t total_num_samps, spb;
    double rate, freq, gain, bw;

    //setup the program options
    po::options_description desc("Allowed options");
    desc.add_options()
        ("help", "help message")
        ("args", po::value<std::string>(&args)->default_value(""), "multi uhd device address args")
        ("file", po::value<std::string>(&file)->default_value("usrp_samples.dat"), "name of the file to write binary samples to")
        ("type", po::value<std::string>(&type)->default_value("float"), "sample type: double, float, or short")
        ("nsamps", po::value<size_t>(&total_num_samps)->default_value(0), "total number of samples to receive")
        ("spb", po::value<size_t>(&spb)->default_value(10000), "samples per buffer")
        ("rate", po::value<double>(&rate), "rate of incoming samples")
        ("freq", po::value<double>(&freq), "RF center frequency in Hz")
        ("gain", po::value<double>(&gain), "gain for the RF chain")
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

	//timing stuff
	unsigned __int64 start;
	unsigned __int64 stop;
	unsigned __int64 procFreq=2.8E9;
	//variables
	//unsigned int i;
	//unsigned int j;
	bool packetValid;
	FILE *fid;

	/*
	start = __rdtsc();
	boost::this_thread::sleep(boost::posix_time::milliseconds(1000)); 
	
	procFreq=(stop-start);
		
	
	start = __rdtsc();
	boost::this_thread::sleep(boost::posix_time::milliseconds(10)); 
	stop = __rdtsc();

	puts("*** George's Hijacked Version! ***");
	printf("freq: %lld\n",procFreq);
	printf("test took: %f\n",(double(stop-start)/double(procFreq))*1e6);
	printf("raw1 value: %lld\n",start);
	printf("raw2 value: %lld\n",stop);
	*/
	
	try
	{
		printf("George's UDP test V0.07 \n\r");
		server a(io_service,"192.168.10.1", 9090);
		//server b(io_service,"255.255.255.255", 9090);
		should_run = true;

		boost::thread   t(service_thread);

		// generate an endpoint for 'a'
		udp::resolver           resolver(io_service);
		udp::resolver::query    query(udp::v4(), "255.255.255.255", "9091");
		udp::endpoint           endp_a = *resolver.resolve(query);
		//TODO: Not receiving, I think I'm not bound to the correct port.
		
	//should_run = false;

		for(unsigned int j = 3;j <= 13; j++)
		{
			for (unsigned int i = 0; i < 500; i++)
			{
				std::stringstream   sstr;
				//for (unsigned int j = 0; j < 1000; ++j) {
				//	sstr << i;
				//}
				sstr.put(0xde);
				sstr.put(0xad);
				sstr.put(0xbe);
				sstr.put(0xef);
				sstr.put(0x1);
				sstr.put(0x0);
				sstr.put(0x0);
				sstr.put(0x0);
				sstr.put(0x0);
				sstr.put(0x0);
				sstr.put(0x0);
				sstr.put(0xa0);
				sstr.put(j); //fftsize
				sstr.put(0x2); //mode
				sstr.put(0x0);
				sstr.put(0x0);
				sstr.put(0x0);
				sstr.put(0x0);
				sstr.put(0x0);
				sstr.put(0x0);
				//puts("here0");
				boost::this_thread::sleep(boost::posix_time::milliseconds(10));
				boost::system_time timeout = boost::get_system_time() + boost::posix_time::milliseconds(1000);
				start = __rdtsc();
				//puts("here1");
				packetValid = a.send(endp_a, sstr.str()); //this thread is mutex locked
				
				stop = __rdtsc();
				//puts("here2");
				boost::this_thread::sleep(boost::posix_time::milliseconds(10));
				//printf("%f\n",(double(stop-start)/double(procFreq))*1e6);
				//boost::this_thread::sleep(boost::posix_time::milliseconds(10));
				if(packetValid == 1)
				{
					fid=fopen("crushUDPTest.dat","a");
					if(fid !=NULL)
					{
						fprintf(fid,"%d,%f\n",j,(double(stop-start)/double(procFreq))*1e6);
						fclose(fid);
					}
				}
				else
				{
					//puts("Missed a packet");
				}

			}
			printf("*** - %d ***\n\r\n\r",j);
			boost::this_thread::sleep(boost::posix_time::milliseconds(10));
		}

		boost::this_thread::sleep(boost::posix_time::milliseconds(1000));

		std::cout << "b sent " << a.messages_sent_ << " messages"
				  << std::endl;
		std::cout << "a received " << a.messages_received_ << " messages"
				  << std::endl;

		// stop the listening thread
		should_run = false;
		io_service.stop();
		t.join();
	  }
	  catch (std::exception& e)
	  {
		std::cerr << "Exception: " << e.what() << "\n";
	  }
	
	printf("test took: %f\n",(double(stop-start)/double(procFreq))*1e6);
	/*
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
    usrp->issue_stream_cmd(stream_cmd);
    if (total_num_samps == 0){
        std::signal(SIGINT, &sig_int_handler);
        std::cout << "Press Ctrl + C to stop streaming..." << std::endl;
    }

    //recv to file
    if (type == "double") recv_to_file<std::complex<double> >(usrp, uhd::io_type_t::COMPLEX_FLOAT64, file, spb);
    else if (type == "float") recv_to_file<std::complex<float> >(usrp, uhd::io_type_t::COMPLEX_FLOAT32, file, spb);
    else if (type == "short") recv_to_file<std::complex<short> >(usrp, uhd::io_type_t::COMPLEX_INT16, file, spb);
    else throw std::runtime_error("Unknown type " + type);

    //finished
    std::cout << std::endl << "Done!" << std::endl << std::endl;
	*/
    return 0;
}
