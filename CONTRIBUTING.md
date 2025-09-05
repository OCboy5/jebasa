# Contributing to Jebasa

Thank you for your interest in contributing to Jebasa! This document provides guidelines and information for contributors.

## Getting Started

### Development Setup

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/yourusername/jebasa.git
   cd jebasa
   ```

3. Create a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # Linux/macOS
   # or
   venv\Scripts\activate  # Windows
   ```

4. Install development dependencies:
   ```bash
   pip install -e .[dev]
   pre-commit install
   ```

### Running Tests

```bash
pytest
```

### Code Quality

We use several tools to maintain code quality:

- **Black**: Code formatting
- **isort**: Import sorting  
- **flake8**: Linting
- **mypy**: Type checking

Run all checks:
```bash
pre-commit run --all-files
```

## How to Contribute

### Reporting Issues

- Use the issue templates provided
- Include steps to reproduce
- Provide system information (OS, Python version, etc.)
- Include relevant error messages and logs

### Suggesting Features

- Check existing issues first
- Describe the use case clearly
- Explain why existing features don't meet your needs
- Be open to discussion and alternative solutions

### Pull Requests

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**:
   - Write clear, readable code
   - Add tests for new functionality
   - Update documentation as needed
   - Follow existing code style

3. **Test your changes**:
   ```bash
   pytest
   pre-commit run --all-files
   ```

4. **Commit your changes**:
   ```bash
   git add .
   git commit -m "Add: brief description of changes"
   ```

5. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**:
   - Use the PR template provided
   - Describe changes clearly
   - Link related issues
   - Ensure all checks pass

## Code Guidelines

### Python Code Style

- Follow PEP 8
- Use type hints for all functions
- Write docstrings for public functions and classes
- Keep functions focused and small
- Use meaningful variable names

### Testing

- Write tests for new features
- Maintain test coverage above 90%
- Use pytest fixtures for common test data
- Test edge cases and error conditions

### Documentation

- Update docstrings for changed functionality
- Add examples to documentation
- Keep README.md up to date
- Update changelog for significant changes

## Project Structure

```
jebasa/
├── src/jebasa/          # Main package
├── tests/               # Test files
├── docs/                # Documentation
├── examples/            # Usage examples
└── .github/             # GitHub templates and workflows
```

## Commit Message Guidelines

Use clear, descriptive commit messages:

- `Add: new feature or functionality`
- `Fix: bug fixes`
- `Update: improvements to existing features`
- `Remove: deleted code or features`
- `Docs: documentation changes`
- `Test: test additions or changes`

## Release Process

1. Update version in `src/jebasa/__init__.py`
2. Update CHANGELOG.md
3. Create a git tag: `git tag v0.1.0`
4. Push tag: `git push origin v0.1.0`
5. GitHub Actions will handle PyPI release

## Getting Help

- Check existing documentation
- Search closed issues
- Ask questions in discussions
- Join our community chat

## Recognition

Contributors will be recognized in:

- CONTRIBUTORS.md file
- Release notes
- Project documentation

Thank you for contributing to Jebasa! 🎉