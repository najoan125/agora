# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Agora** is a Flutter-based multi-platform messenger application supporting Android, iOS, Web, Linux, macOS, and Windows. It's built with Flutter 3.x and Dart SDK 3.0+, using Material Design 3 theming.

**Current Status:** Early-stage UI framework with 5 main screens, mock data, and basic navigation. Ready for backend integration and state management enhancement.

## Architecture

### High-Level Structure

```
MyApp (MaterialApp) → Material Design 3 Theme
    ↓
LoginScreen (Auth entry point)
    ↓
MainScreen (Bottom navigation hub with 3 tabs)
    ├── HomeScreen (Friends list + Teams list via TabController)
    ├── ChatScreen (1:1 chats + Team chats via TabController)
    └── MoreScreen (User profile & settings)
```

### Key Architectural Characteristics

- **State Management:** Currently using basic `StatefulWidget` with `setState()`. No complex state management framework (GetX, BLoC, Provider, Riverpod) implemented yet.
- **Navigation:**
  - Bottom navigation bar in MainScreen for primary tabs
  - TabController within HomeScreen and ChatScreen for secondary views
  - Simple MaterialPageRoute-based screen transitions
- **Data:** All data is currently mock/hardcoded in screen widgets. No backend integration yet.
- **UI Pattern:** Tab-based views with list displays (friends, teams, chats, settings)

### Screen Components

| Screen | Location | Type | Key Features |
|--------|----------|------|--------------|
| **LoginScreen** | `lib/screens/login_screen.dart` | StatefulWidget | Email/password input, password visibility toggle, forgot password link, signup link, loading animation |
| **MainScreen** | `lib/screens/main_screen.dart` | StatefulWidget | Bottom navigation bar controlling 3 main tabs, navigation state management |
| **HomeScreen** | `lib/screens/home_screen.dart` | StatefulWidget | TabController managing Friends Tab (online status indicators) and Teams Tab (member counts) |
| **ChatScreen** | `lib/screens/chat_screen.dart` | StatefulWidget | TabController managing 1:1 Chat Tab (last message preview, unread badges) and Team Chat Tab (last message, unread badges) |
| **MoreScreen** | `lib/screens/more_screen.dart` | StatelessWidget | User profile info, notification settings, privacy/security toggles, help section, app info, logout |

## Development Commands

### Essential Setup
```bash
# Initial setup - ensure Flutter is properly configured
flutter doctor

# Install dependencies
flutter pub get
```

### Running the Application
```bash
# Run with hot reload (default)
flutter run

# Run in release mode (optimized performance)
flutter run --release

# Run on specific device
flutter run -d <device_id>

# List available devices/emulators
flutter devices

# Run on Linux with ATK accessibility warnings suppressed
GTK_A11Y=none GDK_DEBUG="" flutter run -d linux
```

**Linux-specific:** If you encounter `Atk-CRITICAL` or cursor theme errors when running on Linux:
```bash
# Method 1: Set environment variables before running
export GTK_A11Y=none
export GDK_DEBUG=""
flutter run -d linux

# Method 2: Use the convenience script
./run_linux.sh
```

### Code Quality & Analysis
```bash
# Analyze code for issues
flutter analyze

# Format all Dart code
dart format lib/

# Check for outdated packages
flutter pub outdated

# Security audit
dart pub audit
```

### Building for Distribution
```bash
# Android APK
flutter build apk

# Android App Bundle (Play Store)
flutter build appbundle

# iOS
flutter build ios

# Web
flutter build web

# Desktop (Linux, macOS, Windows)
flutter build linux
flutter build macos
flutter build windows
```

### Testing
```bash
# Run all tests (no test files currently in project)
flutter test

# Run specific test file
flutter test test/path/to/test.dart

# Run with coverage
flutter test --coverage
```

## Project Structure

```
lib/
├── main.dart                    # Entry point, app configuration, theme setup
└── screens/                     # All screen widgets
    ├── login_screen.dart
    ├── main_screen.dart
    ├── home_screen.dart
    ├── chat_screen.dart
    └── more_screen.dart

android/                        # Android native code & gradle config
ios/                           # iOS native code & Xcode project
web/                           # Web platform files
linux/, macos/, windows/       # Desktop platform files

pubspec.yaml                   # Dependencies & project config
analysis_options.yaml          # Dart analyzer rules
.metadata                      # Flutter project metadata
```

## Key Configuration Files

- **`pubspec.yaml`** - Project dependencies, assets, and metadata
- **`analysis_options.yaml`** - Dart linting rules and analyzer settings
- **`main.dart`** - App entry point with Material Design 3 theme configuration

## Common Development Tasks

### Adding a New Screen
1. Create a new file in `lib/screens/` following the naming pattern `feature_screen.dart`
2. Extend `StatefulWidget` or `StatelessWidget` appropriately
3. Use Material Design 3 widgets (prefer Material widgets over Cupertino unless targeting iOS primarily)
4. Add navigation route in `main.dart` if it's a primary screen
5. Update `MainScreen` bottom navigation if it's a main tab

### Working with Tab Views
HomeScreen and ChatScreen both use `TabController` for managing multiple tab views. Follow the pattern:
```dart
// In initState:
_tabController = TabController(length: 2, vsync: this);

// In build:
TabBar(controller: _tabController, tabs: [...])
TabBarView(controller: _tabController, children: [...])
```

### Adding Mock Data
All mock data is currently hardcoded in screen widget bodies. When integrating a backend:
- Replace mock data lists with state variables
- Connect to API endpoints
- Implement error handling and loading states
- Consider moving to a state management solution (GetX, BLoC, or Provider)

## Dependencies

**Core:**
- `flutter` (SDK) - Base framework
- `cupertino_icons: ^1.0.2` - iOS-style icons

**Development:**
- `flutter_lints: ^2.0.0` - Dart linting rules

**Note:** No state management, networking, or database packages currently integrated. These should be added based on backend integration requirements.

## Theme & Design

- **Material Design 3:** Fully enabled (`useMaterial3: true`)
- **Primary Color:** Material Blue swatch
- **Material 3 Features:** Latest Material Design components and transitions

## Target Platforms & Minimum Requirements

- **Android:** Flutter standard minimum
- **iOS:** iOS 11.0+
- **Web:** Modern browsers (Chrome, Firefox, Safari, Edge)
- **Desktop:** Linux, macOS, Windows (Flutter desktop support)

## Planned Features (from README)

- Real-time chat functionality
- File sharing
- Voice/video calls
- Group chat improvements
- Chat search
- Emoji/emoticon support
- Chat notifications
- User profile customization
- Dark mode support
- Internationalization (i18n)

## Future Enhancements

**Recommended Next Steps:**
1. Integrate state management solution (GetX recommended for simplicity, or BLoC/Provider for scalability)
2. Add backend API integration (networking layer)
3. Implement real-time messaging (WebSocket or Firebase)
4. Add data persistence (local database)
5. Implement authentication service
6. Add push notifications
7. Implement error handling and logging
8. Add comprehensive test coverage
9. Implement dark mode theme
10. Add internationalization support
