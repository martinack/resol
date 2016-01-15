package Resol::Facade::ResolFacade;

our @ISA = qw(Resol::LowerLayer::Object);

use Resol::LowerLayer::Object;
use Resol::ServiceLayer::ServiceContext;
use Resol::ServiceLayer::DeviceProvider;
use Resol::ServiceLayer::Connector;
use Resol::ServiceLayer::DataReceiver;
use Resol::ServiceLayer::ConverterService;

use constant TEMPLATE_PATH => "/templates/";
use constant NOT_INITIALIZED => "Not Initialized";

sub new {
	my $class = shift;
	my $this = $class->SUPER::new();
	bless $this, $class;
	return $this;
}

sub getNetworkDeviceAddresses {
	my $this = shift;
	
	$this->{_networkDevices} = $this->getService("deviceProvider")->searchNetworkDevices();
	
	return $this->{_networkDevices};
}

sub createNetworkDevice {
	my $this = shift;
	my $name = shift;
	my $addr = shift;
	my $port = shift;
	my $password = shift;
	
	$this->getService("deviceProvider")->createNetworkDevice($name, $addr, $port, $password);
}

sub getCommunicationChannels {
	my $this = shift;
	my $device = shift;
	
	$this->getService("deviceProvider")->searchChannels($device);
}

sub renderTemplate {
	my $this = shift;
	my $templateName = shift;
	my $values = shift;
	
	my $templatePath = $this->getRootPath() . TEMPLATE_PATH . $templateName;
	
	#$this->getLogger()->debug("will render template: '$templatePath'");
	
	my $template = $this->getService("configurationService")->readFile($templatePath);
	
	my $renderedTemplate = $template;
	#$this->getLogger()->trace("got template: $renderedTemplate");
	
	foreach my $valName (keys %{$values}) {
		#$this->getLogger()->trace("will replace %$valName% with " . $values->{$valName});
		$renderedTemplate =~ s/%$valName%/$values->{$valName}/g;
	}
	
	
	#$this->getLogger()->trace("will return $renderedTemplate");
	return $renderedTemplate;
}

sub getRootPath {
	my $this = shift;
	
	if (!defined($this->{_rootPath})) {
		$this->{_rootPath} = File::Spec::Functions::rel2abs(File::Basename::dirname(__FILE__));
		$this->{_rootPath} =~ s/\\/\//g;
	}
	
	return $this->{_rootPath};
}

sub getDataForChannel {
	my $this = shift;
	my $channel = shift;

	return $this->getService("deviceProvider")->getOneValidFrameByChannel($channel);
}

sub createChannelForDevice {
	my $this = shift;
	my $deviceName = shift;
	my $channelName = shift;
	my $source = shift;
	my $destination = shift;
	my $framecount = shift;

	my $newChannel = $this->getService("channel");
	$newChannel->setSource($source);
	$newChannel->setDestination($destination);
	$newChannel->setFramecount($framecount);
	$newChannel->setDeviceName($deviceName);
	$newChannel->setName($channelName);
	
	$this->getService("deviceProvider")->getNetworkDevice($deviceName)->addChannel($newChannel);
	
	return $channel;
}

1;
