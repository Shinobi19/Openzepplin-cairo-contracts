// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts for Cairo v0.3.2 (account/IAccount.cairo)

%lang starknet

from openzeppelin.account.library import AccountCallArray

@contract_interface
namespace IAccount {
    //
    // Business logic
    //

    func is_valid_signature(hash: felt, signature_len: felt, signature: felt*) -> (is_valid: felt) {
    }

    func __validate__(
        call_array_len: felt, call_array: AccountCallArray*, calldata_len: felt, calldata: felt*
    ) {
    }

    func __validate_declare__(class_hash: felt) {
    }

    func __execute__(
        call_array_len: felt, call_array: AccountCallArray*, calldata_len: felt, calldata: felt*
    ) -> (response_len: felt, response: felt*) {
    }
}
