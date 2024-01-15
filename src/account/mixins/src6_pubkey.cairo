// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts for Cairo v0.8.0 (account/mixins/src6_pubkey.cairo)

#[starknet::component]
mod SRC6PubKeyMixin {
    use openzeppelin::account::AccountComponent::{PublicKeyImpl, PublicKeyCamelImpl};
    use openzeppelin::account::AccountComponent::{SRC6Impl, SRC6CamelOnlyImpl};
    use openzeppelin::account::AccountComponent;
    use openzeppelin::account::mixins::interface;
    use openzeppelin::introspection::src5::SRC5Component::SRC5Impl;
    use openzeppelin::introspection::src5::SRC5Component;
    use starknet::ContractAddress;
    use starknet::account::Call;

    #[storage]
    struct Storage {}

    #[embeddable_as(SRC6PubKeyMixinImpl)]
    impl SRC6PubKeyMixin<
        TContractState,
        +HasComponent<TContractState>,
        impl Account: AccountComponent::HasComponent<TContractState>,
        +SRC5Component::HasComponent<TContractState>,
        +Drop<TContractState>
    > of interface::ISRC6PubKeyMixin<ComponentState<TContractState>> {
        // ISRC6
        fn __execute__(
            self: @ComponentState<TContractState>, calls: Array<Call>
        ) -> Array<Span<felt252>> {
            let account = self.get_account();
            account.__execute__(calls)
        }

        fn __validate__(self: @ComponentState<TContractState>, calls: Array<Call>) -> felt252 {
            let account = self.get_account();
            account.__validate__(calls)
        }

        fn is_valid_signature(
            self: @ComponentState<TContractState>, hash: felt252, signature: Array<felt252>
        ) -> felt252 {
            let account = self.get_account();
            account.is_valid_signature(hash, signature)
        }

        // ISRC6CamelOnly
        fn isValidSignature(
            self: @ComponentState<TContractState>, hash: felt252, signature: Array<felt252>
        ) -> felt252 {
            let account = self.get_account();
            account.isValidSignature(hash, signature)
        }

        // IPublicKey
        fn get_public_key(self: @ComponentState<TContractState>) -> felt252 {
            let account = self.get_account();
            account.get_public_key()
        }

        fn set_public_key(ref self: ComponentState<TContractState>, new_public_key: felt252) {
            let mut account = get_dep_component_mut!(ref self, Account);
            account.set_public_key(new_public_key);
        }

        // IPublicKeyCamel
        fn getPublicKey(self: @ComponentState<TContractState>) -> felt252 {
            let account = self.get_account();
            account.getPublicKey()
        }

        fn setPublicKey(ref self: ComponentState<TContractState>, newPublicKey: felt252) {
            let mut account = get_dep_component_mut!(ref self, Account);
            account.setPublicKey(newPublicKey);
        }

        // ISRC5
        fn supports_interface(
            self: @ComponentState<TContractState>, interface_id: felt252
        ) -> bool {
            let contract = self.get_contract();
            let src5 = SRC5Component::HasComponent::<TContractState>::get_component(contract);
            src5.supports_interface(interface_id)
        }
    }

    #[generate_trait]
    impl GetDepImpl<
        TContractState,
        +HasComponent<TContractState>,
        +AccountComponent::HasComponent<TContractState>,
        +Drop<TContractState>
    > of GetDepTrait<TContractState> {
        fn get_account(
            self: @ComponentState<TContractState>
        ) -> @AccountComponent::ComponentState::<TContractState> {
            let contract = self.get_contract();
            AccountComponent::HasComponent::<TContractState>::get_component(contract)
        }
    }
}