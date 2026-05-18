const std = @import("std");
const eql = std.mem.eql;
const print = std.debug.print;

pub fn main() !void {
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

    // print("Buffer {s}", .{buffer});
    const result1 = try parseMuls(buffer, false);
    print("The parsed result is: {d} with mul Do's disabled \n", .{result1});

    const result2 = try parseMuls(buffer, true);
    print("The parsed result is: {d} with mul Do's enabled \n", .{result2});
}

fn parseMuls(input: []const u8, enable_dos: bool) !i64 {
    var mulEnabled: bool = true;
    var position: u32 = 0;
    var result: i64 = 0;
    while (position < input.len - 4) {
        if (eql(u8, input[position .. position + 4], "mul(")) {
            position += 4;

            // parse number 1
            if (input[position] >= '0' and input[position] <= '9') {
                const num1start = position;
                position += 1;
                while (input[position] >= '0' and input[position] <= '9') {
                    position += 1;
                }
                const num1 = try std.fmt.parseInt(i64, input[num1start..position], 10);
                if (input[position] == ',') {
                    position += 1;

                    // parse number 2
                    if (input[position] >= '0' and input[position] <= '9') {
                        const num2start = position;
                        position += 1;
                        while (input[position] >= '0' and input[position] <= '9') {
                            position += 1;
                        }
                        const num2 = try std.fmt.parseInt(i64, input[num2start..position], 10);
                        if (input[position] == ')' and mulEnabled) {
                            position += 1;
                            // print("multiplication: {s} \n", .{input[num1start - 4 .. position]});
                            // print("parsed num1: {d} \t", .{num1});
                            // print("parsed num2: {d} \n", .{num2});
                            // print("********** \n", .{});
                            result += num1 * num2;
                        }
                    }
                }
            }
        } else if (enable_dos == true) {
            if (eql(u8, input[position .. position + 4], "do()")) {
                mulEnabled = true;
                position += 4;
            } else if (eql(u8, input[position .. position + 7], "don't()")) {
                mulEnabled = false;
                position += 7;
            } else {
                position += 1;
            }
        } else {
            position += 1;
        }
    }
    return result;
}

test "test part 1" {
    const input: []const u8 = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";
    print("Working on input: {s} \n", .{input});

    const result = try parseMuls(input, false);
    print("{d} \n", .{result});
    try std.testing.expectEqual(161, result);
}

test "test part 2" {
    const input: []const u8 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";
    print("Working on input: {s} \n", .{input});

    const result = try parseMuls(input, true);
    print("{d} \n", .{result});
    try std.testing.expectEqual(48, result);
}
