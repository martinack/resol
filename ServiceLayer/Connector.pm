package Resol::ServiceLayer::Connector;

our @ISA = qw(Resol::LowerLayer::Object);

use Resol::LowerLayer::Object;
use IO::Socket::INET;

sub new {
	my $class = shift;
	my $this = $class->SUPER::new();
	bless $this, $class;
	return $this;
}

sub setAddress {
	my $this = shift;
	
	$this->{_ip} = shift;
	$this->{_port} = shift;
}

sub connect {
	my $this = shift;
	
	if (ref($this->{_connection}) ne "IO::Socket::INET") {
		if (length($this->{_ip}) > 0 && length($this->{_port}) > 0) {
			$this->{_connection} = new IO::Socket::INET (
				PeerHost => $this->{_ip},
				PeerPort => $this->{_port},
				Proto => 'tcp',
			);
			die "cannot connect to the server $!\n" unless $this->{_connection};
			
			my $buf = $this->receive(14);
			if ($buf ne 'b28454c4c4f4a0') {
				print("connection established, but something seems to be not correct.\n");
			} else {
				print("connection successfully established.\n");
			}
			
		} else {
			print("No address set, cannot create an connection.\n");
		}
	}
}

sub login {
	my $this = shift;
	
	if (ref($this->{_connection}) eq "IO::Socket::INET") {
		if (!$this->{_loggedIn}) {
			$this->send('PASS vbus');
			my $buf = $this->receive(46);
			if ($buf eq 'b2f4b4a3020516373777f62746021636365607475646a0') {
				$this->{_loggedIn} = 1;
				print("login succeeded.\n");
			} else {
				print("login failed.\n");
			}
		}
	}
}

sub listen {
	my $this = shift;
	my $receiver = shift;
	
	$this->send('DATA');
	
	my $buf = $this->receive(44);
	
	#if ($buf eq 'b2f4b4a302441647160296e636f6d696e676e2e2e2a0') {
		print("start listing...\n");
		while (1) {
			$buf = $this->receive(2048);
			my @p = $this->unwrap($buf);
			
			#my $counter = 1;
			#print("\n\n\nreceived data:\n");
			#foreach (@p) {
			#	print("$_ ");
			#	if ($counter % 13 == 0) {
			#		print("\n");
			#	}
			#	$counter++;
			#}
			
			
			
			$receiver->receiveData(@p);
		}
	#}

}

sub receive {
	my $this = shift;
	my $length = shift;
	
	my $ret = "";
	$this->{_connection}->recv($ret, $length);
	
	$ret = unpack('H*', $ret);
	
	return $ret;
}

sub send {
	my $this = shift;
	$this->{_connection}->send(shift);
}

sub unwrap {
	my $this = shift;
	my $rawData = shift;
	
	my @ret;
	
	my @tmp = split(//, $rawData);
	
	my $buf = "";
	my $counter = 1;
	foreach my $halfByte (@tmp) {
		$buf = $buf . $halfByte;
		if ($counter % 2 == 0) {
			push(@ret, $buf);
			$buf = "";
		}
		$counter++;
	}
	
	return @ret;
}

1;
