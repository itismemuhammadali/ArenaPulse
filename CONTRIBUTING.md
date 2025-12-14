# Contributing to Sports Chat App

Thank you for your interest in contributing to the Sports Chat App! This document provides guidelines and information for contributors.

## 🚀 Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/sports_chat_app.git
   cd sports_chat_app
   ```
3. **Set up the development environment** following the [README.md](README.md)
4. **Create a new branch** for your feature:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## 📋 Development Guidelines

### Code Style
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter analyze` to check for issues
- Format code with `dart format .`
- Use meaningful variable and function names
- Add comments for complex logic

### Commit Messages
Use conventional commit format:
- `feat: add new chat feature`
- `fix: resolve notification bug`
- `docs: update API setup guide`
- `style: format code according to style guide`
- `refactor: improve message handling logic`
- `test: add unit tests for auth service`

### Testing
- Write unit tests for new features
- Ensure existing tests pass: `flutter test`
- Test on multiple platforms when possible
- Include integration tests for critical features

### Documentation
- Update README.md if adding new features
- Document new API endpoints or services
- Update setup guides if configuration changes
- Add inline code comments for complex logic

## 🔧 Development Setup

### Prerequisites
- Flutter SDK 3.9.2+
- Firebase CLI
- Android Studio / Xcode
- Git

### Environment Setup
1. Follow the [API_KEYS_SETUP.md](API_KEYS_SETUP.md) guide
2. Set up your own Firebase project for testing
3. Configure development environment variables
4. Test the app runs successfully

### Firebase Development
- Use a separate Firebase project for development
- Don't use production Firebase credentials
- Test Cloud Functions locally when possible
- Follow Firebase security rules best practices

## 🐛 Bug Reports

When reporting bugs:
1. Use the bug report template
2. Include steps to reproduce
3. Provide device/platform information
4. Include relevant logs or screenshots
5. Check if the issue already exists

## ✨ Feature Requests

For new features:
1. Use the feature request template
2. Explain the use case and benefits
3. Consider implementation complexity
4. Discuss potential breaking changes
5. Provide mockups or examples if helpful

## 🔄 Pull Request Process

1. **Update documentation** if needed
2. **Add tests** for new functionality
3. **Ensure all tests pass**
4. **Follow code style guidelines**
5. **Write clear commit messages**
6. **Update CHANGELOG.md** if applicable

### PR Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No breaking changes (or clearly documented)
- [ ] Tested on relevant platforms

## 🏗️ Project Structure

```
lib/
├── main.dart              # App entry point
├── models/               # Data models
├── services/             # Business logic and API calls
├── screens/              # UI screens
├── widgets/              # Reusable UI components
├── utils/                # Helper functions and constants
└── assets/               # Images and static files

test/                     # Unit and widget tests
integration_test/         # Integration tests
android/                  # Android-specific code
ios/                     # iOS-specific code
web/                     # Web-specific code
functions/               # Firebase Cloud Functions
```

## 🔒 Security Guidelines

- **Never commit API keys** or sensitive data
- Use environment variables for configuration
- Follow Firebase security rules best practices
- Validate all user inputs
- Use HTTPS for all network requests
- Implement proper authentication checks

## 📱 Platform Considerations

### Android
- Test on multiple Android versions (API 21+)
- Consider different screen sizes
- Test with different Android manufacturers
- Verify permissions work correctly

### iOS
- Test on multiple iOS versions (12.0+)
- Test on different device sizes
- Verify App Store guidelines compliance
- Test with iOS-specific features

### Web
- Test on major browsers (Chrome, Firefox, Safari)
- Ensure responsive design
- Test PWA functionality
- Verify web-specific APIs work

## 🤝 Community Guidelines

- Be respectful and inclusive
- Help others learn and grow
- Provide constructive feedback
- Follow the code of conduct
- Ask questions if unsure

## 📞 Getting Help

- Check existing documentation first
- Search existing issues
- Ask questions in discussions
- Reach out to maintainers if needed

## 🎯 Areas for Contribution

We especially welcome contributions in:
- UI/UX improvements
- Performance optimizations
- Accessibility features
- Additional sports-specific features
- Documentation improvements
- Test coverage expansion
- Bug fixes and stability improvements

## 📄 License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

Thank you for contributing to Sports Chat App! 🏆