sub colorize_hash {
    my $input_hash = shift;

    # Validate the input hash
    unless ($input_hash =~ /^[0-9a-fA-F]+$/ && length($input_hash) % 2 == 0) {
        die "Invalid input hash format";
    }

    my $colorized_output = '';
    my @colors = (
        "#1f78b4", "#33a02c", "#e31a1c", "#ff7f00", "#6a3d9a", "#b15928", "#a6cee3", "#b2df8a",
        "#fb9a99", "#fdbf6f", "#cab2d6", "#ffff99", "#8da0cb", "#d9d9d9", "#bc80bd", "#ccebc5"
    );

    for my $i (0 .. (length($input_hash) / 2) - 1) {
        my $segment = substr($input_hash, $i * 2, 2);
        my $color = $colors[$i % @colors];
        $colorized_output .= qq|<font color="$color">$segment</font>|;
    }

    return $colorized_output;
}

# Example usage:
my $hash_input = "aabbccddeeff0011";
my $result = colorize_hash($hash_input);
print $result;
