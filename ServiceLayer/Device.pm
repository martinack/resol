package Resol::ServiceLayer::Device;

our @ISA = qw(Resol::ServiceLayer::Observable);

use Resol::ServiceLayer::Observable;
use IO::Socket::INET;

use constant PASSWORD_ACCEPTED => "2b4f4b3a2050617373776f72642061636365707465640a";
use constant CONNECTION_ACCEPTED => "2b48454c4c4f0a";
use constant START_DATA_TRANSMISSION => "2b4f4b3a204461746120696e636f6d696e672e2e2e0a";

#
# @author Martin Ackermann
#
# Representation of a vbus network device.<br />
# It can establish a connection, sending data, perform the login, receiving (raw) data and disconnect.
#

sub new {
	my $class = shift;
	my $networkAddress = shift;
	my $password = shift;
	my $this = $class->SUPER::new();
	bless $this, $class;
	
	$this->{_interpreters} = ();
	$this->{_channels} = ();
	
	return $this;
}

sub getPassword {
	my $this = shift;
	return $this->{_password};
}

sub setPassword {
	my $this = shift;
	my $password = shift;
	$this->{_password} = $password;
}

sub getName {
	my $this = shift;
	return $this->{_name};
}

sub setName {
	my $this = shift;
	$this->{_name} = shift;
}

sub setPort {
	my $this = shift;
	$this->{_port} = shift;
}

sub getPort {
	my $this = shift;
	return $this->{_port};
}

sub getHostname {
	my $this = shift;
	return $this->{_hostname};
}

sub setHostname {
	my $this = shift;
	$this->{_hostname} = shift;
}

sub getReceiver {
	my $this = shift;
	return $this->{_receiver};
}

sub setReceiver {
	my $this = shift;
	$this->{_receiver} = shift;
}

sub getChannels {
	my $this = shift;
	
	return $this->{_channels};
}

sub addChannel {
	my $this = shift;
	my $channel = shift;
	
	push(@{$this->{_channels}}, $channel);
}

sub setChannels {
	my $this = shift;
	$this->{_channels} = shift;
}

sub registerInterpreter {
	my $this = shift;
	my $interpreter = shift;
	
	$interpreter->setDeviceName($this->getName());
	$this->getReceiver()->registerObserver($interpreter);
	push(@{$this->{_interpreters}}, $interpreter);
	
	my $name = $this->getName();
}

sub getConnection {
	my $this = shift;
	
	return $this->{_connection};
}

sub listen {
	my $this = shift;
	my $timeout = shift;
	
	if (!defined($this->getConnection())) {
		$this->connect();
	}

	if (!defined($this->getConnection())) {
		print("ERROR: Unable to connect, can not receive any data.\n");
		return undef;
	}
	
	if (!defined($this->{_loggedIn}) || $this->{_loggedIn} == 0) {
		$this->login();
	}
	
	my $buf;
	if (!defined($this->{_transmissionBegun}) || $this->{_transmissionBegun} == 0) {
		$this->send('DATA');
		$buf = $this->receive(44);
		if ($buf eq START_DATA_TRANSMISSION) {
			print("ERROR: Something seems to be not correct: after saying 'DATA' to vbus, he answered not as expected.\n");
		}
		$this->{_transmissionBegun} = 1;
	} else {
		$this->getReceiver()->getBuffer()->clear();
	}
	
	my $hostname = $this->getHostname();
	my $foundValid = 0;
	if (defined($timeout) && $timeout > -1) {
		my $start = time;
		my $timeDiff;
		while (time - $start < $timeout) {
			$buf = $this->receive(2048);
			my @data = $this->unwrap($buf);
			if (!$foundValid) {
				$foundValid = $this->getReceiver()->receiveData(@data);
			} else {
				$this->getReceiver()->receiveData(@data);
			}
		}
		
		if (!$foundValid) {
			$this->resetConnection();
			$this->listen($timeout);
		}
		
	} else {
		async {
			$buf = $this->receive(2048);
			my @data = $this->unwrap($buf);
			$this->getReceiver()->receiveData(@data);
		}
	}
}

sub resetConnection {
	my $this = shift;
	
	$this->{_transmissionBegun} = 0;
	$this->{_loggedIn} = 0;
	undef $this->{_connection};
	$this->getReceiver()->getBuffer()->clear();
}

sub login {
	my $this = shift;
	
	if (defined($this->getConnection())) {
		if (!$this->{_loggedIn}) {
			my $password = $this->getPassword();
			$this->send("PASS $password");
			my $buf = $this->receive(46);
			if ($buf eq PASSWORD_ACCEPTED) {
				$this->{_loggedIn} = 1;
			} else {
				print("ERROR: login failed, using pw: '$password'\n");
			}
		}
	}
}

sub connect {
	my $this = shift;
	
	my $hostname = $this->getHostname();
	my $port = $this->getPort();
	
	if (!defined($this->{_connection})) {
		if (defined($hostname) && defined($port)) {

			$this->{_connection} = new IO::Socket::INET (
				PeerHost => $hostname,
				PeerPort => $port,
				Proto => 'tcp'
			);

			unless ($this->{_connection}) {
				print("ERROR: $! - Connection will be reset.\n");

				$this->resetConnection();
				return undef;
			}

			my $buf = $this->receive(14);
			
			if ($buf ne CONNECTION_ACCEPTED) {
				print("WARN: Connection to '$hostname' established, but something seems to be not correct.\n");
			}
			
		} else {
			print("Address is not complete: [hostname: '$hostname', port: '$port']\n");
		}
	}
}

sub disconnect {
	my $this = shift;

	if (defined($this->getConnection())) {
		$this->send("QUIT\n");
		$this->getConnection()->close();
	}
	$this->resetConnection();
}

sub receive {
	my $this = shift;
	my $length = shift;
	
	my $ret = "";

	if (defined($this->getConnection())) {
		$this->getConnection()->recv($ret, $length);
	
		$ret = unpack('H*', $ret);
	}
	
	return $ret;
}

sub send {
	my $this = shift;
	if (defined($this->getConnection())) {
		$this->getConnection()->send(shift);
	}
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

sub getData {
	my $this = shift;
	my $interpreter = shift;
	
	my $ret = undef;
	
	foreach my $registeredInterpreter (@{$this->{_interpreters}}) {
		if ($registeredInterpreter == $interpreter) {
			$ret = $interpreter->getData();
			last;
		}
	}
	
	return $ret;
}

1;
