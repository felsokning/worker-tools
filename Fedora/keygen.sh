#!/usr/bin/env -S gpg2 --batch --expert --gen-key
# Brief: Generate ECC PGP keys for signing (primary key) & encryption (subkey)
# Run as: chmod +x gpg_ecc-25519_keygen; ./gpg_ecc-25519_keygen
# Ref: https://www.gnupg.org/documentation/manuals/gnupg/Unattended-GPG-key-generation.html

%echo "Generating ECC keys (sign & encr) with no-expiry"
  %no-protection
  Key-Type: EDDSA
    Key-Curve: ed25519
  Subkey-Type: ECDH
    Subkey-Curve: cv25519
  Name-Real: octoworker
  Expire-Date: 0
  # Now, let's do a commit here, so that we can later print "done" :-)
  %commit
%echo Done