#!/usr/bin/env lua
--- Test script for tmux control mode client
-- Run with: lua test_tmux_client.lua

local tmux_client = require("user.tmux_client")

print("=" .. string.rep("=", 60))
print("Testing tmux control mode client")
print("=" .. string.rep("=", 60))
print()

local client = tmux_client.new()

print("1. Listing sessions:")
local sessions = client:list_sessions()
for _, session in ipairs(sessions) do
    print("   - " .. session)
end

print("\n2. Listing windows:")
local windows = client:list_windows()
for _, window in ipairs(windows) do
    print("   - " .. window)
end

print("\n3. Getting pane ID:")
local pane_id = client:get_pane_id()
print("   Pane ID: " .. (pane_id or "(none)"))

print("\n4. Getting pane output:")
local output = client:get_pane_output()
if output then
    print("   Output (last 5 lines):")
    local lines = {}
    for line in output:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    local start = math.max(1, #lines - 4)
    for i = start, #lines do
        print("   " .. lines[i])
    end
else
    print("   (no output)")
end

print("\n5. Testing command execution:")
local result = client:send_command("show-options -g prefix")
print("   Prefix key: " .. (result.response[1] or "(unknown)"))

print("\nClosing client...")
client:close()

print("\nTest complete!")
