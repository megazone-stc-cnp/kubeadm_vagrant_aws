#! /usr/bin/env bash

sh ./ubuntu_commons.sh node1

cat > $HOME/run.sh <<EOF
aws s3 cp ${S3_BUCKET_PATH}/token.join token.sh
chmod +x token.sh
sh token.sh
EOF

chmod +x $HOME/run.sh