const std = @import("std");
const log = std.log;

const SinglyLinkedList = @import("singly_linked_list.zig").SinglyLinkedList;
const DoublyLinkedList = @import("doubly_linked_list.zig");
const BinarySearchTree = @import("binary_search_tree.zig");

pub fn main() !void {
    log.info("Some general usages...", .{});

    log.info("singly linked list usage ...", .{});
    singlyLinkedListUsage();
}

const Job = enum {
    Butcher,
    Baker,
    CandlestickMaker,
};

const Person = struct {
    name: []const u8,
    age: u8,
    job: Job,

    fn compare(self: Person, other: Person) std.math.Order {
        if (std.mem.eql(u8, self.name, other.name)) {
            return .eq;
        } else {
            return .lt;
        }
    }

    pub fn format(
        self: Person,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = options;
        _ = fmt;
        const job_str = switch (self.job) {
            .Baker => "Baker",
            .Butcher => "Butcher",
            .CandlestickMaker => "CandlestickMaker",
        };

        try writer.print("({s} {} {s})", .{ self.name, self.age, job_str });
    }
};

fn singlyLinkedListUsage() void {
    log.info("create a singly linked list type to hold our people", .{});
    const SLL = SinglyLinkedList(Person, Person.compare);

    log.info("make a reference to the 'node' for this new type", .{});
    const Node = SLL.Node;

    log.info("get an empty (default) list as var so we can mutate it", .{});
    var sll = SLL{};

    log.info("our new singly linked list is empty\n\n{any}\n", .{sll});

    log.info("create a few people nodes", .{});
    var node_1 = Node{
        .data = Person{
            .name = "Frank",
            .age = 44,
            .job = .Butcher,
        },
    };
    var node_2 = Node{
        .data = Person{
            .name = "Hank",
            .age = 35,
            .job = .Baker,
        },
    };
    var node_3 = Node{
        .data = Person{
            .name = "Bill",
            .age = 65,
            .job = .CandlestickMaker,
        },
    };

    log.info("created these people:\n\n{s}\n{s}\n{s}\n", .{ node_1.data, node_2.data, node_3.data });

    log.info("add one to our list", .{});

    sll.push(&node_1);

    log.info("now the list is:\n\n{any}\n", .{sll});
    log.info("add the other two", .{});

    sll.push(&node_2);
    sll.push(&node_3);

    log.info("now the list is:\n\n{any}\n", .{sll});
    log.info("remove the middle", .{});

    _ = sll.remove(Person{ .name = "Hank", .age = 35, .job = .Baker });

    log.info("now the list is:\n\n{any}\n", .{sll});
}
