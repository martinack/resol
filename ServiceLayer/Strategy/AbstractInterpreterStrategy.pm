package Resol::ServiceLayer::Strategy::AbstractInterpreterStrategy;

our @ISA = qw(Resol::ServiceLayer::InterpreterStrategy);

use ServiceLayer::InterpreterStrategy;

our ($DATA_FOLLOWS, $DATA_FOLLOWS_NEED_RETURN, $NEED_DATA);

*DATA_FOLLOWS = "data_follows";
*DATA_FOLLOWS_NEED_RETURN = "data_follows_need_return";
*NEED_DATA = "need_data";


our %commandMapping = (
	"0100" => DATA_FOLLOWS,
	"0200" => DATA_FOLLOWS_NEED_RETURN,
	"0300" => NEED_DATA
);

sub new
{
	my $class = shift;
	my $this = {};
	bless $this, $class;
	return $this;
}

sub interpretDefaults {
	my $this = shift;
	my $frame = shift;
	
	my %ret = ();
	
	my $rawCommand = $frame->byteSwitch($frame->getHeader()->getCommand());
	
	my $command = %commandMapping->{$rawCommand};
	
	%ret->{"command"} = $command;
	
	return %ret;
}

sub getTemperaturValue {
	my $this = shift;
	my $frame = shift;
	my $frameIndex = shift;
	my $firstByte = shift;
	
	my $lowByte = $frame->getDataFrame($frameIndex)->getDataByteAsHexString($firstByte);
	my $highByte = $frame->getDataFrame($frameIndex)->getDataByteAsHexString($firstByte + 1);
	
	my $ret = hex($highByte . $lowByte);
	
	return $ret;
}

sub getBitValue {
	my $this = shift;
	my $frame = shift;
	my $frameIndex = shift;
	my $byte = shift;
	
	return sprintf("%08b", $frame->getDataFrame($frameIndex)->getByteAsHexString($byte));
}

1;
