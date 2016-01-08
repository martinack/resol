package Resol::ServiceLayer::DataExtractor;

our @ISA = qw(Resol::LowerLayer::Object);

use Resol::LowerLayer::Object;

sub new {
	my $class = shift;
	my $this = {};
	bless $this, $class;
	
	return $this;
}

sub extractData {
	my $this = shift;
	my $frame = shift;
	
	my @ret = ();
	
	my $dataFrame = $frame->getDataFrame($this->getFrameNumber());
	
	for my $i (0..$this->getDataLength() - 1) {
		push(@ret, $dataFrame->getDataByte($i));
	}
	
	return \@ret;
}

sub getFrameNumber {
	my $this = shift;
	
	return $this->{_frameNumber};
}

sub setFrameNumber {
	my $this = shift;
	
	$this->{_frameNumber} = shift;
}

sub getByteNumber {
	my $this = shift;
	
	return $this->{_byteNumber};
}

sub setByteNumber {
	my $this = shift;
	
	$this->{_byteNumber} = shift;
}

sub getDataLength {
	my $this = shift;
	
	return $this->{_dataLength};
}

sub setDataLength {
	my $this = shift;
	
	$this->{_dataLength} = shift;
}


1;