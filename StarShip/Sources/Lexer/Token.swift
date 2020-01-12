//
//  Token.swift
//  StarShip
//

import Foundation

public struct Token {
    let type: TokenType
    let val: String
}

public enum TokenType {
    case equals
    case `let`
    case funcAssignment
    case name
    case amp
    case arrow
    case end
    case `return`

    case number
    case string
    case bool

    case array

    case eol
}
