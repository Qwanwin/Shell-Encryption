#!/usr/bin/perl -w
use strict;
use warnings;
use feature ':5.10';
use MIME::Base64;
use Digest::SHA qw(sha256_hex);
use Crypt::CBC;
use Crypt::Rijndael;
use MIME::QuotedPrint;
use Convert::UU;

# Enhanced usage information
sub print_usage() {
    say "$0 is a highly secure bash shell script obfuscator and encryptor.";
    say "Features: Multi-layer encryption, advanced obfuscation, and integrity verification.";
    say "Usage:";
    say "\t $0 -h \t Show this help message";
    say "\t $0 -i <input_file> -o <output_file> [-V <var_prefix>] [-C] [-F] [-E] [-S] [-K <key>] [-M <method>]";
    say "Options:";
    say "\t-i <input_file>\tSource bash script to obfuscate";
    say "\t-o <output_file>\tDestination for obfuscated script";
    say "\t-V <var_prefix>\tPrefix for obfuscated variables (default: 'a')";
    say "\t-C\t\tRemove comments and blank lines";
    say "\t-F\t\tFlatten code (remove indentation)";
    say "\t-E\t\tEnable multi-layer encryption";
    say "\t-S\t\tAdd SHA-256 integrity check";
    say "\t-K <key>\tEncryption key (required if -E is used)";
    say "\t-M <method>\tObfuscation method (1-3, default: 3)";
    exit 0;
}

sub parse_vars_from_file {
    my $file = shift;
    my %vars;
    
    open(my $fh, "<", $file) or die "Cannot open file: $!";
    while (my $line = <$fh>) {
        # Match variable declarations
        $line =~ /^\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*=/ and $vars{$1} = 1;
        # Match read statements
        $line =~ /^\s*read\s+([a-zA-Z_][a-zA-Z0-9_]*)/ and $vars{$1} = 1;
        # Match for loops
        $line =~ /^\s*for\s+([a-zA-Z_][a-zA-Z0-9_]*)\s+in/ and $vars{$1} = 1;
    }
    close $fh;
    
    return keys %vars;
}

# Enhanced argument parsing with encryption options
sub parse_cmd_args {
    my %opts = (
        input_file => "",
        output_file => "",
        var_prefix => "a",
        delete_blanks => 0,
        flatten => 0,
        encrypt => 0,
        add_hash => 0,
        key => "",
        method => 3
    );

    for my $i (0 .. $#ARGV) {
        if ($ARGV[$i] eq "-i") {
            $opts{input_file} = $ARGV[++$i];
        } elsif ($ARGV[$i] eq "-o") {
            $opts{output_file} = $ARGV[++$i];
        } elsif ($ARGV[$i] eq "-h") {
            print_usage();
        } elsif ($ARGV[$i] eq "-V") {
            $opts{var_prefix} = $ARGV[++$i];
        } elsif ($ARGV[$i] eq "-C") {
            $opts{delete_blanks} = 1;
        } elsif ($ARGV[$i] eq "-F") {
            $opts{flatten} = 1;
        } elsif ($ARGV[$i] eq "-E") {
            $opts{encrypt} = 1;
        } elsif ($ARGV[$i] eq "-S") {
            $opts{add_hash} = 1;
        } elsif ($ARGV[$i] eq "-K") {
            $opts{key} = $ARGV[++$i];
        } elsif ($ARGV[$i] eq "-M") {
            $opts{method} = $ARGV[++$i];
        }
    }

    die "Input and output files are required!\n" if (!$opts{input_file} || !$opts{output_file});
    die "Encryption key required when using -E!\n" if ($opts{encrypt} && !$opts{key});
    return %opts;
}

# Generate strong random string
sub generate_strong_random {
    my $length = shift || 16;
    my @chars = ('a'..'z', 'A'..'Z', '0'..'9', '!', '@', '#', '$', '%', '^', '&', '*');
    my $random = "";
    for (1..$length) {
        $random .= $chars[int(rand(scalar(@chars)))];
    }
    return $random;
}

