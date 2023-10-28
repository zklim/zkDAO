program zkdao.aleo;

struct Membership:
    requests as boolean;
    approvals as field;
    granted as boolean;

struct Admin:
    num_admins as field;
    destruct_approvals as field;
    destructed as boolean;


mapping admins:
	key as field.public;
	value as boolean.public;


mapping admin_struct:
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
    output r3 as zkdao.aleo/grant_admin_initial.future;

finalize grant_admin_initial:
    input r0 as field.public;
    cast 0field 0field false into r1 as Admin;
    get.or_use admin_struct[0field] r1 into r2;
    assert.eq r2.destructed false;
    set true into admins[r0];
    add r2.num_admins 1field into r3;
    cast r3 r2.destruct_approvals r2.destructed into r4 as Admin;
    set r4 into admin_struct[0field];


function remove_admin_initial:
    input r0 as address.private;
    hash.bhp256 self.caller into r1 as field;
    assert.eq r1 5471346192118974203811093312871574098188146069506081670514657699548656288468field;
    hash.bhp256 r0 into r2 as field;
    async remove_admin_initial r2 into r3;
    output r3 as zkdao.aleo/remove_admin_initial.future;

finalize remove_admin_initial:
    input r0 as field.public;
    cast 0field 0field false into r1 as Admin;
    get.or_use admin_struct[0field] r1 into r2;
    assert.eq r2.destructed false;
    gt r2.num_admins 0field into r3;
    assert.eq r3 true;
    set false into admins[r0];
    sub r2.num_admins 1field into r4;
    cast r4 r2.destruct_approvals r2.destructed into r5 as Admin;
    set r5 into admin_struct[0field];


function destruct_owner:
    async destruct_owner into r0;
    output r0 as zkdao.aleo/destruct_owner.future;

finalize destruct_owner:
    cast 0field 0field false into r0 as Admin;
    get.or_use admin_struct[0field] r0 into r1;
    gt r1.destruct_approvals 2field into r2;
    assert.eq r2 true;
    cast r1.num_admins r1.destruct_approvals true into r3 as Admin;
    set r3 into admin_struct[0field];


function approve_destruct:
    hash.bhp256 self.caller into r0 as field;
    async approve_destruct r0 into r1;
    output r1 as zkdao.aleo/approve_destruct.future;

finalize approve_destruct:
    input r0 as field.public;
    get.or_use admins[r0] false into r1;
    assert.eq r1 true;
    cast 0field 0field false into r2 as Admin;
    get.or_use admin_struct[0field] r2 into r3;
    add r3.destruct_approvals 1field into r4;
    cast r3.num_admins r4 r3.destructed into r5 as Admin;
    set r5 into admin_struct[0field];


function request_membership:
    input r0 as address.private;
    hash.bhp256 r0 into r1 as field;
    async request_membership r1 into r2;
    output r2 as zkdao.aleo/request_membership.future;

finalize request_membership:
    input r0 as field.public;
    get membership[r0] into r1;
    cast true r1.approvals r1.granted into r2 as Membership;
    set r2 into membership[r0];


function approve_membership:
    input r0 as address.private;
    hash.bhp256 r0 into r1 as field;
    hash.bhp256 self.caller into r2 as field;
    async approve_membership r2 r1 into r3;
    output r3 as zkdao.aleo/approve_membership.future;

finalize approve_membership:
    input r0 as field.public;
    input r1 as field.public;
    get.or_use admins[r0] false into r2;
    assert.eq r2 true;
    get membership[r1] into r3;
    add r3.approvals 1field into r4;
    cast r3.requests r4 r3.granted into r5 as Membership;
    set r5 into membership[r1];


function grant_membership:
    input r0 as address.private;
    hash.bhp256 r0 into r1 as field;
    async grant_membership r1 into r2;
    output r2 as zkdao.aleo/grant_membership.future;

finalize grant_membership:
    input r0 as field.public;
    get membership[r0] into r1;
    gt r1.approvals 2field into r2;
    assert.eq r2 true;
    cast r1.requests r1.approvals true into r3 as Membership;
    set r3 into membership[r0];
