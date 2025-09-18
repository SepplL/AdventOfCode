const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
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
    var safeRows1: u16 = 0;
    var safeRows2: u16 = 0;
    var rows = std.mem.splitAny(u8, buffer, "\n");
    while (rows.next()) |row| {
        var currentRow: [10]i16 = undefined;
        @memset(&currentRow, 0);
        var currentNumIndex: u16 = 0;
        var currentNums = std.mem.splitAny(u8, row, " ");
        while (currentNums.next()) |num| {
            for (num) |digit| {
                const newDigit = digit - 48;
                if (newDigit < 0) {
                    continue;
                }
                currentRow[currentNumIndex] *= 10;
                currentRow[currentNumIndex] += newDigit;
            }
            currentNumIndex += 1;
        }
        // print("current row {any} \n", .{currentRow});
        // row constructed properly. Now check for conditions and update safeRows.
        // part 1
        const safety1 = isSafe(&currentRow);
        // part 2
        const safety2 = isDampenedSafe(&currentRow);

        // print("current row {any} \n", .{currentRow});
        if (safety1) {
            safeRows1 += 1;
        }
        if (safety2) {
            safeRows2 += 1;
        }
    }
    // ISSUE: counting also last 0, 0, 0 row - error from importing. Fix later.
    print("Number of safe rows in part 1: {d} \n", .{safeRows1 - 1});
    print("Number of safe rows in part 1: {d} \n", .{safeRows2 - 1});
}

fn isSafe(list: []const i16) bool {
    var first: bool = true;
    var last: i16 = 0;
    var order: i16 = 0;
    // increasing vs decreasing
    // 0 < i - j < 3

    for (list) |number| {
        // check for non 0 valid entries. Only evaluate actual numbers
        if (number <= 0) {
            break;
        }

        if (first) {
            first = false;
        } else {
            const diff = last - number;
            if (diff == 0 or diff < -3 or diff > 3) {
                return false;
            }
            if (order == 0) {
                order = diff;
            } else {
                if ((order < 0 and diff > 0) or (order > 0 and diff < 0)) {
                    return false;
                }
            }
        }
        last = number;
    }
    return true;
}

fn isDampenedSafe(list: []const i16) bool {
    // use part 2 dampening
    var combined: [10]i16 = undefined;

    if (isSafe(list)) {
        return true;
    } else {
        var index: u8 = 0;
        while (index < list.len) {
            // remove index from list and test on remaining list:
            // const dampenedList = list[0..index] ++ list[index..list.len];
            const newPart1 = list[0..index];
            const newPart2 = list[index + 1 .. list.len];
            @memcpy(combined[0..newPart1.len], newPart1);
            @memcpy(combined[newPart1.len .. list.len - 1], newPart2);
            // print("old list: {any} \n", .{list});
            // print("new list 1: {any} \n", .{newPart1});
            // print("new list 2: {any} \n", .{newPart2});
            // print("concatenated: {any} \n", .{combined[0 .. list.len - 1]});
            if (isSafe(combined[0 .. list.len - 1])) {
                return true;
            } else {
                index += 1;
            }
        }
        return false;
    }
}

test "part1 test" {
    const expectEqual = std.testing.expectEqual;
    const input = [6][5]i16{
        [_]i16{ 7, 6, 4, 2, 1 },
        [_]i16{ 1, 2, 7, 8, 9 },
        [_]i16{ 9, 7, 6, 2, 1 },
        [_]i16{ 1, 3, 2, 4, 5 },
        [_]i16{ 8, 6, 4, 4, 1 },
        [_]i16{ 1, 3, 6, 7, 9 },
    };

    var part1Safe: u8 = 0;
    for (&input) |row| {
        if (isSafe(&row)) {
            part1Safe += 1;
        }
    }

    try expectEqual(2, part1Safe);
    print("Loaded input: {any} \n", .{input});
}

test "part2 test" {
    const expectEqual = std.testing.expectEqual;
    const input = [6][5]i16{
        [_]i16{ 7, 6, 4, 2, 1 },
        [_]i16{ 1, 2, 7, 8, 9 },
        [_]i16{ 9, 7, 6, 2, 1 },
        [_]i16{ 1, 3, 2, 4, 5 },
        [_]i16{ 8, 6, 4, 4, 1 },
        [_]i16{ 1, 3, 6, 7, 9 },
    };

    var part2Safe: u8 = 0;
    for (&input) |row| {
        if (isDampenedSafe(&row)) {
            part2Safe += 1;
        }
    }

    try expectEqual(4, part2Safe);
    // print("Loaded input: {any} \n", .{input});
}
