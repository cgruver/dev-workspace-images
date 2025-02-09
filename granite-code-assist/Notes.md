openssl s_client -showcerts -servername ollama-granite-code-assist.apps.region-01.clg.lab -connect ollama-granite-code-assist.apps.region-01.clg.lab:443 </dev/null 2>/dev/null | openssl x509 -outform PEM > /projects/ocp-cert.pem

