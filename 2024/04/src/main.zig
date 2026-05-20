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

    var timer = try std.time.Timer.start();
    var sum1: i64 = 0;
    var sum2: i64 = 0;
    const iterations: usize = 10000;

    // Read file into buffer
    const stat = try file.stat();
    const buffer = try file.readToEndAlloc(allocator, stat.size);
    defer allocator.free(buffer);

    // print("Buffer {s}", .{buffer});
    for (0..iterations) |_| {
        sum1 += try parse_xmas(buffer);
        sum2 += try parse_x_mas(buffer);
    }

    const elapsed = timer.read();  // time in ns
    const per_run = elapsed / iterations;

    print("The parsed result is: {d} \n", .{@divTrunc(sum1, iterations)});
    print("The parsed result for part 2 (X-MAS'es) is: {d} \n", .{@divTrunc(sum2, iterations)});
    print("Total elapsed time: {d} ns\n", .{elapsed});
    print("per run: {d} ns\n", .{per_run});
}

fn parse_xmas(input: []const u8) !i64 {
    var result: i64 = 0;

    // initial parsing run for knowing the size of the input
    const stride_length: usize = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    const lines: usize = input.len / stride_length;
    const chars_per_line: usize = stride_length - 1;

    // print("len of input: {d} \n", .{input.len});
    // print("chars per line: {d} \n", .{chars_per_line});
    // print("number of lines: {d} \n", .{lines});

    // search for: horizontal forwards and backwards
    var line: usize = 0;
    var pos: usize = 0;

    const xmas: u32 = @bitCast([4]u8{ 'X','M','A','S' });
    const samx: u32 = @bitCast([4]u8{ 'S','A','M','X' });

    while (line < lines) {
        const row: usize = line * stride_length;
        while (pos < chars_per_line - 3) {
            const ind: usize = row + pos;
            const word: u32 = @bitCast(input[ind ..][0 .. 4].*);
            // print("testing horizontal word: {s} \n", .{input[index .. index + 4]});
            if (word == xmas or word == samx) result += 1;

            pos += 1;
        }
        line += 1;
        pos = 0;
    }
    // print("result after horizontal search: {d} \n", .{result});

    // search for: vertical upwards and downwards
    line = 0;
    pos = 0;
    while (pos < chars_per_line) {
        while (line < lines - 3) {
            const ind: usize = line * stride_length + pos;
            const word: u32 =
                (@as(u32, input[ind + 0 * stride_length]) << 0) |
                (@as(u32, input[ind + 1 * stride_length]) << 8) |
                (@as(u32, input[ind + 2 * stride_length]) << 16) |
                (@as(u32, input[ind + 3 * stride_length]) << 24);

            // print("testing vertical word: {s} \n", .{word});
            if (word == xmas or word == samx) result += 1;

            line += 1;
        }
        pos += 1;
        line = 0;
    }
    // print("result after vertical search: {d} \n", .{result});

    // search for: diagonal upper left to lower right and upper right to lower left
    line = 0;
    pos = 0;
    while (pos < chars_per_line - 3) {
        while (line < lines - 3) {

            // upper left -> lower right
            const ind: usize = line * stride_length + pos;
            const word1: u32 =
                (@as(u32, input[ind + 0 * stride_length]) << 0) |
                (@as(u32, input[ind + 1 * (stride_length + 1)]) << 8) |
                (@as(u32, input[ind + 2 * (stride_length + 1)]) << 16) |
                (@as(u32, input[ind + 3 * (stride_length + 1)]) << 24);

            // print("testing vertical word: {s} \n", .{word});
            if (word1 == xmas or word1 == samx) result += 1;

            // upper right -> lower left
            const idx: usize = line * stride_length + pos + 3;
            const word2: u32 =
                (@as(u32, input[idx + 0 * stride_length]) << 0) |
                (@as(u32, input[idx + 1 * (stride_length - 1)]) << 8) |
                (@as(u32, input[idx + 2 * (stride_length - 1)]) << 16) |
                (@as(u32, input[idx + 3 * (stride_length - 1)]) << 24);

            // print("testing vertical word: {s} \n", .{word});
            if (word2 == xmas or word2 == samx) result += 1;

            line += 1;
        }
        pos += 1;
        line = 0;
    }
    // print("result after diagonal search: {d} \n", .{result});
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
    // only search for initial "A" in space 1 .. max - 1 for lines and chars
    var line: usize = 1;
    var pos: usize = 1;

    const mas: u24 = @bitCast([3]u8{ 'M','A','S' });
    const sam: u24 = @bitCast([3]u8{ 'S','A','M' });
    while (pos < chars_per_line - 1) {
        while (line < lines - 1) {

            const ind: usize = line * stride_length + pos;
            if (input[ind] == 'A') {
                // found necessary middle "A" for X-MAS
                // check if cross pattern matches in 1 step

                const word1: u24 =
                    (@as(u24, input[ind - 1 * (stride_length + 1)]) << 0) |
                    (@as(u24, input[ind + 0 * (stride_length + 1)]) << 8) |
                    (@as(u24, input[ind + 1 * (stride_length + 1)]) << 16);
                const word2: u24 =
                    (@as(u24, input[ind - 1 * (stride_length - 1)]) << 0) |
                    (@as(u24, input[ind + 0 * (stride_length - 1)]) << 8) |
                    (@as(u24, input[ind + 1 * (stride_length - 1)]) << 16);
                if ((word1 == mas or word1 == sam) and (word2 == mas or word2 == sam)) {
                    result += 1;
                }
            }

            line += 1;
        }
        pos += 1;
        line = 1;
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
