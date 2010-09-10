#!/bin/bash

openssl pkcs12 -clcerts -nokeys -out cert.pem -in Certificate.p12
openssl pkcs12 -nocerts -out key.pem -in Certificate.p12
cat cert.pem key.pem > ck.pem