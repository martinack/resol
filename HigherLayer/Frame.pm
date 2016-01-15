package Resol::HigherLayer::Frame;

our @ISA = qw(Resol::LowerLayer::Object);

use Resol::MiddleLayer::FrameHeader;
use Resol::MiddleLayer::FrameData;
use Resol::LowerLayer::Object;

#
# @author Martin Ackermann
#
# Combination of a frame header and the related data frames.<br />
# Data can be pushed into this frame.<br />
# It detects automatically if the data is for the header or for data frames.
#

sub new {
	my $class = shift;
	my $this = $class->SUPER::new();

	$this->{_header} = new Resol::MiddleLayer::FrameHeader();
	$this->{_frames} = [];

	bless $this, $class;
	
	return $this;
}

sub pushData {
	my $this = shift;
	my @data = @_;
	
	foreach (@data) {
		
		if (!$this->isValid()) {
			if (!$this->getHeader()->isFull()) {
				$this->getHeader()->pushByte($_);
			} else {
				if (defined($this->getLastDataFrame()) && !$this->getLastDataFrame()->isFull()) {
					$this->getLastDataFrame()->pushByte($_);
				} elsif (defined($this->getLastDataFrame())) {
					if ($this->getDataFrameCount() < $this->getHeader()->getFrameCount()) {
						my $newFrame = new Resol::MiddleLayer::FrameData();
						$newFrame->pushByte($_);
						$this->addFrame($newFrame);
					} else {
						my $byte = $_;
						for my $i ($this->getDataFrameCount()..0) {
							$byte = $this->getDataFrame($i)->pushByte($byte);
						}
						$this->getHeader()->pushByte($byte);
					}
				} elsif ($this->getHeader()->isValid()) {
					my $newFrame = new Resol::MiddleLayer::FrameData();
					$newFrame->pushByte($_);
					$this->addFrame($newFrame);
				} else {
					$this->getHeader()->pushByte($_);
				}
			}
		}
	}
}

sub getHeader {
	my $this = shift;
	
	return $this->{_header};
}

sub addFrame {
	my $this = shift;
	my $newFrame = shift;
	
	push(@{$this->{_frames}}, $newFrame);
}

sub getDataFrame {
	my $this = shift;
	my $index = shift;
	
	return @{$this->{_frames}}[$index];
}

sub getLastDataFrame {
	my $this = shift;
	
	my $currentFrameCount = $this->getDataFrameCount();
	
	return @{$this->{_frames}}[$currentFrameCount - 1];
}

sub getDataFrameCount {
	my $this = shift;
	
	my $currentFrameCount = @{$this->{_frames}};
	
	return $currentFrameCount;
}

sub isValid {
	my $this = shift;
	
	my $ret;
	
	$ret = $this->getHeader()->isValid();
	
	for my $i (0..$this->getDataFrameCount() - 1) {
		$ret = $ret && defined($this->getDataFrame($i));
		if ($ret) {
			$ret = $ret && $this->getDataFrame($i)->isValid();
		}
	}
	
	$ret = $ret && $this->getHeader()->getFrameCount() == $this->getDataFrameCount();
	
	return $ret;
}

sub clear {
	my $this = shift;
	
	$this->{_header} = new Resol::MiddleLayer::FrameHeader();
	$this->{_frames} = [];
}

sub isEmpty {
	my $this = shift;
	
	my $ret = $this->getHeader()->getCurrentLength() == 0;
	$ret = $ret && $this->getDataFrameCount() == 0;
	
	return $ret;
}

#@TODO: is this method used?
sub byteSwitch {
	my $this = shift;
	my $bytesToSwitch = shift;	
	
	my $ret = substr($bytesToSwitch, 2, 2) . substr($bytesToSwitch, 0, 2);
	
	return $ret;
}

1;
