package Resol::ServiceLayer::ConverterService;

our @ISA = qw(Resol::ServiceLayer::Interpreter::AbstractDataInterpreter);

use Resol::ServiceLayer::Interpreter::AbstractDataInterpreter;
use Resol::HigherLayer::Channel;


sub new {
	my $class = shift;
	my $this = $class->SUPER::new();
	bless $this, $class;
	return $this;
}

sub toTemperature {
	my $this = shift;
	my $input = shift;
	
	#$this->getLogger()->info($input->getDataByte(0));
	
	
	
	if (defined($input->instanceof)) {
		if ($input->instanceof("Resol::HigherLayer::Frame")) {
		
		} elsif ($input->instanceof("Resol::HigherLayer::Frame")) {
		
		}
	} elsif (ref($input) == "ARRAY") {
		
	} else {
		
	}
	
	my $ret = "";
	
	return $ret;
}

sub toBitmask {
	my $this = shift;
	
	my $ret = "";
	
	return $ret;
}

sub toPercent {
	my $this = shift;
	
	my $ret = "";
	
	return $ret;
}

sub toTrigger {
	my $this = shift;
	
	my $ret = "";
	
	return $ret;
}

sub toHex {
	my $this = shift;
	
	my $ret = "";
	
	return $ret;
}
