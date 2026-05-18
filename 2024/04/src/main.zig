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
    const result = try parse_xmas(buffer);
    print("The parsed result is: {d} \n", .{result});

    const result2 = try parse_x_mas(buffer);
    print("The parsed result for part 2 (X-MAS'es) is: {d} \n", .{result2});
}

fn parse_xmas(input: []const u8) !i64 {
    var result: i64 = 0;

    // initial parsing run for knowing the size of the input
    const stride_length: usize = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    const lines: usize = input.len / stride_length;
    const chars_per_line: usize = stride_length - 1;

    print("len of input: {d} \n", .{input.len});
    print("chars per line: {d} \n", .{chars_per_line});
    print("number of lines: {d} \n", .{lines});

    // search for: horizontal forwards and backwards
    var line: usize = 0;
    var pos: usize = 0;

    while (line < lines) {
        while (pos < chars_per_line - 3) {
            const index: usize = line * stride_length + pos;
            // print("testing horizontal word: {s} \n", .{input[index .. index + 4]});
            if (eql(u8, input[index .. index + 4], "XMAS")) {
                result += 1;
            } else if (eql(u8, input[index .. index + 4], "SAMX")) {
                result += 1;
            }

            pos += 1;
        }
        line += 1;
        pos = 0;
    }
    print("result after horizontal search: {d} \n", .{result});

    // search for: vertical upwards and downwards
    line = 0;
    pos = 0;
    while (pos < chars_per_line) {
        while (line < lines - 3) {
            var indices: [4]usize = undefined;
            for (0 .. 4) |i| {
                indices[i] = (line + i) * stride_length + pos;
            }
            var word: [4]u8 = undefined;

            for (indices, 0..) |index, word_index| {
                word[word_index] = input[index];
            }
            // print("testing vertical word: {s} \n", .{word});
            if (eql(u8, &word, "XMAS")) {
                result += 1;
            } else if (eql(u8, &word, "SAMX")) {
                result += 1;
            }

            line += 1;
        }
        pos += 1;
        line = 0;
    }
    print("result after vertical search: {d} \n", .{result});

    // search for: diagonal upper left to lower right and upper right to lower left
    line = 0;
    pos = 0;
    while (pos < chars_per_line - 3) {
        while (line < lines - 3) {

            // upper left -> lower right
            var indices: [4]usize = undefined;
            for (0..4) |i| {
                indices[i] = (line + i) * stride_length + pos + i;
            }
            var word: [4]u8 = undefined;

            for (indices, 0..) |index, word_index| {
                word[word_index] = input[index];
            }
            // print("testing vertical word: {s} \n", .{word});
            if (eql(u8, &word, "XMAS")) {
                result += 1;
            } else if (eql(u8, &word, "SAMX")) {
                result += 1;
            }

            // upper right -> lower left
            indices = undefined;
            for (0..4) |i| {
                indices[i] = (line + i) * stride_length + pos + 3 - i;
            }
            word = undefined;

            for (indices, 0..) |index, word_index| {
                word[word_index] = input[index];
            }
            // print("testing vertical word: {s} \n", .{word});
            if (eql(u8, &word, "XMAS")) {
                result += 1;
            } else if (eql(u8, &word, "SAMX")) {
                result += 1;
            }

            line += 1;
        }
        pos += 1;
        line = 0;
    }
    print("result after diagonal search: {d} \n", .{result});
    return result;
}

fn parse_x_mas(input: []const u8) !i64 {
    var result: i64 = 0;

    // initial parsing run for knowing the size of the input
    const stride_length: usize = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    const lines: usize = input.len / stride_length;
    const chars_per_line: usize = stride_length - 1;

    // search for: x-mas diagonal patterns of overlapping mas only
    // search for: diagonal upper left to lower right and upper right to lower left
    var line: usize = 0;
    var pos: usize = 0;

    while (pos < chars_per_line - 2) {
        while (line < lines - 2) {

            // upper left -> lower right
            var indices: [3]usize = undefined;
            for (0..3) |i| {
                indices[i] = (line + i) * stride_length + pos + i;
            }
            var word: [3]u8 = undefined;

            for (indices, 0..) |index, word_index| {
                word[word_index] = input[index];
            }
            // print("testing vertical word: {s} \n", .{word});
            if (eql(u8, &word, "MAS") or eql(u8, &word, "SAM")) {

                // upper right -> lower left
                indices = undefined;
                for (0..3) |i| {
                    indices[i] = (line + i) * stride_length + pos + 2 - i;
                }
                word = undefined;

                for (indices, 0..) |index, word_index| {
                    word[word_index] = input[index];
                }
                // print("testing vertical word: {s} \n", .{word});
                if (eql(u8, &word, "MAS") or eql(u8, &word, "SAM")) {
                    result += 1;
                }
            }

            line += 1;
        }
        pos += 1;
        line = 0;
    }
    return result;
}

test "xmas count part 1" {
    const input: []const u8 = "MMMSXXMASM\nMSAMXMSMSA\nAMXSXMAAMM\nMSAMASMSMX\nXMASAMXAMM\nXXAMMXXAMA\nSMSMSASXSS\nSAXAMASAAA\nMAMMMXMMMM\nMXMXAXMASX\n";
    print("Working on input: \n{s}\n", .{input});

    const result = try parse_xmas(input);
    print("Found {d} xmas in test input. \n", .{result});
    try std.testing.expectEqual(18, result);
}

test "xmas count part 2" {
    const input: []const u8 = "MMMSXXMASM\nMSAMXMSMSA\nAMXSXMAAMM\nMSAMASMSMX\nXMASAMXAMM\nXXAMMXXAMA\nSMSMSASXSS\nSAXAMASAAA\nMAMMMXMMMM\nMXMXAXMASX\n";
    print("Working on input: \n{s}\n", .{input});

    const result = try parse_x_mas(input);
    print("Found {d} xmas in test input. \n", .{result});
    try std.testing.expectEqual(9, result);
}
