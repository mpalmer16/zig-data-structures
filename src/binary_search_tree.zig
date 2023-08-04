const std = @import("std");
const expect = std.testing.expect;

fn BinarySearchTree(
    comptime T: type,
    comptime compareFn: anytype,
    comptime equalFn: anytype,
) type {
    return struct {
        const Self = @This();

        fn compare(a: T, b: T) std.math.Order {
            return compareFn(a, b);
        }

        fn eql(a: T, b: T) bool {
            return equalFn(a, b);
        }

        const Node = struct {
            data: T,
            left: ?*Node = null,
            right: ?*Node = null,

            fn push(self: *Node, node: *Node) void {
                if (compare(self.data, node.data) == .lt) {
                    if (self.right) |right| {
                        right.push(node);
                    } else {
                        self.right = node;
                    }
                } else {
                    if (self.left) |left| {
                        left.push(node);
                    } else {
                        self.left = node;
                    }
                }
            }
        };

        root: ?*Node = null,

        fn push(self: *Self, node: *Node) void {
            if (self.root) |root| {
                root.push(node);
            } else {
                self.root = node;
            }
        }

        fn find(self: Self, data: T) bool {
            var current = self.root;
            while (current) |node| {
                if (eql(node.data, data)) {
                    return true;
                } else {
                    if (compare(node.data, data) == .lt) {
                        current = current.?.right orelse return false;
                    } else {
                        current = current.?.left orelse return false;
                    }
                }
            } else {
                return false;
            }
        }

        fn remove(self: *Self, data: T) ?T {
            var current = self.root;
            var previous: ?*Node = null;
            while (current) |node| {
                if (eql(node.data, data)) {
                    if (previous) |prev| {
                        // we are not at root!
                        // but we know left or right
                        // must contain our value
                        // check each one
                        // and set the one that has it to null
                        if (prev.left) |l| {
                            if (l.data == data) {
                                prev.left = null;
                            }
                        }
                        if (prev.right) |r| {
                            if (r.data == data) {
                                prev.right = null;
                            }
                        }
                        // now push left and right sides
                        // back into the previous node
                        // with left priority
                        var right = current.?.right orelse null;
                        var left = current.?.left orelse null;
                        if (left) |l| {
                            if (right) |r| {
                                l.push(r);
                            }
                            prev.push(l);
                        } else if (right) |r| {
                            prev.push(r);
                        }
                        return data;
                    } else {
                        // we are at the root
                        var right = current.?.right orelse null;
                        var left = current.?.left orelse null;
                        if (left) |l| {
                            // left priority - if there is a left branch
                            // use it as the replacement, pushing any
                            // right branch into it
                            if (right) |r| {
                                l.push(r);
                            }
                            self.root = l;
                        } else if (right) |r| {
                            // no left branch,
                            // so only need to use the right branch
                            self.root = r;
                        } else {
                            // no left or right branches
                            // and we are at the root
                            // so root goes back to null
                            self.root = null;
                        }
                        return data;
                    }
                } else {
                    if (node.data < data) {
                        previous = current;
                        current = current.?.right orelse return null;
                    } else {
                        previous = current;
                        current = current.?.left orelse return null;
                    }
                }
            } else {
                return null;
            }
        }
    };
}

fn equalNumbers(a: i32, b: i32) bool {
    return a == b;
}

test "create binary tree" {
    const bt = BinarySearchTree(i32, std.math.order, equalNumbers);
    const Node = bt.Node;
    var btree = bt{};

    var node_1 = Node{ .data = 1 };
    var node_2 = Node{ .data = 2 };
    var node_3 = Node{ .data = 3 };
    var node_4 = Node{ .data = 4 };
    var node_5 = Node{ .data = 5 };

    btree.push(&node_3);
    btree.push(&node_1);
    btree.push(&node_5);
    btree.push(&node_2);
    btree.push(&node_4);

    try expect(btree.root.?.data == 3);
    try expect(btree.root.?.left.?.data == 1);
    try expect(btree.root.?.right.?.left.?.data == 4);
}

test "find in tree" {
    const bt = BinarySearchTree(i32, std.math.order, equalNumbers);
    const Node = bt.Node;
    var btree = bt{};

    var node_1 = Node{ .data = 1 };
    var node_2 = Node{ .data = 2 };
    var node_3 = Node{ .data = 3 };
    var node_4 = Node{ .data = 4 };
    var node_5 = Node{ .data = 5 };

    btree.push(&node_3);
    btree.push(&node_1);
    btree.push(&node_5);
    btree.push(&node_2);
    btree.push(&node_4);

    try expect(btree.find(3));
    try expect(btree.find(4));
    try expect(btree.find(2));
    try expect(btree.find(5));

    try expect(!btree.find(10));
}

test "remove from tree" {
    const bt = BinarySearchTree(i32, std.math.order, equalNumbers);
    const Node = bt.Node;
    var btree = bt{};

    var node_1 = Node{ .data = 1 };
    var node_2 = Node{ .data = 2 };
    var node_3 = Node{ .data = 3 };
    var node_4 = Node{ .data = 4 };
    var node_5 = Node{ .data = 5 };

    btree.push(&node_3);
    btree.push(&node_1);
    btree.push(&node_5);
    btree.push(&node_2);
    btree.push(&node_4);

    try expect(btree.remove(3) == 3);
    try expect(btree.remove(5) == 5);
    try expect(btree.remove(5) == null);
    try expect(btree.remove(2) == 2);
    try expect(btree.remove(4) == 4);

    try expect(btree.remove(10) == null);
}

fn eq(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

test "people tree" {
    const Person = struct {
        const Self = @This();

        name: []const u8,
        age: usize,

        fn new(name: []const u8, age: usize) Self {
            return Self{
                .name = name,
                .age = age,
            };
        }

        fn compare(a: Self, b: Self) std.math.Order {
            if (a.age < b.age) {
                return .lt;
            } else if (a.age == b.age) {
                return .eq;
            } else {
                return .gt;
            }
        }

        fn eql(a: Self, b: Self) bool {
            return eq(a.name, b.name) and a.age == b.age;
        }
    };

    const BT = BinarySearchTree(Person, Person.compare, Person.eql);
    const Node = BT.Node;
    var peopleTree = BT{};

    var person1 = Node{ .data = Person.new("Bill", 24) };
    var person2 = Node{ .data = Person.new("Frank", 54) };
    var person3 = Node{ .data = Person.new("Ted", 5) };

    peopleTree.push(&person1);
    peopleTree.push(&person2);
    peopleTree.push(&person3);

    try expect(eq(peopleTree.root.?.data.name, "Bill"));

    try expect(peopleTree.find(Person.new("Ted", 5)));
}
