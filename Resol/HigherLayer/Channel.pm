package Resol::HigherLayer::Channel;

our @ISA = qw(Resol::LowerLayer::Object);

use Resol::LowerLayer::Object;

#
# @author Martin Ackermann
#
# Representation of a communication chanel.<br />
# It consists of a source address, destination address and the framecount.<br />
# The framecount is important, since communication can occur for instance from<br />
# "001" to "711" but with a different amount of data frames (e.g. "11" or "08").<br />
# Each chanel contains different data.
#

sub new {
	my $class = shift;
	my $this = $class->SUPER::new();
	bless $this, $class;
	
	return $this;
}

sub getSource {
	my $this = shift;
	
	return $this->{_source};
}

sub setSource {
	my $this = shift;
	
	$this->{_source} = shift;
}

sub getDeviceName {
	my $this = shift;
	
	return $this->{_deviceName};
}

sub setDeviceName {
	my $this = shift;
	
	$this->{_deviceName} = shift;
}

sub getDestination {
	my $this = shift;
	
	return $this->{_destination};
}

sub setDestination {
	my $this = shift;
	
	$this->{_destination} = shift;
}

sub getFramecount {
	my $this = shift;
	
	return $this->{_framecount};
}

sub setFramecount {
	my $this = shift;
	
	$this->{_framecount} = shift;
}

sub getName {
	my $this = shift;
	
	return $this->{_name};
}

sub setName {
	my $this = shift;
	
	$this->{_name} = shift;
}

sub equals {
	my $this = shift;
	my $obj = shift;
	
	my $ret = 0;
	
	if ($this == $obj) {
		$ret = 1;
	}
	
	if (!$ret && $obj->instanceof("Resol::HigherLayer::Channel")) {
		$ret = ($this->getName() eq $obj->getName());
		$ret &= ($this->getSource() eq $obj->getSource());
		$ret &= ($this->getDestination() eq $obj->getDestination());
		$ret &= ($this->getFramecount() eq $obj->getFramecount());
		$ret &= ($this->getDeviceName() eq $obj->getDeviceName());
	}

	return $ret;
}

1;
