// Test TypeScript file to verify compilation

// Type annotations
const greet = (name: string): string => {
  return `Hello, ${name}!`;
};

// Interface
interface User {
  id: number;
  name: string;
  email: string;
  active: boolean;
}

// Function with typed parameters and return
const processUser = (user: User): string => {
  return `User ${user.name} (${user.email}) is ${user.active ? 'active' : 'inactive'}`;
};

// Test data
const testUser: User = {
  id: 1,
  name: 'Test User',
  email: 'test@example.com',
  active: true
};

// Array with types
const numbers: number[] = [1, 2, 3, 4, 5];
const sum: number = numbers.reduce((acc, num) => acc + num, 0);

// Generics
function identity<T>(value: T): T {
  return value;
}

// Type union
type Status = 'success' | 'error' | 'pending';

const handleStatus = (status: Status): void => {
  console.log(`Status: ${status}`);
};

// Export for testing
export {
  greet,
  processUser,
  testUser,
  sum,
  identity,
  handleStatus
};

// Console output for verification
console.log('✅ TypeScript Test File Loaded');
console.log('Greeting:', greet('TypeScript'));
console.log('User:', processUser(testUser));
console.log('Sum:', sum);
console.log('Identity:', identity(42));
handleStatus('success');

// This would cause a TypeScript error (uncomment to test):
// const badUser: User = { id: 'wrong', name: 123 };  // ❌ Type error!
// handleStatus('invalid');  // ❌ Not in Status union!
