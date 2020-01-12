# Syntax
## Introduction
StarShip uses a functional syntax and only has a few patterns. This makes the syntax easy to learn and parse but might need some adjusting when coming from a language like Swift or Python.

## Function definitions
Functions are the most important and common pattern in StarShip. You define a function by giving it a name, followed by two double points (`::`). Then, you define the data types of the arguments you expect. These need to be separated by an ampersand (&). These arguments will be available as `arg1`, `arg2` and so on. This means the value of the first argument will be available as `arg1`.

After defining the arguments, you'll need to add an arrow (`->`) to indicate the following type is the data type you'll return. Right now, every function has to return and can only have one return type.

A function definition will have to be ended with the keyword `end`

Here is an example of a function definition:
```
functionName :: String, Bool -> String
    -- code
    -- the first argument (string) is available as arg1
end
```

## Return
Return is written as `return`. After the keyword, you can either insert an absolute value or reference a variable.

Here is an example of returning an absolute value …
```
return "hello world"
```

… and here one of returning a variable
```
return variableName
```

## Comments
If you want to document your code, you'll need comments. A comment starts with two hyphens (`--`). The comment spans to the end of the line.

Here is an example of some comments:
```
-- comment
code -- comment
```

## Variable definitions
If a variable is not yet defined, you can define it with an absolute value or by calling a function. Since you can't call functions without assigning the return value to a variable, you'll define lots of variables. This also helps to document the progress of a program. When defining a variable with an absolute value, use this syntax:

```
let variableName = 42
```

Here the keyword is `let`. It lets the interpreter know, you want to define a new variable. If you want to call a function to define a variable, you put the function name directly after the equals sign. After the name, you list all arguments. These shouldn't be separated by an ampersand.

Here is an example:
```
let variableName = functionName "hello" "world"
```

If you want to reassign a variable, you can omit the `let` keyword. The data type of new value will have to match the one of the original value. Right now, you can't use the value of a variable when redefining it. For example:

```
variableName = inc variableName -- won't work
```

## Basic data types
Right now, StarShip has three data types:

- Strings can be written in quotes ("String value")
- Numbers can be written as numbers (42)
- Bools have the values `True` and `False`
- Arrays are written like this: `[ 1 | 2 | 3]`

## That's it!
StarShip is a pretty simplistic language. It doesn't have many features, but in combination with the [standard library](StandardLibrary.md), it can do some pretty cool stuff. Install the CLI, and give it a try!
