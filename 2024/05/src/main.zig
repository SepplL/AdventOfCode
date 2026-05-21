const std = @import("std");
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
    const result = try parse_printing_rules(buffer, false);
    print("Result for sum after applying part 1 printing rules: {d}", .{result});
}

fn parse_printing_rules(input: []const u8, verbose: bool) !usize {
    var result: usize = 0;
    const max_size: usize = 100;

    // split input data on blank line separating part rules and part instructions
    const split = std.mem.splitSequence(u8, input, "\n\n");

    var it = split;
    const rules = it.next().?;
    const instruct = it.next().?;

    // print("Buffer {s}", .{input});
    // print("rules {s} \n", .{rules});
    // print("instructions {s} \n", .{instruct});

    // 2d 100x100 lookup matrix, non symmetry based on rules
    var rule_table: [max_size + 1][max_size + 1]bool = .{.{false} ** (max_size + 1)} ** (max_size + 1);
    var rule_lines = std.mem.splitSequence(u8, rules, "\n");
    while (rule_lines.next()) |rl| {
        if (rl.len == 0) continue;
        var parts = std.mem.splitSequence(u8, rl, "|");

        const left_part = try std.fmt.parseInt(usize, parts.next().?, 10);
        const right_part = try std.fmt.parseInt(usize, parts.next().?, 10);
        rule_table[left_part][right_part] = true;
    }

    var instruct_lines = std.mem.splitSequence(u8, instruct, "\n");
    while (instruct_lines.next()) |line| {
        if (line.len == 0) continue; // safety guard
        var legal_order: bool = true;

        // init 1d vector to keep track of visited numbers
        var nums: [64]usize = undefined;
        var count: usize = 0;

        var numbers = std.mem.splitSequence(u8, line, ",");
        var prev_number: ?[]const u8 = null;
        while (numbers.next()) |n| {
            if (prev_number == null) {
                prev_number = n;

                const curr = try std.fmt.parseInt(usize, n, 10);
                nums[count] = curr;
                count += 1;

                continue;
            }
            const prev = try std.fmt.parseInt(usize, prev_number.?, 10);
            const curr = try std.fmt.parseInt(usize, n, 10);

            nums[count] = curr;
            if (rule_table[prev][curr] == false) {
                legal_order = false;
            }

            prev_number = n;
            count += 1;
        }
        if (verbose == true) {
            if (legal_order == true) {
                print("Line with instructions {s} are legal!\n", .{line});
            } else {
                print("Line with instructions {s} are NOT legal!\n", .{line});
            }
        }
        if (legal_order == true) {
            // add middle number to result
            const middle = nums[count / 2];
            result += middle;
        }
    }
    return result;
}

test "day 05 part 01" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        _ = gpa.deinit();
    }

    // Open the file
    const file = try std.fs.cwd().openFile("test-input.txt", .{});
    defer file.close();

    // Read file into buffer
    const stat = try file.stat();
    const buffer = try file.readToEndAlloc(allocator, stat.size);
    defer allocator.free(buffer);

    print("Working on input: \n{s}\n", .{buffer});

    const result = try parse_printing_rules(buffer, true);
    print("Calculated Sum {d} in test input. \n", .{result});
    try std.testing.expectEqual(143, result);
}
