use array::SpanTrait;
use array::ArrayTrait;
use core::result::ResultTrait;
use option::OptionTrait;
use starknet::ContractAddress;
use starknet::Felt252TryIntoContractAddress;
use starknet::SyscallResultTrait;
use starknet::call_contract_syscall;
use traits::Into;
use traits::TryInto;

use openzeppelin::utils::try_selector_with_fallback;
use openzeppelin::utils::Felt252TryIntoBool;
use openzeppelin::utils::selectors;

#[derive(Copy, Drop)]
struct DualCaseOwnable {
    contract_address: ContractAddress
}

trait DualCaseOwnableTrait {
    fn owner(self: @DualCaseOwnable) -> ContractAddress;
    fn transfer_ownership(self: @DualCaseOwnable, new_owner: ContractAddress);
    fn renounce_ownership(self: @DualCaseOwnable);
}

impl DualCaseOwnableImpl of DualCaseOwnableTrait {
    fn owner(self: @DualCaseOwnable) -> ContractAddress {
        (*call_contract_syscall(*self.contract_address, selectors::owner, ArrayTrait::new().span())
            .unwrap_syscall()
            .at(0))
            .try_into()
            .unwrap()
    }

    fn transfer_ownership(self: @DualCaseOwnable, new_owner: ContractAddress) {
        let snake_selector = selectors::transfer_ownership;
        let camel_selector = selectors::transferOwnership;

        let mut args = ArrayTrait::new();
        args.append(new_owner.into());

        try_selector_with_fallback(
            *self.contract_address, snake_selector, camel_selector, args.span()
        )
            .unwrap_syscall();
    }

    fn renounce_ownership(self: @DualCaseOwnable) {
        let snake_selector = selectors::renounce_ownership;
        let camel_selector = selectors::renounceOwnership;

        let mut args = ArrayTrait::new();

        try_selector_with_fallback(
            *self.contract_address, snake_selector, camel_selector, args.span()
        )
            .unwrap_syscall();
    }
}
