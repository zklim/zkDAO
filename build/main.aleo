program zkdao_v0_0_2.aleo;

struct Membership:
    requests as boolean;
    approvals as field;
    granted as boolean;

struct Admin:
    requests as boolean;
    approvals as field;
    remove_requests as boolean;
    remove_approvals as field;
    granted as boolean;

struct AdminGlobal:
    num_admins as field;
    destruct_approvals as field;
    destructed as boolean;

struct Proposal:
    approvals as field;
    approved as boolean;


mapping block_double_admin:
	key as field.public;
	value as boolean.public;


mapping reset_admin:
	key as field.public;
	value as boolean.public;


mapping block_double_member:
	key as field.public;
	value as boolean.public;


mapping reset_member:
	key as field.public;
	value as boolean.public;


mapping admin_global:
	key as field.public;
	value as AdminGlobal.public;


mapping admins:
	key as field.public;
	value as boolean.public;


mapping admin_req:
	key as field.public;
	value as Admin.public;


mapping membership:
	key as field.public;
	value as Membership.public;


mapping proposals:
	key as field.public;
	value as Proposal.public;

function grant_admin_initial:
    input r0 as address.private;
    hash.bhp256 self.caller into r1 as field;
    assert.eq r1 5471346192118974203811093312871574098188146069506081670514657699548656288468field;
    hash.bhp256 r0 into r2 as field;
    async grant_admin_initial r2 into r3;
    output r3 as zkdao_v0_0_2.aleo/grant_admin_initial.future;

finalize grant_admin_initial:
    input r0 as field.public;
    cast 0field 0field false into r1 as AdminGlobal;
    get.or_use admin_global[0field] r1 into r2;
    assert.eq r2.destructed false;
    get.or_use admins[r0] false into r3;
    assert.eq r3 false;
    set true into admins[r0];
    add r2.num_admins 1field into r4;
    cast r4 r2.destruct_approvals r2.destructed into r5 as AdminGlobal;
    set r5 into admin_global[0field];


function remove_admin_initial:
    input r0 as address.private;
    hash.bhp256 self.caller into r1 as field;
    assert.eq r1 5471346192118974203811093312871574098188146069506081670514657699548656288468field;
    hash.bhp256 r0 into r2 as field;
    async remove_admin_initial r2 into r3;
    output r3 as zkdao_v0_0_2.aleo/remove_admin_initial.future;

finalize remove_admin_initial:
    input r0 as field.public;
    cast 0field 0field false into r1 as AdminGlobal;
    get.or_use admin_global[0field] r1 into r2;
    assert.eq r2.destructed false;
    gt r2.num_admins 0field into r3;
    assert.eq r3 true;
    get admins[r0] into r4;
    assert.eq r4 true;
    set false into admins[r0];
    sub r2.num_admins 1field into r5;
    cast r5 r2.destruct_approvals r2.destructed into r6 as AdminGlobal;
    set r6 into admin_global[0field];


function request_admin:
    input r0 as address.private;
    hash.bhp256 r0 into r1 as field;
    async request_admin r1 into r2;
    output r2 as zkdao_v0_0_2.aleo/request_admin.future;

finalize request_admin:
    input r0 as field.public;
    cast false 0field false 0field false into r1 as Admin;
    get.or_use admin_req[r0] r1 into r2;
    cast true r2.approvals r2.remove_requests r2.remove_approvals r2.granted into r3 as Admin;
    set r3 into admin_req[r0];


function approve_admin:
    input r0 as address.private;
    hash.bhp256 r0 into r1 as field;
    hash.bhp256 self.caller into r2 as field;
    async approve_admin r2 r1 into r3;
    output r3 as zkdao_v0_0_2.aleo/approve_admin.future;

finalize approve_admin:
    input r0 as field.public;
    input r1 as field.public;
    set false into reset_admin[0field];
    get admins[r0] into r2;
    get.or_use block_double_admin[r0] false into r3;
    assert.eq r2 true;
    assert.eq r3 false;
    get admin_req[r1] into r4;
    assert.eq r4.requests true;
    add r4.approvals 1field into r5;
    cast r4.requests r5 r4.remove_requests r4.remove_approvals r4.granted into r6 as Admin;
    set r6 into admin_req[r1];
    set true into block_double_admin[r0];


function grant_admin:
    input r0 as address.private;
    hash.bhp256 r0 into r1 as field;
    async grant_admin r1 into r2;
    output r2 as zkdao_v0_0_2.aleo/grant_admin.future;

