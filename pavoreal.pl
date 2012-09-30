use strict;
use IO::Socket::INET;
use LWP::Simple;
use warnings;
use JSON qw(decode_json);

our $server		= "irc.freenode.net";
our $port		= "6667";
our $channel		= "#fearnode";
our $nick		= "PavoReal";
our $password		= "lalala";
our $last		= time;

print "*** Connecting to $server:$port...\r\n";

our $sock = IO::Socket::INET->new(PeerAddr => $server,
	PeerPort => $port,
	Proto    => "tcp");

print "*** Connected!\r\n";
print "*** Registering as $nick...\r\n";
print $sock "PASS $nick:$password\r\n";
print $sock "NICK $nick\r\n";
print $sock "USER lol lol lol :lol\r\n";

while (my $input = <$sock>) {
	if ($input =~ /001\s(.*)\s:/) {
		$nick = $1;
		last;
	} elsif ($input =~ /433/) {
		die "Nickname is already in use.";
	} elsif ($input =~ /^PING\s(.*)$/i) {
		print $sock "PONG $1\r\n";
		print "<- PONG $1 \r\n";
	} elsif ($input =~ /^ERROR\s:(.*)$/i) {
		print "ERROR: $1";
	}
}

print "*** Joining $channel...\r\n";
print $sock "JOIN $channel\r\n";

while (my $input = <$sock>) {
	if ($input =~ /^PING\s(.*)$/i) {
		print $sock "PONG $1\r\n";
		print "<- PONG $1 \r\n";
	} elsif ($input =~ /^:(.*)!.*@.*\sPRIVMSG\s$channel\s:.*$nick/i) {
                next if ($last > (time - 2));
                $last = time;
		print $sock "PRIVMSG $channel :$1: a mí me dejas en paz\r\n";
	} elsif ($input =~ /^:.*!.*@.*\sPRIVMSG\s$channel\s:.*https?:\/\/(www\.)?twitter\.com\/(\#!\/)?[a-zA-Z0-9_]+\/status(es)?\/(\d+)/i) {
                next if ($last > (time - 2));
                $last = time;
		my $requrl = "https://api.twitter.com/1/statuses/show.json?id=$4";
		my $json = get($requrl);
		if (!$json) {
			# tampoco nos vamos a poner flamencos para mirar qué ha fallado, habrase visto
			print $sock "PRIVMSG $channel :Ese tweet no existe, está protegido, ha petado la API o yo qué sé.\r\n";
			next;
		}
		my $decoded_json = decode_json($json);
		my $user = $decoded_json->{user}{screen_name};
		my $tweet = $decoded_json->{text};
		$output = "PRIVMSG $channel :Tweet de \x02\@$user\x02: $tweet";
		$output =~ s/\r|\n/ /g;
		print $sock "$output\r\n";
	} elsif ($input =~ /^ERROR\s:(.*)$/i) {
		print "ERROR: $1\n";
	}
}
