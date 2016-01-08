package Resol::ServiceLayer::Observer;

our @ISA = qw(Resol::LowerLayer::Object);

use Resol::LowerLayer::Object;

sub new
{
	my $class = shift;
	my $this = {};
	bless $this, $class;
	return $this;
}

sub receiveEvent {
	my $this = shift;
	$this->getLogger()->error("The method Resol::ServiceLayer::Observer->receiveEvent is not implemented by default, add a valid implementation!");
	die;
}
