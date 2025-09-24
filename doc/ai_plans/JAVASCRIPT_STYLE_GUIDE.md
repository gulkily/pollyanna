# JavaScript Style Guide for Pollyanna

This document defines the JavaScript coding style and conventions used in the Pollyanna project, derived from analysis of the existing codebase.

## General Formatting

- Use tabs for indentation
- Use single quotes for string literals
- End statements with semicolons
- Limit line length to approximately 80-100 characters
- Add a space after keywords like `if`, `for`, `while`, etc.

## File Structure

- Begin files with a comment indicating the filename: `/* filename.js */` or `// == begin filename.js`
- End files with a corresponding end comment: `/* / filename.js */` or `// == end filename.js`
- Group related functions together
- Include function alternatives in comments where appropriate (e.g., alternative function names)

## Naming Conventions

- Use camelCase for function and variable names
- Use descriptive names that reflect the purpose of functions and variables
- Function names usually begin with a verb (e.g., `GetPrefs()`, `SetPrefs()`, `ShowAdvanced()`)
- Use full words rather than abbreviations where possible

## Comments

- Add closing comment tag after each function: `} // FunctionName()`
- Include alternative function names as comments above function definitions
- Use `// #todo` comments to mark areas for future improvement
- Use `//alert('DEBUG: ...')` commented-out debug statements (currently disabled)
- Include explanatory comments for non-obvious code sections
- Use `// function AlternativeName()` to note alternative names for functions

## Function Definitions

- Define functions using the pattern: `function FunctionName (parameters) { ... }`
- Document function parameters with inline comments when not obvious
- Provide purpose comments at the start of complex functions
- Return values are documented through consistent patterns

## Variable Declarations

- Declare variables at the top of functions
- Use `var` for variable declarations
- Initialize variables where appropriate
- Group related variable declarations

## Conditional Statements

- Use explicit comparisons (e.g., `if (value == true)` rather than `if (value)`)
- Add spaces around operators (e.g., `a + b`, not `a+b`)
- Include brackets even for single-line conditional blocks
- Use nested conditionals sparingly

## Browser Compatibility

- Include feature detection for browser compatibility
- Use fallbacks for older browsers
- Check for existence of objects and methods before using them
- Avoid assuming modern browser capabilities

## Error Handling

- Use silent error handling where appropriate
- Include fallbacks when features might not be available
- Return meaningful values from functions to indicate success/failure

## DOM Manipulation

- Check for element existence before manipulating it
- Use feature detection for DOM methods
- Cache DOM references for performance
- Use consistent patterns for creating and manipulating elements

## Event Handling

- Attach event handlers using DOM element attributes
- Use consistent function naming for event handlers
- Delegate to appropriate functions for handling complex event logic

## State Management

- Use localStorage for persistent state where appropriate
- Manage preferences through the `GetPrefs()` and `SetPrefs()` functions
- Update UI state based on user preferences

## Performance Considerations

- Cache DOM references to avoid repeated lookups
- Minimize DOM manipulations
- Use the `window.EventLoop` pattern for periodic updates
- Include performance optimization settings

## Module Pattern

- Use global variables sparingly
- Use the `window` object to store shared state
- Structure related functionality into logical groupings

## Debugging

- Include commented-out debug statements for easy debugging
- Use consistent patterns for debug output
- Document complex logic with comments