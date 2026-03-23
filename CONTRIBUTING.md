# Contributing to MowTodo

Thanks for your interest in contributing! Here's how to help.

## Development Setup

```bash
# Clone the repo
git clone https://github.com/azizyuwono/mowtodo.git
cd mowtodo

# Get dependencies
flutter pub get

# Run on your platform
flutter run -d windows  # or -d macos, -d linux
```

## Running Tests

```bash
# Unit tests
flutter test test/unit/

# All tests
flutter test
```

## Code Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable names
- Keep files focused (single responsibility)
- Add tests for new functionality

## Making Changes

1. **Create a feature branch** off `master`

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Write tests first** (TDD approach)
   - Tests in `test/unit/` for business logic
   - Tests in `test/widget/` for UI components

3. **Implement your feature**
   - Follow existing code patterns
   - Keep UI simple and calm
   - Document public APIs

4. **Run tests locally**

   ```bash
   flutter test
   flutter analyze
   ```

5. **Commit with clear messages**

   ```bash
   git commit -m "feat: add new feature"
   git commit -m "fix: resolve issue"
   ```

6. **Push and create a PR**
   - Reference any related issues
   - Describe what changed and why

## Design Principles

Any contribution should respect MowTodo's core design:

- **Focus First** — Elements must justify their existence
- **Whitespace is Content** — Space reduces cognitive load
- **One Action at a Time** — Interactions should be atomic
- **Calm Colors** — Stick with the monochrome palette
- **Always Accessible** — Readable text, obvious interactions

## Questions?

Open an issue! We're friendly.

---

Happy coding! 🎯
