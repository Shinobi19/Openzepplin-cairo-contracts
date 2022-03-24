# SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_le
from openzeppelin.utils.constants import TRUE, FALSE
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_signed_nn_le,
    uint256_sub
)
from starkware.starknet.common.syscalls import (
    get_contract_address)
from openzeppelin.security.reentrancy_guard import (  
    ReentrancyGuard_start,
    ReentrancyGuard_end
)

@contract_interface
namespace ISafeMath:
    func uint256_checked_sub_le(a: Uint256, b: Uint256) -> (c: Uint256):
    end
end

@contract_interface
namespace IReentrancyGuardAttacker:
    func callSender(data : felt):
    end
end

@contract_interface
namespace IReentrancyGuard:
    func countThisRecursive(n : felt):
    end
end

@storage_var
func counter() -> (res : felt):  
end

@storage_var
func attacker_address() -> (res : felt):  
end

@constructor
func constructor{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(attacker : felt):
    attacker_address.write(attacker)
    counter.write(0)
    return ()
end

@external
func callback{syscall_ptr : felt*, 
    pedersen_ptr : HashBuiltin*,
    range_check_ptr}():
    ReentrancyGuard_start()
    _count()
    ReentrancyGuard_end()
    return ()
end

@external
func countLocalRecursive {syscall_ptr : felt*, 
    pedersen_ptr : HashBuiltin*,
    range_check_ptr} (n : felt):
    ReentrancyGuard_start()
    assert_le(1, n)
    _count()
    countLocalRecursive(n - 1)
    ReentrancyGuard_end()
    return ()
end

@external
func countThisRecursive {syscall_ptr : felt*, 
    pedersen_ptr : HashBuiltin*,
    range_check_ptr} (n : Uint256):
    ReentrancyGuard_start()
    uint256_signed_nn_le(1, n)
    _count()
    let (contract_address) = get_contract_address()
    let (new_n: Uint256) = uint256_sub(n,1)
    IReentrancyGuard.countThisRecursive(
        contract_address=contract_address, n=new_n )
    ReentrancyGuard_end()
    return ()    
end

func _count{syscall_ptr : felt*, 
    pedersen_ptr : HashBuiltin*,
    range_check_ptr}():
    let (current_count) = counter.read()
    counter.write(current_count + 1)
    return ()
end