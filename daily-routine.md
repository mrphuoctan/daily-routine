# Weekly Schedule

| Time          | Monday          | Tuesday         | Wednesday       | Thursday        | Friday          | Saturday        | Sunday          |
| ------------- | --------------- | --------------- | --------------- | --------------- | --------------- | --------------- | --------------- |
| 00:00 → 05:00 | Sleep           | Sleep           | Sleep           | Sleep           | Sleep           |                 |                 |
| 00:00 → 06:20 |                 |                 |                 |                 |                 | Sleep           | Sleep           |
| 05:00 → 05:30 | Morning Routine | Morning Routine | Morning Routine | Morning Routine | Morning Routine |                 |                 |
| 05:30 → 06:40 | Gym / Running   | Gym / Running   | Gym / Running   | Gym / Running   | Gym / Running   |                 |                 |
| 06:20 → 06:40 |                 |                 |                 |                 |                 | Morning Routine | Morning Routine |
| 06:40 → 07:30 | EM              | EM              | EM              | EM              | EM              | EM              | Master Degree   |
| 07:30 → 08:30 | Commute         | Commute         | Commute         | Commute         | Commute         | Billiards       | Master Degree   |
| 08:30 → 11:30 | Work            | Work            | Work            | Work            | Work            | Billiards       | Master Degree   |
| 11:30 → 12:00 | Work            | Work            | Work            | Work            | Work            | Commute         | Commute         |
| 12:00 → 13:00 | Work / Lunch    | Work / Lunch    | Work / Lunch    | Work / Lunch    | Work / Lunch    | Lunch / Rest    | Lunch / Rest    |
| 13:00 → 15:00 | Work            | Work            | Work            | Work            | Work            | Master Degree   | Freelancer      |
| 15:00 → 15:30 | Work            | Work            | Work            | Work            | Work            | Break           | Break           |
| 15:30 → 17:30 | Work            | Work            | Work            | Work            | Work            | Freelancer      | Freelancer      |
| 17:30 → 18:30 | Commute         | Commute         | Commute         | Commute         | Commute         | Freelancer      | Freelancer      |
| 18:30 → 19:00 | Evening Routine | Evening Routine | Evening Routine | Evening Routine | Evening Routine | Dinner          | Free / Social   |
| 19:00 → 19:30 | HSK             | HSK             | HSK             | HSK             | HSK             | HSK             | Dinner          |
| 19:30 → 20:00 | Dinner          | Dinner          | Dinner          | Dinner          | Dinner          | Free Time       | Free Time       |
| 20:00 → 21:00 | Freelancer      | Freelancer      | Freelancer      | Freelancer      | Freelancer      | NCP GenAI       | NCP GenAI       |
| 21:00 → 22:00 | Freelancer      | Freelancer      | Freelancer      | Freelancer      | Freelancer      | Freelancer      | Freelancer      |
| 22:00 → 22:45 | Freelancer      | Freelancer      | Freelancer      | Freelancer      | Freelancer      | Console / Relax | Console / Relax |
| 22:45 → 23:15 | NCP GenAI       | NCP GenAI       | NCP GenAI       | NCP GenAI       | NCP GenAI       | Console / Relax | Console / Relax |
| 23:15 → 23:30 | Master Degree   | Master Degree   | Master Degree   | Master Degree   | Master Degree   | Console / Relax | Console / Relax |
| 23:30 → 00:00 | Console / Relax | Console / Relax | Console / Relax | Console / Relax | Console / Relax | Console / Relax | Console / Relax |

---

# Weekly / Monthly Summary

|               | Work | Freelancer | Master Degree | NCP GenAI | HSK | Gym / Running |  EM |   Sleep |   Total |
| ------------- | ---: | ---------: | ------------: | --------: | --: | ------------: | --: | ------: | ------: |
| Monday        |   9h |         3h |           15m |       30m | 30m |         1h10m | 50m |      5h |  20h15m |
| Tuesday       |   9h |         3h |           15m |       30m | 30m |         1h10m | 50m |      5h |  20h15m |
| Wednesday     |   9h |         3h |           15m |       30m | 30m |         1h10m | 50m |      5h |  20h15m |
| Thursday      |   9h |         3h |           15m |       30m | 30m |         1h10m | 50m |      5h |  20h15m |
| Friday        |   9h |         3h |           15m |       30m | 30m |         1h10m | 50m |      5h |  20h15m |
| Saturday      |    - |         5h |            2h |        1h | 45m |             - | 50m |   6h20m |  15h55m |
| Sunday        |    - |         5h |         4h50m |        1h | 45m |             - |   - |   6h20m |  17h55m |
| Weekly Total  |  45h |        25h |         8h05m |     4h30m |  4h |         5h50m |  5h |  37h40m | 135h05m |
| Monthly Total | 180h |       100h |        32h20m |       18h | 16h |        23h20m | 20h | 150h40m | 540h20m |

