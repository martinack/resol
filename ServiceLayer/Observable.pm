package Resol::ServiceLayer::Observable;

our @ISA = qw(Resol::LowerLayer::Object);

use Resol::LowerLayer::Object;

sub new
{
	my $class = shift;
	my $this = {
		_observers => []
	};
	bless $this, $class;
	return $this;
}

sub fireEvent {
	my $this = shift;
	my $event = shift;
	
	foreach my $observer (@{$this->{_observers}}) {
		$observer->receiveEvent($event);
	}
}

sub registerObserver {
	my $this = shift;
	my $observer = shift;
	
	if (defined($observer->instanceof) && $observer->instanceof("Resol::ServiceLayer::Observer")) {
		push(@{$this->{_observers}}, $observer);
	}
}
