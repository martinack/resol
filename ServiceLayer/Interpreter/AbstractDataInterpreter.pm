package Resol::ServiceLayer::Interpreter::AbstractDataInterpreter;

our @ISA = qw(Resol::ServiceLayer::Observer);

use Resol::ServiceLayer::Observer;

sub new
{
	my $class = shift;
	my $this = {};
	bless $this, $class;
	return $this;
}

sub getData {
	my $this = shift;
	$this->getLogger()->error("The method Resol::ServiceLayer::Interpreter::AbstractDataInterpreter->getData is not implemented by default, add a valid implementation!");
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
	
	return substr($address, 2, 2) . substr($address, 0, 1);
}

1;