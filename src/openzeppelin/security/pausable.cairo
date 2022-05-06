# SPDX-License-Identifier: MIT
# OpenZeppelin Contracts for Cairo v0.1.0 (security/pausable.cairo)

%lang starknet

from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE

@storage_var
func Pausable_paused() -> (paused: felt):
end

namespace Pausable:

    func pause{
            syscall_ptr : felt*, 
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }():
        assert_not_paused()
        Pausable_paused.write(TRUE)
        return ()
    end

    func unpause{
            syscall_ptr : felt*, 
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }():
        assert_paused()
        Pausable_paused.write(FALSE)
        return ()
    end

    func is_paused{
            syscall_ptr : felt*, 
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }() -> (is_paused: felt):
        let (is_paused) = Pausable_paused.read()
        return (is_paused)
    end

    func assert_not_paused{
            syscall_ptr : felt*, 
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }():
        let (is_paused) = Pausable_paused.read()
        with_attr error_message("Pausable: contract is paused"):
            assert is_paused = FALSE
        end
        return ()
    end

    func assert_paused{
            syscall_ptr : felt*, 
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }():
        let (is_paused) = Pausable_paused.read()
        with_attr error_message("Pausable: contract is not paused"):
            assert is_paused = TRUE
        end
        return ()
    end

end
