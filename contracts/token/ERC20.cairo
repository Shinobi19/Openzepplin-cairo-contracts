%lang starknet
%builtins pedersen range_check ecdsa

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.uint256 import (
    Uint256, uint256_add, uint256_sub, uint256_le, uint256_lt
)

#
# Storage
#

@storage_var
func balances(user: felt) -> (res: Uint256):
end

@storage_var
func allowances(owner: felt, spender: felt) -> (res: Uint256):
end

@storage_var
func total_supply() -> (res: Uint256):
end

@storage_var
func decimals() -> (res: felt):
end

#
# Constructor
#

@constructor
func constructor{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}(deployer: felt):
    decimals.write(18)
    _mint(deployer, Uint256(1000,0))
    return ()
end

#
# Getters
#

@view
func get_total_supply{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, 
        range_check_ptr} () -> (res : Uint256):
    let (res: Uint256) = total_supply.read()
    return (res)
end

@view
func get_decimals{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr} () -> (res: felt):
    let (res) = decimals.read()
    return (res)
end

@view
func balance_of{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr} (user: felt) -> (res: Uint256):
    let (res: Uint256) = balances.read(user=user)
    return (res)
end

@view
func allowance{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr} (owner: felt, spender: felt) -> (res: Uint256):
    let (res: Uint256) = allowances.read(owner=owner, spender=spender)
    return (res)
end

#
# Internals
#

func _mint{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr} (recipient: felt, amount: Uint256):
    alloc_locals

    let (res: Uint256) = balances.read(user=recipient)
    # the underscore is for the 1 bit carry
    let (local to_add, _: Uint256) = uint256_add(res, amount)
    balances.write(recipient, to_add)

    let (supply: Uint256) = total_supply.read()
    # the underscore is for the 1 bit carry
    let (local to_add, _: Uint256) = uint256_add(supply, amount)
    total_supply.write(to_add)
    return ()
end

func _transfer{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}(sender: felt, recipient: felt, amount: Uint256):
    alloc_locals    
    let (sender_balance: Uint256) = balances.read(user=sender)
    local sender_balance: Uint256 = sender_balance

    # reassign syscall_ptr and pedersen_ptr to avoid revocation
    local syscall_ptr: felt* = syscall_ptr
    local pedersen_ptr: HashBuiltin* = pedersen_ptr

    # validates amount <= sender_balance and returns 1 if true
    let (validate_le) = uint256_le(amount, sender_balance)
    # fails if validate_le == 0
    assert_not_zero(validate_le)

    # substract from sender
    let (new_sender_bal: Uint256) = uint256_sub(sender_balance, amount)
    balances.write(sender, new_sender_bal)

    # add to recipient
    let (recipient_bal: Uint256) = balances.read(user=recipient)
    let (new_recipient_bal, _: Uint256) = uint256_add(recipient_bal, amount)
    balances.write(recipient, new_recipient_bal)
    return ()
end

func _approve{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}(caller: felt, spender: felt, amount: Uint256):
    allowances.write(caller, spender, amount)
    return ()
end

#
# Externals
#

@external
func transfer{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}(recipient: felt, amount: Uint256):
    let (sender) = get_caller_address()
    _transfer(sender, recipient, amount)
    return ()
end

@external
func transfer_from{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}(sender: felt, recipient: felt, amount: Uint256):
    alloc_locals
    let (caller) = get_caller_address()
    local caller = caller

    let (caller_allowance: Uint256) = allowances.read(owner=sender, spender=caller)
    local caller_allowance: Uint256 = caller_allowance

    # reassign syscall_ptr and pedersen_ptr to avoid revocation
    local syscall_ptr: felt* = syscall_ptr
    local pedersen_ptr: HashBuiltin* = pedersen_ptr

    local amount: Uint256 = amount

    # validates amount <= caller_allowance and returns 1 if true   
    let (validate_le) = uint256_le(amount, caller_allowance)
    # fails if validate_le == 0
    assert_not_zero(validate_le)

    _transfer(sender, recipient, amount)

    # update allowance
    let (new_allowance: Uint256) = uint256_sub(caller_allowance, amount)
    allowances.write(sender, caller, new_allowance)
    return ()
end

@external
func approve{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}(spender: felt, amount: Uint256):
    let (caller) = get_caller_address()
    _approve(caller, spender, amount)
    return ()
end

@external
func increase_allowance{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}(spender: felt, added_value: Uint256):
    alloc_locals
    let (caller) = get_caller_address()
    local caller = caller

    let (current_allowance: Uint256) = allowances.read(caller, spender)

    local added_value: Uint256 = added_value

    # reassign syscall_ptr and pedersen_ptr to avoid revocation
    local syscall_ptr: felt* = syscall_ptr
    local pedersen_ptr: HashBuiltin* = pedersen_ptr

    let (new_allowance, _: Uint256) = uint256_add(current_allowance, added_value)
    local new_allowance: Uint256 = new_allowance

    # validates current_allowance < new_allowance and returns 1 if true   
    let (validate_lt) = uint256_lt(current_allowance, new_allowance)
    # fails if validate_lt == 0
    assert_not_zero(validate_lt)

    _approve(caller, spender, new_allowance)
    return()
end

@external
func decrease_allowance{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr} (spender: felt, subtracted_value: Uint256):
    alloc_locals
    let (caller) = get_caller_address()
    local caller = caller

    let (current_allowance: Uint256) = allowances.read(owner=caller, spender=spender)

    # reassign syscall_ptr and pedersen_ptr to avoid revocation
    local syscall_ptr: felt* = syscall_ptr
    local pedersen_ptr: HashBuiltin* = pedersen_ptr

    let (new_allowance: Uint256) = uint256_sub(current_allowance, subtracted_value)
    local new_allowance: Uint256 = new_allowance

    # validates new_allowance < current_allowance and returns 1 if true   
    let (validate_lt) = uint256_lt(new_allowance, current_allowance)
    ## fails if validate_lt == 0
    assert_not_zero(validate_lt)

    _approve(caller, spender, new_allowance)
    return()
end

