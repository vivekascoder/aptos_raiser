/**
Trying to write fundraiser contract in move lang.
**/


module aptos_raiser::fundraiser {
    use std::signer;
    use std::debug;
    use std::simple_map;
    use aptos_framework::aptos_account;
    use aptos_framework::system_addresses;
    use aptos_framework::aptos_coin::{Self, AptosCoin};
    use aptos_framework::coin::{Self, MintCapability};

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

    #[test(aptos_framework = @aptos_framework, a = @0xAAAA, person = @0xBBBB)]
    public fun test_fund_address(aptos_framework: signer, a: signer, person: signer) acquires Storage {
        let donate_amount = 100;

        // Register accounts.
        aptos_account::create_account(signer::address_of(&a));
        aptos_account::create_account(signer::address_of(&person));

        // Setup AptosCoin for testing.
        test_aptos_coin(&aptos_framework);

        // Allocate Storage.
        publish_storage(&person);

        // Give some test AptosCoin to `a`.
        aptos_coin::mint(&aptos_framework, signer::address_of(&a), donate_amount);

        debug::print(&coin::balance<AptosCoin>(signer::address_of(&a)));

        assert!(coin::balance<AptosCoin>(signer::address_of(&a)) > 0, 10);

        // a will give some funds.
        donate(&a, signer::address_of(&person), donate_amount);
    }
}

