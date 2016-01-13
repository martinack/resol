package Resol::ServiceLayer::DataInterpreter;

our @ISA = qw(Resol::ServiceLayer::Observer);

use ServiceLayer::Observer;
use ServiceLayer::Strategy::DfaInterpreterStrategy;
use ServiceLayer::Strategy::ComputerInterpreterStrategy;
use ServiceLayer::Strategy::El1InterpreterStrategy;
use ServiceLayer::Strategy::DeltaSolProInterpreterStrategy;
use ServiceLayer::Strategy::DeltaSolB_53_25InterpreterStrategy;
use ServiceLayer::Strategy::WmzM1InterpreterStrategy;
use ServiceLayer::Strategy::Msr44InterpreterStrategy;
use ServiceLayer::Strategy::DeltaSolPlusInterpreterStrategy;
use ServiceLayer::Strategy::El23InterpreterStrategy;
use ServiceLayer::Strategy::MidiProInterpreterStrategy;
use ServiceLayer::Strategy::DeltaSolMInterpreterStrategy;

use constant DFA => "DFA";
use constant COMPUTER => "Computer";
use constant EL1 => "EL1";
use constant DELTASOL_PRO => "DeltaSolPro";
use constant DELTASOL_B_53_25 => "DeltaSolB(53.25)";
use constant WMZ_M1 => "WMZ-M1";
use constant MSR_44 => "MSR-44";
use constant DELTASOL_PLUS => "DeltaSolPlus";
use constant EL23 => "EL23";
use constant MIDI_PRO => "MidiPro";
use constant DELTASOL_M => "DeltaSolM";

our %interpreters = (
	&DFA => new Resol::ServiceLayer::Strategy::DfaInterpreterStrategy(),
	&COMPUTER => new Resol::ServiceLayer::Strategy::ComputerInterpreterStrategy(),
	&EL1 => new Resol::ServiceLayer::Strategy::El1InterpreterStrategy(),
	&DELTASOL_PRO => new Resol::ServiceLayer::Strategy::DeltaSolProInterpreterStrategy(),
	&DELTASOL_B_53_25 => new Resol::ServiceLayer::Strategy::DeltaSolB_53_25InterpreterStrategy(),
	&WMZ_M1 => new Resol::ServiceLayer::Strategy::WmzM1InterpreterStrategy(),
	&MSR_44 => new Resol::ServiceLayer::Strategy::Msr44InterpreterStrategy(),
	&DELTASOL_PLUS => new Resol::ServiceLayer::Strategy::DeltaSolPlusInterpreterStrategy(),
	&EL23 => new Resol::ServiceLayer::Strategy::El23InterpreterStrategy(),
	&MIDI_PRO => new Resol::ServiceLayer::Strategy::MidiProInterpreterStrategy(),
	&DELTASOL_M => new Resol::ServiceLayer::Strategy::DeltaSolMInterpreterStrategy()
);

our %addressMapping = (
	"001" => &DFA,
	"002" => &COMPUTER,
	"321" => &EL1,
	"322" => &DELTASOL_PRO,
	"331" => &DELTASOL_B_53_25,
	"401" => &WMZ_M1,
	"441" => &MSR_44,
	"531" => &DELTASOL_PLUS,
	"551" => &EL23,
	"661" => &MIDI_PRO,
	"731" => &DELTASOL_M
);

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
	
	%data = $this->interpretData($frame);
	
	for (keys(%data)) {
		print($_ . ":\t" . %data->{$_} . "\n");
	}
}

sub interpretData {
	my $this = shift;
	my $frame = shift;
	
	$this->determineInterpreterStrategies($frame);
	
	my %ret = $this->getReceiveStrategy()->interpretData($frame);
	
	%ret->{"senderDevice"} = $this->getSenderDevice();
	%ret->{"receiverDevice"} = $this->getReceiverDevice();
	
	return %ret;
}

sub determineTypeByAddress {
	my $this = shift;
	my $address = shift;
	my $strategy;
	
	my $addrPrefix = substr($address, 2, 2) . substr($address, 0, 1);
	
	my $type = %addressMapping->{$addrPrefix};
	
	return $type;
}

sub determineInterpreterStrategies {
	my $this = shift;
	my $frame = shift;
	
	my $sourceAddress = $frame->getHeader()->getSource();
	my $destinationAddress = $frame->getHeader()->getDestination();
	
	my $receiverType = $this->determineTypeByAddress($destinationAddress);
	my $senderType = $this->determineTypeByAddress($sourceAddress);
	my $receiveStrat = $this->getStrategyByAddress($sourceAddress);
	my $sendStrat = $this->getStrategyByAddress($destinationAddress);
	
	if (defined($receiveStrat) && defined($receiveStrat->instanceof) && $receiveStrat->instanceof("Resol::ServiceLayer::InterpreterStrategy")) {
		$this->{_receiverType} = $receiverType;
		$this->{_receiveStrategy} = $receiveStrat;
	}
	
	if (defined($sendStrat) && defined($sendStrat->instanceof) && $sendStrat->instanceof("Resol::ServiceLayer::InterpreterStrategy")) {
		$this->{_senderType} = $senderType;
		$this->{_sendStrategy} = $sendStrat;
	}
}

sub getStrategyByAddress {
	my $this = shift;
	my $address = shift;
	my $strategy;
	
	my $addrPrefix = substr($address, 2, 2) . substr($address, 0, 1);
	
	my $type = $this->determineTypeByAddress($address);
	
	if (defined($type) && $type ne "") {
		$strategy = %interpreters->{$type};
	}
	
	return $strategy;
}

sub getReceiveStrategy {
	my $this = shift;
	
	return $this->{_receiveStrategy};
}

sub getSendStrategy {
	my $this = shift;
	
	return $this->{_sendStrategy};
}

sub getSenderDevice {
	my $this = shift;
	
	return $this->{_senderType};
}

sub getReceiverDevice {
	my $this = shift;
	
	return $this->{_receiverType};
}

1;
