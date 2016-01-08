package Resol::ServiceLayer::Strategy::Msr44InterpreterStrategy;

our @ISA = qw(Resol::ServiceLayer::Strategy::AbstractInterpreterStrategy);

use ServiceLayer::Strategy::AbstractInterpreterStrategy;

sub new
{
	my $class = shift;
	my $this = {};
	bless $this, $class;
	return $this;
}

sub interpretData {
	my $this = shift;
	my $frame = shift;
	
	my %ret = $this->interpretDefaults($frame);
	
	%ret->{"RelaisMask"} = $this->getBitValue($frame, 0, 0);
	%ret->{"RelaisTarget"} = $this->getBitValue($frame, 0, 1);
	%ret->{"SensorMask"} = $this->getBitValue($frame, 0, 2);
	
	return %ret;
}

1;
