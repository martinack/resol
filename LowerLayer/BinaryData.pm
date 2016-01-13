package Resol::LowerLayer::BinaryData;

our @ISA = qw(Resol::LowerLayer::Object);

use Resol::LowerLayer::Object;

sub new
{
	my $class = shift;
	my $this = $class->SUPER::new();
	bless $this, $class;
	return $this;
}

sub setMaxLength {
	my $this = shift;
	my $maxLength = shift;
	
	$this->{_maxLength} = $maxLength if defined($maxLength);
}

sub getMaxLength {
	my $this = shift;
	
	my $ret = -1;
	
	if (defined($this->{_maxLength})) {
		$ret = $this->{_maxLength};
	}
	
	return $ret;
}

sub getData {
	my $this = shift;
	
	if (!defined($this->{_data})) {
		$this->{_data} = [];
	}
	
	return $this->{_data};
}

sub getCurrentLength {
	my $this = shift;
	
	my $ret = @{$this->getData()};
	
	return $ret;
}

sub pushByte {
	my $this = shift;
	
	my $val = hex(shift);
	
	my $ret;
	
	if ($val <= 0xFF) {
	
		if ($this->getMaxLength() > -1) {
			if ($this->getCurrentLength() >= $this->getMaxLength()) {
				$ret = shift @{$this->getData()};
			}
		}
	
		push(@{$this->getData()}, $val);
	}
	
	return $ret;
}

sub pushBytes {
	my $this = shift;
	
	foreach (@_) {
		$this->pushByte($_);
	}
}

sub asHexString {
	my $this = shift;
	my $ret;
	
	foreach (@{$this->getData()}) {
		$tmp = uc sprintf("%x",$_);
		if (length($tmp) == 1) {
			$tmp = "0" . $tmp;
		}
		$ret = $ret . $tmp . " ";
	}
	
	return $ret;
}

sub getByte {
	my $this = shift;
	
	return @{$this->getData()}[shift];
}

sub getByteAsHexString {
	my $this = shift;
	
	my $ret = uc sprintf("%x",$this->getByte(shift));
	
	if (length($ret) == 1) {
		$ret = "0" . $ret;
	}
	
	return $ret;
}

sub getByteAsBinaryString {
	my $this = shift;
	
	my $ret = uc sprintf("%b",$this->getByte(shift));
	
	while (length($ret) < 8) {
		$ret = "0" . $ret;
	}
	
	return $ret;
}

sub isFull {
	my $this = shift;
	
	return $this->getMaxLength() == $this->getCurrentLength();
}

1;
