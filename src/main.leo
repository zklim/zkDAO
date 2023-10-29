// The 'zkdao' program.
program zkdao_v0_0_1.aleo {

    // Current double approval blocking mechanism is not perfect
    // Every action shares the same double approval lock thus every single actions must be sequencial for now (request -> approve -> grant)
    // IMPORTANT: Admins must unblock themselves before approving new action to avoiding bricking their admin access

    struct Membership {
        requests: bool,
        approvals: field,
        granted: bool,
    }

    struct Admin {
        requests: bool,
        approvals: field,
        remove_requests: bool,
        remove_approvals: field,
        granted: bool,
    }

    struct AdminGlobal {
        num_admins: field,
        destruct_approvals: field,
        destructed: bool,
    }

    // admins access, hashed address as key
    mapping admins: field => bool;
    // prevent double approval from same admin, always store at 0field as global variable
    mapping block_double: field => bool;
    // unblock from double approval guard, always store at 0field as global variable
    mapping reset: field => bool;
    // admin_global always store at 0field as global variables
    mapping admin_global: field => AdminGlobal;
    mapping admin_req: field => Admin;
    mapping membership: field => Membership;

    // Grant address admins access by owner, program owner could be threshold signing / multisig
    // Precompute hash of owner instead of plain address
    transition grant_admin_initial(admin: address) {
        let owner: field = BHP256::hash_to_field(self.caller);
        assert_eq(owner, 5471346192118974203811093312871574098188146069506081670514657699548656288468field);

        let hash: field = BHP256::hash_to_field(admin);
        return then finalize(hash);
    }

    finalize grant_admin_initial(hash: field) {
        let temp: AdminGlobal = Mapping::get_or_use(admin_global, 0field, AdminGlobal {
            num_admins: 0field,
            destruct_approvals: 0field,
            destructed: false,
        });
        assert_eq(temp.destructed, false); // checks function is not destructed

        let admin: bool = Mapping::get_or_use(admins, hash, false);
        assert_eq(admin, false); // not granted as admin before, to prevent messing up with num_admins number

        Mapping::set(admins, hash, true);
        Mapping::set(admin_global, 0field, AdminGlobal {
            num_admins: temp.num_admins + 1field,
            destruct_approvals: temp.destruct_approvals,
            destructed: temp.destructed,
        });
    }

    // Remove admin by owner
    transition remove_admin_initial(admin: address) {
        let owner: field = BHP256::hash_to_field(self.caller);
        assert_eq(owner, 5471346192118974203811093312871574098188146069506081670514657699548656288468field);
        
        let hash: field = BHP256::hash_to_field(admin);
        return then finalize(hash);
    }

    finalize remove_admin_initial(hash: field) {
        let temp: AdminGlobal = Mapping::get_or_use(admin_global, 0field, AdminGlobal {
            num_admins: 0field,
            destruct_approvals: 0field,
            destructed: false,
        });
        assert_eq(temp.destructed, false); // checks function is not destructed
        assert(temp.num_admins > 0field); // underflow check

        let admin: bool = Mapping::get(admins, hash);
        assert_eq(admin, true); // checks granted as admin before, to prevent messing up with num_admins number

        Mapping::set(admins, hash, false);
        Mapping::set(admin_global, 0field, AdminGlobal {
            num_admins: temp.num_admins - 1field,
            destruct_approvals: temp.destruct_approvals,
            destructed: temp.destructed,
        });
    }

    // ========================================================================Admins functions========================================================================
    // Request to join admin
    transition request_admin(admin: address) {
        let hash: field = BHP256::hash_to_field(admin);
        return then finalize(hash);
    }

    finalize request_admin(hash: field) {
        let request: Admin = Mapping::get_or_use(admin_req, hash,  Admin {
            requests: false,
            approvals: 0field,
            remove_requests: false,
            remove_approvals: 0field,
            granted: false,
        });
        Mapping::set(admin_req, hash, Admin {
            requests: true,
            approvals: request.approvals,
            remove_requests: request.remove_requests,
            remove_approvals: request.remove_approvals,
            granted: request.granted,
        });
    }

    // IMPORTANT: make sure every admin unblock himself before approving new request
    // Adding new admin without owner
    transition approve_admin(admin: address) {
        let hash: field = BHP256::hash_to_field(admin);
        let caller: field = BHP256::hash_to_field(self.caller);
        return then finalize(caller, hash);
    }

    finalize approve_admin(caller: field, hash: field) {
        Mapping::set(reset, 0field, false); // disable unblock function until action is finished

        let is_admin: bool = Mapping::get(admins, caller);
        let is_blocked: bool = Mapping::get_or_use(block_double, caller, false);
        assert_eq(is_admin, true); // caller is admin
        assert_eq(is_blocked, false); // is not blocked

        let request: Admin = Mapping::get(admin_req, hash);
        assert_eq(request.requests, true); // made request before approving

        Mapping::set(admin_req, hash, Admin {
            requests: request.requests,
            approvals: request.approvals + 1field,
            remove_requests: request.remove_requests,
            remove_approvals: request.remove_approvals,
            granted: request.granted,
        });
        Mapping::set(block_double, caller, true);
    }

   // Grant admin, anyone can call this function but need to meet approvals threshold to be success. For now is >= 3
    transition grant_admin(admin: address) {
        let hash: field = BHP256::hash_to_field(admin);
        return then finalize(hash);
    }

    finalize grant_admin(hash: field) {
        let temp: Admin = Mapping::get(admin_req, hash);
        assert(temp.approvals > 2field);

        Mapping::set(admin_req, hash, Admin {
            requests: false,
            approvals: 0field,
            remove_requests: false,
            remove_approvals: 0field,
            granted: true,
        });                               // clear data struct and grant admin
        Mapping::set(admins, hash, true); // grant admin

        let global: AdminGlobal = Mapping::get(admin_global, 0field);
        Mapping::set(admin_global, 0field, AdminGlobal {
            num_admins: global.num_admins + 1field,
            destruct_approvals: global.destruct_approvals,
            destructed: global.destructed,
        });
        Mapping::set(reset, 0field, true); // enable unblock self
    }

    // Request to remove admin
    transition request_remove_admin(admin: address) {
        let hash: field = BHP256::hash_to_field(admin);
        return then finalize(hash);
    }

    finalize request_remove_admin(hash: field) {
        let request: Admin = Mapping::get_or_use(admin_req, hash,  Admin {
            requests: false,
            approvals: 0field,
            remove_requests: false,
            remove_approvals: 0field,
            granted: false,
        });
        Mapping::set(admin_req, hash, Admin {
            requests: request.requests,
            approvals: request.approvals,
            remove_requests: true,
            remove_approvals: request.remove_approvals,
            granted: request.granted,
        });
    }

    // IMPORTANT: make sure every admin unblock himself before approving new request
    // Removing admin without owner, directly removing hashed key
    transition approve_remove_admin(admin: field) {
        let caller: field = BHP256::hash_to_field(self.caller);
        return then finalize(caller, admin);
    }

    finalize approve_remove_admin(caller: field, admin: field) {
        Mapping::set(reset, 0field, false); // disable unblock function until action is finished

        let is_admin: bool = Mapping::get(admins, caller);
        let is_blocked: bool = Mapping::get_or_use(block_double, caller, false);
        assert_eq(is_admin, true); // caller is admin
        assert_eq(is_blocked, false); // is not blocked

        let request: Admin = Mapping::get(admin_req, admin);
        assert_eq(request.remove_requests, true); // made request before approving

        Mapping::set(admin_req, admin, Admin {
            requests: request.requests,
            approvals: request.approvals,
            remove_requests: request.remove_requests,
            remove_approvals: request.remove_approvals + 1field,
            granted: request.granted,
        });
        Mapping::set(block_double, caller, true); // prevent double approval
    }

   // Remove admin, anyone can call this function but need to meet approvals threshold to be success. For now is >= 3
   // Direct access with hashed key
    transition remove_admin(admin: field) {
        return then finalize(admin);
    }

    finalize remove_admin(hash: field) {
        let temp: Admin = Mapping::get(admin_req, hash);
        assert(temp.remove_approvals > 2field);

        Mapping::set(admin_req, hash, Admin {
            requests: false,
            approvals: 0field,
            remove_requests: false,
            remove_approvals: 0field,
            granted: false,
        });                                // clear data struct
        Mapping::set(admins, hash, false); // remove admin

        let global: AdminGlobal = Mapping::get(admin_global, 0field);
        assert(global.num_admins > 0field); // underflow protection

        Mapping::set(admin_global, 0field, AdminGlobal {
            num_admins: global.num_admins - 1field,
            destruct_approvals: global.destruct_approvals,
            destructed: global.destructed,
        });
        Mapping::set(reset, 0field, true); // enable unblock self
    }

    // IMPORTANT: make sure every admin unblock himself before approving new request
    // AdminGlobal approval for destructing owner functions
    transition approve_destruct() {
        let caller: field = BHP256::hash_to_field(self.caller);
        return then finalize(caller);
    }

    finalize approve_destruct(caller: field) {
        Mapping::set(reset, 0field, false); // disable unblock function until action is finished

        let is_admin: bool = Mapping::get(admins, caller);
        let is_blocked: bool = Mapping::get_or_use(block_double, caller, false);
        assert_eq(is_admin, true); // caller is admin
        assert_eq(is_blocked, false); // is not blocked

        let temp: AdminGlobal = Mapping::get(admin_global, 0field);
        assert_eq(temp.destructed, false); // not destructed

        Mapping::set(admin_global, 0field, AdminGlobal {
            num_admins: temp.num_admins,
            destruct_approvals: temp.destruct_approvals + 1field,
            destructed: temp.destructed,
        });
        Mapping::set(block_double, caller, true);
    }

    // Destructing owner functions
    transition destruct_owner() {
        return then finalize();
    }

    finalize destruct_owner() {
        let temp: AdminGlobal = Mapping::get(admin_global, 0field);
        assert(temp.destruct_approvals > 2field);

        Mapping::set(admin_global, 0field, AdminGlobal {
            num_admins: temp.num_admins,
            destruct_approvals: temp.destruct_approvals,
            destructed: true,
        });
        Mapping::set(reset, 0field, true); // enable unblock self
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

    // IMPORTANT: make sure every admin unblock himself before approving new request
    // AdminGlobal approval for certain member address
    transition approve_membership(member: address) {
        let hash: field = BHP256::hash_to_field(member);
        let caller: field = BHP256::hash_to_field(self.caller);
        return then finalize(caller, hash);
    }

    finalize approve_membership(caller: field, hash: field) {
        Mapping::set(reset, 0field, false); // disable unblock function until action is finished

        let is_admin: bool = Mapping::get(admins, caller);
        let is_blocked: bool = Mapping::get_or_use(block_double, caller, false);
        assert_eq(is_admin, true); // caller is admin
        assert_eq(is_blocked, false); // is not blocked

        let temp: Membership = Mapping::get(membership, hash);
        assert_eq(temp.requests, true); // has made request before approving

        Mapping::set(membership, hash, Membership {
            requests: temp.requests,
            approvals: temp.approvals + 1field,
            granted: temp.granted,
        });
        Mapping::set(block_double, caller, true);
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
            requests: false,
            approvals: 0field,
            granted: true,
        });                                // clear data struct and grant membership
        Mapping::set(reset, 0field, true); // enable unblock self
    }

    // Unblock self after action is done
    transition unblock(admin: address) {
        let hash: field = BHP256::hash_to_field(admin);
        return then finalize(hash);
    }

    finalize unblock(hash: field) {
        let is_blocked: bool = Mapping::get(block_double, hash);
        assert_eq(is_blocked, true);

        let enabled: bool = Mapping::get(reset, 0field);
        assert_eq(enabled, true);

        Mapping::set(block_double, hash, false);
    }

    // IMPORTANT: Backdoor to unbrick admin access, for testing purpose
    transition backdoor_reset() {
        return then finalize();
    }

    finalize backdoor_reset() {
        Mapping::set(reset, 0field, true);
    }
}