finalize grant_admin:
    input r0 as field.public;
    get admin_req[r0] into r1;
    gte r1.approvals 3field into r2;
    assert.eq r2 true;
    cast false 0field false 0field true into r3 as Admin;
    set r3 into admin_req[r0];
    set true into admins[r0];
    get admin_global[0field] into r4;
    add r4.num_admins 1field into r5;
    cast r5 r4.destruct_approvals r4.destructed into r6 as AdminGlobal;
    set r6 into admin_global[0field];
    set true into reset_admin[0field];


function request_remove_admin:
    input r0 as field.private;
    async request_remove_admin r0 into r1;
    output r1 as zkdao_v0_0_2.aleo/request_remove_admin.future;

finalize request_remove_admin:
    input r0 as field.public;
    cast false 0field false 0field false into r1 as Admin;
    get.or_use admin_req[r0] r1 into r2;
    cast r2.requests r2.approvals true r2.remove_approvals r2.granted into r3 as Admin;
    set r3 into admin_req[r0];


function approve_remove_admin:
    input r0 as field.private;
    hash.bhp256 self.caller into r1 as field;
    async approve_remove_admin r1 r0 into r2;
    output r2 as zkdao_v0_0_2.aleo/approve_remove_admin.future;

finalize approve_remove_admin:
    input r0 as field.public;
    input r1 as field.public;
    set false into reset_admin[0field];
    get admins[r0] into r2;
    get.or_use block_double_admin[r0] false into r3;
    assert.eq r2 true;
    assert.eq r3 false;
    get admin_req[r1] into r4;
    assert.eq r4.remove_requests true;
    add r4.remove_approvals 1field into r5;
    cast r4.requests r4.approvals r4.remove_requests r5 r4.granted into r6 as Admin;
    set r6 into admin_req[r1];
    set true into block_double_admin[r0];


function remove_admin:
    input r0 as field.private;
    async remove_admin r0 into r1;
    output r1 as zkdao_v0_0_2.aleo/remove_admin.future;

finalize remove_admin:
    input r0 as field.public;
    get admin_req[r0] into r1;
    gte r1.remove_approvals 3field into r2;
    assert.eq r2 true;
    cast false 0field false 0field false into r3 as Admin;
    set r3 into admin_req[r0];
    set false into admins[r0];
    get admin_global[0field] into r4;
    gt r4.num_admins 0field into r5;
    assert.eq r5 true;
    sub r4.num_admins 1field into r6;
    cast r6 r4.destruct_approvals r4.destructed into r7 as AdminGlobal;
    set r7 into admin_global[0field];
    set true into reset_admin[0field];


function approve_destruct:
    hash.bhp256 self.caller into r0 as field;
    async approve_destruct r0 into r1;
    output r1 as zkdao_v0_0_2.aleo/approve_destruct.future;

finalize approve_destruct:
    input r0 as field.public;
    set false into reset_admin[0field];
    get admins[r0] into r1;
    get.or_use block_double_admin[r0] false into r2;
    assert.eq r1 true;
    assert.eq r2 false;
    get admin_global[0field] into r3;
    assert.eq r3.destructed false;
    add r3.destruct_approvals 1field into r4;
    cast r3.num_admins r4 r3.destructed into r5 as AdminGlobal;
    set r5 into admin_global[0field];
    set true into block_double_admin[r0];


function destruct_owner:
    async destruct_owner into r0;
    output r0 as zkdao_v0_0_2.aleo/destruct_owner.future;

finalize destruct_owner:
    get admin_global[0field] into r0;
    gte r0.destruct_approvals 3field into r1;
    assert.eq r1 true;
    cast r0.num_admins r0.destruct_approvals true into r2 as AdminGlobal;
    set r2 into admin_global[0field];
    set true into reset_admin[0field];


function request_membership:
    input r0 as address.private;
    hash.bhp256 r0 into r1 as field;
    async request_membership r1 into r2;
    output r2 as zkdao_v0_0_2.aleo/request_membership.future;

finalize request_membership:
    input r0 as field.public;
    cast false 0field false into r1 as Membership;
    get.or_use membership[r0] r1 into r2;
    cast true r2.approvals r2.granted into r3 as Membership;
    set r3 into membership[r0];


function approve_membership:
    input r0 as address.private;
    hash.bhp256 r0 into r1 as field;
    hash.bhp256 self.caller into r2 as field;
    async approve_membership r2 r1 into r3;
    output r3 as zkdao_v0_0_2.aleo/approve_membership.future;

