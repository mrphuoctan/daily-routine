# Daily Routine - iOS App

A personal productivity and life tracking iOS app built with **SwiftUI + SwiftData + MVVM**.

## Features

- 📋 **Schedule Dashboard** — Current/next activity, progress ring, quick actions
- ⏱️ **Daily Timeline** — Full day timeline with check-in/check-out tracking
- 📅 **Weekly Calendar** — 7-day grid view with week navigation
- 📊 **Analytics** — Weekly bar chart, monthly pie chart, streaks, focus score
- 🔥 **Calorie Tracker** — Food/exercise calorie logging with daily/weekly/monthly summary
- ⚙️ **Settings** — Language switching (EN/VI/ZH-Hans), notifications, categories CRUD

## Tech Stack

| Component | Technology |
|-----------|-----------|
| UI | SwiftUI |
| Architecture | MVVM |
| Database | SwiftData |
| Charts | Swift Charts |
| Notifications | UNUserNotificationCenter |
| Min Target | iOS 17.0 |

## Project Structure

```
daily-routine/
├── DailyRoutineApp.swift          # App entry point
├── Models/                        # 9 SwiftData entities
├── ViewModels/                    # 7 view models
├── Views/                         # 18 view files across 7 directories
│   ├── Dashboard/                 # Current activity, progress ring, quick actions
│   ├── Timeline/                  # Daily timeline with date picker
│   ├── WeeklyCalendar/           # 7-day calendar grid
│   ├── Analytics/                 # Charts and statistics
│   ├── Calorie/                  # Calorie tracker + entry form
│   ├── Settings/                 # Language, notifications, categories
│   └── Components/               # Reusable components
├── Services/                      # 6 service files
├── Utilities/                     # Constants, extensions
├── Localization/                  # EN, VI, ZH-Hans
├── Assets.xcassets/              # Color sets, app icon
├── DailyRoutineTests/            # 4 test suites
├── project.yml                   # XcodeGen spec
└── build_and_test.sh             # Automated build + test runner
```

## Languages

| Language | Status |
|----------|--------|
| 🇺🇸 English | ✅ |
| 🇻🇳 Tiếng Việt | ✅ |
| 🇨🇳 简体中文 | ✅ |

## Getting Started

### Prerequisites
- macOS with Xcode 15+ installed
- iOS 17+ simulator or device

### Build & Run
```bash
# Generate Xcode project
brew install xcodegen
xcodegen generate

# Open in Xcode
open DailyRoutine.xcodeproj

# Or use automated script
./build_and_test.sh
```

### Run Tests
```bash
xcodebuild test \
    -project DailyRoutine.xcodeproj \
    -scheme DailyRoutine \
    -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Test Coverage

| Test Suite | Tests | Description |
|-----------|-------|-------------|
| DatabaseTests | 20 | SwiftData models, CRUD, relationships, seeder |
| BackendTests | 18 | Services, ViewModels, business logic |
| UIUXTests | 22 | Theme consistency, display strings, spec compliance |
| WorkflowTests | 8 | End-to-end user flows |

## License

Private project.
