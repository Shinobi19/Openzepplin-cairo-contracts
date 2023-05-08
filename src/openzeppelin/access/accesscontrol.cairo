use starknet::ContractAddress;

#[abi]
trait IAccessControl {
    fn has_role(role: felt252, account: ContractAddress) -> bool;
    fn get_role_admin(role: felt252) -> felt252;
    fn grant_role(role: felt252, account: ContractAddress);
    fn revoke_role(role: felt252, account: ContractAddress);
    fn renounce_role(role: felt252, account: ContractAddress);
}

#[contract]
mod AccessControl {
    // OZ modules
    use super::IAccessControl;
    use openzeppelin::introspection::erc165::ERC165;

    // Constants
    use openzeppelin::utils::constants::{DEFAULT_ADMIN_ROLE, IACCESSCONTROL_ID};

    use starknet::{ContractAddress, get_caller_address};

    struct Storage {
        role_admin: LegacyMap<felt252, felt252>,
        role_members: LegacyMap<(felt252, ContractAddress), bool>,
    }

    #[event]
    fn RoleGranted(role: felt252, account: ContractAddress, sender: ContractAddress) {}

    #[event]
    fn RoleRevoked(role: felt252, account: ContractAddress, sender: ContractAddress) {}

    #[event]
    fn RoleAdminChanged(role: felt252, previous_admin_role: felt252, new_admin_role: felt252) {}

    impl AccessControlImpl of IAccessControl {
        fn has_role(role: felt252, account: ContractAddress) -> bool {
            role_members::read((role, account))
        }

        fn get_role_admin(role: felt252) -> felt252 {
            role_admin::read(role)
        }

        fn grant_role(role: felt252, account: ContractAddress) {
            let admin = get_role_admin(role);
            assert_only_role(admin);
            _grant_role(role, account);
        }

        fn revoke_role(role: felt252, account: ContractAddress) {
            let admin: felt252 = get_role_admin(role);
            assert_only_role(admin);
            _revoke_role(role, account);
        }

        fn renounce_role(role: felt252, account: ContractAddress) {
            let caller: ContractAddress = get_caller_address();
            assert(caller == account, 'Can only renounce role for self');
            _revoke_role(role, account);
        }
    }

    #[view]
    fn supports_interface(interface_id: u32) -> bool {
        ERC165::supports_interface(interface_id)
    }

    #[view]
    fn has_role(role: felt252, account: ContractAddress) -> bool {
        AccessControlImpl::has_role(role, account)
    }

    #[view]
    fn get_role_admin(role: felt252) -> felt252 {
        AccessControlImpl::get_role_admin(role)
    }

    #[external]
    fn grant_role(role: felt252, account: ContractAddress) {
        AccessControlImpl::grant_role(role, account);
    }

    #[external]
    fn revoke_role(role: felt252, account: ContractAddress) {
        AccessControlImpl::revoke_role(role, account);
    }

    #[external]
    fn renounce_role(role: felt252, account: ContractAddress) {
        AccessControlImpl::renounce_role(role, account);
    }

    #[internal]
    fn initializer() {
        ERC165::register_interface(IACCESSCONTROL_ID);
    }

    #[internal]
    fn assert_only_role(role: felt252) {
        let caller: ContractAddress = get_caller_address();
        let authorized: bool = has_role(role, caller);
        assert(authorized, 'Caller is missing role');
    }

    //
    // WARNING
    // The following internal methods are unprotected and should not be used
    // outside of a contract's constructor.
    //


    ///
    #[internal]
    fn _grant_role(role: felt252, account: ContractAddress) {
        if !has_role(
            role, account
        ) {
            let caller: ContractAddress = get_caller_address();
            role_members::write((role, account), true);
            RoleGranted(role, account, caller);
        }
    }

    #[internal]
    fn _revoke_role(role: felt252, account: ContractAddress) {
        if has_role(
            role, account
        ) {
            let caller: ContractAddress = get_caller_address();
            role_members::write((role, account), false);
            RoleRevoked(role, account, caller);
        }
    }

    #[internal]
    fn _set_role_admin(role: felt252, admin_role: felt252) {
        let previous_admin_role: felt252 = get_role_admin(role);
        role_admin::write(role, admin_role);
        RoleAdminChanged(role, previous_admin_role, admin_role);
    }
}
