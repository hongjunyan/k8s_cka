mkdir ca_side
mkdir server_side

# ------------ CA side ----------------------------
# Create a CA private key
openssl genrsa -out ca_side/ca.key 4096

# Generate CA certificate
openssl req -x509 -new -nodes -sha512 -days 3650 \
 -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=yourdomain.com" \
 -key ca_side/ca.key \
 -out ca_side/ca.crt

# ------------ Our Server side---------------------
# Generate a private key
openssl genrsa -out server_side/slave1.key 4096

# Use private key to crate a CSR
openssl req -sha512 -new \
    -subj "/C=TW/ST=Taipei/L=Taipei/O=sysjust/OU=personal/CN=slave1" \
    -key server_side/slave1.key \
    -out server_side/slave1.csr

# Show public key and subject (https://www.shellhacks.com/decode-csr/)
echo 'Public Key:'
openssl req -in server_side/slave1.csr -noout -pubkey
echo 'Subject:'
openssl req -in server_side/slave1.csr -noout -subject

# ----------- CA side --------------------------
# Generate X509 v3 extension file
cat > ca_side/x509_v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=slave1
DNS.2=slave1.com
EOF

# Use X509_v3.ext file to generate a certificate(slave1.crt) for slave1 host
openssl x509 -req -sha512 -days 3650 \
    -extfile ca_side/x509_v3.ext \
    -CA ca_side/ca.crt -CAkey ca_side/ca.key -CAcreateserial \
    -in server_side/slave1.csr \
    -out server_side/slave1.crt

# Copy certificate and server private key to harbor data dir
sudo mkdir -p /data/cert
sudo cp server_side/slave1.crt /data/cert/
sudo cp server_side/slave1.key /data/cert/

