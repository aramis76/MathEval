
# MathEval - Expression Evaluator Unit for Turbo Pascal

**MathEval** is a Turbo Pascal unit designed to evaluate mathematical expressions with various functions and constants. It supports multiple precision formats (Single, Double, and Extended) and provides a lightweight and efficient way to handle mathematical operations in Turbo Pascal projects. 

This unit is ideal for developers working with Turbo Pascal who need an expression evaluator to handle mathematical operations without relying on external libraries or more modern compilers.

## Features
- **Supports Multiple Precision Formats:** You can choose from Single, Double, or Extended precision for floating-point operations.
- **Mathematical Functions:** Includes basic functions such as `exp`, `ln`, `sin`, `cos`, `tan`, and exponentiation.
- **Mathematical Constants:** Supports built-in constants like `pi`, `e`, `ln2`, `ln10`, and automatic handling of `INF` and `NaN`.
- **Expression Evaluation:** Evaluate complex expressions with operators like `+`, `-`, `*`, `/`, and `^` (exponentiation).
- **Custom Functions and Constants:** You can define your own custom functions and constants to be used in expressions.
- **Error Handling:** Handles division by zero, overflow, and invalid operations (e.g., taking the square root of a negative number).

## Supported Precision Formats

The following precision formats are supported, and the precision is determined at compile time based on the chosen settings:

- **Single Precision** (`single`): 32-bit floating-point numbers.
- **Double Precision** (`double`): 64-bit floating-point numbers.
- **Extended Precision** (`extended`): 80-bit floating-point numbers.

You can select the desired precision format by defining one of the following symbols at compile time:

- `UseSingle`: For single precision.
- `UseDouble`: For double precision.
- If neither is defined, `extended` precision is used by default.

Example:

```pascal
{ To use single precision }
{$D-} 
{$define UseSingle}
```

```pascal
{ To use double precision }
{$D-}
{$define UseDouble}
```

## Constants

The following constants are pre-defined:

- `pi`: The mathematical constant π.
- `e`: Euler's number (e).
  
In addition to these, you can also define your own custom constants for use in expressions. For example:

```pascal
RegisterConstant('myConst', 42.0);
```

This would allow you to use `myConst` in your expressions.

## Custom Functions

You can also define your own custom functions and register them for use in expressions. For example:

```pascal
RegisterFunction('myFunc', @myFunction);
```

This would allow you to use `myFunc(x)` in expressions, where `myFunction` is a procedure or function you define.

## Example Usage

Here's a simple example of how to use **MathEval** to evaluate an expression:

```pascal
program TestMathEval;

uses MathEval;

var
   result: float;

begin
   result := Evaluate('3*sqrt(4) + pi');
   writeln('Result: ', result);
end.
```

This will evaluate the expression `3*sqrt(4) + pi` and print the result.

### Using Custom Functions and Constants

You can also use custom functions and constants within expressions:

```pascal
program TestCustomFunctions;

uses MathEval,Math;

function myFunction(x: float):float;
begin
   // Custom function logic
end;

begin
   RegisterFunction('myFunc', @myFunction);
   RegisterConstant('myConst', 42.0);
   
   writeln('Result: ', Evaluate('myFunc(myConst)'));
end.
```

## Limitations

- This unit works on Turbo Pascal and does not have support for complex numbers. All operations are real-number based, and functions like `sqrt(-1)` will result in errors.

## License

This project is released under the MIT License. See [LICENSE](LICENSE) for more details.

---

MathEval is developed and maintained by the community. Feel free to contribute or modify this project according to your needs.
