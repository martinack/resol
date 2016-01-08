package Resol::MiddleLayer::FrameData;

our @ISA = qw(Resol::LowerLayer::BinaryData);

use Resol::LowerLayer::BinaryData;

sub new
{
	my $class = shift;
	my $this = {};
	bless $this, $class;
	
	$this->setMaxLength(6);
	
	return $this;
}

sub getDataByte {
	my $this = shift;
	my $index = shift;
	
	my $ret = $this->getByte($index);
	if ($this->hasMsb($index)) {
		$ret = $ret | 0x80;
	}
	
	return $ret;
}

sub getDataByteAsHexString {
	my $this = shift;
	
	my $ret = uc sprintf("%x",$this->getDataByte(shift));
	
	if (length($ret) == 1) {
		$ret = "0" . $ret;
	}
	
	return $ret;
}

sub getSeptett {
	my $this = shift;
	my $ret;
	
	$ret = $this->getByteAsHexString(4);
	
	return $ret;
}

sub hasMsb {
	my $this = shift;
	my $index = shift;
	
	my $sep = $this->getSeptett();
	my $ret;
	
	if ($index == 0) {
		$ret = $sep & 0x1;
	} elsif ($index == 1) {
		$ret = $sep & 0x2;
	} elsif ($index == 2) {
		$ret = $sep & 0x4;
	} elsif ($index == 3) {
		$ret = $sep & 0x8;
	}

	return $ret;
}

sub getChecksum {
	my $this = shift;
	my $ret;
	
	$ret = $this->getByteAsHexString(5);
	
	return $ret;
}

sub buildChecksum {
	my $this = shift;
	my $ret;
	
	for my $i (0..4) {
		$ret = $ret + @{$this->getData()}[$i];
	}
	
	$ret = $ret ^ 0xFF; #invert
	$ret = $ret & 0x7F; #delete msb

	return $ret;
}

sub isValid {
	my $this = shift;
	return $this->buildChecksum() == hex($this->getChecksum());
}

1;
