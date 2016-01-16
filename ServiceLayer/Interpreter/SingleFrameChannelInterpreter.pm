package Resol::ServiceLayer::Interpreter::SingleFrameChannelInterpreter;

our @ISA = qw(Resol::ServiceLayer::Interpreter::AbstractDataInterpreter);

use Resol::ServiceLayer::Interpreter::AbstractDataInterpreter;
use Resol::HigherLayer::Channel;

#
# @author Martin Ackermann
#
# Extension of AbstractDataInterpreter which checks if a received frame is for a specific chanel.<br />
# #getData will return the first valid received frame for the specified chanel.
#

sub new
{
	my $class = shift;
	my $this = $class->SUPER::new();
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
	
	if ((!$this->hasFrame()) && $this->isFrameForChannel($frame)) {
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
	return $ret;
}

1;
