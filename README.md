# Advanced Bash Script Security and Installation Guide

## Security Features

### 1. Multi-layer Encryption
- AES-256 (Rijndael) for primary data encryption
- Base64 encoding for special character protection
- QuotedPrintable encoding as additional layer
- UUencoding as final layer
- Random IV (Initialization Vector) for each encryption session

### 2. Anti-Debugging Measures
```bash
if [[ "${BASH_ARGV[0]}" =~ "bash -x" ]] || [[ "${BASH_ARGV[0]}" =~ "set -x" ]]; then
    echo "Debugging not allowed"
    exit 1
fi
trap '' DEBUG
```
- Prevents bash -x debugging
- Captures and deactivates DEBUG signals
- Detects debugging flags
- Runtime integrity checks

### 3. Variable Obfuscation
- Random variable names (12 characters: 8+4)
- Uses combination of letters, numbers, and symbols
- Preserves variable context and functionality
- Complex substitution patterns

### 4. Integrity Verification
- SHA-256 hashing implementation
- Script integrity verification
- Modification detection
- Runtime checksum validation

## Installation Instructions

### Termux Installation
```bash
# Update repository
pkg update && pkg upgrade

# Install dependencies
pkg install perl
pkg install make
pkg install clang

# Install CPAN
cpan

# Install required Perl modules
cpan MIME::Base64
cpan Digest::SHA  
cpan Crypt::CBC
cpan Crypt::Rijndael
cpan MIME::QuotedPrint
cpan Convert::UU
```

### Linux Installation
```bash
# Update repository
sudo apt update && sudo apt upgrade 

# Install Perl & dependencies
sudo apt install perl
sudo apt install build-essential
sudo apt install cpanminus

# Install required Perl modules
sudo cpanm MIME::Base64
sudo cpanm Digest::SHA
sudo cpanm Crypt::CBC  
sudo cpanm Crypt::Rijndael
sudo cpanm MIME::QuotedPrint
sudo cpanm Convert::UU
```

## Usage Guide

1. Set up the script:
```bash
chmod +x bash-obfuscator.pl
```

2. Basic command format:
```bash
./bash-obfuscator.pl -i <input_file> -o <output_file> [options]
```

3. Example with full security features:
```bash
./bash-obfuscator.pl -i script.sh -o secure.sh -E -K "password123" -S -C -F -M 3
```

### Command Options
- `-i` : Input bash script file
- `-o` : Encrypted output file
- `-E` : Enable multi-layer encryption
- `-K` : Encryption password/key
- `-S` : Add SHA-256 integrity check
- `-C` : Remove comments and blank lines
- `-F` : Flatten code (remove indentation)
- `-M` : Obfuscation method (1-3)

4. Minimal usage example:
```bash
./bash-obfuscator.pl -i script.sh -o secure.sh -E -K "mypassword"
```

## Security Levels

### Level 1 (Basic)
```bash
./bash-obfuscator.pl -i input.sh -o output.sh -C -F
```
- Basic obfuscation
- Comment and whitespace removal

### Level 2 (Medium)
```bash
./bash-obfuscator.pl -i input.sh -o output.sh -C -F -E -K "password" -M 2
```
- Basic encryption
- Medium variable obfuscation
- Basic anti-debugging

### Level 3 (Strong)
```bash
./bash-obfuscator.pl -i input.sh -o output.sh -C -F -E -K "password" -S -M 3
```
- Full encryption suite
- Maximum obfuscation
- Integrity verification
- Advanced anti-debugging
- Runtime protection

## Additional

1. Password Best Practices:
   - Minimum 16 characters
   - Mix of letters, numbers, symbols
   - Avoid dictionary words
   - Use unique passwords for each script

2. File Permissions:
```bash
chmod 700 secure.sh
```

3. Secure Original File Deletion:
```bash
shred -u script.sh
```

4. Key Management:
   - Never store passwords in scripts
   - Use environment variables for keys
   - Implement secure key rotation
   - Use different keys for each script

5. Runtime Security:
   - Implement memory clearing
   - Add timeout mechanisms
   - Include error handling
   - Log suspicious activities

## Advanced Protection Techniques

