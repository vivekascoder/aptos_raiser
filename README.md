# Aptos fund raiser application

## Things to so today.

- [ ] A resource account will keep the funds.
- [ ] Users should be able to claim their funds from this resource account.
- [ ] Deploy the contracts.

## How to publish ?

```bash
aptos move publish --named-addresses aptos_raiser=default --estimate-max-gas
```

## Deployed info

```json
{
  "Result": {
    "transaction_hash": "0xd0d2a57b5bb38b63690b87c8958f56eb6a691cbc9c8fc09a9ff4b1ce266a06e8",
    "gas_used": 7764,
    "gas_unit_price": 100,
    "sender": "3b3f1ebdfed349c2c5dd79e06b942ec1de07818232a69e75379738557d476679",
    "sequence_number": 1,
    "success": true,
    "timestamp_us": 1666264815182729,
    "version": 12272151,
    "vm_status": "Executed successfully"
  }
}
```
