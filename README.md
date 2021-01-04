# Escrow-smart-contract

# Requirement!

The purpose of the smart contract is to act as an escrow account between a buyer and a seller and in case of any dispute, there is a judge who can resolve the issue, provided both the parties have paid the fees of judge- Contract has an judge (who is contract owner), judge fees, dispute time, buyer, seller

- Buyer sends money to contract which is withdrawable by seller after x seconds
- After x seconds, seller can withdraw funds in case there is no dispute
- Before x seconds, buyer can  raise a dispute by paying judge fees
- When there is a dispute, both buyer and seller have to pay judge's fee before dispute time
- If seller does not pay fee, then buyer wins and receives fees+amount
- If buyer and seller pay fee then judge decides who wins
- Funds are withdrawable by the winner
	- Considering fee collected by Judge from both parties kept by Judge.
- Judge fees is withdrawable by judge.

Create contrcat BY passing
- Buyer
- Seller
- Dispute time in Seconds
- Dispute fee in wei

Cases To Tested

Case 1
1. Buyer send funds to contrcat.
2. Buyer raise dispute before Dispute expiry time.
3. Seller pay fee fot Judement.
4. Judge give winner address.
5. If buyer winner funds transfer to buyer.
6. If seller winner seller can withdraw funds any time.

Case 2
1. Buyer send funds to contrcat.
2. Buyer raise dispute before Dispute expiry time.
3. Seller didn't pay fee.
4. Judge refund the amount and fee to buyer.

Case 3

1. Seller withdraw funds.
2. Judge withdraw fees.

