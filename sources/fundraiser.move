/**
Trying to write fundraiser contract in move lang.
**/


module aptos_raiser::fundraiser {
    use std::signer;
    use aptos_framework::system_addresses;
    use aptos_framework::aptos_coin::{Self, AptosCoin};
    use aptos_framework::coin::{Self, MintCapability};
    use std::simple_map;

    const ERROR_ALREADY_STORAGE_RESOURCE: u64 = 0;

    struct Storage has key, store {
        value: u64,
        ledger: simple_map::SimpleMap<address, u64>
    }

    /// Publish `Storage` to `sender`.
    public fun publish_storage(sender: &signer) {
        // Make sure the `sender` already doesn't have the `Storage` resource.
        assert!(!exists<Storage>(signer::address_of(sender)), ERROR_ALREADY_STORAGE_RESOURCE);

        move_to(sender, Storage {value: 0, ledger: simple_map::create<address,u64>()});
    }

    public fun donate(sender: &signer, to: address, amount: u64) acquires Storage{
        // `to` should have the `Storage` resource.
        assert!(exists<Storage>(to), ERROR_ALREADY_STORAGE_RESOURCE);

        // Transfer `amount` Octa to `to` from `sender`
        coin::transfer<AptosCoin>(sender, to, amount);

        // Increment the state.
        let to_storage = borrow_global_mut<Storage>(to);
        to_storage.value = to_storage.value + amount;

        if (simple_map::contains_key<address, u64>(&to_storage.ledger, &signer::address_of(sender)) ){
            // Get the value.
            let val = simple_map::borrow_mut(&mut to_storage.ledger, &signer::address_of(sender));

            // Increment the value.
            *val = amount + *val;
        } else {
            simple_map::add(&mut to_storage.ledger, signer::address_of(sender), amount);
        }
    }

    public fun get_raised_amount(addr: address): u64 acquires Storage {
        borrow_global<Storage>(addr).value
    }



    struct AptosCoinCapabilities has key {
        mint_cap: MintCapability<AptosCoin>,
    }

    /// This is only called during Genesis, which is where MintCapability<AptosCoin> can be created.
    /// Beyond genesis, no one can create AptosCoin mint/burn capabilities.
    public(friend) fun store_aptos_coin_mint_cap(aptos_framework: &signer, mint_cap: MintCapability<AptosCoin>) {
        system_addresses::assert_aptos_framework(aptos_framework);
        move_to(aptos_framework, AptosCoinCapabilities { mint_cap })
    }


    #[test_only]
    public fun test_aptos_coin(
        aptos_framework: &signer
    ) {
        let (burn_cap, mint_cap) = aptos_coin::initialize_for_test(aptos_framework);
        store_aptos_coin_mint_cap(aptos_framework, mint_cap);
        coin::destroy_burn_cap<AptosCoin>(burn_cap);
    }

    // This function assumes the stake module already the capability to mint aptos coins.
    #[test_only]
    public fun mint_coins(amount: u64): coin::Coin<AptosCoin> acquires AptosCoinCapabilities {
        let mint_cap = &borrow_global<AptosCoinCapabilities>(@aptos_framework).mint_cap;
        coin::mint(amount, mint_cap)
        // Returns Coin<AptosCoin> {value: u64}
    }

    #[test_only]
    public fun mint(account: &signer, amount: u64) acquires AptosCoinCapabilities {
        let account_address = signer::address_of(account);
        if (!coin::is_account_registered<AptosCoin>(account_address)) {
            coin::register<AptosCoin>(account);
        };

        coin::deposit(account_address, mint_coins(amount));
    }


    #[test(aptos_framework = @aptos_framework, a = @0xAAAA, person = @0xBBBB)]
    public fun test_fund_address(aptos_framework: signer, a: signer, person: signer) acquires Storage {
        test_aptos_coin(&aptos_framework);
        coin::register<AptosCoin>(&a);

        let donate_amount = 100;
        // Allocate Storage.
        publish_storage(&person);

        // Give some test AptosCoin to `a`.
        aptos_coin::mint(&aptos_framework, signer::address_of(&a), donate_amount);

        assert!(coin::balance<AptosCoin>(signer::address_of(&a)) > 0, 10);

        // a will give some funds.
        donate(&a, signer::address_of(&person), donate_amount);
    }
}