---

# iOS App Prompt

## Goal

Build a personal productivity and life tracking iOS app for a single user.

The app should help manage:

* Daily schedule
* Habit tracking
* Time tracking
* Check-in / check-out activities
* Weekly and monthly statistics
* Reminder notifications
* Focus tracking

No authentication, login, account system, cloud sync, or multi-user support is needed.
This is a local-first personal productivity app.

---

## Multi-language Support

The app must support:

* Vietnamese
* English
* Chinese

Requirements:

* Dynamic language switching
* Localized UI
* Localized notifications
* Localized date/time formats
* Support simplified Chinese

Design considerations:

* Flexible layouts for multilingual text
* Proper font rendering
* Clean typography across languages
* Avoid text truncation

---

## Platform

* iOS only
* SwiftUI
* Local storage only
* Prefer SwiftData or CoreData
* Modern iOS design
* Dark mode support
* Widget support (optional)

---

## Main Features

### 1. Schedule Dashboard

Display today's timeline:

* Current activity
* Upcoming activity
* Remaining free time
* Daily completion percentage

Activities include:

* Sleep
* Work
* Freelancer
* Master Degree
* NCP GenAI
* HSK
* Gym / Running
* EM
* Commute
* Console / Relax

---

### 2. Check-in / Check-out Tracking

Each activity can:

* Start manually
* End manually
* Auto-calculate duration

Track:

* Planned duration
* Actual duration
* Completion status
* Overdue status

Example:

* Freelancer planned: 20:00 → 23:00
* Actual: 20:15 → 22:40

Store historical logs.

---

### 3. Notifications & Reminders

Local notifications only.

Examples:

* "Time for HSK"
* "Start Freelancer Session"
* "Go to sleep"
* "Gym starts in 10 minutes"

Support:

* Daily repeating reminders
* Weekend-specific reminders
* Snooze notification

---

### 4. Weekly & Monthly Analytics

Provide statistics:

* Total hours by category
* Planned vs actual time
* Completion rate
* Streak tracking
* Focus score
* Sleep consistency

Charts:

* Weekly bar chart
* Monthly pie chart
* Daily timeline chart

---

### 5. Task Categories

Create reusable activity categories:

* Work
* Study
* Fitness
* Relationship
* Relax
* Commute

Each category has:

* Icon
* Color
* Default duration
* Notification settings

---

### 6. Quick Actions

Buttons:

* Start activity
* Pause activity
* Skip activity
* Complete activity
* Extend activity

---

### 7. Dashboard Widgets

Optional iOS widgets:

* Current task
* Next task
* Today's completion
* Remaining freelance hours

---

## UI Style

Design style:

* Minimal
* Clean
* Dark modern aesthetic
* Apple Human Interface Guidelines
* Smooth animations
* Focus-oriented

Use:

* Cards
* Timeline UI
* Progress rings
* Heatmaps
* Charts

---

## Suggested Architecture

* SwiftUI
* MVVM
* SwiftData/CoreData
* NotificationCenter
* Local notification scheduling
* Charts framework

---

## Suggested Screens

1. Home Dashboard
2. Daily Timeline
3. Weekly Calendar
4. Analytics
5. Activity History
6. Settings

---

## UI & UX Requirements

Design philosophy:

* Minimal UI
* White / bright tone
* Sporty and energetic feeling
* Friendly and clean interface
* Reduce icon usage as much as possible
* Focus on typography, spacing, cards, and timeline layouts
* Smooth animations
* Large tap areas
* Fast interaction flow

Device optimization:

* Optimize for iPhone 15
* Support Dynamic Island interactions
* Live Activity support for ongoing tasks
* Lock screen progress tracking
* Real-time session timer in Dynamic Island

Examples:

* Current task running timer
* Remaining session time
* Quick check-out button from Dynamic Island

---

## Activity Recording System

Every activity should support:

* Check-in
* Check-out
* Pause
* Resume
* Auto duration calculation
* Manual adjustment

Workflow example:

1. User taps "Check In"
2. Timer starts
3. Activity becomes active
4. Live Activity appears on Dynamic Island
5. User taps "Check Out"
6. Actual duration is stored in database

Track:

* Planned time
* Actual time
* Difference
* Completion status
* Daily streak
* Weekly consistency

---

## Evidence / Selfie Feature

Optional feature for accountability.

For each activity:

* User can optionally open camera
* Take a selfie or environment photo
* Save as activity evidence
* Store locally only

Example use cases:

* Gym selfie
* Study desk proof
* Freelancer work session
* University attendance

Requirements:

* Local storage only
* No cloud upload
* No sharing features
* Attach image to activity log

