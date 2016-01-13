package Resol::ServiceLayer::Device;

our @ISA = qw(Resol::ServiceLayer::Observable);

use Resol::ServiceLayer::Observable;
use IO::Socket::INET;

use constant PASSWORD_ACCEPTED => "2b4f4b3a2050617373776f72642061636365707465640a";
use constant CONNECTION_ACCEPTED => "2b48454c4c4f0a";
use constant START_DATA_TRANSMISSION => "2b4f4b3a204461746120696e636f6d696e672e2e2e0a";

sub new {
	my $class = shift;
	my $networkAddress = shift;
	my $password = shift;
	my $this = {};
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
	#$this->getLogger()->debug("registered interpreter '$interpreter' to device '$name'");
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
	
	if (!defined($this->{_loggedIn}) || $this->{_loggedIn} == 0) {
		$this->login();
	}
	
	my $buf;
	if (!defined($this->{_transmissionBegun}) || $this->{_transmissionBegun} == 0) {
		$this->send('DATA');
		$buf = $this->receive(44);
		#if ($buf eq START_DATA_TRANSMISSION) {
		#	$this->getLogger()->debug("data connection established...");
		#} else {
		#	$this->getLogger()->warn("something seems to be not correct: after saying 'DATA' to vbus, he answered not as expected.");
		#}
		$this->{_transmissionBegun} = 1;
	} else {
		$this->getLogger()->debug("data connection was already established, clearing buffer and start listening...");
		$this->getReceiver()->getBuffer()->clear();
	}
	
	my $hostname = $this->getHostname();
	my $foundValid = 0;
	if (defined($timeout) && $timeout > -1) {
		#$this->getLogger()->info("will listen to $hostname for $timeout seconds");
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
			#$this->getLogger()->warn("don't received valid data for $timeout seconds. Will reset connection and try it again...");
			$this->resetConnection();
			$this->listen($timeout);
		}
		
	} else {
		#$this->getLogger()->info("will start asynchronous listening to $hostname");
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
			#$this->getLogger()->trace("trying password $password");
			$this->send("PASS $password");
			my $buf = $this->receive(46);
			if ($buf eq PASSWORD_ACCEPTED) {
				$this->{_loggedIn} = 1;
				#$this->getLogger()->debug("login succeeded.");
			} else {
				#$this->getLogger()->error("login failed, using pw: '$password'");
			}
		}
	}
}

sub connect {
	my $this = shift;
	
	my $hostname = $this->getHostname();
	my $port = $this->getPort();
	
	#$this->getLogger()->debug("trying to connect to $hostname:$port");
	
	if (!defined($this->{_connection})) {
		if (defined($hostname)&& defined($port)) {
			my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
			$mon += 1;
			my $time = ($year + 1900) . "/" . sprintf("%02d", $mon) . "/" . sprintf("%02d", $mday) . " " . sprintf("%02d", $hour) . ":" . sprintf("%02d", $min) . ":" . sprintf("%02d", $sec);
			$this->{_connection} = new IO::Socket::INET (
				PeerHost => $hostname,
				PeerPort => $port,
				Proto => 'tcp'
			);
			die "[ERROR] [$time] - $!" unless $this->{_connection};
			
			my $buf = $this->receive(14);
			
			if ($buf ne CONNECTION_ACCEPTED) {
				#$this->getLogger()->warn("connection to '$hostname' established, but something seems to be not correct.");
			} else {
				#$this->getLogger()->info("connection to '$hostname' successfully established.");
			}
			
		} else {
			#$this->getLogger()->error("Address is not complete: [hostname: '$hostname', port: '$port']");
		}
	}
}

sub receive {
	my $this = shift;
	my $length = shift;
	
	my $ret = "";
	$this->getConnection()->recv($ret, $length);
	
	$ret = unpack('H*', $ret);
	
	return $ret;
}

sub send {
	my $this = shift;
	$this->getConnection()->send(shift);
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
	
	#$this->getLogger()->trace("checking registered interpreters for '$interpreter'");
	foreach my $registeredInterpreter (@{$this->{_interpreters}}) {
		#$this->getLogger()->trace("checking '$registeredInterpreter'");
		if ($registeredInterpreter == $interpreter) {
			#$this->getLogger()->debug("will return data of interpreter '$interpreter'");
			$ret = $interpreter->getData();
			last;
		}
	}
	
	return $ret;
}

1;
