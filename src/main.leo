// The 'zkdao' program.
program zkdao_v0_0_1.aleo {

    struct Membership {
        requests: bool,
        approvals: field,
        granted: bool,
    }

    struct Admin {
        num_admins: field,
        destruct_approvals: field,
        destructed: bool,
        reset: bool,
    }

    mapping admins: field => bool;
    // admin_struct always store at 0field as global variables
    mapping admin_struct: field => Admin;
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
        let temp: Admin = Mapping::get_or_use(admin_struct, 0field, Admin {
            num_admins: 0field,
            destruct_approvals: 0field,
            destructed: false,
            reset: false,
        });
        assert_eq(temp.destructed, false);

        let admin: bool = Mapping::get_or_use(admins, hash, false);
        assert_eq(admin, false);

        Mapping::set(admins, hash, true);
        Mapping::set(admin_struct, 0field, Admin {
            num_admins: temp.num_admins + 1field,
            destruct_approvals: temp.destruct_approvals,
            destructed: temp.destructed,
            reset: temp.reset,
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
        let temp: Admin = Mapping::get_or_use(admin_struct, 0field, Admin {
            num_admins: 0field,
            destruct_approvals: 0field,
            destructed: false,
            reset: false,
        });
        assert_eq(temp.destructed, false);
        assert(temp.num_admins > 0field);

        let admin: bool = Mapping::get(admins, hash);
        assert_eq(admin, true);

        Mapping::set(admins, hash, false);
        Mapping::set(admin_struct, 0field, Admin {
            num_admins: temp.num_admins - 1field,
            destruct_approvals: temp.destruct_approvals,
            destructed: temp.destructed,
            reset: temp.reset,
        });
    }


    // Destructing owner functions
    transition destruct_owner() {
        return then finalize();
    }

    finalize destruct_owner() {
        let temp: Admin = Mapping::get_or_use(admin_struct, 0field, Admin {
            num_admins: 0field,
            destruct_approvals: 0field,
            destructed: false,
            reset: false,
        });
        assert(temp.destruct_approvals > 2field);

        Mapping::set(admin_struct, 0field, Admin {
            num_admins: temp.num_admins,
            destruct_approvals: temp.destruct_approvals,
            destructed: true,
            reset: temp.reset,
        });
    }

    // Admin approval for destructing owner functions
    transition approve_destruct() {
        let caller: field = BHP256::hash_to_field(self.caller);
        return then finalize(caller);
    }

    finalize approve_destruct(caller: field) {
        let has_access: bool = Mapping::get_or_use(admins, caller, false);
        assert_eq(has_access, true);

        let temp: Admin = Mapping::get_or_use(admin_struct, 0field, Admin {
            num_admins: 0field,
            destruct_approvals: 0field,
            destructed: false,
            reset: false,
        });
        Mapping::set(admin_struct, 0field, Admin {
            num_admins: temp.num_admins,
            destruct_approvals: temp.destruct_approvals + 1field,
            destructed: temp.destructed,
            reset: temp.reset,
        });
    }

    // Request to join member
    transition request_membership(member: address) {
        let hash: field = BHP256::hash_to_field(member);
        return then finalize(hash);
    }

    finalize request_membership(hash: field) {
        let temp: Membership = Mapping::get_or_use(membership, hash,  Membership {
            requests: false,
            approvals: 0field,
            granted: false,
        });
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
            approvals: temp.approvals + 1field,
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
        assert(temp.approvals > 2field);

        Mapping::set(membership, hash, Membership {
            requests: temp.requests,
            approvals: temp.approvals,
            granted: true,
        });
    }
}
