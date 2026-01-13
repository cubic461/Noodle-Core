# Simplied Noodle Sample - zonder module syntax die lexer nog niet ondersteunt
# Basic syntax die WEL werkt met huidige compiler

# Import statements (worden nog niet volledig ondersteund)
# import "std.io";

# Simpele hello world functie
def hello_world() {
    let message = "Hallo vanuit NoodleCore!";
    return message;
}

# Wiskundige functie voor testen
def add_numbers(x, y) {
    return x + y;
}

# Complexer voorbeeld met control flow
def calculate_average(numbers) {
    let sum = 0;
    let count = 0;
    
    # For loop met conditionele logica
    for (let i = 0; i < numbers.length; i = i + 1) {
        sum = sum + numbers[i];
        count = count + 1;
    }
    
    if (count > 0) {
        return sum / count;
    }
    
    return 0;
}

# Main entry point
def main() {
    # Variable declarations
    let greeting = "Welkom bij NoodleCore!";
    let result1 = add_numbers(5, 7);
    let result2 = calculate_average([10, 20, 30, 40]);
    
    # Function calls (print zal nog met runtime geïmplementeerd worden)
    return 0;
}
