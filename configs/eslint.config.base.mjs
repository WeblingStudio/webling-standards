// ESLint v9 flat config — base configuration for Webling Studio projects.
// Usage in your project's eslint.config.mjs:
//
//   import weblingBase from '~/.webling/configs/eslint.config.base.mjs'
//   export default [...weblingBase, { /* project overrides */ }]

import tseslint from 'typescript-eslint'

export default tseslint.config(
  // TypeScript type-checked rules
  ...tseslint.configs.recommendedTypeChecked,

  {
    rules: {
      // Types
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/no-unsafe-assignment': 'error',
      '@typescript-eslint/no-unsafe-call': 'error',
      '@typescript-eslint/no-unsafe-member-access': 'error',
      '@typescript-eslint/no-unsafe-return': 'error',
      '@typescript-eslint/consistent-type-imports': ['error', { prefer: 'type-imports' }],

      // Promises — enforce no floating promises (matches async conventions)
      '@typescript-eslint/no-floating-promises': 'error',
      '@typescript-eslint/no-misused-promises': 'error',
      'no-return-await': 'off',
      '@typescript-eslint/return-await': ['error', 'in-try-catch'],

      // Variables
      '@typescript-eslint/no-unused-vars': ['error', {
        argsIgnorePattern: '^_',
        varsIgnorePattern: '^_',
      }],

      // Imports
      'no-duplicate-imports': 'error',
    },
  },

  {
    // Test files — relax some rules for test utilities
    files: ['**/tests/*', '**/*.test.ts', '**/*.spec.ts'],
    rules: {
      '@typescript-eslint/no-unsafe-assignment': 'off',
      '@typescript-eslint/no-explicit-any': 'warn',
    },
  },

  {
    // Ignore build output and generated files
    ignores: ['dist/**', 'build/**', 'coverage/**', '*.config.js'],
  },
)
