neofetch | lolcat
/keygen.sh
fingerprint=$(gpg2 --list-keys | grep -Po '\w{20,}')
echo "Using Fingerpint: $fingerprint"
pass init $(echo $fingerprint)