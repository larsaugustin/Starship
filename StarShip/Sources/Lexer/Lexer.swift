//
//  Lexer.swift
//  StarShip
//

import Foundation

public class Lexer {

    struct Keyword {
        var value: String
        var type: TokenType
    }
    let keywords: [Keyword] = [
        Keyword(value: " = ", type: .equals),
        Keyword(value: " :: ", type: .funcAssignment),
        Keyword(value: "& ", type: .amp),
        Keyword(value: "->", type: .arrow),
        Keyword(value: "end", type: .end),
        Keyword(value: "let ", type: .let),
        Keyword(value: "rtrn ", type: .return),
        Keyword(value: "True", type: .bool),
        Keyword(value: "False", type: .bool),
        Keyword(value: "\n", type: .eol)]

    func Run(_ input: String) -> [Token] {
        var tokens = [Token]()
        var program = input

        program = program.replacingOccurrences(of: "\n", with: " \n ") // direct line breaks can confuse the lexer

        while program.count > 0 {
            program = program.trimmingCharacters(in: .whitespaces) // remove whitespace at the beginning of the program
            if let firstKeyword = keywords.first(where: { keyword -> Bool in
                program.hasPrefix(keyword.value)
            }) {
                let newToken = Token(type: firstKeyword.type, val: firstKeyword.value)
                tokens.append(newToken)
                program.removeFirst(firstKeyword.value.count)
            } else if program.hasPrefix("--") { // comment, starts with "--" ends at new line
                let parts = String(program.dropFirst()).split(separator: "\n")
                program = (parts.count != 1) ? String(parts.dropFirst().joined(separator: "\n")) : "" // no new token; skipping the comment
            } else if program.hasPrefix("\"") { // string literal, enclosed value
                let parts = String(program.dropFirst()).split(separator: "\"")
                let newToken = Token(type: .string, val: String(parts[0]))
                tokens.append(newToken)
                program = (parts.count != 1) ? String(parts.dropFirst().joined(separator: "\"")) : ""
            } else {
                let seperatedItems = program.split(separator: " ")
                if let _ = Float(seperatedItems[0]) { // if a float can be made from the token, it's a number
                    let newToken = Token(type: .number, val: String(seperatedItems[0]))
                    tokens.append(newToken)
                    program.removeFirst(seperatedItems[0].count)
                } else { // otherwise it's a name
                    let newToken = Token(type: .name, val: String(seperatedItems[0]))
                    tokens.append(newToken)
                    program.removeFirst(seperatedItems[0].count)
                }
            }
        }

        return tokens
    }
}
