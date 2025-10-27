## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd mobile
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the App

```bash
# Run on connected device/emulator
flutter run

# Run on specific platform
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
flutter run -d windows       # Windows
flutter run -d android       # Android
flutter run -d ios          # iOS
```

## 🛠️ Development

### Adding New Dependencies

```bash
flutter pub add package_name
```

### Code Quality

```bash
# Run static analysis
flutter analyze

# Format code
flutter format .

# Check outdated packages
flutter pub outdated
```

### Hot Reload & Hot Restart

During development:
- `r` - Hot reload (fast, preserves state)
- `R` - Hot restart (slower, resets state)
- `q` - Quit

## 🧪 Testing

### Run Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

## 🐛 Troubleshooting

### Common Issues

**1. Package Conflicts**
```bash
flutter clean
flutter pub get
```

**2. Font Not Loading**
```bash
flutter clean
flutter pub get
flutter run
```

### Debug Commands

```bash
# Check Flutter installation
flutter doctor

# List connected devices
flutter devices

# View logs
flutter logs

# Clean build artifacts
flutter clean
```

## 🤝 Contributing

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Make changes and commit: `git commit -m "Add your feature"`
3. Push to branch: `git push origin feature/your-feature`
4. Create Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- [Flutter Documentation](https://docs.flutter.dev/)
- [Material Design 3](https://m3.material.io/)
- [Google Fonts](https://fonts.google.com/)
- Figma design team for color tokens and UI specifications

---

**Built with ❤️ using Flutter**
