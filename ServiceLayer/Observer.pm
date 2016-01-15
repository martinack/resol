package Resol::ServiceLayer::Observer;

our @ISA = qw(Resol::LowerLayer::Object);

use Resol::LowerLayer::Object;

#
# @author Martin Ackermann
#
# An 'classical' observer.
#

sub new
{
	my $class = shift;
	my $this = $class->SUPER::new();
	bless $this, $class;
	return $this;
}

sub receiveEvent {
	my $this = shift;
	print("The method Resol::ServiceLayer::Observer->receiveEvent is not implemented by default, add a valid implementation!");
	#dieing here is okay - since this can only happen during development time.
	die;
}
