package Resol::Facade::ResolFacade;

our @ISA = qw(Resol::LowerLayer::Object);

use Resol::LowerLayer::Object;
use Resol::ServiceLayer::DeviceProvider;
use Resol::ServiceLayer::DataReceiver;

#
# @author Martin Ackermann
#
# This class serves as entry point for usage of resol4perl.
#

sub new {
	my $class = shift;
	my $this = $class->SUPER::new();
	bless $this, $class;
	return $this;
}

#
# This method creates a network device with the given parameters.<br />
# Afterwards you can refer to the device by the chosen name.<br />
# You should only create one device per physical device - however it
# should work also when you "overdefine" your device (untested).
# 
# @param name 
# 	- the name of the network device. This is a free choosable name.
# @param addr
#	- the network address of the vbus device - either an IP address or an dns alias is possible.
# @param port
#	- the communication port of the vbus (in most cases it should be 7053)
# @param password
#	- the password of the vbus (if you haven't changed it it is "vbus1")
#
sub createNetworkDevice {
	my $this = shift;
	my $name = shift;
	my $addr = shift;
	my $port = shift;
	my $password = shift;
	
	my $deviceProvider = Resol::ServiceLayer::DeviceProvider->getInstance();
	$deviceProvider->createNetworkDevice($name, $addr, $port, $password);
}

#
# This method opens a connection to the given device and just listen some seconds to the communication.< br/>
# The device has to be defined previosly.
# Afterwards it will return every "channel" which occured during listening.
#
# @see createNetworkDevice
#
# @param device
#	- the name of the (defined!) (vbus) device.
#
sub getCommunicationChannels {
	my $this = shift;
	my $device = shift;
	
	my $deviceProvider = Resol::ServiceLayer::DeviceProvider->getInstance();
	$deviceProvider->searchChannels($device);
}

#
# This method will listen to the given chanel for 5 seconds and then
# either return the first valid frame for this chanel or undef.
#
#
sub getDataForChannel {
	my $this = shift;
	my $channel = shift;

	my $deviceProvider = Resol::ServiceLayer::DeviceProvider->getInstance();
	return $deviceProvider->getOneValidFrameByChannel($channel);
}

#
# This methods registers a channel with the given settings for the given device.
#
# @param deviceName
#	- the name of the device.
# @param channelName
#	- the name of the channel.
# @param source
#	- the source of the communication (in all known cases this is "001").
# @param destination
#	- the destination of the communication (such as "711" for DeltaSolBxPlus)
# @param framecount
#	- the number of frames of this chanel.
#
sub createChannelForDevice {
	my $this = shift;
	my $deviceName = shift;
	my $channelName = shift;
	my $source = shift;
	my $destination = shift;
	my $framecount = shift;

	my $newChannel = new Resol::HigherLayer::Channel();
	$newChannel->setSource($source);
	$newChannel->setDestination($destination);
	$newChannel->setFramecount($framecount);
	$newChannel->setDeviceName($deviceName);
	$newChannel->setName($channelName);
	
	my $deviceProvider = Resol::ServiceLayer::DeviceProvider->getInstance();
	$deviceProvider->getNetworkDevice($deviceName)->addChannel($newChannel);
	
	return $channel;
}

1;
