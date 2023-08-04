const std = @import("std");
const expect = std.testing.expect;

fn DoublyLinkedList(comptime T: type) type {
    return struct {
        const Node = struct {
            data: T,
            previous: ?*Node = null,
            next: ?*Node = null,
        };
        const Self = @This();

        head: ?*Node = null,
        tail: ?*Node = null,

        fn push(self: *Self, node: *Node) void {
            if (self.tail) |tail| {
                tail.next = node;
                node.previous = tail;
                self.tail = node;
            } else {
                self.head = node;
                self.tail = node;
            }
        }

        fn popHead(self: *Self) ?*Node {
            var head = self.head orelse return null;
            self.head = head.next;
            return head;
        }

        fn popTail(self: *Self) ?*Node {
            var tail = self.tail orelse return null;
            self.tail = tail.previous;
            return tail;
        }

        fn searchFromHead(self: *Self, data: T) bool {
            var current = self.head;
            while (current) |node| {
                if (node.data == data) {
                    return true;
                } else {
                    current = current.?.next orelse return false;
                }
            } else {
                return false;
            }
        }

        fn searchFromTail(self: *Self, data: T) bool {
            var current = self.tail;
            while (current) |node| {
                if (node.data == data) {
                    return true;
                } else {
                    current = current.?.previous orelse return false;
                }
            } else {
                return false;
            }
        }

        fn length(self: *Self) i32 {
            var count: i32 = 0;
            var current = self.head;
            while (current) |_| {
                count += 1;
                current = current.?.next;
            }
            return count;
        }
    };
}

test "push to tail" {
    const DLL = DoublyLinkedList(i32);
    const Node = DLL.Node;
    var dll = DLL{};

    var node_1 = Node{ .data = 1 };
    var node_2 = Node{ .data = 2 };
    var node_3 = Node{ .data = 3 };

    dll.push(&node_1);
    dll.push(&node_2);
    dll.push(&node_3);

    try expect(dll.head.?.data == 1);
    try expect(dll.tail.?.data == 3);

    try expect(dll.tail.?.previous.?.data == 2);
    try expect(dll.head.?.next.?.data == 2);
}

test "search from head" {
    const DLL = DoublyLinkedList(i32);
    const Node = DLL.Node;
    var dll = DLL{};

    var node_1 = Node{ .data = 1 };
    var node_2 = Node{ .data = 2 };
    var node_3 = Node{ .data = 3 };

    dll.push(&node_1);
    dll.push(&node_2);
    dll.push(&node_3);

    try expect(dll.searchFromHead(3));
    try expect(dll.searchFromHead(1));
    try expect(!dll.searchFromHead(10));
}

test "search from tail" {
    const DLL = DoublyLinkedList(i32);
    const Node = DLL.Node;
    var dll = DLL{};

    var node_1 = Node{ .data = 1 };
    var node_2 = Node{ .data = 2 };
    var node_3 = Node{ .data = 3 };

    dll.push(&node_1);
    dll.push(&node_2);
    dll.push(&node_3);

    try expect(dll.searchFromTail(3));
    try expect(dll.searchFromTail(1));
    try expect(!dll.searchFromTail(10));
}

test "pop head and tail" {
    const DLL = DoublyLinkedList(i32);
    const Node = DLL.Node;
    var dll = DLL{};

    var node_1 = Node{ .data = 1 };
    var node_2 = Node{ .data = 2 };
    var node_3 = Node{ .data = 3 };

    dll.push(&node_1);
    dll.push(&node_2);
    dll.push(&node_3);

    try expect(dll.popHead().?.data == 1);

    try expect(dll.popTail().?.data == 3);

    try expect(dll.head.?.data == 2);
    try expect(dll.tail.?.data == 2);
}

test "length" {
    const DLL = DoublyLinkedList(i32);
    const Node = DLL.Node;
    var dll = DLL{};

    var node_1 = Node{ .data = 1 };
    var node_2 = Node{ .data = 2 };
    var node_3 = Node{ .data = 3 };

    dll.push(&node_1);
    dll.push(&node_2);
    dll.push(&node_3);

    try expect(dll.length() == 3);
}
