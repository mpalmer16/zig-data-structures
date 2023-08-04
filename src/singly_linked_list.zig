const std = @import("std");

const expect = std.testing.expect;

pub fn SinglyLinkedList(
    comptime T: type,
    comptime compareFn: anytype,
) type {
    return struct {
        pub const Node = struct {
            data: T,
            next: ?*Node = null,
        };

        const Self = @This();

        head: ?*Node = null,

        fn compare(a: T, b: T) std.math.Order {
            return compareFn(a, b);
        }

        pub fn format(
            self: Self,
            comptime fmt: []const u8,
            options: std.fmt.FormatOptions,
            writer: anytype,
        ) !void {
            _ = options;
            _ = fmt;

            var current = self.head;
            while (current) |node| {
                try writer.print("{s} -> ", .{node.data});
                current = current.?.next;
            } else {
                try writer.print("null", .{});
            }
        }

        pub fn push(self: *Self, new_node: *Node) void {
            new_node.next = self.head;
            self.head = new_node;
        }

        pub fn pop(self: *Self) ?*Node {
            var old_head = self.head orelse return null;
            self.head = old_head.next;
            return old_head;
        }

        pub fn tail(self: Self) ?*Node {
            var current = self.head orelse return null;
            while (current.next) |next| {
                current = next;
            }
            return current;
        }

        pub fn find(self: Self, data: T) bool {
            var current = self.head;
            while (current) |node| {
                if (compare(node.data, data) == .eq) {
                    return true;
                } else {
                    current = current.?.next orelse return false;
                }
            } else {
                return false;
            }
        }

        pub fn length(self: *Self) i32 {
            var count: i32 = 0;
            var current = self.head;
            while (current) |_| {
                count += 1;
                current = current.?.next;
            }
            return count;
        }

        pub fn remove(self: *Self, data: T) ?T {
            var current = self.head;
            var previous: ?*Node = null;
            while (current) |node| {
                if (compare(node.data, data) == .eq) {
                    if (previous) |prev| {
                        prev.next = node.next;
                    } else {
                        self.head = node.next;
                    }
                    return data;
                } else {
                    previous = current;
                    current = current.?.next orelse return null;
                }
            } else {
                return null;
            }
        }
    };
}

test "push to list" {
    const LL = SinglyLinkedList(i32, std.math.order);
    const Node = LL.Node;
    var ll = LL{};

    try expect(ll.head == null);

    var node_1 = Node{ .data = 1 };
    var node_2 = Node{ .data = 2 };

    ll.push(&node_2);
    ll.push(&node_1);

    try expect(ll.head.?.data == 1);
    try expect(ll.head.?.next.?.data == 2);

    var node_3 = Node{ .data = 3 };
    var node_4 = Node{ .data = 4 };

    ll.push(&node_4);
    ll.push(&node_3);

    try expect(ll.head.?.data == 3);
    try expect(ll.head.?.next.?.data == 4);
    try expect(ll.head.?.next.?.next.?.data == 1);
    try expect(ll.head.?.next.?.next.?.next.?.data == 2);
}

test "pop from list" {
    const LL = SinglyLinkedList(i32, std.math.order);
    const Node = LL.Node;
    var ll = LL{};

    var node_1 = Node{ .data = 1 };
    var node_2 = Node{ .data = 2 };

    ll.push(&node_1);
    ll.push(&node_2);

    try expect(ll.head.?.data == 2);

    var pop_2 = ll.pop();

    try expect(pop_2.?.data == 2);
    try expect(ll.head.?.data == 1);

    var pop_1 = ll.pop();
    try expect(pop_1.?.data == 1);
    try expect(ll.head == null);

    var pop_null = ll.pop();
    try expect(pop_null == null);
}

test "find in list" {
    const LL = SinglyLinkedList(i32, std.math.order);
    const Node = LL.Node;
    var ll = LL{};

    var node_1 = Node{ .data = 1 };
    var node_2 = Node{ .data = 2 };
    var node_3 = Node{ .data = 3 };
    var node_4 = Node{ .data = 4 };

    ll.push(&node_4);
    ll.push(&node_3);
    ll.push(&node_2);
    ll.push(&node_1);

    try expect(ll.find(1));
    try expect(ll.find(4));
    try expect(!ll.find(10));
}

test "length" {
    const LL = SinglyLinkedList(i32, std.math.order);
    const Node = LL.Node;
    var ll = LL{};

    var node_1 = Node{ .data = 1 };
    var node_2 = Node{ .data = 2 };
    var node_3 = Node{ .data = 3 };
    var node_4 = Node{ .data = 4 };

    ll.push(&node_4);
    ll.push(&node_3);
    ll.push(&node_2);
    ll.push(&node_1);

    try expect(ll.length() == 4);
}

test "remove from list" {
    const LL = SinglyLinkedList(i32, std.math.order);
    const Node = LL.Node;
    var ll = LL{};

    var node_1 = Node{ .data = 1 };
    var node_2 = Node{ .data = 2 };
    var node_3 = Node{ .data = 3 };
    var node_4 = Node{ .data = 4 };

    ll.push(&node_4);
    ll.push(&node_3);
    ll.push(&node_2);
    ll.push(&node_1);

    try expect(ll.head.?.data == 1);

    try expect(ll.remove(1) == 1);
    try expect(ll.head.?.data == 2);

    try expect(ll.remove(3) == 3);
    try expect(ll.head.?.data == 2);
    try expect(ll.head.?.next.?.data == 4);

    try expect(ll.remove(10) == null);
}

test "find tail" {
    const LL = SinglyLinkedList(i32, std.math.order);
    const Node = LL.Node;
    var ll = LL{};

    var node_1 = Node{ .data = 1 };
    var node_2 = Node{ .data = 2 };
    var node_3 = Node{ .data = 3 };
    var node_4 = Node{ .data = 4 };

    ll.push(&node_4);
    ll.push(&node_3);
    ll.push(&node_2);
    ll.push(&node_1);

    try expect(ll.tail().?.data == 4);
}

test "People list" {
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

        fn compare(self: *Self, other: *Self) std.math.Order {
            if (self.name == other.name) {
                return .eq;
            } else {
                return .lt;
            }
        }
    };

    const LL = SinglyLinkedList(Person, Person.compare);
    const Node = LL.Node;
    var ll = LL{};

    var p1 = Node{ .data = Person.new("jack", 12) };
    var p2 = Node{ .data = Person.new("hank", 4) };
    var p3 = Node{ .data = Person.new("tank", 33) };

    ll.push(&p1);
    ll.push(&p2);
    ll.push(&p3);

    try expect(std.mem.eql(u8, ll.head.?.data.name, "tank"));
    try expect(std.mem.eql(u8, ll.tail().?.data.name, "jack"));
}
