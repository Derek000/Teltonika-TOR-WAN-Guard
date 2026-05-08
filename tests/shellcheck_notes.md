# Shellcheck Notes

These scripts are intended for Teltonika RutOS / OpenWRT-style environments where BusyBox `sh` is common.

Recommended local lint command before publishing changes:

```sh
shellcheck scripts/*.sh
```

Some warnings may need to be assessed in the context of BusyBox compatibility.
