package Resol::ServiceLayer::Strategy::DeltaSolB_53_25InterpreterStrategy;

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
	
	my $super = $this->super('interpretData');
	
	my %ret = $super->($self, $frame);
	
	
	
	return %ret;
}

1;
