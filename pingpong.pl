# Código en el dominio público

use strict;
use Crypt::OpenSSL::AES;
use MIME::Base64;
use Digest::MD5;

our $private_key = "DKAE2jDQUpC4AvQgqTDRaniTBQCiMrDE1aNU";

sub our_encode_base64 {
	my $tmp = encode_base64(@_[0]);
	$tmp =~ s/\+/[/g;
	$tmp =~ s/\//]/g;
	$tmp;
}

sub our_decode_base64 {
	my $tmp = @_[0];
	$tmp =~ s/\[/+/g;
	$tmp =~ s/\]/\//g;
	$tmp = decode_base64($tmp);
	$tmp;
}

sub descifrar {
	my $d_ping = our_decode_base64(@_[0]);
	my $d_key = our_decode_base64(@_[1]);

	my $tmp_key = substr($d_key, 0, 24).substr($d_ping, 0, 8);
	my $tmp_msg = substr($d_ping, 8, 16);
	my $aes_ctx_1 = new Crypt::OpenSSL::AES($tmp_key);
	my $tmp_msg = uc $aes_ctx_1->decrypt($tmp_msg);

	my $random = substr(Digest::MD5::md5_hex(rand), 0, 8);
	$tmp_key = substr($tmp_key, 0, 24).$random;
	my $aes_ctx_2 = new Crypt::OpenSSL::AES($tmp_key);
	$tmp_msg = $aes_ctx_2->encrypt($tmp_msg);

	my $pong = $random.substr($tmp_msg, 0, 16);

	our_encode_base64($pong);
}

print "Uso: $0 [ping cifrado]\nEjemplo: $0 NYpg0VoE13CbcyvqjoVQqs65bG9E4xFJ\n"
	and exit unless $ARGV[0] =~ m/^(PING\s)?:?[a-zA-Z0-9\[\]]{32}$/;

my $ping = $ARGV[0];
$ping =~ s/^(PING\s)?:?//;
print "PONG :".descifrar($ping, $private_key);