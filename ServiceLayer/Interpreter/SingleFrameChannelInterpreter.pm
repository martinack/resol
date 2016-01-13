package Resol::ServiceLayer::Interpreter::SingleFrameChannelInterpreter;

our @ISA = qw(Resol::ServiceLayer::Interpreter::AbstractDataInterpreter);

use Resol::ServiceLayer::Interpreter::AbstractDataInterpreter;
use Resol::HigherLayer::Channel;

sub new
{
	my $class = shift;
	my $this = {};
	bless $this, $class;
	$this->{_channels} = ();
	return $this;
}

sub getChannel {
	my $this = shift;
	
	return $this->{_channel};
}

sub setChannel {
	my $this = shift;
	
	$this->{_channel} = shift;
}

sub receiveEvent {
	my $this = shift;
	my $frame = shift;
	
	#$this->getLogger()->trace("received frame: '$frame'");
	#$this->getLogger()->trace("has frame: " . $this->hasFrame());
	#$this->getLogger()->trace("channel frame: " . $this->isFrameForChannel($frame));
	if ((!$this->hasFrame()) && $this->isFrameForChannel($frame)) {
		#$this->getLogger()->debug("found valid frame: '$frame'");
		$this->{_frame} = $frame;
	}
}

sub isFrameForChannel {
	my $this = shift;
	my $frame = shift;
	my $channel = $this->getChannel();
	
	my $source = $this->unwrapAddress($frame->getHeader()->getSource());
	my $destination = $this->unwrapAddress($frame->getHeader()->getDestination());
	my $framecount = $frame->getHeader()->getFrameCount();
	
	my $ret = 1;
	
	#$this->getLogger()->trace("source: [frame: '$source', channel: '" . $channel->getSource() . "']");
	#$this->getLogger()->trace("destination: [frame: '$destination', channel: '" . $channel->getDestination() . "']");
	#$this->getLogger()->trace("framecount: [frame: '$framecount', channel: '" . $channel->getFramecount() . "']");
	$ret &= ($source eq $channel->getSource());
	$ret &= ($destination eq $channel->getDestination());
	$ret &= ($framecount eq $channel->getFramecount());
	
	return $ret;
}

sub hasFrame {
	my $this = shift;
	
	return defined($this->{_frame});
}

sub getData {
	my $this = shift;
	
	my $ret = $this->{_frame};
	#$this->getLogger()->trace("will return frame:" . $ret);
	return $ret;
}

1;
