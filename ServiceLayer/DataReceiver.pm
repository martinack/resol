package Resol::ServiceLayer::DataReceiver;

our @ISA = qw(Resol::ServiceLayer::Observable);

use Resol::HigherLayer::Frame;
use Resol::ServiceLayer::Observable;
use Storable;

sub new
{
	my $class = shift;
	my $this = {
		_bufferFrame => new Resol::HigherLayer::Frame(),
		_validFrames => []
	};
	bless $this, $class;
	return $this;
}

sub receiveData {
	my $this = shift;
	my @data = @_;
	
	my $foundValid = 0;
	
	
	#$this->getLogger()->debug("received raw data:" . @data);
	
	foreach my $date (@data) {
		$this->getBuffer()->pushData($date);
		#if ($this->getLogger()->is_trace()) {
		#	for my $i (0..$this->getBuffer()->getDataFrameCount() - 1) {
		#		my $frame = $this->getBuffer()->getDataFrame($i);
		#	}
		#}
		if ($this->getBuffer()->isValid()) {
			$foundValid = 1;
			#$this->getLogger()->trace("found valid data, will fire event");
			my $frame = $this->archiveFrame();
			#$this->getLogger()->debug("found valid frame, framecount:" . $frame->getHeader()->getFrameCount());
			$this->fireEvent($frame);
			$this->getBuffer()->clear();
		}
	}
	
	return $foundValid;
}

sub getBuffer {
	my $this = shift;
	
	return $this->{_bufferFrame};
}

sub archiveFrame {
	my $this = shift;
	
	#since the frame is the object of event handling, which may or may not occur asynchronously,
	#it is necessary to create a clone of the current buffer
	my $frame = Storable::dclone($this->getBuffer());
	
	push(@{$this->{_validFrames}}, $frame);
	
	return $frame;
}

1;
