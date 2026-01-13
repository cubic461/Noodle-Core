# NoodleCore Integration Test Sample
# Dit compileert naar NBC bytecode voor integratie met DeployableUnit


    import "std.io";
    import "std.math";
    
    # Simpele service functie
    function hello_world() -> string {
        return "Hallo vanuit NoodleCore!";
    }
    
    # Wiskundige functie voor testen
    function add_numbers(x: int, y: int) -> int {
        return x + y;
    }
    
    # Complexer voorbeeld met error handling
    function process_data(data: array<int>) -> int {
        let sum: int = 0;
        
        if (data.length() == 0) {
            return 0;
        }
        
        for (let item: int in data) {
            sum = sum + item;
        }
        
        return sum / data.length();
    }
    
    # Main entry point voor test
    function main() -> int {
        let message: string = hello_world();
        print(message);
        
        let result: int = add_numbers(5, 7);
        print("5 + 7 = " + result);
        
        let data: array<int> = [10, 20, 30, 40];
        let avg: int = process_data(data);
        print("Gemiddelde: " + avg);
        
        return 0;
    }
}
