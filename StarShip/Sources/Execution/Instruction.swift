//
//  Instruction.swift
//  StarShip
//

import Foundation

public protocol Instruction {
    var type: InstructionType { get }
}

public enum InstructionType {
    case absoluteVariable
    case functionVariable
    case functionDefinition
    case functionCall
    case printVariable
    case printValue
    case removeAndReplace
    case returnVariable
    case returnAbsoluteValue
    case removeAndValue
}

public enum DataType {
    case string
    case number
    case bool

    case stringArray
    case numberArray
    case boolArray
}

public struct absoluteVariable: Instruction {
    public var type = InstructionType.absoluteVariable
    var name: String
    var value: Any
    var dataType: DataType
}

struct returnVariable: Instruction {
    var type = InstructionType.returnVariable
    var name: String
}

struct returnAbsoluteValue: Instruction {
    var type = InstructionType.returnAbsoluteValue
    var value: Any
    var dataType: DataType
}

struct functionVariable: Instruction {
    var type = InstructionType.functionVariable
    var name: String
    var functionName: String
    var arguments: [Token]
}

struct functionDefinition: Instruction {
    var type = InstructionType.functionDefinition
    var name: String
    var functionArguments: [Token]
    var returningTypes: [Token]
    var innerCode: [Token] // code is interpreted when the function gets called
}

struct functionCall: Instruction {
    var type = InstructionType.functionCall
    var name: String
    var arguments: [Token]
}

struct printVariable: Instruction {
    var type = InstructionType.printVariable
    var name: String
}

struct printValue: Instruction {
    var type = InstructionType.printValue
    var value: Any
    var dataType: DataType
}

struct removeAndReplace: Instruction {
    var type = InstructionType.removeAndReplace
    var name: String
    var functionName: String
    var arguments: [Token]
}

struct removeAndValue: Instruction {
    var type = InstructionType.removeAndValue
    var name: String
    var value: Any
    var dataType: DataType
}
