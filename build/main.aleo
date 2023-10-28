program zkdao_v0_0_1.aleo;

struct Membership:
    requests as boolean;
    approvals as field;
    granted as boolean;

struct Admin:
    requests as boolean;
    approvals as field;
    remove_approvals as field;
    granted as boolean;

struct AdminGlobal:
    num_admins as field;
    destruct_approvals as field;
    destructed as boolean;


mapping admins:
	key as field.public;
	value as boolean.public;


mapping block_double:
	key as field.public;
	value as boolean.public;


mapping reset:
	key as field.public;
	value as boolean.public;


mapping admin_global:
	key as field.public;
	value as AdminGlobal.public;


mapping admin_req:
	key as field.public;
	value as Admin.public;


mapping membership:
	key as field.public;
	value as Membership.public;

function grant_admin_initial:
    input r0 as address.private;
    hash.bhp256 self.caller into r1 as field;
    assert.eq r1 5471346192118974203811093312871574098188146069506081670514657699548656288468field;
    hash.bhp256 r0 into r2 as field;
    async grant_admin_initial r2 into r3;
    output r3 as zkdao_v0_0_1.aleo/grant_admin_initial.future;

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
    output r3 as zkdao_v0_0_1.aleo/remove_admin_initial.future;

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
    output r2 as zkdao_v0_0_1.aleo/request_admin.future;

finalize request_admin:
    input r0 as field.public;
    cast false 0field 0field false into r1 as Admin;
    get.or_use admin_req[r0] r1 into r2;
    cast true r2.approvals r2.remove_approvals r2.granted into r3 as Admin;
    set r3 into admin_req[r0];


function approve_admin:
    input r0 as address.private;
    hash.bhp256 r0 into r1 as field;
    hash.bhp256 self.caller into r2 as field;
    async approve_admin r2 r1 into r3;
    output r3 as zkdao_v0_0_1.aleo/approve_admin.future;

finalize approve_admin:
    input r0 as field.public;
    input r1 as field.public;
    get admins[r0] into r2;
    get.or_use block_double[r0] false into r3;
    assert.eq r2 true;
    assert.eq r3 false;
    get admin_req[r1] into r4;
    add r4.approvals 1field into r5;
    cast r4.requests r5 r4.remove_approvals r4.granted into r6 as Admin;
    set r6 into admin_req[r1];
    set true into block_double[r0];


function grant_admin:
    input r0 as address.private;
    hash.bhp256 r0 into r1 as field;
    async grant_admin r1 into r2;
    output r2 as zkdao_v0_0_1.aleo/grant_admin.future;

finalize grant_admin:
    input r0 as field.public;
    get admin_req[r0] into r1;
    gt r1.approvals 2field into r2;
    assert.eq r2 true;
    cast r1.requests r1.approvals r1.remove_approvals true into r3 as Admin;
    set r3 into admin_req[r0];
    set true into admins[r0];
    get admin_global[0field] into r4;
    add r4.num_admins 1field into r5;
    cast r5 r4.destruct_approvals r4.destructed into r6 as AdminGlobal;
    set r6 into admin_global[0field];
    set true into reset[0field];


function approve_remove_admin:
    input r0 as field.private;
    hash.bhp256 self.caller into r1 as field;
    async approve_remove_admin r1 r0 into r2;
    output r2 as zkdao_v0_0_1.aleo/approve_remove_admin.future;

finalize approve_remove_admin:
    input r0 as field.public;
    input r1 as field.public;
    get admins[r0] into r2;
    get.or_use block_double[r0] false into r3;
    assert.eq r2 true;
    assert.eq r3 false;
    get admin_req[r1] into r4;
    add r4.remove_approvals 1field into r5;
    cast r4.requests r4.approvals r5 r4.granted into r6 as Admin;
    set r6 into admin_req[r1];
    set true into block_double[r0];


function remove_admin:
    input r0 as field.private;
    async remove_admin r0 into r1;
    output r1 as zkdao_v0_0_1.aleo/remove_admin.future;

finalize remove_admin:
    input r0 as field.public;
    get admin_req[r0] into r1;
    gt r1.remove_approvals 2field into r2;
    assert.eq r2 true;
    cast false 0field 0field false into r3 as Admin;
    set r3 into admin_req[r0];
    set false into admins[r0];
    get admin_global[0field] into r4;
    gt r4.num_admins 0field into r5;
    assert.eq r5 true;
    sub r4.num_admins 1field into r6;
    cast r6 r4.destruct_approvals r4.destructed into r7 as AdminGlobal;
    set r7 into admin_global[0field];
    set true into reset[0field];


function destruct_owner:
    async destruct_owner into r0;
    output r0 as zkdao_v0_0_1.aleo/destruct_owner.future;

finalize destruct_owner:
    get admin_global[0field] into r0;
    gt r0.destruct_approvals 2field into r1;
    assert.eq r1 true;
    cast r0.num_admins r0.destruct_approvals true into r2 as AdminGlobal;
    set r2 into admin_global[0field];


function approve_destruct:
    hash.bhp256 self.caller into r0 as field;
    async approve_destruct r0 into r1;
    output r1 as zkdao_v0_0_1.aleo/approve_destruct.future;

finalize approve_destruct:
    input r0 as field.public;
    get admins[r0] into r1;
    assert.eq r1 true;
    get admin_global[0field] into r2;
    add r2.destruct_approvals 1field into r3;
    cast r2.num_admins r3 r2.destructed into r4 as AdminGlobal;
    set r4 into admin_global[0field];


function request_membership:
    input r0 as address.private;
    hash.bhp256 r0 into r1 as field;
    async request_membership r1 into r2;
    output r2 as zkdao_v0_0_1.aleo/request_membership.future;

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
    output r3 as zkdao_v0_0_1.aleo/approve_membership.future;

finalize approve_membership:
    input r0 as field.public;
    input r1 as field.public;
    get admins[r0] into r2;
    assert.eq r2 true;
    get membership[r1] into r3;
    add r3.approvals 1field into r4;
    cast r3.requests r4 r3.granted into r5 as Membership;
    set r5 into membership[r1];


function grant_membership:
    input r0 as address.private;
    hash.bhp256 r0 into r1 as field;
    async grant_membership r1 into r2;
    output r2 as zkdao_v0_0_1.aleo/grant_membership.future;

finalize grant_membership:
    input r0 as field.public;
    get membership[r0] into r1;
    gt r1.approvals 2field into r2;
    assert.eq r2 true;
    cast r1.requests r1.approvals true into r3 as Membership;
    set r3 into membership[r0];


function unblock:
    input r0 as address.private;
    hash.bhp256 r0 into r1 as field;
    async unblock r1 into r2;
    output r2 as zkdao_v0_0_1.aleo/unblock.future;

finalize unblock:
    input r0 as field.public;
    get block_double[r0] into r1;
    assert.eq r1 true;
    get reset[0field] into r2;
    assert.eq r2 true;
    set false into block_double[r0];
