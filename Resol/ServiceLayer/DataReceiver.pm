package Resol::ServiceLayer::DataReceiver;

our @ISA = qw(Resol::ServiceLayer::Observable);

use Resol::HigherLayer::Frame;
use Resol::ServiceLayer::Observable;
use Storable;

#
# @author Martin Ackermann
#
# Receives data and push it into a frame until a valid frame was found.<br />
# Once a valid frame was found the frame gets archived and a new, empty frame is created.
#

sub new
{
	my $class = shift;
	my $this = $class->SUPER::new();

	$this->{_bufferFrame} = new Resol::HigherLayer::Frame();
	$this->{_validFrames} = [];

	bless $this, $class;
	return $this;
}

sub receiveData {
	my $this = shift;
	my @data = @_;
	
	my $foundValid = 0;
	
	
	foreach my $date (@data) {
		$this->getBuffer()->pushData($date);
		if ($this->getBuffer()->isValid()) {
			$foundValid = 1;
			my $frame = $this->archiveFrame();
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
