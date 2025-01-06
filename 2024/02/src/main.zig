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
    var safeRows: u16 = 0;
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

        var sign: i8 = -1;
        var signSwaps: u8 = 0;
        var index: u8 = 0;
        var deltaViolation: bool = false;
        // increasing vs decreasing
        // 0 < i - j < 3

        for (currentRow) |number| {
            // check for non 0 valid entries. Only evaluate actual numbers
            if (number <= 0) {
                break;
            }

            if (index == 0) {
                index += 1;
                continue;
            }

            const deltaNum = number - currentRow[index - 1];
            // print("number {d} and previous number {d} \n", .{ number, currentRow[index - 1] });
            if (deltaNum * sign < 0) {
                sign *= -1;
                signSwaps += 1;
            }

            if (@abs(deltaNum) == 0 or @abs(deltaNum) > 3) {
                deltaViolation = true;
            }
            // print("delta: {d} and sign swap? {d} \n", .{ deltaNum, signSwaps });
            index += 1;
        }
        // print("current row {any} \n", .{currentRow});
        if (deltaViolation == true) {
            continue;
        } else {
            if (sign == -1 and signSwaps == 0) {
                safeRows += 1;
                // print("safe row found! \n", .{});
            }
            if (sign == 1 and signSwaps == 1) {
                safeRows += 1;
                // print("safe row found! \n", .{});
            }
        }
    }
    print("Number of safe rows: {d}", .{safeRows});
}

test "example test" {
    // const expect = std.testing.expect;
    const input = [6][5]u8{
        [_]u8{ 7, 6, 4, 2, 1 },
        [_]u8{ 1, 2, 7, 8, 9 },
        [_]u8{ 9, 7, 6, 2, 1 },
        [_]u8{ 1, 3, 2, 4, 5 },
        [_]u8{ 8, 6, 4, 4, 1 },
        [_]u8{ 1, 3, 6, 7, 9 },
    };
    // try expect(safeTesting(input), 2);
    print("Loaded input: {any}", .{input});
}
