<h1 align="center">Daily Routine</h1>

<p align="center">
  A professional iOS productivity app for personal schedule management, activity tracking, and AI-powered wellness monitoring.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Swift-5.9-F05138?style=flat-square&logo=swift&logoColor=white" alt="Swift">
  <img src="https://img.shields.io/badge/SwiftUI-17+-0071E3?style=flat-square&logo=apple&logoColor=white" alt="SwiftUI">
  <img src="https://img.shields.io/badge/SwiftData-Offline--First-34C759?style=flat-square&logo=apple&logoColor=white" alt="SwiftData">
  <img src="https://img.shields.io/badge/iOS-17%2B-000000?style=flat-square&logo=apple&logoColor=white" alt="iOS 17+">
  <img src="https://img.shields.io/badge/Xcode-15%2B-147EFB?style=flat-square&logo=xcode&logoColor=white" alt="Xcode">
  <img src="https://img.shields.io/badge/Architecture-MVVM-8B5CF6?style=flat-square" alt="MVVM">
</p>

---

Daily Routine is a comprehensive daily life management platform built with SwiftUI and SwiftData, designed to optimize personal productivity through intelligent scheduling, real-time activity tracking, and AI-powered wellness insights.

- Flexible management of daily/weekly/monthly schedules with conflict detection and dynamic CRUD.
- Real-time activity check-in/check-out with timer tracking, pause/resume, and evidence capture.
- AI-Powered Insights: Fatigue detection, burnout prediction, and adaptive schedule optimization.
- Productivity tools: Pomodoro focus timer, goal tracking, achievement badges, mood tracking.
- Multi-Language: English, Vietnamese, Chinese with localized notifications.

<h2 align="center">Key Features</h2>

```
120 features across 15 categories
```

```
12 SwiftData models with offline-first persistence
```

```
7 AI-powered analysis algorithms
```

```
3 languages (EN / VI / ZH-Hans)
```

<h2 align="center">System Architecture</h2>

```mermaid
graph TD
    User([User]) -->|Touch / Voice| App[Daily Routine App]

    subgraph Presentation Layer
        direction TB
        TabView[MainTabView] --> Dashboard[Dashboard]
        TabView --> Timeline[Timeline]
        TabView --> Weekly[Weekly Calendar]
        TabView --> Analytics[Analytics]
        TabView --> More[More Hub]
        More --> Goals[Goals]
        More --> Achievements[Achievements]
        More --> Mood[Mood Tracker]
        More --> FocusTimer[Focus Timer]
        More --> AIInsights[AI Insights]
        More --> Export[Export PDF]
        More --> Voice[Voice Check-In]
    end

    subgraph Business Logic Layer
        direction TB
        DashVM[DashboardViewModel] --> ScheduleSvc[ScheduleService]
        DashVM --> TimerSvc[TimerService]
        AnalyticsVM[AnalyticsViewModel] --> StatCache[StatisticsCache]
        AISvc[AIScheduleService] --> Fatigue[Fatigue Detection]
        AISvc --> Burnout[Burnout Prediction]
        AISvc --> Optimize[Schedule Optimizer]
        MediaSvc[MediaControlService] --> FocusModes[Focus Modes]
    end

    subgraph Data Layer
        direction TB
        SwiftData[(SwiftData)] --> Models[12 Models]
        Models --> Schedule[DailySchedule]
        Models --> ActivityLog[ActivityLog]
        Models --> Goal_M[Goal]
        Models --> Achievement_M[Achievement]
        Models --> MoodEntry_M[MoodEntry]
        Models --> CalorieEntry_M[CalorieEntry]
    end

    subgraph Apple Ecosystem Services
        direction LR
        Watch[WatchSync]
        Cloud[CloudSync]
        Siri[SiriShortcuts]
        Health[HealthKit]
        LiveAct[LiveActivity]
    end

    App --> TabView
    Dashboard --> DashVM
    Analytics --> AnalyticsVM
    AIInsights --> AISvc
    DashVM --> SwiftData
    AISvc --> SwiftData
```

<h2 align="center">Database Design</h2>

```mermaid
erDiagram
    SCHEDULE_TEMPLATE {
        uuid id PK
        string activityType
        int dayOfWeek
        int startHour
        int endHour
    }
    DAILY_SCHEDULE {
        uuid id PK
        date date
        string activity
        date plannedStartTime
        date plannedEndTime
        string status
    }
    ACTIVITY_LOG {
        uuid id PK
        string activityType
        date actualStartTime
        date actualEndTime
        string status
    }
    CHECK_IN_RECORD {
        uuid id PK
        date checkInTime
        date checkOutTime
    }
    CALORIE_ENTRY {
        uuid id PK
        string name
        double calories
        bool isConsumed
    }
    GOAL {
        uuid id PK
        string title
        double targetValue
        double currentValue
        bool isCompleted
    }
    ACHIEVEMENT {
        uuid id PK
        string title
        string category
        double requirement
        double currentProgress
    }
    MOOD_ENTRY {
        uuid id PK
        date date
        int moodLevel
        int energyLevel
        int stressLevel
    }
    DAILY_SCHEDULE ||--o| ACTIVITY_LOG : "tracks"
    ACTIVITY_LOG ||--o{ CHECK_IN_RECORD : "has"
    SCHEDULE_TEMPLATE ||--o{ DAILY_SCHEDULE : "generates"
```

<h2 align="center">User Workflow</h2>

```mermaid
sequenceDiagram
    participant User
    participant Dashboard
    participant Timer as TimerService
    participant AI as AIScheduleService
    participant DB as SwiftData

    User->>Dashboard: Open App
    Dashboard->>DB: Fetch today schedule
    DB-->>Dashboard: Activities loaded

    Note over User,Dashboard: Activity Check-In Flow
    User->>Dashboard: Tap Check In
    Dashboard->>Timer: Start timer
    Dashboard->>DB: Update status to inProgress

    User->>Dashboard: Tap Check Out
    Dashboard->>Timer: Stop timer
    Dashboard->>DB: Save actual duration

    Note over AI,DB: AI Analysis
    AI->>DB: Fetch historical logs
    AI->>AI: Detect fatigue level
    AI->>AI: Predict burnout risk
    AI-->>Dashboard: Recovery suggestions
```

<h2 align="center">Getting Started</h2>

### 1. Prerequisites
- macOS 14+ (Sonoma)
- Xcode 15+
- XcodeGen (`brew install xcodegen`)
- iOS 17+ device or Simulator

### 2. Installation

```bash
# Clone the repository
git clone https://github.com/MrPhuocTan/daily-routine.git
cd daily-routine

# Generate Xcode project and open
xcodegen generate
open DailyRoutine.xcodeproj
```

The app will run on iOS Simulator or a connected device via Xcode.

```
Select your device -> Run (Cmd+R)
```

<h2 align="center">Support & Contact</h2>

For inquiries, feedback, or collaboration opportunities, contact the developer.

Author & Credits: MrPhuocTan - [phtan.working@gmail.com](mailto:phtan.working@gmail.com) - 097.201.2901

Daily Routine - (c) 2026 MrPhuocTan. All rights reserved.
