//
//  StandardLibrary.swift
//  StarShip
//

import Foundation

extension Execution {

    // MARK: Add
    func stdAdd(arguments: [absoluteVariable]) -> Any {
        if arguments.count != 0 {
            if arguments[0].dataType == .number {
                var returningNumber = arguments[0].value as! Float
                for argument in arguments.dropFirst() {
                    if argument.dataType == .number {
                        returningNumber += argument.value as! Float
                    } else {
                        print("Fatal error: can't add anything but numbers")
                        exit(0)
                    }
                }
                return returningNumber
            } else {
                print("Fatal error: can't add anything but numbers")
                exit(0)
            }
        }
        return Float.zero
    }

    // MARK: Sub
    func stdSub(arguments: [absoluteVariable]) -> Any {
        if arguments.count != 0 {
            if arguments[0].dataType == .number {
                var returningNumber = arguments[0].value as! Float
                for argument in arguments.dropFirst() {
                    if argument.dataType == .number {
                        returningNumber -= argument.value as! Float
                    } else {
                        print("Fatal error: Can't subtract anything but numbers")
                        exit(0)
                    }
                }
                return returningNumber
            } else {
                print("Fatal error: Can't subtract anything but numbers")
                exit(0)
            }
        }
        return Float.zero
    }

    // MARK: Mul
    func stdMul(arguments: [absoluteVariable]) -> Any {
        if arguments.count != 0 {
            if arguments[0].dataType == .number {
                var returningNumber = arguments[0].value as! Float
                for argument in arguments.dropFirst() {
                    if argument.dataType == .number {
                        returningNumber *= argument.value as! Float
                    } else {
                        print("Fatal error: Can't mulitply anything but numbers")
                        exit(0)
                    }
                }
                return returningNumber
            } else {
                print("Fatal error: Can't mulitply anything but numbers")
                exit(0)
            }
        }
        return Float.zero
    }

    // MARK: Div
    func stdDiv(arguments: [absoluteVariable]) -> Any {
        if arguments.count != 0 {
            if arguments[0].dataType == .number {
                var returningNumber = arguments[0].value as! Float
                for argument in arguments.dropFirst() {
                    if argument.dataType == .number {
                        returningNumber /= argument.value as! Float
                    } else {
                        print("Fatal error: Can't divide anything but numbers")
                        exit(0)
                    }
                }
                return returningNumber
            } else {
                print("Fatal error: Can't divide anything but numbers")
                exit(0)
            }
        }
        return Float.zero
    }

    // MARK: Inc
    func stdInc(arguments: [absoluteVariable]) -> Any {
        if arguments.count == 1 {
            if arguments[0].dataType == .number {
                return arguments[0].value as! Float + 1
            } else {
                print("Fatal error: Can't inc anything but a number")
                exit(0)
            }
        } else {
            print("Fatal error: Inc can only take one argument")
            exit(0)
        }
    }

    // MARK: Dec
    func stdDec(arguments: [absoluteVariable]) -> Any {
        if arguments.count == 1 {
            if arguments[0].dataType == .number {
                return arguments[0].value as! Float - 1
            } else {
                print("Fatal error: Can't dec anything but a number")
                exit(0)
            }
        } else {
            print("Fatal error: Dec can only take one argument")
            exit(0)
        }
    }

    // MARK: For
    func stdFor(count: Float, functionCode: [Token]) -> Any {
        let parser = Parser().Run(functionCode)
        for _ in 0...Int(count) {
            let vm = Execution()
            vm.variableStack = variableStack
            vm.functionStack = functionStack
            vm.execute(parser)
        }
        return count
    }

    // MARK: If
    func stdIf(variable: Bool, functionCode: [Token]) -> Any {
        let parser = Parser().Run(functionCode)
        if variable {
            let vm = Execution()
            vm.variableStack = variableStack
            vm.functionStack = functionStack
            vm.execute(parser)
        }
        return variable
    }

    // MARK: Equal
    func stdEqual(first firstVar: absoluteVariable, second secondVar: absoluteVariable) -> Any {
        if firstVar.dataType == .string && secondVar.dataType == .string {
            return firstVar.value as! String == secondVar.value as! String
        } else if firstVar.dataType == .number && secondVar.dataType == .number {
            return firstVar.value as! Float == secondVar.value as! Float
        } else if firstVar.dataType == .bool && secondVar.dataType == .bool {
            return firstVar.value as! Bool == secondVar.value as! Bool
        } else {
            print("Fatal error: Different types can't be compared")
            exit(0)
        }
    }

    // MARK: Bigger
    func stdBigger(first firstVar: absoluteVariable, second secondVar: absoluteVariable) -> Any {
        if firstVar.dataType == .number && secondVar.dataType == .number {
            return firstVar.value as! Float > secondVar.value as! Float
        } else {
            print("Fatal error: Only number can be compared")
            exit(0)
        }
    }

    // MARK: Smaller
    func stdSmaller(first firstVar: absoluteVariable, second secondVar: absoluteVariable) -> Any {
        if firstVar.dataType == .number && secondVar.dataType == .number {
            return secondVar.value as! Float > firstVar.value as! Float
        } else {
            print("Fatal error: Only number can be compared")
            exit(0)
        }
    }
}
