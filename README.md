# caterpillar-tui
Caterpillar game for terminal using zig language

## Usage

```
Usage: ./caterpillar-tui [options]

Options:
  -s, --speed D       Set speed of the game to D (default: 50)
  -u, --user USER     Set user name to USER (default: User)
  -h, --help          Show this help and exit
```

Speed must be higher than `0` but less than `255`.

Setting user name to `""` will revert it to the default value: `User`.

## Important

NOTE: This example has been tested to work with the following build command:

```bash
zig build -Doptimize=ReleaseSmall -Dtarget=x86_64-linux-musl -Dstrip
```

Other targets and/or optimization level may fail.