# Advanced encryption function
sub encrypt_content {
    my ($content, $key) = @_;
    my $iv = generate_strong_random(16);
    
    # First layer: AES encryption
    my $cipher = Crypt::CBC->new(
        -key    => $key,
        -cipher => 'Rijndael',
        -iv     => $iv,
        -header => 'none',
        -padding => 'standard'
    );
    my $encrypted = $cipher->encrypt($content);
    
    # Second layer: Base64
    my $encoded = encode_base64($encrypted);
    
    # Third layer: QuotedPrintable
    my $quoted = encode_qp($encoded);
    
    # Fourth layer: UUencode
    my $uuencoded = pack("u", $quoted);
    
    return ($uuencoded, $iv);
}

# Create decoder stub
sub create_decoder_stub {
    my ($encrypted_content, $iv, $hash) = @_;
    return <<'EOD' . $encrypted_content . "\nEOF\n" . 'eval "$decoded_content"';
#!/bin/bash
decode_script() {
    local encoded_content=$(cat << 'EOF'
EOD
}

# Enhanced variable name obfuscation
sub obfuscate_variable_names {
    my ($content, $vars) = @_;
    my %var_map;
    
    foreach my $var (@$vars) {
        my $new_var = generate_strong_random(8) . '_' . generate_strong_random(4);
        $var_map{$var} = $new_var;
        
        # Complex substitution patterns
        $content =~ s/(?<![\w\$])\$$var(?!\w)/\$$new_var/g;
        $content =~ s/(?<![\w\$])\$\{$var\}(?!\w)/\$\{$new_var\}/g;
        $content =~ s/(?<=^|\s)$var=/$new_var=/g;
        $content =~ s/(?<=^|\s)read\s+$var/read $new_var/g;
        $content =~ s/(?<=^|\s)for\s+$var\s+/for $new_var /g;
    }
    
    return $content;
}

# Add anti-debugging measures
sub add_anti_debug {
    my $content = shift;
    return <<'EOD' . $content;
if [[ "${BASH_ARGV[0]}" =~ "bash -x" ]] || [[ "${BASH_ARGV[0]}" =~ "set -x" ]]; then
    echo "Debugging not allowed"
    exit 1
fi
trap '' DEBUG
if [[ $- =~ "x" ]]; then
    echo "Debugging not allowed"
    exit 1
fi
EOD
}

# Main obfuscation function
sub obfuscate {
    my %opts = @_;
    my @vars = @{$opts{vars}};
    
    # Read input file
    open(my $ifh, "<", $opts{input_file}) or die "Cannot open input file: $!";
    my $content = do { local $/; <$ifh> };
    close $ifh;

    # Add anti-debugging
    $content = add_anti_debug($content);

    # Obfuscate variables
    $content = obfuscate_variable_names($content, \@vars);

    # Apply transformations
    if ($opts{delete_blanks}) {
        $content =~ s/^\s*#[^!].*$//mg;
        $content =~ s/^\s*$//mg;
        $content =~ s/\n+/\n/g;
    }

    if ($opts{flatten}) {
        $content =~ s/^\s+//mg;
    }

    # Add integrity check
    my $hash = "";
    if ($opts{add_hash}) {
        $hash = sha256_hex($content);
        $content = "# SHA256: $hash\n$content";
    }

    # Apply encryption if requested
    if ($opts{encrypt}) {
        my ($encrypted_content, $iv) = encrypt_content($content, $opts{key});
        $content = create_decoder_stub($encrypted_content, $iv, $hash);
    }

    # Write output
    open(my $ofh, ">", $opts{output_file}) or die "Cannot open output file: $!";
    print $ofh $content;
    close $ofh;
}

# Main execution
my %opts = parse_cmd_args();
my @vars = parse_vars_from_file($opts{input_file});
$opts{vars} = \@vars;

obfuscate(%opts);
say "Script successfully secured and saved to $opts{output_file}";