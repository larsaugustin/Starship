//
//  ExecHelpers.swift
//  StarShip
//

import Foundation

extension Execution {

    // getting a number value from a token
    func resolveNumberForToken(_ token: Token) -> Float {
        if token.type == .name {
            if let absVar = variableStack.last(where: { variable -> Bool in
                variable.name == token.val
            }) {
                if absVar.dataType == .number {
                    return absVar.value as! Float
                } else {
                    print("Fatal error: Variable in not a number")
                    exit(0)
                }
            } else {
                print("Fatal error: Could not resolve variable")
                exit(0)
            }
        } else if token.type == .number {
            return Float(token.val)!
        } else {
            print("Fatal error: Could not resolve variable as name")
            exit(0)
        }
    }

    // getting a bool value for from a token
    func resolveBoolForToken(_ token: Token) -> Bool {
        if token.type == .name {
            if let absVar = variableStack.last(where: { variable -> Bool in
                variable.name == token.val
            }) {
                if absVar.dataType == .bool {
                    return absVar.value as! Bool
                } else {
                    print("Fatal error: Variable in not a bool")
                    exit(0)
                }
            } else {
                print("could not resolve variable")
                exit(0)
            }
        } else if token.type == .bool {
            return Bool(token.val.lowercased())!
        } else {
            print("could not resolve as name")
            exit(0)
        }
    }

    // translating a token into an absolute variable
    func getAbsoluteVarForToken(_ token: Token) -> absoluteVariable {
        switch token.type {
        case .name:
            guard let retunVar = variableStack.last(where: { absVar -> Bool in
                absVar.name == token.val
            }) else {
                print("variable for equal not found")
                exit(0)
            }
            return retunVar
        case .bool:
            return absoluteVariable(name: "absoluteVariable", value: Bool(token.val.lowercased())!, dataType: .bool)
        case .string:
            return absoluteVariable(name: "absoluteVariable", value: token.val, dataType: .string)
        case .number:
            return absoluteVariable(name: "absoluteVariable", value: Float(token.val) ?? 0, dataType: .number)
        default:
            print("unresolvable")
            exit(0)
        }
    }

    // get an absolute variable
    func getAbsoluteVariable(_ token: Token, named name: String) -> absoluteVariable? {
        switch token.type {
        case .number:
            return absoluteVariable(name: name, value: Float(token.val)!, dataType: .number)
        case .string:
            return absoluteVariable(name: name, value: token.val, dataType: .string)
        case .bool:
            return absoluteVariable(name: name, value: Bool(token.val.lowercased())!, dataType: .bool)
        default:
            return nil
        }
    }
}
