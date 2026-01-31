# Datuk App - Landing Page

Flutter mobile application for the Datuk app landing page, converted from HTML/Tailwind CSS to native Flutter widgets.

## 📱 Features

- **Beautiful Hero Section** with network image and gradient overlay
- **Interactive Step Cards** with tap animations
- **Social Proof Section** with user avatars
- **Floating CTA Button** with gradient and shadow effects
- **Light/Dark Mode Support** with custom theme
- **Responsive Design** optimized for mobile devices

## 🎨 Design

The app follows a modern design system with:
- **Primary Color**: #42F099 (vibrant green)
- **Typography**: Plus Jakarta Sans font family
- **Rounded Corners**: Consistent 32px border radius
- **Smooth Animations**: Hover and tap interactions

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── config/
│   └── theme.dart              # App theme configuration
├── constants/
│   ├── colors.dart             # Color constants
│   └── text_styles.dart        # Text style constants
├── screens/
│   └── landing_page.dart       # Main landing page screen
└── widgets/
    ├── custom_app_bar.dart     # Reusable app bar widget
    ├── hero_section.dart       # Hero section with image
    ├── step_card.dart          # Individual step card widget
    ├── social_proof.dart       # Social proof section
    └── floating_cta_button.dart # Sticky CTA button
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.10.4 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- An Android/iOS emulator or physical device

### Installation

1. **Clone the repository** (if applicable) or navigate to the project directory:
   ```bash
   cd "e:\Back up data D\Project\Datuk\datuk"
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

### Running on Specific Platforms

- **Android**: `flutter run -d android`
- **iOS**: `flutter run -d ios` (macOS only)
- **Web**: `flutter run -d chrome`

## 🎯 Key Components

### Custom App Bar
Sticky app bar with logo, title, and menu button with glassmorphism effect.

### Hero Section
Full-width image section with:
- 4:5 aspect ratio
- Gradient overlay
- Hover scale animation
- Centered text content

### Step Cards
Three interactive cards showing the app workflow:
1. **Record** - Speak naturally
2. **Analyze** - Process thoughts
3. **Result** - Get insights

Each card features:
- Custom icon and colors
- Step number badge
- Tap animation
- Responsive layout

### Social Proof
Displays user trust with:
- Overlapping circular avatars
- "+9k" count badge
- Network images

### Floating CTA Button
Sticky bottom button with:
- Gradient background
- Shadow effect
- Arrow icon with animation
- Tap feedback

## 🌙 Dark Mode

To enable dark mode, change the `themeMode` in `lib/main.dart`:

```dart
themeMode: ThemeMode.dark,  // or ThemeMode.system for auto
```

## 🎨 Customization

### Colors
Edit `lib/constants/colors.dart` to change the color scheme.

### Typography
Modify `lib/constants/text_styles.dart` to adjust font styles.

### Theme
Update `lib/config/theme.dart` for overall theme changes.

## 📦 Dependencies

- `google_fonts: ^6.2.1` - For Plus Jakarta Sans font family

## 🔧 Development

### Adding New Widgets
1. Create a new file in `lib/widgets/`
2. Import necessary constants and dependencies
3. Export the widget in the screen where it's used

### Modifying the Landing Page
Edit `lib/screens/landing_page.dart` to change the layout or add new sections.

## 📸 Screenshots

The app replicates the original HTML design with:
- Clean, modern interface
- Smooth animations
- Professional color scheme
- Mobile-optimized layout

## 🐛 Troubleshooting

### Images not loading
- Check internet connection
- Verify network image URLs are accessible
- Check for CORS issues on web platform

### Font not displaying
- Run `flutter pub get` to ensure google_fonts is installed
- Clear build cache: `flutter clean && flutter pub get`

### Build errors
- Ensure Flutter SDK is up to date: `flutter upgrade`
- Check Dart SDK version compatibility
- Run `flutter doctor` to diagnose issues

## 📝 License

This project is part of the Datuk application.

## 👨‍💻 Author

Created as a Flutter conversion of the original HTML/Tailwind CSS landing page.
