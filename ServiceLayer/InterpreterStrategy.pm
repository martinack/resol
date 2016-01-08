package Resol::ServiceLayer::InterpreterStrategy;

our @ISA = qw(Resol::LowerLayer::Object);

use LowerLayer::Object;

sub new
{
	my $class = shift;
	my $this = {};
	bless $this, $class;
	return $this;
}

sub interpretData {
	print("The method Resol::ServiceLayer::DataInterpreter->interpret is not implemented by default\n", 
	"You have to implement it on our Resol::ServiceLayer::DataInterpreter class");
}
