# Renew used BTC addresses in GIT

Will grep for BTC addresses in a file, check if they are used, and,
for each address, if it is, generate new address of the same type
(P2PKH, P2SH-SegWit or Bech32), and replace it in a file. Then do
git add, commit and push.

Will ignore addresses not belonging to a Bitcoin Core wallet accessible
by default XML-RPC configuration (`~/.bitcoin/bitcoin.conf`).

