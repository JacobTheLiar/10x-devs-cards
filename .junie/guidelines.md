# AI Rules for {{project-name}}

{{project-description}}

## CODING_PRACTICES

### Guidelines for SUPPORT_LEVEL

#### SUPPORT_EXPERT

- Favor elegant, maintainable solutions over verbose code. Assume understanding of language idioms and design patterns.
- Highlight potential performance implications and optimization opportunities in suggested code.
- Frame solutions within broader architectural contexts and suggest design alternatives when appropriate.
- Focus comments on 'why' not 'what' - assume code readability through well-named functions and variables.
- Proactively address edge cases, race conditions, and security considerations without being prompted.
- When debugging, provide targeted diagnostic approaches rather than shotgun solutions.
- Suggest comprehensive testing strategies rather than just example tests, including considerations for mocking, test organization, and coverage.


### Guidelines for VERSION_CONTROL

#### GITHUB

- Use pull request templates to standardize information provided for code reviews
- Implement branch protection rules for {{protected_branches}} to enforce quality checks
- Configure required status checks to prevent merging code that fails tests or linting
- Use GitHub Actions for CI/CD workflows to automate testing and deployment
- Implement CODEOWNERS files to automatically assign reviewers based on code paths
- Use GitHub Projects for tracking work items and connecting them to code changes


### Guidelines for STATIC_ANALYSIS

#### ESLINT

- Configure project-specific rules in eslint.config.js to enforce consistent coding standards
- Use shareable configs like eslint-config-airbnb or eslint-config-standard as a foundation
- Implement custom rules for {{project_specific_patterns}} to maintain codebase consistency
- Configure integration with Prettier to avoid rule conflicts for code formatting
- Use the --fix flag in CI/CD pipelines to automatically correct fixable issues
- Implement staged linting with husky and lint-staged to prevent committing non-compliant code


## FRONTEND

### Guidelines for ANGULAR

#### ANGULAR_CODING_STANDARDS

- Use standalone components, directives, and pipes instead of NgModules
- Implement signals for state management instead of traditional RxJS-based approaches
- Use the new inject function instead of constructor injection
- Implement control flow with @if, @for, and @switch instead of *ngIf, *ngFor, etc.
- Leverage functional guards and resolvers instead of class-based ones
- Use the new deferrable views for improved loading states
- Implement OnPush change detection strategy for improved performance
- Use TypeScript decorators with explicit visibility modifiers (public, private)
- Leverage Angular CLI for schematics and code generation
- Implement proper lazy loading with loadComponent and loadChildren

#### NGRX

- Use the createFeature and createReducer functions to simplify reducer creation
- Implement the facade pattern to abstract NgRx implementation details from components
- Use entity adapter for collections to standardize CRUD operations
- Leverage selectors with memoization to efficiently derive state and prevent unnecessary calculations
- Implement @ngrx/effects for handling side effects like API calls
- Use action creators with typed payloads to ensure type safety throughout the application
- Implement @ngrx/component-store for local state management in complex components
- Use @ngrx/router-store to connect the router to the store
- Leverage @ngrx/entity-data for simplified entity management
- Implement the concatLatestFrom operator for effects that need state with actions


### Guidelines for STYLING

#### SCSS

- Use the ThemeProvider for consistent theming across components
- Implement the css helper for sharing styles between components
- Use props for conditional styling within template literals
- Leverage the createGlobalStyle for global styling
- Implement attrs method to pass HTML attributes to the underlying DOM elements
- Use the as prop for dynamic component rendering
- Leverage styled(Component) syntax for extending existing components
- Implement the css prop for one-off styling needs
- Use the & character for nesting selectors
- Leverage the keyframes helper for animations


