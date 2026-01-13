# Pattern Matching Demonstration - NoodleCore Advanced Features
# Shows match expressions, structural decomposition, and type inference

# Algebraic data types
type Option[T] = Some(T) | None
type Result[T, E] = Ok(T) | Err(E)
type List[T] = Nil | Cons(T, List[T])
type Expression = Number(int) | Add(Expression, Expression) | Mul(Expression, Expression)

# Pattern matching with algebraic types
func process_option(opt: Option[int]) -> Option[int]:
    """
    Extract value from Option if present.
    """
    match opt:
        case Some(x):
            return Some(x * 2)  # Double the value
        case None:
            return None

func fib_opt(n: int) -> Option[int]:
    """
    Safe Fibonacci: returns Option to handle negative inputs.
    """
    if n < 0:
        return None
    elif n == 0:
        return Some(0)
    elif n <= 2:
        return Some(1)
    else:
        # Get previous two values safely
        match (fib_opt(n - 1), fib_opt(n - 2)):
            case (Some(a), Some(b)):
                return Some(a + b)
            case _:
                return None

# Advanced pattern matching with guards
func evaluate(expr: Expression) -> int:
    """
    Evaluate mathematical expression using structural matching.
    """
    match expr:
        case Number(int value):
            return value
        case Add(Number(a), Number(b)):
            return a + b
        case Add(left, right):
            return evaluate(left) + evaluate(right)
        case Mul(Number(a), Number(b)):
            return a * b  
        case Mul(left, right):
            return evaluate(left) * evaluate(right)

# Complex nested pattern matching
func process_user(user_data: dict) -> Option[str]:
    """
    Extract email from user data structure.
    """
    match user_data:
        case {
            "profile": {
                "contact": {
                    "email": email
                }
            }
        }:
            return Some(email)
        case _:
            return None

# Advanced: tail-recursive list functions with pattern matching
func sum_list(lst: List[int]) -> int:
    """
    Calculate sum of all list elements recursively.
    """
    match lst:
        case Nil:
            return 0
        case Cons(head, tail):
            return head + sum_list(tail)

func map_list[T, U](lst: List[T], f: func(T) -> U) -> List[U]:
    """
    Transform list using function f.
    """
    match lst:
        case Nil:
            return Nil
        case Cons(head, tail):
            return Cons(f(head), map_list(tail, f))

func filter_list[T](lst: List[T], f: func(T) -> bool) -> List[T]:
    """
    Filter list elements by predicate.
    """
    match lst:
        case Nil:
            return Nil
        case Cons(head, tail):
            if f(head):
                return Cons(head, filter_list(tail, f))
            else:
                return filter_list(tail, f)

# Demo: Using match with lists and patterns
func demo_pattern_matching():
    print("=== Pattern Matching Demo ===\n")
    
    # 1. Basic pattern matching
    let opt1 = Some(42)
    let opt2 = None
    
    print("Processing Some(42):")
    match process_option(opt1):
        case Some(result):
            print("Result: " + str(result))  # Should print 84
        case None:
            print("No result")
    
    print("Processing None:")
    match process_option(opt2):
        case Some(result):
            print("Result: " + str(result))
        case None:
            print("No result")
    print()
    
    # 2. Expression evaluation
    let expr = Add(Number(10), Mul(Number(5), Number(2)))  # 10 + (5 * 2) = 20
    print("Evaluate 10 + 5 * 2:")
    let result = evaluate(expr)
    print("Result: " + str(result))
    print()
    
    # 3. List operations
    let numbers = Cons(1, Cons(2, Cons(3, Cons(4, Nil))))
    
    print("Original list: ")
    print(list_to_string(numbers))
    print("Sum: " + str(sum_list(numbers)))
    
    print("Even numbers only:")
    let evens = filter_list(numbers, func(x: int) -> bool: x % 2 == 0)
    print(list_to_string(evens))
    
    print("Squared values:")
    let squared = map_list(numbers, func(x: int) -> int: x * x)
    print(list_to_string(squared))

# Helper: Convert list to display string
func list_to_string(lst: List[int]) -> str:
    match lst:
        case Nil:
            return "[]"
        case Cons(head, tail):
            return "[" + str(head) + list_tail_string(tail) + "]"

func list_tail_string(lst: List[int]) -> str:
    match lst:
        case Nil:
            return ""
        case Cons(head, tail):
            return ", " + str(head) + list_tail_string(tail)

if __name__ == "__main__":
    demo_pattern_matching()
