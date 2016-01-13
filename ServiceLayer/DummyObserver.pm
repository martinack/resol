package Resol::ServiceLayer::DummyObserver;

our @ISA = qw(Resol::ServiceLayer::Observer);

use Resol::ServiceLayer::Observer;

sub new
{
	my $class = shift;
	my $this = $class->SUPER::new();
	bless $this, $class;
	return $this;
}

sub receiveEvent {
	my $this = shift;
	my $frame = shift;
	print("\nFound valid Data:\n");
	print("Header: " . $frame->getHeader()->asHexString() . "\n");
	for my $i (0..$frame->getDataFrameCount() - 1) {
		print("Frame $i: " . $frame->getDataFrame($i)->asHexString() . "\n");
	}
}
