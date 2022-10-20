# Aptos fund raiser application

## Things to so today.

- [ ] A resource account will keep the funds.
- [ ] Users should be able to claim their funds from this resource account.
- [ ] Deploy the contracts.

## Error that I'm getting for the test `test_fund_address`.

```
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING aptos_raiser
Running Move unit tests
[ FAIL    ] 0x4::fundraiser::test_fund_address

Test failures:

Failures in 0x4::fundraiser:

┌── test_fund_address ──────
│ ITE: An unknown error was reported. Location: error[E11001]: test failure
│     ┌─ /Users/vivekascoder/.move/https___github_com_aptos-labs_aptos-core_git_main/aptos-move/framework/aptos-framework/sources/account.move:492:23
│     │
│ 491 │     public(friend) fun register_coin<CoinType>(account_addr: address) acquires Account {
│     │                        ------------- In this function in 0x1::account
│ 492 │         let account = borrow_global_mut<Account>(account_addr);
│     │                       ^^^^^^^^^^^^^^^^^
│
│
│ VMError (if there is one): VMError {
│     major_status: MISSING_DATA,
│     sub_status: None,
│     message: None,
│     exec_state: None,
│     location: Module(
│         ModuleId {
│             address: 0000000000000000000000000000000000000000000000000000000000000001,
│             name: Identifier(
│                 "account",
│             ),
│         },
│     ),
│     indices: [],
│     offsets: [
│         (
│             FunctionDefinitionIndex(24),
│             1,
│         ),
│     ],
│ }
└──────────────────

Test result: FAILED. Total tests: 1; passed: 0; failed: 1
{
  "Error": "Move unit tests failed"
}
```
