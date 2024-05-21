INSERT INTO remote_addr_ip_log (
	file_hash,
	remote_addr,
	first_three_octets,
	first_two_octets
) VALUES (
	?, ?, ?, ?
)