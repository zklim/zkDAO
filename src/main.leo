// The 'zkdao' program.
program zkdao.aleo {

    struct Membership {
        requests: bool,
        approvals: u8,
        granted: bool,
    }

    struct Admin {
        num_admins: u8,
        destruct_approvals: u8,
        destructed: bool,
    }

    mapping admins: field => bool;
    // num_admins always store at 0u8
    mapping admin_struct: u8 => Admin;
    mapping membership: field => Membership;

    // Grant address admins access, program owner could be threshold signing / multisig
    // Precompute hash of owner instead of plain address
    transition grant_admin_initial(admin: address) {
        let owner: field = BHP256::hash_to_field(self.caller);
        assert_eq(owner, 5471346192118974203811093312871574098188146069506081670514657699548656288468field);

        let hash: field = BHP256::hash_to_field(admin);
        return then finalize(hash);
    }

    finalize grant_admin_initial(hash: field) {
        let temp: Admin = Mapping::get_or_use(admin_struct, 0u8, Admin {
            num_admins: 0u8,
            destruct_approvals: 0u8,
            destructed: false,
        });
        assert_eq(temp.destructed, false);

        Mapping::set(admins, hash, true);
        Mapping::set(admin_struct, 0u8, Admin {
            num_admins: temp.num_admins + 1u8,
            destruct_approvals: temp.destruct_approvals,
            destructed: temp.destructed,
        });
    }

    // Remove admin
    transition remove_admin_initial(admin: address) {
        let owner: field = BHP256::hash_to_field(self.caller);
        assert_eq(owner, 5471346192118974203811093312871574098188146069506081670514657699548656288468field);
        
        let hash: field = BHP256::hash_to_field(admin);
        return then finalize(hash);
    }

    finalize remove_admin_initial(hash: field) {
        let temp: Admin = Mapping::get_or_use(admin_struct, 0u8, Admin {
            num_admins: 0u8,
            destruct_approvals: 0u8,
            destructed: false,
        });
        assert_eq(temp.destructed, false);
        assert(temp.num_admins > 0u8);

        Mapping::set(admins, hash, false);
        Mapping::set(admin_struct, 0u8, Admin {
            num_admins: temp.num_admins - 1u8,
            destruct_approvals: temp.destruct_approvals,
            destructed: temp.destructed,
        });
    }


    // WIP: add threshold admins approval before destructing owner
    transition destruct_owner() {
        return then finalize();
    }

    finalize destruct_owner() {
        let temp: Admin = Mapping::get_or_use(admin_struct, 0u8, Admin {
            num_admins: 0u8,
            destruct_approvals: 0u8,
            destructed: false,
        });
        assert(temp.destruct_approvals > 2u8);

        Mapping::set(admin_struct, 0u8, Admin {
            num_admins: temp.num_admins,
            destruct_approvals: temp.destruct_approvals,
            destructed: true,
        });
    }

    // Admin approval for destructing owner
    transition approve_destruct() {
        let caller: field = BHP256::hash_to_field(self.caller);
        return then finalize(caller);
    }

    finalize approve_destruct(caller: field) {
        let has_access: bool = Mapping::get_or_use(admins, caller, false);
        assert_eq(has_access, true);

        let temp: Admin = Mapping::get_or_use(admin_struct, 0u8, Admin {
            num_admins: 0u8,
            destruct_approvals: 0u8,
            destructed: false,
        });
        Mapping::set(admin_struct, 0u8, Admin {
            num_admins: temp.num_admins,
            destruct_approvals: temp.destruct_approvals + 1u8,
            destructed: temp.destructed,
        });
    }

    // Request to join member
    transition request_membership(member: address) {
        let hash: field = BHP256::hash_to_field(member);
        return then finalize(hash);
    }

    finalize request_membership(hash: field) {
        let temp: Membership = Mapping::get(membership, hash);
        Mapping::set(membership, hash, Membership {
            requests: true,
            approvals: temp.approvals,
            granted: temp.granted,
        });
    }

    // Admin approval for certain member address
    transition approve_membership(member: address) {
        let hash: field = BHP256::hash_to_field(member);
        let caller: field = BHP256::hash_to_field(self.caller);
        return then finalize(caller, hash);
    }

    finalize approve_membership(caller: field, hash: field) {
        let has_access: bool = Mapping::get_or_use(admins, caller, false);
        assert_eq(has_access, true);

        let temp: Membership = Mapping::get(membership, hash);
        Mapping::set(membership, hash, Membership {
            requests: temp.requests,
            approvals: temp.approvals + 1u8,
            granted: temp.granted,
        });
    }

    // Grant membership, anyone can call this function but need to meet approvals threshold to be success. For now is >= 3
    transition grant_membership(member: address) {
        let hash: field = BHP256::hash_to_field(member);
        return then finalize(hash);
    }

    finalize grant_membership(hash: field) {
        let temp: Membership = Mapping::get(membership, hash);
        assert(temp.approvals > 2u8);

        Mapping::set(membership, hash, Membership {
            requests: temp.requests,
            approvals: temp.approvals,
            granted: true,
        });
    }


    // ==================================================================Internal functions==================================================================
    // Internal function to check is member (Not able to call finalize via function)
    // function is_member(member: address) {
    //     let hash: field = BHP256::hash_to_field(member);
    //     return then finalize(hash);
    // }

    // finalize is_member(hash: field) {
    //     let member: Membership = Mapping::get_or_use(membership, hash, Membership {
    //         requests: false,
    //         approvals: 0u8,
    //         granted: false,
    //     });
    //     assert_eq(member.granted, true);
    // }
}
