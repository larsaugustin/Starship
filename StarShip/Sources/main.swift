//
//  main.swift
//  StarShip
//

import Foundation

print("🚀 Welcome to StarShip")

var inputData: Data?

if CommandLine.arguments.count != 2 {
    // no input file
    print("Usage (if installed):")
    print("-> starship [path to file]")
    exit(0)
} else {
    let arguments = CommandLine.arguments

    if !arguments[1].hasSuffix("strs") {
        print("Fatal Error: Can only execute StarShip (strs) files.")
        exit(0)
    }

    if arguments[1].hasPrefix("/") {
        // absolute path input
        inputData = FileManager.default.contents(atPath: arguments[1])
    } else if arguments[1].hasPrefix("~") {
        // user path
        let userPath = FileManager.default.homeDirectoryForCurrentUser.relativePath
        let pathToFile = String(arguments[1].dropFirst())
        inputData = FileManager.default.contents(atPath: userPath + pathToFile)
    } else {
        // plain input file
        let completePath = FileManager.default.currentDirectoryPath + "/" + CommandLine.arguments[1]
        inputData = FileManager.default.contents(atPath: completePath)
    }
}

if inputData == nil {
    print("Fatal error: Could not find file")
    exit(0)
}

guard let program = String(data: inputData!, encoding: .utf8) else {
    print("Fatal error: Could not open file as text")
    exit(0)
}

var vm = Execution()
vm.execute(Parser().Run(Lexer().Run(program)))
