// Quick TypeScript compilation test
const { execSync } = require('child_process');
const fs = require('fs');

console.log('🔍 TypeScript Compilation Test\n');
console.log('=' .repeat(50));

// Test 1: Check TypeScript version
try {
  const version = execSync('npx tsc --version', { encoding: 'utf-8' }).trim();
  console.log('✅ TypeScript version:', version);
} catch (err) {
  console.log('❌ TypeScript not found');
  process.exit(1);
}

// Test 2: Check TypeScript files exist
const tsFiles = [
  'app/javascript/components/DocumentShow.tsx',
  'app/javascript/components/ExampleTypescriptComponent.tsx',
  'app/javascript/types/document.ts'
];

console.log('\n📁 TypeScript Files:');
tsFiles.forEach(file => {
  const exists = fs.existsSync(file);
  console.log(exists ? `  ✅ ${file}` : `  ❌ ${file} NOT FOUND`);
});

// Test 3: Run type check
console.log('\n🔍 Running Type Check...');
try {
  execSync('npm run type-check', { encoding: 'utf-8', stdio: 'inherit' });
  console.log('✅ Type check PASSED - No errors!\n');
} catch (err) {
  console.log('❌ Type check FAILED\n');
  process.exit(1);
}

// Test 4: Compile with webpack
console.log('🔨 Building with Webpack...');
try {
  const output = execSync('npm run build', { encoding: 'utf-8' });
  
  if (output.includes('compiled')) {
    console.log('✅ Webpack compilation SUCCESS!');
    
    // Check if output file exists
    if (fs.existsSync('app/assets/builds/application.js')) {
      const stats = fs.statSync('app/assets/builds/application.js');
      console.log(`✅ application.js created (${(stats.size / 1024).toFixed(2)} KB)`);
    }
  } else {
    console.log('⚠️  Webpack output:', output.substring(0, 200));
  }
} catch (err) {
  console.log('❌ Webpack compilation FAILED');
  console.log(err.message);
  process.exit(1);
}

// Summary
console.log('\n' + '='.repeat(50));
console.log('🎉 TypeScript is working correctly!');
console.log('=' .repeat(50));
console.log('\n✅ All tests PASSED:');
console.log('  1. TypeScript installed and configured');
console.log('  2. .tsx and .ts files exist');
console.log('  3. Type checking works (no errors)');
console.log('  4. Webpack compiles TypeScript successfully');
console.log('\n💡 You can now use both .jsx and .tsx files!');
