package Resol::ServiceLayer::Interpreter::AbstractDataInterpreter;

our @ISA = qw(Resol::ServiceLayer::Observer);

use Resol::ServiceLayer::Observer;

#
# @author Martin Ackermann
#
# Extension of Observer which is meant to receive valid frames.
#


sub new
{
	my $class = shift;
	my $this = $class->SUPER::new();
	bless $this, $class;
	return $this;
}

sub getData {
	my $this = shift;
	print("ERROR: The method Resol::ServiceLayer::Interpreter::AbstractDataInterpreter->getData is not implemented by default, add a valid implementation!");
	die;
}

sub getDeviceName {
	my $this = shift;
	
	return $this->{_deviceName};
}

sub setDeviceName {
	my $this = shift;
	
	$this->{_deviceName} = shift;
}

sub unwrapAddress {
	my $this = shift;
	my $address = shift;
	
	return substr($address, 2, 2) . substr($address, 0, 2);
}

1;