1. Environment Checks:
```bash
# Add to your scripts
if [[ "$(ps -e | grep -E "strace|ltrace|ptrace")" != "" ]]; then
    exit 1
fi
```

2. Memory Protection:
```bash
# Clear sensitive variables
unset password
export password=""
```

3. Timing Attack Prevention:
```bash
# Add random delays
sleep $(awk 'BEGIN{print rand()/2}')
```

4. System Integrity:
```bash
# Check for common analysis tools
if command -v gdb >/dev/null 2>&1; then
    exit 1
fi
```
1. **Installation First**
```bash
# For Termux
pkg update && pkg upgrade
pkg install perl make clang
cpan MIME::Base64 Digest::SHA Crypt::CBC Crypt::Rijndael MIME::QuotedPrint Convert::UU

# For Linux
sudo apt update && sudo apt upgrade
sudo apt install perl build-essential cpanminus
sudo cpanm MIME::Base64 Digest::SHA Crypt::CBC Crypt::Rijndael MIME::QuotedPrint Convert::UU
```

2. **Save The Obfuscator**
```bash
# Create file
nano bash-obfuscator.pl

# Paste the code from earlier
# Press CTRL + X, then Y to save

# Make executable
chmod +x bash-obfuscator.pl
```

3. **Create Test Script**
```bash
# Create sample bash script
cat > test.sh << 'EOF'
#!/bin/bash
name="John"
echo "Hello $name"
read -p "Enter age: " age
echo "You are $age years old"
EOF

chmod +x test.sh
```

4. **Basic Usage Examples**

a) Simple Obfuscation:
```bash
./bash-obfuscator.pl -i test.sh -o secure.sh -C -F
```

b) Medium Security:
```bash
./bash-obfuscator.pl -i test.sh -o secure.sh -E -K "mypassword123" -C
```

c) Maximum Security:
```bash
./bash-obfuscator.pl -i test.sh -o secure.sh -E -K "mypassword123" -S -C -F -M 3
```

5. **Options Explained**
```bash
-i : Input file (your original script)
-o : Output file (encrypted result)
-E : Enable encryption
-K : Your encryption key/password
-S : Add SHA-256 check
-C : Remove comments
-F : Remove spacing/formatting
-M : Security method (1-3)
```

6. **Testing The Result**
```bash
# Make output executable
chmod +x secure.sh

# Run encrypted script
./secure.sh
```

7. **Security Best Practices**
```bash
# Remove original after encryption
shred -u test.sh

# Set proper permissions
chmod 700 secure.sh

# Keep backup in safe location
cp test.sh /path/to/backup/
```

8. **Practical Example**

```bash
# Step 1: Create script
cat > myscript.sh << 'EOF'
#!/bin/bash
echo "Secret Program"
password="1234"
if [ "$1" == "$password" ]; then
    echo "Access Granted"
else
    echo "Access Denied"
fi
EOF

# Step 2: Test original
chmod +x myscript.sh
./myscript.sh 1234

# Step 3: Encrypt with maximum security
./bash-obfuscator.pl -i myscript.sh -o secure_script.sh -E -K "MySecretKey123!" -S -C -F -M 3

# Step 4: Test encrypted version
chmod +x secure_script.sh
./secure_script.sh 1234

# Step 5: Clean up
shred -u myscript.sh
```

9. **Troubleshooting**

If you get errors:
```bash
# Check perl installation
perl -v

# Check module installation
perl -MMIME::Base64 -e 'print "OK\n"'
perl -MDigest::SHA -e 'print "OK\n"'
perl -MCrypt::CBC -e 'print "OK\n"'

# Check file permissions
ls -l bash-obfuscator.pl
```

10. **Maintenance**
```bash
# Keep backup of original scripts
mkdir -p ~/script_backups
cp yourscript.sh ~/script_backups/

# Keep encryption keys safe
echo "Script: secure_script.sh, Key: MySecretKey123!" >> ~/keys.txt
chmod 600 ~/keys.txt
```

Remember:
- Always test encrypted script before deleting original
- Keep encryption keys secure
- Use strong passwords
- Make backups of important scripts
- Don't share encryption keys in script
