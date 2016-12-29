#!/usr/bin/perl
use strict;

use IO::Socket;
use Net::DHCP::Packet;
use Net::DHCP::Constants;

######## La ip del server:
my $server_ip = "10.10.10.176";
my $gateway = "10.10.10.1";
my $dnserver = "8.8.8.8";
my $subnet_mask = "255.255.255.0";

my %mac_a_ip = ();

# Decodificador Telecentro
$mac_a_ip{"b0b28f232fc900000000000000000000"} = "10.10.10.200";
# Maquina VM trabajo
$mac_a_ip{"080027ddbbf100000000000000000000"} = "10.10.10.55";

my $socket_in = IO::Socket::INET->new(
	LocalPort => 67,
	LocalAddr => "255.255.255.255",
	Proto    => 'udp') or die $@;

while(1) {
	my $buf;
	print "Waiting...";
	$socket_in->recv($buf,4096);
	my $packet = new Net::DHCP::Packet($buf);
	my $messagetype = $packet->getOptionValue(DHO_DHCP_MESSAGE_TYPE());
	print "Received:\n";
	print $packet->toString();

	if ($messagetype eq DHCPDISCOVER()) {
		send_offer($packet);
	} elsif ($messagetype eq DHCPREQUEST()) {
		$packet->comment(1);
		send_ack($packet);
	}
}

sub send_offer {
	my($request)=@_;
	print "-------- Envio mi oferta ---------\n";
	my $which_machine = $request->chaddr;
	my $client_ip = $mac_a_ip{"$which_machine"};
	print "A $which_machine Ofrezco IP: $client_ip [Servidor: $server_ip:67]\n";
	my $socket_out = IO::Socket::INET->new(
		PeerPort => 68,
		PeerAddr => "255.255.255.255",
		LocalAddr => "$server_ip:67",
		Broadcast => 1,
		Proto    => 'udp') or die $@;

	my $offer = new Net::DHCP::Packet(
                                     Op => BOOTREPLY(),
                                     Xid => $request->xid(),
                                     Flags => $request->flags(),
                                     Ciaddr => $request->ciaddr(),
                                     Yiaddr => $client_ip,
                                     Siaddr => $server_ip,
                                     Giaddr => $request->giaddr(),
                                     Chaddr => $request->chaddr(),
                                     DHO_DHCP_MESSAGE_TYPE() => DHCPOFFER(),
                                   );
	$offer->addOptionValue(DHO_DHCP_LEASE_TIME, 84600);
	$offer->addOptionValue(DHO_DOMAIN_NAME_SERVERS, $dnserver);
	$offer->addOptionValue(DHO_ROUTERS, $gateway);
	$offer->addOptionValue(DHO_SUBNET_MASK(), $subnet_mask);
	$offer->addOptionValue(DHO_NAME_SERVERS, $server_ip);
	$offer->addOptionValue(DHO_DHCP_LEASE_TIME, 100);
	print $offer->toString();
	$socket_out->send($offer->serialize()) or die $!;
}

sub send_ack {
	my ($request) = @_;
	print "-------- Envio ACK ---------\n";
	my $which_machine = $request->chaddr;
	my $client_ip = $mac_a_ip{"$which_machine"};
	print "A $which_machine ACK de IP: $client_ip [Servidor: $server_ip:67]\n";
	my $socket_out = IO::Socket::INET->new(
		PeerPort => 68,
		PeerAddr => "255.255.255.255",
		LocalAddr => "$server_ip:67",
		Broadcast => 1,
		Proto    => 'udp') or die $@;

	$request = Net::DHCP::Packet->new(
            Comment                 => $request->comment(),
            Op                      => BOOTREPLY(),
            Hops                    => $request->hops(),
            Xid                     => $request->xid(),
            Flags                   => $request->flags(),
            Ciaddr                  => $request->ciaddr(),
            Yiaddr                  => $client_ip,
            Siaddr                  => $request->siaddr(),
            Giaddr                  => $request->giaddr(),
            Chaddr                  => $request->chaddr(),
            DHO_DHCP_MESSAGE_TYPE() => DHCPACK(),
        );

	$request->addOptionValue(DHO_DHCP_LEASE_TIME, 84600);
	$request->addOptionValue(DHO_DOMAIN_NAME_SERVERS, $dnserver);
	$request->addOptionValue(DHO_SUBNET_MASK(), $subnet_mask);
	$request->addOptionValue(DHO_ROUTERS, $gateway);
	$socket_out->send($request->serialize()) or die $!;
	print STDERR "send ack\n";
}

