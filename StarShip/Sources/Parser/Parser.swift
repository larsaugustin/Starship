//
//  Parser.swift
//  StarShip
//

import Foundation

public class Parser {
    public func Run(_ input: [Token]) -> [Instruction] {
        var instructions: [Instruction] = []
        var tokens = input

        tokens.append(Token(type: .eol, val: "\n")) // many parts of the compiler rely on the eol signal; if a program ends without an eol, the parser will crash

        while tokens.count > 0 {
            if tokens.first!.type == .let {
                /* Possible patterns:
                    - "let" name "=" function arguments?
                    - "let" name "=" value
                    - 0     1    2   3        4
                 */
                if tokens[3].type == .string || tokens[3].type == .number || tokens[3].type == .bool {
                    // MARK: Absolute variable
                    // "let" name "=" value
                    let newInstruction = absoluteVariable(name: tokens[1].val, value: Helpers().getValueFromToken(tokens[3]), dataType: Helpers().getDataType(tokens[3]))
                    instructions.append(newInstruction)
                    tokens.removeFirst(4)
                } else if tokens[3].type == .name {
                    // MARK: Function variable
                    // "let" name "=" functionName arguments
                    let firstLineBreak = tokens.firstIndex { token -> Bool in
                        token.type == .eol
                    }!
                    // arguments are tokens between index 5 and the first line break
                    // when a function gets called, there won't be amp tokens between the arguments
                    let arguments = Helpers().ArrayBetween(5, and: firstLineBreak, on: tokens) as! [Token]

                    let newInstruction = functionVariable(name: tokens[1].val, functionName: tokens[3].val, arguments: arguments)
                    instructions.append(newInstruction)
                    tokens.removeFirst(4 + arguments.count)
                }

            } else if tokens.first!.type == .string || tokens.first!.type == .number || tokens.first!.type == .bool {
                // MARK: Print absolute value
                // just the value on a line
                let newInstruction = printValue(value: Helpers().getValueFromToken(tokens.first!), dataType: Helpers().getDataType(tokens.first!))
                instructions.append(newInstruction)
                tokens.removeFirst()

            } else if tokens.first!.type == .name {
                // check if the next one is an eol or function definition
                // if the next token is an eol, the value of a variable will be printed, otherwise the next token is a function assignment (::)
                // there will always be two tokens left (that's why the final eol was added), so checking index 1 is okay
                if tokens[1].type == .funcAssignment {
                    // MARK: Function definition
                    // find the first eol to "measure" the function
                    let firstEolIndex = tokens.firstIndex { token -> Bool in
                        token.type == .eol
                    }
                    // a function can look pretty different, depending on the definition:
                    // an example: function :: argument & argument & argument -> return
                    // could also be function :: -> return
                    // or function :: argument

                    // if the function doesn't end with and end token, the parser ends the program
                    let firstEndIndex = tokens.firstIndex { token -> Bool in
                        token.type == .end
                    }
                    if firstEndIndex == nil {
                        print("Fatal error: Function definition did not end")
                        exit(0)

                    } else {
                        let relevantRange = Helpers().ArrayBetween(3, and: firstEolIndex!, on: tokens) as! [Token] // relevant range is the relevant range for searching return statements and arguments
                        let returnStatements = relevantRange.filter { token -> Bool in
                            token.type == .arrow
                        }
                        let mainContent = Helpers().ArrayBetween(firstEolIndex! + 1, and: firstEndIndex!, on: tokens) as! [Token]
                        if relevantRange.count == 0 {
                            // the function has no arguments and doesn't return anything
                            // right now a function has to return a value, but that might change in the future

                            let newInstruction = functionDefinition(name: tokens[0].val, functionArguments: [], returningTypes: [], innerCode: mainContent)
                            instructions.append(newInstruction)
                        } else if returnStatements.count == 0 {
                            // the function has arguments, but doesn't return anything
                            // right now a function has to return a value, but that might change in the future

                            // remove the amp tokens, which separate the argument types
                            let allArguments = relevantRange.filter { token -> Bool in
                                token.type != .amp
                            }

                            let newInstruction = functionDefinition(name: tokens[0].val, functionArguments: allArguments, returningTypes: [], innerCode: mainContent)
                            instructions.append(newInstruction)
                        } else if returnStatements.count == 1 {
                            // right now only one return type is supported

                            // the arrow indicates a return type
                            let parts = relevantRange.split { token -> Bool in
                                token.type == .arrow
                            }
                            // before the arrow are all the arguments, after the arrow the return types
                            let allArguments = parts.first!.filter { token -> Bool in
                                token.type != .amp
                            }

                            // this is in preparation for multiple return types, which might be coming in the future
                            let returnTypes = parts.last!.filter { token -> Bool in
                                token.type != .amp
                            }

                            if tokens[2].type != .arrow {
                                // the function returns and has arguments
                                let newInstruction = functionDefinition(name: tokens[0].val, functionArguments: allArguments, returningTypes: returnTypes, innerCode: mainContent)
                                instructions.append(newInstruction)
                            } else {
                                // the function returns, but has no arguments
                                let newInstruction = functionDefinition(name: tokens[0].val, functionArguments: [], returningTypes: returnTypes, innerCode: mainContent)
                                instructions.append(newInstruction)
                            }
                        }

                        tokens.removeFirst(firstEndIndex! + 1)
                    }
                } else if tokens[1].type == .eol {
                    // MARK: Variable print
                    let newInstruction = printVariable(name: tokens.first!.val)
                    instructions.append(newInstruction)
                    tokens.removeFirst()
                } else if tokens[1].type == .equals {
                    // this is a variable reassignment:
                    // name = value
                    // name = functionName arguments
                    if tokens[2].type == .string || tokens[2].type == .number || tokens[2].type == .bool {
                        // MARK: Function value redefinition
                        // "removeAndValue" removes the variable from the stack and then adds it back to the stack;
                        // more info in the execution module
                        let newInstruction = removeAndValue(name: tokens[0].val, value: Helpers().getValueFromToken(tokens[2]), dataType: Helpers().getDataType(tokens[2]))
                        instructions.append(newInstruction)
                        tokens.removeFirst(3)

                    } else if tokens[2].type == .name {
                        // MARK: Function variable redefinition
                        let firstLineBreak = tokens.firstIndex { token -> Bool in
                            token.type == .eol
                        }!

                        // get the arguments
                        let arguments = Helpers().ArrayBetween(4, and: firstLineBreak, on: tokens) as! [Token]

                        let newInstruction = removeAndReplace(name: tokens[0].val, functionName: tokens[2].val, arguments: arguments)
                        instructions.append(newInstruction)

                        tokens.removeFirst(3 + arguments.count)
                    }
                }
            } else if tokens.first!.type == .return {
                // MARK: Return statement
                // a variable or a value can be returned
                if tokens[1].type == .name {
                    let newInstruction = returnVariable(name: tokens[1].val)
                    instructions.append(newInstruction)
                } else if tokens[1].type == .string || tokens[1].type == .number || tokens[1].type == .bool {
                    let newInstruction = returnAbsoluteValue(value: Helpers().getValueFromToken(tokens[1]),
                                                             dataType: Helpers().getDataType(tokens[1]))
                    instructions.append(newInstruction)
                }
                tokens.removeFirst(2)
            } else {
                // MARK: Unknown pattern
                if tokens.first!.type != .eol { // eol will be resolved later
                    print("Fatal error: Unknown pattern")
                    exit(0)
                }
            }

            // resolving eol
            if tokens.first!.type == .eol {
                tokens = Array(tokens.dropFirst())
            }
        }
        return instructions
    }
}