finalize approve_membership:
    input r0 as field.public;
    input r1 as field.public;
    set false into reset_admin[0field];
    get admins[r0] into r2;
    get.or_use block_double_admin[r0] false into r3;
    assert.eq r2 true;
    assert.eq r3 false;
    get membership[r1] into r4;
    assert.eq r4.requests true;
    add r4.approvals 1field into r5;
    cast r4.requests r5 r4.granted into r6 as Membership;
    set r6 into membership[r1];
    set true into block_double_admin[r0];


function grant_membership:
    input r0 as address.private;
    hash.bhp256 r0 into r1 as field;
    async grant_membership r1 into r2;
    output r2 as zkdao_v0_0_2.aleo/grant_membership.future;

finalize grant_membership:
    input r0 as field.public;
    get membership[r0] into r1;
    gte r1.approvals 3field into r2;
    assert.eq r2 true;
    cast false 0field true into r3 as Membership;
    set r3 into membership[r0];
    set true into reset_admin[0field];


function unblock_admin:
    input r0 as address.private;
    hash.bhp256 r0 into r1 as field;
    async unblock_admin r1 into r2;
    output r2 as zkdao_v0_0_2.aleo/unblock_admin.future;

finalize unblock_admin:
    input r0 as field.public;
    get block_double_admin[r0] into r1;
    assert.eq r1 true;
    get reset_admin[0field] into r2;
    assert.eq r2 true;
    set false into block_double_admin[r0];


function backdoor_reset_admin:
    async backdoor_reset_admin into r0;
    output r0 as zkdao_v0_0_2.aleo/backdoor_reset_admin.future;

finalize backdoor_reset_admin:
    set true into reset_admin[0field];


function propose:
    input r0 as field.private;
    hash.bhp256 self.caller into r1 as field;
    async propose r1 r0 into r2;
    output r2 as zkdao_v0_0_2.aleo/propose.future;

finalize propose:
    input r0 as field.public;
    input r1 as field.public;
    get membership[r0] into r2;
    assert.eq r2.granted true;
    cast 0field false into r3 as Proposal;
    set r3 into proposals[r1];


function vote_member:
    input r0 as field.private;
    hash.bhp256 self.caller into r1 as field;
    async vote_member r1 r0 into r2;
    output r2 as zkdao_v0_0_2.aleo/vote_member.future;

finalize vote_member:
    input r0 as field.public;
    input r1 as field.public;
    set false into reset_member[0field];
    get membership[r0] into r2;
    get.or_use block_double_member[r0] false into r3;
    assert.eq r2.granted true;
    assert.eq r3 false;
    get proposals[r1] into r4;
    add r4.approvals 1field into r5;
    cast r5 r4.approved into r6 as Proposal;
    set r6 into proposals[r1];
    set true into block_double_member[r0];


function vote_admin:
    input r0 as field.private;
    hash.bhp256 self.caller into r1 as field;
    async vote_admin r1 r0 into r2;
    output r2 as zkdao_v0_0_2.aleo/vote_admin.future;

finalize vote_admin:
    input r0 as field.public;
    input r1 as field.public;
    set false into reset_member[0field];
    get admins[r0] into r2;
    get.or_use block_double_member[r0] false into r3;
    assert.eq r2 true;
    assert.eq r3 false;
    get proposals[r1] into r4;
    add r4.approvals 1field into r5;
    cast r5 r4.approved into r6 as Proposal;
    set r6 into proposals[r1];
    set true into block_double_member[r0];


function pass_proposal:
    input r0 as field.private;
    async pass_proposal r0 into r1;
    output r1 as zkdao_v0_0_2.aleo/pass_proposal.future;

finalize pass_proposal:
    input r0 as field.public;
    get proposals[r0] into r1;
    gte r1.approvals 3field into r2;
    assert.eq r2 true;
    add r1.approvals 1field into r3;
    cast r3 r1.approved into r4 as Proposal;
    set r4 into proposals[r0];
    set true into reset_member[0field];


function unblock_member:
    input r0 as address.private;
    hash.bhp256 r0 into r1 as field;
    async unblock_member r1 into r2;
    output r2 as zkdao_v0_0_2.aleo/unblock_member.future;

finalize unblock_member:
    input r0 as field.public;
    get block_double_member[r0] into r1;
    assert.eq r1 true;
    get reset_member[0field] into r2;
    assert.eq r2 true;
    set false into block_double_member[r0];


function backdoor_reset_member:
    async backdoor_reset_member into r0;
    output r0 as zkdao_v0_0_2.aleo/backdoor_reset_member.future;

finalize backdoor_reset_member:
    set true into reset_member[0field];
