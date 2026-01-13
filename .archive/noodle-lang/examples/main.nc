# Welcome to Noodle IDE - Real Implementation
# This demonstrates true NoodleCore functionality

let message = "Hello from real NoodleCore!";
let version = "3.0.0";
let features = ["real-execution", "file-operations", "syntax-highlighting"];

def greet(name):
    return message + " " + name;

def show_features():
    for feature in features:
        print "- " + feature;

# Main execution
print "=== NoodleCore IDE Demo ===";
print "Version: " + version;
show_features();
print greet("Developer");

return {
    "status": "success",
    "message": message,
    "features": features
};
