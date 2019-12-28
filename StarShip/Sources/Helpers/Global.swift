//
//  Global.swift
//  StarShip
//

import Foundation

// global helper functions
public class Helpers {
    public func ArrayBetween(_ first: Int, and second: Int, on input: Array<Any>) -> Array<Any> {
        Array(input.dropLast(input.count - second).dropFirst(first - 1))
    }

    // translating a string description of a data type into a data type
    public func getDataType(fromString string: String) -> DataType {
        switch string {
        case "String":
            return .string
        case "Bool":
            return .bool
        case "Number":
            return .number
        default:
            return .string
        }
    }

    // getting a string value from an absolute variable
    public func getStringValue(_ variable: absoluteVariable) -> String {
        switch variable.dataType {
        case .string:
            return variable.value as! String
        case .bool:
            return String(variable.value as! Bool)
        case .number:
            return String(variable.value as! Float)
        }
    }

    // getting the token type from a string
    public func getTokenTypeFromString(_ input: String) -> TokenType {
        if input == "String" {
            return .string
        } else if input == "Bool" {
            return .bool
        } else if input == "Number" {
            return .number
        } else {
            print("undefined type")
            exit(0)
        }
    }

    // checking if a value matches a data type
    public func checkIf(any input: Any, matches dataType: DataType) -> Bool {
        if dataType == .bool {
            return input as? Bool != nil
        } else if dataType == .number {
            return input as? Float != nil
        } else if dataType == .string {
            return input as? String != nil
        } else {
            return false
        }
    }

    // translating a data type into a token type
    public func getTokenType(fromDataType dataType: DataType) -> TokenType {
        switch dataType {
        case .bool:
            return .bool
        case .number:
            return .number
        case .string:
            return .string
        }
    }

    // returns the real value of a token as any
    public func getValueFromToken(_ token: Token) -> Any {
        if token.type == .bool {
            return Bool(token.val.lowercased())!
        } else if token.type == .number {
            return Float(token.val)!
        } else {
            return token.val
        }
    }

    // returns the data type for the value of a token
    public func getDataType(_ token: Token) -> DataType {
        if token.type == .bool {
            return .bool
        } else if token.type == .number {
            return .number
        } else {
            return .string
        }
    }

}
