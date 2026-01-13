# Hello World in Noodle
# This is a simple example of the Noodle programming language

# Import standard library
import "std.io";

# Main function
def main() -> int {
    # Variable declaration with type annotation
    let message: string = "Hello, World!";
    let version: int = 1;
    
    # Print message
    print(message);
    print("Noodle Language v" + version);
    
    # Return success code
    return 0;
}

# Execute main function
let exit_code = main();