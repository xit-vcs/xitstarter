const std = @import("std");
const xit = @import("xit");
const rp = xit.repo;

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;
    const io = init.io;

    const cwd_path = try std.process.currentPathAlloc(io, allocator);
    defer allocator.free(cwd_path);

    const work_path = try std.fs.path.resolve(allocator, &.{ cwd_path, "myrepo" });
    defer allocator.free(work_path);

    var repo = try rp.Repo(.xit, .{}).init(io, allocator, .{ .path = work_path });
    defer repo.deinit(io, allocator);

    try repo.addConfig(io, allocator, .{ .name = "user.name", .value = "mr magoo" });
    try repo.addConfig(io, allocator, .{ .name = "user.email", .value = "mister@magoo" });

    const readme = try repo.core.work_dir.createFile(io, "README.md", .{});
    defer readme.close(io);
    try readme.writeStreamingAll(io, "hello, world!");
    try repo.add(io, allocator, &.{"README.md"});

    const oid = try repo.commit(io, allocator, .{ .message = "initial commit" });
    std.debug.print("committed with object id: {s}\n", .{oid});
}
