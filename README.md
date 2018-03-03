# Nautilus Script

My personal Nautilus scripts.

## Requirement

Tested on Ubuntu 17.10, Bash 4.4

nameref is used, so Bash >= 4.3 is required.

## Install

Via SCons

``` bash
$ scons -Q install
```

Custom location can be specified by option `--install-dir`.

## Uninstall

``` bash
$ scons -Qc install
```

If installed to a custom location, add option `--install-dir`.

## Usage

Right click any file/directory in GNOME Files.

## Known Issues

- function "unarchive": can't unarchive and convmv SMB share files
  with invalid encoding filenames.
  Workaround: copy to local, unarchive, and copy back

## License

The MIT License (MIT). Please see [License File](LICENSE.md) for more information.
