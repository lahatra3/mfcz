# mfcz
**` mfcz `** is a cli tool written in [`Zig`](https://ziglang.org/) for merging the contents of files in a directory into a single file.

To run:

```bash
$ ~ zig build run
```

To build

- For Linux (arch x86_64)

```bash
$ ~ zig build -Dtarget=x86_64-linux -Doptimize=ReleaseSafe
```

- For Windows (arch x86_64):

```bash
$ ~ zig build -Dtarget=x86_64-windows -Doptimize=ReleaseSafe
```

How to use it ?

```bash
$ ~ ./mfcz --ext=".csv" --dir="path/to/directory" --sink="path/to/destination_file"
```