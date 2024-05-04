for f in `find -type f | grep sh$`; do sed -i -e 's/\r$//' $f; done # fix windows line endings in shell scripts
