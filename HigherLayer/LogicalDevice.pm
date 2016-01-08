package Resol::HigherLayer::LogicalDevice;

our @ISA = qw(Resol::LowerLayer::Object);

use Resol::LowerLayer::Object;

sub new {
	my $class = shift;
	my $this = {};
	bless $this, $class;
	
	return $this;
}

sub addChannel {
	my $this = shift;
	my $channel = shift;
	my $extractor = shift;
	
	$this->{$channel} = $extractor;
}

sub getName {
	my $this = shift;
	
	return $this->{_name};
}

sub setName {
	my $this = shift;
	
	$this->{_name} = shift;
}

sub getDataType {
	my $this = shift;
	
	return $this->{_dataType};
}

sub setDataType {
	my $this = shift;
	
	$this->{_dataType} = shift;
}

1;