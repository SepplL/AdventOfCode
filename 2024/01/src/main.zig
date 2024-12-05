const std = @import("std");
const print = std.debug.print;
const parseInt = std.fmt.parseInt;

pub fn main() !void {
    // 01 code - figure out good zig structure over time

    // init general allocator for reading the whole file
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        _ = gpa.deinit();
    }

    // Open the file
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    // Read file into buffer
    const stat = try file.stat();
    const buffer = try file.readToEndAlloc(allocator, stat.size);
    defer allocator.free(buffer);

    // create array for both colunms and allocate buffer
    // print("file stats: {}", .{stat});
    // assume knowledge now: how to count lines in files?
    var list1: [1000]i32 = undefined;
    var list2: [1000]i32 = undefined;

    // iterate over buffer
    var numbers = std.mem.splitAny(u8, buffer, " ,\n");
    var index: u16 = 0;
    var listIndex: u4 = 0;
    while (numbers.next()) |number| {
        if (number.len == 1) {
            continue;
        }
        var num: i32 = 0;
        for (number) |digit| {
            const newDigit = digit - 48;
            if (newDigit < 0) {
                continue;
            }
            num *= 10;
            num += newDigit;
        }
        if (listIndex == 0 and num > 0) {
            list1[index] = num;
            listIndex += 1;
            continue;
        }
        if (listIndex == 1 and num > 0) {
            list2[index] = num;
            listIndex -= 1;
            index += 1;
            continue;
        }
    }

    // print("List left: {any} \n", .{list1});
    // print("List left: {any} \n", .{list2});
    // lists prepared. Sort now in decending order.
    std.mem.sort(i32, &list1, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, &list2, {}, comptime std.sort.asc(i32));

    // calculate distances and add up
    var totalDist: u32 = 0;
    for (list1, list2) |num1, num2| {
        totalDist += @abs(num1 - num2);
    }
    print("The total distance is: {d}\n", .{totalDist});

    // part two: similarity score
    // version 1: brute force double for loops:
    //
    var similarityScore: i32 = 0;
    for (list1) |num1| {
        var occurances: i16 = 0;
        for (list2) |num2| {
            if (num2 == num1) {
                occurances += 1;
            }
        }
        similarityScore += occurances * num1;
    }

    print("The total similarity score is: {d}\n", .{similarityScore});
}

fn readFile() [2][]i32 {}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
