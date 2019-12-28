//
//  Execution.swift
//  StarShip
//

import Foundation

public class Execution {
    var variableStack: [absoluteVariable] = []      // all variables with their values
    var functionStack: [functionDefinition] = []    // all functions with their tokens
    var returningValue: Any? = nil                  // every execution unit has a return value
                                                    // since a new function uses a new execution
                                                    // unit. This way the returned value can be
                                                    // used after a unit has executed

    let stdFuncs = ["add",      // add two numbers
                    "sub",      // subtract one number from another
                    "mul",      // multiplies two numbers
                    "div",      // divides two numbers
                    "exit",     // exit a function
                    "inc",      // add one to a number
                    "dec",      // subtract one from a number
                    "for",      // repeat a function x times
                    "if",       // if a bool is true, run a function
                    "eql",      // checks if two values are the same
                    "big",      // checks if first value is bigger than the second one
                    "sml",      // checks if first value is smaller than the second one
                    "not"]      // flips a bool

    var variablesToReplace: [DataType] = []     // saves a data type between removal of a variable
                                                // and adding it back on.
                                                // more info in "removeAndReplace"

    public func execute(_ input: [Instruction]) {
        var instructions = input

        // first, we filter out all function definitions and add them to the function stack
        // this way functions defined at the bottom of the document can be called from the top of the document

        let functions = instructions.filter { instruction -> Bool in
            instruction.type == .functionDefinition
        }
        for function in functions {
            functionStack.append(function as! functionDefinition)
            instructions.remove(at: instructions.firstIndex(where: { inst -> Bool in
                let instFunc = inst as? functionDefinition
                let funcFunc = function as! functionDefinition
                if instFunc != nil {
                    return instFunc!.name == funcFunc.name
                } else {
                    return false
                }
            })!)
        }

        while instructions.count > 0 {
            if instructions.first!.type == .absoluteVariable {
                // MARK: Absolute variable definition
                variableStack.append(instructions.first! as! absoluteVariable)
                instructions.removeFirst()
            } else if instructions.first!.type == .functionDefinition {
                // MARK: Function definition
                // A function gets defined with all of its inner tokens; the tokens get parsed when the function is called; then the function will be executed in a new execution unit
                functionStack.append(instructions.first! as! functionDefinition)
                instructions.removeFirst()
            } else if instructions.first!.type == .printValue {
                // MARK: Print value
                print((instructions.first! as! printValue).value)
                instructions.removeFirst()
            } else if instructions.first!.type == .printVariable {
                // MARK: Print variable
                // the last variable with the name will be used, since an old variable with the same name can still be in the stack in certain situations
                // this is mostly just a bug waiting to be fixed
                let printingVariable = variableStack.last(where: { variable -> Bool in
                    variable.name == (instructions.first! as! printVariable).name
                })
                if printingVariable != nil {
                    print(printingVariable!.value)
                } else {
                    print("Fatal error: Variable to print not found")
                    exit(0)
                }
                instructions.removeFirst()
             } else if instructions.first!.type == .functionVariable {
                // MARK: Function variable definition
                // warning: Nested mess ahead

                if let functionToCall = functionStack.first(where: { definition -> Bool in
                    definition.name == (instructions.first! as! functionVariable).functionName &&
                    definition.functionArguments.count == (instructions.first! as! functionVariable).arguments.count
                }) {
                    // found function to call
                    let functionVar = (instructions.first! as! functionVariable)

                    // For defining the arguments as arg1, arg2, arg3, … we generate variable definition code, which will then be parsed and executed in the execution unit of the function
                    var addititonalDefinitions = ""
                    for index in 0..<functionVar.arguments.count {
                        let argument = functionVar.arguments[index]
                        var argumentValue = ""
                        if argument.type == .name {
                            // getting a value from the variable stack as the argument
                            if let argValue = variableStack.last(where: { variable -> Bool in
                                variable.name == argument.val
                            }) {
                                // check if the proposed type matches the type of the input
                                if Helpers().getTokenType(fromDataType: argValue.dataType) != Helpers().getTokenTypeFromString(functionToCall.functionArguments[index].val) {
                                    print("Fatal error: Argument types didn't match")
                                    exit(0)
                                }
                                argumentValue = "\"" + Helpers().getStringValue(argValue) + "\""
                            }
                        } else {
                            // using an absolute value as input
                            if argument.type != Helpers().getTokenTypeFromString(functionToCall.functionArguments[index].val) {
                                print("Fatal error: Argument types didn't match")
                                exit(0)
                            }
                            argumentValue = argument.type != .string ? argument.val : "\"" + argument.val + "\""
                        }
                        // now define generate the variable definition
                        addititonalDefinitions.append(contentsOf: "let arg" + String(index + 1) + " = " + argumentValue + " \n")
                    }

                    if variablesToReplace.count == 1 {
                        if Helpers().getDataType(fromString: functionToCall.returningTypes.first!.val) != variablesToReplace[0] {
                            print("variable that has to be replaced didn't match original type")
                            exit(0)
                        } else {
                            variablesToReplace.removeAll()
                        }
                    }
                    if functionToCall.returningTypes.count != 1 {
                        print("functions can only have one return argument for now")
                    }

                    // now the additional code gets tokenized and appended to the tokenized function code
                    let additionalCode = Lexer().Run(addititonalDefinitions)
                    var functionCode = functionToCall.innerCode
                    functionCode.insert(contentsOf: additionalCode, at: 0)
                    let parser = Parser().Run(functionCode)
                    // the function will be run in a new execution unit
                    let execUnit = Execution()
                    // the variable stack will be added to the new unit
                    execUnit.variableStack = variableStack
                    execUnit.functionStack = functionStack
                    execUnit.execute(parser)
                    // check if the unit returned
                    if (execUnit.returningValue != nil) {
                        let newVariable = absoluteVariable(name: functionVar.name, value: execUnit.returningValue!, dataType: Helpers().getDataType(fromString: functionToCall.returningTypes.first!.val))
                        if Helpers().checkIf(any: execUnit.returningValue!, matches: Helpers().getDataType(fromString: functionToCall.returningTypes.first!.val)) {
                            variableStack.append(newVariable)
                        } else {
                            // Exit if the function returned a different value from what it initially proposed
                            print("Fatal error: Retured value doesn't match return requirement")
                            exit(0)
                        }
                    } else {
                        // The function has to return right now
                        print("Fatal error: The function did not return")
                        exit(0)
                    }
                    instructions.removeFirst()
                } else if let functionToCall = stdFuncs.first(where: { definition -> Bool in
                    definition == (instructions.first! as! functionVariable).functionName
                }) {
                    // if the function isn't in the function stack, it might be a std function
                    let functionVar = (instructions.first! as! functionVariable)

                    var argumentVars: [absoluteVariable] = []
                    for index in 0..<functionVar.arguments.count {
                        let argument = functionVar.arguments[index]
                        if argument.type == .name {
                            if let argValue = variableStack.last(where: { variable -> Bool in
                                variable.name == argument.val
                            }) {
                                argumentVars.append(argValue)
                            } // only say the variable doesn't exist if it isn't an if or for function
                        } else {
                            guard let absVar = getAbsoluteVariable(argument, named: functionVar.name) else { return }
                            argumentVars.append(absVar)
                        }
                    }

                    var newVariable: absoluteVariable?

                    // switch to switch between the standard functions
                    // this code is pretty messy; might clean it up later
                    switch functionToCall {
                    case "add":
                        newVariable = absoluteVariable(name: functionVar.name, value: stdAdd(arguments: argumentVars), dataType: .number)
                    case "sub":
                        newVariable = absoluteVariable(name: functionVar.name, value: stdSub(arguments: argumentVars), dataType: .number)
                    case "mul":
                        newVariable = absoluteVariable(name: functionVar.name, value: stdMul(arguments: argumentVars), dataType: .number)
                    case "div":
                        newVariable = absoluteVariable(name: functionVar.name, value: stdDiv(arguments: argumentVars), dataType: .number)
                    case "exit":
                        print("Program exited")
                        exit(0) // 1 is the code for an in-program exit
                    case "inc":
                        newVariable = absoluteVariable(name: functionVar.name, value: stdInc(arguments: argumentVars), dataType: .number)
                    case "dec":
                        newVariable = absoluteVariable(name: functionVar.name, value: stdDec(arguments: argumentVars), dataType: .number)
                    case "for":
                        // some checking
                        if (functionVar.arguments.count == 2) {
                            let count = resolveNumberForToken(functionVar.arguments[0])
                            let function = functionStack.last { def -> Bool in
                                def.name == functionVar.arguments[1].val
                            }
                            if function == nil {
                                print("Fatal error: Function to repeat not found")
                                exit(0)
                            }
                            let result = stdFor(count: count, functionCode: function!.innerCode)
                            newVariable = absoluteVariable(name: functionVar.name, value: result, dataType: .number)
                        }
                    case "if":
                        // some checking
                        if (functionVar.arguments.count == 2) {
                            let isTrue = resolveBoolForToken(functionVar.arguments[0])
                            let function = functionStack.last { def -> Bool in
                                def.name == functionVar.arguments[1].val
                            }
                            if function == nil {
                                print("Fatal error: Function for condition not found")
                                exit(0)
                            }
                            let result = stdIf(variable: isTrue, functionCode: function!.innerCode)
                            newVariable = absoluteVariable(name: functionVar.name, value: result, dataType: .bool)
                        }
                    case "eql", "big", "sml":
                        if (functionVar.arguments.count == 2) {
                            let first = getAbsoluteVarForToken(functionVar.arguments[0])    // get absolute var before calling stdEqual
                            let second = getAbsoluteVarForToken(functionVar.arguments[1])   // get absolute var before calling stdEqual
                            var result: Any?
                            if functionToCall == "eql" {
                                result = stdEqual(first: first, second: second)
                            } else if functionToCall == "big" {
                                result = stdBigger(first: first, second: second)
                            } else {
                                // sml
                                result = stdSmaller(first: first, second: second)
                            }
                            newVariable = absoluteVariable(name: functionVar.name, value: result!, dataType: .bool)
                        }
                    case "not":
                        // just flip the bool
                        if functionVar.arguments.count == 1 {
                            var result = resolveBoolForToken(functionVar.arguments[0])
                            result.toggle()
                            newVariable = absoluteVariable(name: functionVar.name, value: result, dataType: .bool)
                        }
                    default:
                        return
                    }

                    // random errors
                    newVariable != nil ? variableStack.append(newVariable!) : print("Couldn't invoke standard function")
                    instructions.removeFirst()
                } else {
                    // if the function isn't a std func and not in the function stack, it doesn't exist
                    print("Fatal error: Function isn't yet defined")
                    exit(0)
                }
            } else if instructions.first!.type == .removeAndReplace {
                // MARK: Remove and replace variable
                // This is a hack to not have to write a second variable definition function
                // Essentially, we remove the variable from the variable stack, save its type and then add an instruction to re-add it to the variable stack
                // This isn't the best way to do this, but it works for now

                let firstIndex = variableStack.lastIndex { variable -> Bool in
                    variable.name == (instructions.first! as! removeAndReplace).name
                }
                if firstIndex != nil {
                    variablesToReplace.append(variableStack[firstIndex!].dataType) // add the datatype from the original variable
                    let removeAndRep = instructions.first! as! removeAndReplace
                    // New instruction to re-add the variable to the stack
                    let newInstruction = functionVariable(name: removeAndRep.name, functionName: removeAndRep.functionName, arguments: removeAndRep.arguments)
                    variableStack.remove(at: firstIndex!)
                    instructions.removeFirst()
                    instructions.insert(newInstruction, at: 0)
                } else {
                    print("Fatal error: Variable not yet defined")
                    exit(0)
                }
            } else if instructions.first!.type == .removeAndValue {
                // replace with value
                let removeAndVal = instructions.first! as! removeAndValue
                guard let firstVariable = variableStack.lastIndex(where: { variable -> Bool in
                    variable.name == removeAndVal.name
                }) else {
                    print("Fatal error: Could not find variable for reassignment")
                    exit(0)
                }
                if variableStack[firstVariable].dataType == removeAndVal.dataType {
                    variableStack[firstVariable].value = removeAndVal.value
                    instructions.removeFirst()
                } else {
                    print("Fatal error: Data types did not match")
                    exit(0)
                }
            } else if instructions.first!.type == .returnAbsoluteValue {
                // MARK: Return value
                let returnInstruction = instructions.first! as! returnAbsoluteValue
                returningValue = returnInstruction.value
                instructions.removeFirst()
            } else if instructions.first!.type == .returnVariable {
                // MARK: Return variable
                // the last variable with the name will be used, since an old variable with the same name can still be in the stack in certain situations
                // this is mostly just a bug waiting to be fixed
                let returnVariable = variableStack.last(where: { variable -> Bool in
                    variable.name == (instructions.first! as! returnVariable).name
                })
                if returnVariable != nil {
                    returningValue = returnVariable?.value
                } else {
                    print("Fatal error: Variable not found")
                    exit(0)
                }
                instructions.removeFirst()
            }
        }
    }
}
