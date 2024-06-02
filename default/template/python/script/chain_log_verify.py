#!/usr/bin/python3

import hashlib

# pollyanna chain.log verifier, mostly written by chatgpt4, minor corrections by ilyag
#
# The checksum hash input includes the entire previous line along with the current item's hash and timestamp.
# This chaining method ensures that each entry in the list is dependent not only on the item and timestamp
# but also on the complete state of the previous line, which adds an extra layer of integrity to the verification
# process.
#
# This method effectively makes your linked list more secure because any change in an earlier entry would cause a
# mismatch in all subsequent entries. It's a good strategy for ensuring the authenticity and integrity of the data
# in a sequential log or chain.


def compute_md5_hash(input_string):
	return hashlib.md5(input_string.encode()).hexdigest()

def verify_linked_list(file_path):
	with open(file_path, 'r') as file:
		previous_line = ''
		for line_number, line in enumerate(file, 1):
			parts = line.strip().split('|')
			if len(parts) != 3:
				print(f"Line {line_number} is malformed.")
				continue

			item_hash, timestamp, current_checksum = parts
			# For the first line, we have no previous checksum to include
			hash_input = f"{previous_line}|{item_hash}|{timestamp}"
			computed_checksum = compute_md5_hash(hash_input)

			if computed_checksum == current_checksum:
				print(f"Line {line_number}: OK")
			else:
				print(f"Line {line_number}: Error (computed hash does not match)")

			# Update previous_checksum for the next iteration
			previous_line = f"{item_hash}|{timestamp}|{current_checksum}"

# Path to the file containing the linked list
file_path = 'chain.log'
verify_linked_list(file_path)

