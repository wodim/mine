# Código en el dominio público

use strict;
use Crypt::OpenSSL::AES;

# estas dos funciones son basadas en http://www.perlmonks.org/bare/?node_id=524331
# no puedo usar MIME::Base64 porque en hispano son muy especialitos y tienen
# que usar un base64 modificado
sub encode_base64 {
	my $s = shift;
	my $r = "";
	while ($s =~ /(.{1,45})/gs) {
		chop($r .= substr(pack("u", $1), 1));
	}
	my $pad = (3 - length($s)%3)%3;
	$r =~ tr|` -_|AA-Za-z0-9\[\]|;
	$r =~ s/.{$pad}$/"="x$pad/e if $pad;
	$r =~ s/(.{1,72})/$1\n/g;
	$r;
}

sub decode_base64 {
	my $d = shift;
	$d =~ tr!A-Za-z0-9\[\]!!cd;
	$d =~ s/=+$//;
	$d =~ tr!A-Za-z0-9\[\]! -_!;
	my $r = '';
	while ($d =~ /(.{1,60})/gs){
		my $len = chr(32 + length($1) * 3 / 4);
		$r .= unpack("u", $len.$1);
	}
	$r;
}

sub descifrar {
	# 0: ping
	# 1: key

	my $d_ping = decode_base64 @_[0];
	my $d_key = decode_base64 @_[1];

	my $tmp_key = substr($d_key, 0, 24).substr($d_ping, 0, 8);
	my $tmp_msg = substr($d_ping, 8, 16);
	my $aes_ctx_1 = new Crypt::OpenSSL::AES($tmp_key);
	my $tmp_msg = uc $aes_ctx_1->decrypt($tmp_msg);

	# debería ser al azar y no esta mierda, pero bueno.
	my $random = "aqualung";
	$tmp_key = substr($tmp_key, 0, 24).$random;
	my $aes_ctx_2 = new Crypt::OpenSSL::AES($tmp_key);
	$tmp_msg = $aes_ctx_2->encrypt($tmp_msg);

	my $pong = $random.substr($tmp_msg, 0, 16);

	encode_base64 $pong;
}

my $ping = $ARGV[0];
$ping =~ s/^:?//;
print "PONG :".descifrar($ping,
	"DKAE2jDQUpC4AvQgqTDRaniTBQCiMrDE1aNU");