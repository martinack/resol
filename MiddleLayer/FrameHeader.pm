package Resol::MiddleLayer::FrameHeader;

our @ISA = qw(Resol::LowerLayer::BinaryData);

use Resol::LowerLayer::BinaryData;

sub new
{
	my $class = shift;
	my $this = $class->SUPER::new();
	bless $this, $class;
	
	$this->setMaxLength(9);
	
	return $this;
}

sub getSource {
	my $this = shift;
	my $ret;
	
	$ret = $this->getByteAsHexString(0) . $this->getByteAsHexString(1);
	
	return $ret;
}

sub getDestination {
	my $this = shift;
	my $ret;
	
	$ret = $this->getByteAsHexString(2) . $this->getByteAsHexString(3);
	
	return $ret;
}

sub getProtocol {
	my $this = shift;
	my $ret;
	
	$ret = $this->getByteAsHexString(4);
	
	return $ret;
}

sub getCommand {
	my $this = shift;
	my $ret;
	
	$ret = $this->getByteAsHexString(5) . $this->getByteAsHexString(6);
	
	return $ret;
}

sub getFrameCount {
	my $this = shift;
	my $ret;
	
	$ret = $this->getByteAsHexString(7);
	
	return $ret;
}

sub getChecksum {
	my $this = shift;
	my $ret;
	
	$ret = $this->getByteAsHexString(8);
	
	return $ret;
}

sub buildChecksum {
	my $this = shift;
	my $ret;
	
	for my $i (0..7) {
		$ret = $ret + @{$this->getData()}[$i];
	}
	
	$ret = $ret ^ 0xFF; #invert
	$ret = $ret & 0x7F; #delete msb

	return $ret;
}

sub isValid {
	my $this = shift;
	return ($this->buildChecksum() == hex($this->getChecksum())) && $this->isFull() && ($this->getFrameCount() > 0);
}

sub toReadableString() {
	my $this = shift;
	my $ret = "";
	
	$ret .= "source address: " . $this->getSource() . "\n";
	$ret .= "destination address: " . $this->getDestination() . "\n";
	$ret .= "protocol: " . $this->getProtocol() . "\n";
	$ret .= "command: " . $this->getCommand() . "\n";
	$ret .= "framecount: " . $this->getFrameCount() . "\n";
	$ret .= "checksum: " . $this->getChecksum() . "\n";
	$ret .= "valid: " . $this->isValid();
	
	return $ret;
}

1;
