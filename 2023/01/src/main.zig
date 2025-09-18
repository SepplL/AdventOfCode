const std = @import("std");
const print = std.debug.print;

const wordNumber: [10][]const u8 = .{
    "zero",
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine",
};

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!

    // 01 code - figure out good zig structure over time
    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [512]u8 = undefined;
    var calibrationValue: i64 = 0;
    var printBuffer: [256]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const lineValue: u16 = findNumbers(line);
        const str = try std.fmt.bufPrint(&printBuffer, "{any}", .{lineValue});
        print("The local line Value is: {s} \n", .{str});
        calibrationValue += lineValue;
    }
    const str = try std.fmt.bufPrint(&printBuffer, "{any}", .{calibrationValue});
    print("The calibration Value is: {s}", .{str});
}

fn findNumbers(buf: []u8) u16 {
    print("{s} \n", .{buf});
    const numberConvOffset: u8 = 48;
    var numberList: [64]u8 = undefined;
    var numberListCounter: usize = 0;
    var numbers: [2]u8 = undefined;
    // solves old part1
    // for (buf) |i| {
    //     if (std.ascii.isDigit(i)) {
    //         numbers[0] = @as(u8, i) - numberConvOffset;
    //         // numbers[0] = try std.fmt.parseInt(u8, i, 10);
    //         break;
    //     }
    // }
    // var i: usize = buf.len;
    // while (i > 0) {
    //     i -= 1;
    //     if (std.ascii.isDigit(buf[i])) {
    //         numbers[1] = @as(u8, buf[i]) - numberConvOffset;
    //         break;
    //     }
    // }
    //
    // New part 2 with words:
    var i: usize = 0;
    while (i < buf.len) {
        if (std.ascii.isDigit(buf[i])) {
            const newNum: u8 = @as(u8, buf[i]) - numberConvOffset;
            numberList[numberListCounter] = newNum;
            numberListCounter += 1;
        }
        // search for word matches
        var newNum: u8 = 0;
        while (newNum < wordNumber.len) {
            const length = wordNumber[newNum].len;
            if (i + length > buf.len) {
                newNum += 1;
                continue;
            }
            var match: bool = true;
            var newNumj: u8 = 0;
            while (newNumj < length) {
                if (buf[i + newNumj] != wordNumber[newNum][newNumj]) {
                    match = false;
                }
                newNumj += 1;
            }
            if (match) {
                // print("Hooray - match found! newNumber: {} \n", .{newNum});
                numberList[numberListCounter] = newNum;
                numberListCounter += 1;
            }
            // print("buf: {s}, newNum: {} \n", .{ buf[i .. i + length], newNum });
            newNum += 1;
        }
        i += 1;
    }
    print("Full number list: {any} \n", .{numberList[0..numberListCounter]});
    numbers[0] = numberList[0];
    numbers[1] = numberList[numberListCounter - 1];
    // print("Numbers: {d}\n", .{numbers});
    const result_number: u16 = @as(u16, numbers[0]) * 10 + @as(u16, numbers[1]);
    return result_number;
}

test "simple test" {
    const line: [1][]const u8 = .{"onethreenfkgrvsevenkczctlgkt7"};
    print("Test input: {s}\n", .{line});
    // const lineValue: u16 = findNumbers(line);
    // const str = try std.fmt.bufPrint(&line, "{any}", .{lineValue});
    // print("The local line Value is: {s} \n", .{str});
}
