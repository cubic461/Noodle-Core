# Test Noodle File for VS Code Extension Integration

def main():
    print("Hello from Noodle VS Code Extension!")
    return True

class TestClass:
    def __init__(self):
        self.value = 42
    
    def get_value(self):
        return self.value

# Test function for code completion
def test_function():
    return "This is a test function"

if __name__ == '__main__':
    main()
    test = TestClass()
    print(f"Test value: {test.get_value()}")