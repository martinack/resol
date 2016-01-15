package Resol::ServiceLayer::DeviceProvider;

our @ISA = qw(Resol::LowerLayer::Object);

use Resol::ServiceLayer::Device;
use Resol::ServiceLayer::Interpreter::DeviceAddressInterpreter;
use Resol::ServiceLayer::Interpreter::SingleFrameChannelInterpreter;

#
# @author Martin Ackermann
#
# This service is able to handle devices and chanels - it can create devices,<br />
# searching, creating and getting channels and retrieving data for a chanel.
#

sub new {
	my $class = shift;
	my $this = $class->SUPER::new();
	bless $this, $class;
	return $this;
}

sub getNetworkDevice {
	my $this = shift;
	my $name = shift;
	
	my $ret = undef;
	
	if ($this->isNetworkDevice($name)) {
		$ret = $this->{_networkDevices}->{$name};
	}
	
	return $ret;
}

sub createNetworkDevice {
	my $this = shift;
	my $name = shift;
	my $address = shift;
	my $port = shift;
	my $password = shift;
	
	if (!defined($this->{_networkDevices}->{$name})) {
		my $device = $this->getService("device");
		$device->setName($name);
		$device->setHostname($address);
		$device->setPort($port);
		$device->setPassword($password);
		$device->setReceiver($this->getService("dataReceiver"));
		$this->{_networkDevices}->{$name} = $device;
	}
}

sub isNetworkDevice {
	my $this = shift;
	my $name = shift;
	
	return defined($this->{_networkDevices}->{$name});
}

sub searchChannels {
	my $this = shift;
	
	my $deviceName = shift;
	my @channels = ();
	
	my $device = $this->getNetworkDevice($deviceName);
	my $deviceAddrInterpreter = $this->getService("deviceAddressInterpreter");
	
	$device->registerInterpreter($deviceAddrInterpreter);
	$device->connect();
	$device->login();
	$device->listen(5);
	$device->disconnect();
	my @channels = @{$deviceAddrInterpreter->getData()};
	
	return \@channels;
}

sub getOneValidFrameByChannel {
	my $this = shift;
	my $channelName = shift;
	
	my $channel = $this->getChannel($channelName);
	
	my $device = $this->getNetworkDevice($channel->getDeviceName());
	
	my $interpreter = $this->getService("singleFrameChannelInterpreter");
	$interpreter->setChannel($channel);
	
	$device->registerInterpreter($interpreter);
	$device->listen(5);
	$device->disconnect();
	
	return $device->getData($interpreter);
}

sub getChannel {
	my $this = shift;
	my $channelName = shift;
	
	my $ret;
	
	foreach my $device (values %{$this->{_networkDevices}}) {
		foreach my $channel (@{$device->getChannels()}) {
			if ($channel->getName() eq $channelName) {
				$ret = $channel;
				last;
			}
		}
	}
	
	return $ret;
}

1;
