package Resol::ServiceLayer::Strategy::MidiProInterpreterStrategy;

our @ISA = qw(Resol::ServiceLayer::Strategy::AbstractInterpreterStrategy);

use ServiceLayer::Strategy::AbstractInterpreterStrategy;

sub new
{
	my $class = shift;
	my $this = $class->SUPER::new();
	bless $this, $class;
	return $this;
}

sub interpretData {
	my $this = shift;
	my $frame = shift;
	
	my %ret = $this->interpretDefaults($frame);
	
	if (%ret->{"command"} eq DATA_FOLLOWS) {
	
		%ret->{"TemperaturS1"} = $this->getTemperaturValue($frame, 0, 0);
		%ret->{"TemperaturS2"} = $this->getTemperaturValue($frame, 0, 2);
		%ret->{"TemperaturS3"} = $this->getTemperaturValue($frame, 1, 0);
		%ret->{"TemperaturS4"} = $this->getTemperaturValue($frame, 1, 2);
		%ret->{"TemperaturS5"} = $this->getTemperaturValue($frame, 2, 0);
		%ret->{"TemperaturS6"} = $this->getTemperaturValue($frame, 2, 2);
	
	}
	
	return %ret;
}

1;
