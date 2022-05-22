# bin2dec

This project reads data from STDIN, converts 96-bit binary representation of an integer to 29-bit decima representation and then passes the result to STDOUT.

## Building

To build the app write the following into your terminal:

```bash
make
```

And that's all. The binary file to run should be in `./build/output/` folder.

## Usage

To run the app simply execute the following :

```bash
./build/output/main < [input_file] > [output_file]
```
