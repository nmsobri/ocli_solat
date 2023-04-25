# ocli_solat
Cli app to fetch prayer time from Jakim site using odin programming language

## Build instruction
1. `git clone --recurse-submodules -j8 git@github.com:nmsobri/ocli_solat.git`
2. `cd ocli_solat`
3. `odin build . -out:solat.exe -o:speed`
4. copy and rename `curl.dll` from `ocli_solat/ocurl/external/` to `libcurl.dll` inside folder `ocli_solat`
5. run `solat.exe`
