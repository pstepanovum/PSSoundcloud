#!/usr/bin/env python3
"""Remove tweaks someone else injected into an IPA, so only PSSoundcloud is added.

Shared IPAs often come with extra dylibs (other tweaks, sideload fixes) loaded by the
app binary. This deletes every loose .dylib in the app's Frameworks folder except
Apple's Swift runtime libraries, removes the load commands pointing at them, and
drops the leftover cyan.entitlements file.

Usage: clean-ipa.py <input.ipa> <output.ipa>
"""

import plistlib
import struct
import sys
import zipfile

MH_MAGIC_64 = 0xFEEDFACF
LC_LOAD_DYLIB = 0xC
LC_LOAD_WEAK_DYLIB = 0x80000018
HEADER_SIZE = 32


def is_injected(name):
    """A dylib in Frameworks/ that isn't part of the Swift runtime."""
    filename = name.rsplit("/", 1)[-1]
    return filename.endswith(".dylib") and not filename.startswith("libswift")


def strip_load_commands(binary, dylib_paths):
    """Return the binary without load commands for the given @rpath dylibs, and the names removed."""
    magic, cputype, cpusubtype, filetype, ncmds, sizeofcmds, flags, reserved = struct.unpack_from("<8I", binary, 0)
    if magic != MH_MAGIC_64:
        sys.exit("Only thin 64-bit Mach-O binaries are supported")

    kept, removed = [], []
    offset = HEADER_SIZE
    for _ in range(ncmds):
        cmd, cmdsize = struct.unpack_from("<2I", binary, offset)
        command = binary[offset:offset + cmdsize]

        if cmd in (LC_LOAD_DYLIB, LC_LOAD_WEAK_DYLIB):
            name_offset = struct.unpack_from("<I", command, 8)[0]
            name = command[name_offset:].split(b"\0", 1)[0].decode()
            if name in dylib_paths:
                removed.append(name)
                offset += cmdsize
                continue

        kept.append(command)
        offset += cmdsize

    commands = b"".join(kept)
    header = struct.pack("<8I", magic, cputype, cpusubtype, filetype, len(kept), len(commands), flags, reserved)

    # Pad with zeros to the original size, so nothing after the load commands moves
    padding = b"\0" * (sizeofcmds - len(commands))
    return header + commands + padding + binary[HEADER_SIZE + sizeofcmds:], removed


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    source, destination = sys.argv[1:]

    with zipfile.ZipFile(source) as ipa:
        names = ipa.namelist()
        app = next(name.split("/")[1] for name in names if name.startswith("Payload/") and name.split("/")[1].endswith(".app"))
        app_dir = f"Payload/{app}/"

        info = plistlib.loads(ipa.read(app_dir + "Info.plist"))
        executable = app_dir + info["CFBundleExecutable"]

        frameworks_dir = app_dir + "Frameworks/"
        injected = [name for name in names if name.startswith(frameworks_dir) and "/" not in name[len(frameworks_dir):] and is_injected(name)]
        skipped = set(injected) | {app_dir + "cyan.entitlements"}

        binary, removed = strip_load_commands(ipa.read(executable), {"@rpath/" + name[len(frameworks_dir):] for name in injected})

        with zipfile.ZipFile(destination, "w", zipfile.ZIP_DEFLATED) as output:
            for item in ipa.infolist():
                if item.filename in skipped:
                    continue
                data = binary if item.filename == executable else ipa.read(item)
                output.writestr(item, data)

    for name in injected:
        print(f"Removed {name[len(frameworks_dir):]}")
    for name in removed:
        print(f"Removed load command {name}")


if __name__ == "__main__":
    main()
