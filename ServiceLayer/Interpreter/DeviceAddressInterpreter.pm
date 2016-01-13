package Resol::ServiceLayer::Interpreter::DeviceAddressInterpreter;

our @ISA = qw(Resol::ServiceLayer::Interpreter::AbstractDataInterpreter);

use Resol::ServiceLayer::Interpreter::AbstractDataInterpreter;
use Resol::HigherLayer::Channel;

sub new
{
	my $class = shift;
	my $this = $class->SUPER::new();
	bless $this, $class;
	$this->{_channels} = ();
	return $this;
}

sub receiveEvent {
	my $this = shift;
	my $frame = shift;
	
	#$this->getLogger()->trace("receiving event with data: '$frame'");
	
	
	my $channel = $this->createChannel($this->unwrapAddress($frame->getHeader()->getSource()), $this->unwrapAddress($frame->getHeader()->getDestination()), $frame->getHeader()->getFrameCount());
	
	my $contains = 0;
	
	foreach my $foundChannel (@{$this->{_channels}}) {
		if ($foundChannel->equals($channel)) {
			$contains = 1;
			last;
		}
	}
	
	if (!$contains) {
		push(@{$this->{_channels}}, $channel);
	}
}

sub createChannel {
	my $this = shift;
	my $source = shift;
	my $destination = shift;
	my $framecount = shift;
	
	my $ret = $this->getService("channel");
	$ret->setSource($source);
	$ret->setDestination($destination);
	$ret->setFramecount($framecount);
	$ret->setDeviceName($this->getDeviceName());
	$ret->setName($this->getDeviceName() . "[" . $source . "->" . $destination . "/" . $framecount . "]");
	
	return $ret;
}

sub getData {
	my $this = shift;
	
	return $this->{_channels};
}

1;
