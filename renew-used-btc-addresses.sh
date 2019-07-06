#!/usr/bin/env bash

if [ "$1" == "" ]; then
    echo "Usage: $(basename $0) filename"
    echo ""
    echo "Will grep for BTC addresses in a file, check if they are used, and,"
    echo "for each address, if it is, generate new address of the same type"
    echo "(P2PKH, P2SH-SegWit or Bech32), and replace it in a file. Then do"
    echo "git add, commit and push."
    echo "Will ignore addresses not belonging to a Bitcoin Core wallet accessible"
    echo "by default XML-RPC configuration (~/.bitcoin/bitcoin.conf)."
    exit
fi

directory="$(dirname "$1")"
filename="$(basename "$1")"

cd "$directory" || exit 1

if [ ! -f "$filename" ]; then
    echo "$directory/$filename does not exist"
    cd - > /dev/null
    exit 1
fi

grep -o "\([13][a-km-zA-HJ-NP-Z1-9]\{25,39\}\|bc1[a-z0-9]\{8,87\}\|BC1[A-Z0-9]\{8,87\}\)" "$filename" | sort | uniq | while read address; do
    balance=$(bitcoin-cli getreceivedbyaddress $address 2> /dev/null)
    if [ "$balance" != "" ] && [ "$balance" != "0.00000000" ]; then
        if grep -qs "^3" <<< "$address"; then
            address_type="p2sh-segwit"
        elif grep -qs "^bc1" <<< "$address"; then
            address_type="bech32"
        else
            address_type="legacy"
        fi
        new_address=$(bitcoin-cli getnewaddress "" $address_type 2> /dev/null)
        if [ "$new_address" != "" ]; then
            git pull > /dev/null
            echo "Replacing used BTC address $address to $new_address in $directory/$filename"
            sed -i "s/$address/$new_address/g" "$filename"
        fi
    fi
done

if [ "$(git diff --raw "$filename" | wc -l)" != "0" ]; then
    git add "$filename"
    git commit -m "Renew used BTC address"
    git push
fi

cd - > /dev/null

