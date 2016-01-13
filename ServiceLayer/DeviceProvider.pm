package Resol::ServiceLayer::DeviceProvider;

our @ISA = qw(Resol::LowerLayer::Object);

use Resol::ServiceLayer::Device;
use Resol::ServiceLayer::Interpreter::DeviceAddressInterpreter;
use Resol::ServiceLayer::Interpreter::SingleFrameChannelInterpreter;

sub new {
	my $class = shift;
	my $this = {};
	bless $this, $class;
	return $this;
}

sub searchNetworkDevices {
	my $this = shift;
	
	#$this->getLogger()->info("Scanning for resol network devices...");
	#@TODO: broadcasting, real search for network devices.
	my @ret = ("192.168.178.58:7053:vbus1");
	
	my $devCount = @ret;
	
	if ($devCount == 0) {
		#$this->getLogger()->warn("No resol network devices found.");
	} else {
		#$this->getLogger()->info("Found $devCount resol network devices");
	}
	
	return \@ret;
}

sub loadConfiguredDevices {
	my $this = shift;
	
	my $deviceConfig = $this->getService("configurationService")->getMatchingProperties("^device\..*");

	
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
		#$this->getLogger()->debug("creating network device '$name'");
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
	
	#$this->getLogger()->debug("searching hardware devices for network device '$deviceName'");
	
	my $device = $this->getNetworkDevice($deviceName);
	my $deviceAddrInterpreter = $this->getService("deviceAddressInterpreter");
	
	$device->registerInterpreter($deviceAddrInterpreter);
	$device->connect();
	$device->login();
	$device->listen(5);
	my @channels = @{$deviceAddrInterpreter->getData()};
	
	#foreach my $channel (@channels) {
	#	$this->getLogger()->debug("found channel: " . $channel->getName());
	#}
	
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
