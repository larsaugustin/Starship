# StarShip

<p align="center">
    <img src="https://img.shields.io/badge/version-0.1-blueviolet" alt="Version: 0.1">
    <img src="https://img.shields.io/badge/extension-.strs-yellow" alt="Extension: .strs">
</p>

StarShip is an interpreted, strongly typed, and functional programming language written in Swift. The project includes a lexer, parser, and interpreter.

Since it's still in the early stages of development, it's pretty simple. Basic types like strings, booleans, and numbers are available. Arrays are planned, but not yet implemented.

Even when fully developed, this language shouldn't be used in a production environment. It is intended for having fun while playing around with the syntax and demonstrating the architecture of a simple interpreter.

*If you're interested in the architecture please read [this document](Docs/Architecture.md)*

## Example
The following code prints "hello world" ten times.

```
hello :: -> Bool
    "hello world"
    return True
end

let _ = for 10 hello
```

*The syntax is explained [here](Docs/Syntax.md)*

## Features
- Minimal, functional syntax
- A strong type system
- Basic types like bools, numbers, and strings
- Function definitions with arguments and return types
- Functions for conditional statements and repeated function calls
- A standard library with basic operations for comparing and simple numerical operations

## Building and running the CLI
Since StarShip doesn't use any dependencies, you *should* be able to open up the project in Xcode and create an archive by selecting "Archive" in the "Product" menu. You might have to change the default development team to your own one. If simply opening the project doesn't work, please open an issue.

After exporting the binary, you can drag it into a terminal window to use it immediately or copy the binary to `/usr/local/bin/`.

## Roadmap
- [ ] Arguments for if function
- [ ] Arrays
- [ ] Compile to C/JS or LLVM bitcode
- [ ] Linux support
- [ ] Automated unit tests

## IDE
I'm currently in the process of writing a small IDE for writing and running StarShip code on macOS and iOS. The IDE will be completely portable (you won't need to have the CLI installed) and will (probably) be released on the App Store.

## License
This project is released under the MIT license. See the `LICENSE` file for more info.
