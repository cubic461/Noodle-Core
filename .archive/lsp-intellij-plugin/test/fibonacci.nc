# Fibonacci sequence implementation in NoodleCore
# Demonstrates basic syntax, functions, and recursion

# Type-safe recursive Fibonacci function
func fibonacci(n: int) -> int:
    """
    Calculate nth Fibonacci number recursively.
    Args:
        n (int): Position in Fibonacci sequence (0-based)
    Returns:
        int: Fibonacci number at position n
    """
    # Base cases
    if n <= 0:
        return 0
    elif n == 1:
        return 1
    else:
        # Recursive step
        return fibonacci(n - 1) + fibonacci(n - 2)

# Optimized iterative version (faster)
func fibonacci_fast(n: int) -> int:
    """
    Calculate nth Fibonacci number iteratively.
    O(n) time complexity vs O(2^n) recursive.
    """
    if n <= 0:
        return 0
    elif n == 1:
        return 1
    
    let a = 0
    let b = 1
    let result = 0
    
    for i in range(2, n + 1):
        result = a + b
        a = b
        b = result
    
    return result

# Memoized version (DP approach)
func fibonacci_memo(n: int, memo: dict[int, int] = {}) -> int:
    """
    Calculate nth Fibonacci number with memoization.
    Avoids recomputation of overlapping subproblems.
    """
    if n in memo:
        return memo[n]
    
    if n <= 1:
        result = n
    else:
        result = fibonacci_memo(n - 1, memo) + fibonacci_memo(n - 2, memo)
    
    memo[n] = result
    return result

# Main program for demonstration
func main() -> int:
    print("Calculating Fibonacci numbers 0 to 15...\n")
    
    # Compare different implementations
    for i in range(16):
        let fib_rec = fibonacci(i)
        let fib_iter = fibonacci_fast(i)
        let fib_memo = fibonacci_memo(i)
        
        print("F(" + str(i) + ") = " + str(fib_rec) + 
              " (rec: " + str(fib_rec) + 
              ", iter: " + str(fib_iter) + 
              ", memo: " + str(fib_memo) + ")")
    
    # Performance comparison
    let n = 35
    print("\nPerformance test on F(" + str(n) + "):")
    
    let start_time = time().now()
    let result_fast = fibonacci_fast(n)
    let fast_duration = time().now() - start_time
    print("Fast iterative: " + str(result_fast) + " in " + str(fast_duration) + "ms")
    
    return 0

# Export functions for external use
pub func fib(n: int) -> int:
    return fibonacci_fast(n)

# Run main if this is the entry point
if __name__ == "__main__":
    main()