---

## Database Requirements

The app must NOT use hardcoded schedules.

All schedules, activities, and records must:

* Be stored in local database
* Be editable dynamically from UI
* Support CRUD operations
* Support future scalability

Suggested local database:

* SwiftData preferred
* CoreData fallback

Entities:

* ActivityCategory
* ScheduleTemplate
* DailySchedule
* ActivityLog
* CheckInRecord
* EvidencePhoto
* Reminder
* StatisticsCache

---

## Apple Ecosystem Integration

The app should support Apple ecosystem synchronization while still working fully offline on a single iPhone.

Requirements:

* iPhone-first experience
* Optional MacBook synchronization
* Optional Apple Watch support
* Works normally even without Mac or Watch

Synchronization:

* iCloud sync optional
* Local-first architecture
* Offline support always available
* Automatic sync between Apple devices when enabled

Examples:

* Reminder notification appears on MacBook
* Check-in on iPhone updates Mac app
* Current running task visible on Apple Watch
* Freelancer timer synced across devices

---

## Media Control Integration

The app should include lightweight media controls directly inside the app.

Goals:

* Avoid switching between apps
* Keep focus during work/study sessions
* Support background audio workflows

Supported controls:

* Play / Pause
* Next / Previous
* Volume control
* Current playing media info

Support:

* Apple Music
* Spotify
* YouTube (embedded web/player approach)
* System Now Playing integration

Optional focus modes:

* Study music mode
* Gym mode
* Deep work mode
* Relax mode

Examples:

* Auto-play study playlist when HSK starts
* Gym playlist during running
* Lo-fi music during freelancer session
* White noise during deep focus blocks

Requirements:

* Mini player UI only
* Minimal visual clutter
* Floating bottom player
* Dynamic Island media state integration

---

## Long-Term Scalability

Design architecture for future expansion:

Potential future features:

* AI-powered schedule optimization
* Smart fatigue detection
* Apple Watch integration
* HealthKit integration
* Focus mode automation
* Calendar sync
* Siri shortcuts
* Voice check-in
* Mood tracking
* Burnout detection
* Productivity scoring
* Goal system
* Achievement system
* Habit streaks
* Export reports
* Multi-device sync
* Cloud backup
* Team/shared accountability mode

Architecture should support:

* Modular feature system
* Clean MVVM structure
* Scalable database schema
* Service layer separation
* Offline-first design
* Future API integration

---

## Integrated Features

### Apple Watch Support

* Start/stop activities from Apple Watch
* Check-in/check-out directly on watch
* View current task
* Live timer sync
* Haptic reminder notifications
* Workout integration for Gym / Running

### Siri Shortcuts

* "Start Freelancer Session"
* "Check in Work"
* "Start HSK"
* "End Gym"
* Voice-triggered quick actions

### Focus Mode Integration

* Auto-enable focus modes by schedule
* Work focus during freelancer sessions
* Sleep focus before bedtime
* Gym focus during workout sessions
* Silence notifications automatically

### AI Schedule Optimization

* Detect low productivity periods
* Suggest better time blocks
* Recommend recovery time
* Analyze completion rate
* Predict burnout risk
* Optimize task distribution

### HealthKit Integration

* Sync workout sessions
* Step tracking
* Sleep tracking
* Heart rate during workouts
* Activity energy data
* Wellness monitoring

### Calendar Integration

* Apple Calendar sync
* Auto-create events from schedule
* Detect schedule conflicts
* Import external calendar events
* Daily agenda synchronization

---

## Calorie Tracking System

The app should include a lightweight calorie tracking feature.

Purpose:

* Simple calorie logging
* Daily intake tracking
* Fitness support
* Minimal interaction flow

Requirements:

* Add calorie entries
* Edit calorie entries
* Delete calorie entries
* Daily calorie summary
* Weekly calorie summary
* Monthly calorie summary

Input fields:

* Food/activity name
* Calories value
* Time
* Optional note

Examples:

* Chicken rice: 650 kcal
* Protein shake: 220 kcal
* Running: -350 kcal

Features:

* Manual input only
* Fast add flow
* No complex nutrition database needed initially
* Local storage only

Dashboard:

* Daily total calories
* Calories consumed
* Calories burned
* Net calories
* Simple charts

Optional future support:

* HealthKit calorie sync
* AI food recognition
* Barcode scanner
* Meal templates

---

## Long-Term Scalability

Design architecture for future expansion:

Potential future features:

* Voice AI assistant
* Mood tracking
* Burnout detection
* Productivity scoring
* Goal system
* Achievement system
* Habit streaks
* Export reports
* Team/shared accountability mode

Architecture should support:

* Modular feature system
* Clean MVVM structure
* Scalable database schema
* Service layer separation
* Offline-first design
* Future API integration
