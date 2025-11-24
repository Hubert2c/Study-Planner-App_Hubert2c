# DPlanner - Study Planner App

A comprehensive Flutter-based Study Planner App that helps students organize their tasks, manage deadlines, and stay on top of their academic schedule. Built with modern Flutter practices and featuring a beautiful Material Design interface.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white)

## Features

### Task Management
- **Create Tasks**: Add tasks with title, description, due date, and priority levels
- **Smart Reminders**: Set custom reminder times with intuitive plus/minus controls
- **Task Organization**: View today's tasks, upcoming tasks, and completed tasks
- **Edit & Delete**: Full CRUD operations for task management
- **Priority System**: High, Medium, and Low priority levels with visual indicators

### Calendar Integration
- **Monthly Calendar View**: Beautiful calendar interface showing all days of the month
- **Task Highlighting**: Dates with tasks are visually highlighted
- **Date Selection**: Tap any date to view tasks scheduled for that day
- **Visual Indicators**: Color-coded priority system for easy task identification

### Advanced Reminder System
- **Local Notifications**: Full background notification support using `flutter_local_notifications`
- **Customizable Timing**: Set reminder minutes before due date with intuitive controls
- **Permission Handling**: Automatic notification permission requests
- **Timezone Support**: Proper timezone handling for accurate scheduling

### Robust Data Storage
- **SQLite Database**: Advanced local storage using `sqflite` package
- **Data Persistence**: Tasks remain available after app restart
- **Efficient Queries**: Optimized database operations for smooth performance
- **Data Migration**: Automatic schema updates and data migration support

### Beautiful UI/UX
- **Material Design**: Clean, consistent interface following Material Design principles
- **Dark Theme**: Modern dark theme with customizable colors
- **Responsive Layout**: Works seamlessly in both portrait and landscape orientations
- **Intuitive Navigation**: Bottom navigation bar with Today, Calendar, and Settings screens

## Architecture

### Project Structure
```
lib/
├── main.dart                 # App entry point and theme configuration
├── models/
│   └── todo.dart            # Todo data model with SQLite mapping
├── screens/
│   ├── HomeScreen.dart       # Today's tasks and main dashboard
│   ├── CalendarScreen.dart   # Monthly calendar view
│   └── SettingsScreen.dart   # App settings and preferences
├── services/
│   ├── database_helper.dart  # SQLite database operations
│   ├── notification_service.dart # Local notification management
│   ├── settings_service.dart    # SharedPreferences for app settings
│   └── theme_service.dart       # Theme management and customization
└── widgets/
    ├── add_task_dialog.dart      # Task creation dialog
    ├── edit_task_dialog.dart     # Task editing dialog
    ├── calendar_widget.dart      # Calendar component
    ├── todo_card.dart           # Individual task display
    └── custom_*.dart            # Custom UI components
```

### Key Technologies
- **Flutter SDK**: ^3.8.1
- **State Management**: Provider pattern for theme and data management
- **Local Storage**: SQLite with `sqflite` package
- **Notifications**: `flutter_local_notifications` with timezone support
- **Permissions**: `permission_handler` for notification permissions
- **UI Components**: Material Design widgets with custom styling

## Getting Started

### Prerequisites
- Flutter SDK (^3.8.1)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android emulator or physical device

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/dplanner.git
   cd dplanner
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production
```bash
# Android APK
flutter build apk --release

```

## Screenshots

### Main Features

<table>
<tr>
<td width="33%">
<img src="screenshots/homepage.png" alt="Home Screen" width="100%">
<br><b>Home Screen</b><br>
<small>Clean dashboard showing today's tasks with priority indicators, progress tracking, and beautiful gradient background</small>
</td>
<td width="33%">
<img src="screenshots/calendarpage.png" alt="Calendar Screen" width="100%">
<br><b>Calendar View</b><br>
<small>Monthly calendar with task highlighting and date selection for easy task management</small>
</td>
<td width="33%">
<img src="screenshots/taskcreation.png" alt="Task Creation" width="100%">
<br><b>Task Creation</b><br>
<small>Intuitive dialog with date picker, priority selection, and reminder controls</small>
</td>
</tr>
<tr>
<td width="33%">
<img src="screenshots/taskperiodsetting.png" alt="Task Period Setting" width="100%">
<br><b>Task Period Setting</b><br>
<small>Advanced task scheduling with due date and time selection</small>
</td>
<td width="33%">
<img src="screenshots/remindersettingtime.png" alt="Reminder Setting" width="100%">
<br><b>Reminder Configuration</b><br>
<small>Customizable reminder timing with intuitive plus/minus controls</small>
</td>
<td width="33%">
<img src="screenshots/settingspage.png" alt="Settings Screen" width="100%">
<br><b>Settings Page</b><br>
<small>Comprehensive settings with notification preferences, reminder timing, and data management options</small>
</td>
</tr>
</table>

## Configuration

### Notification Setup
The app uses [Android Asset Studio](https://romannurik.github.io/AndroidAssetStudio/icons-notification.html) for generating notification icons. The notification icons are located in:
- `android/app/src/main/res/drawable-hdpi/ic_stat_access_alarm.png`

### Database Schema
```sql
CREATE TABLE todos (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  isCompleted INTEGER DEFAULT 0,
  createdAt TEXT NOT NULL,
  dueDate TEXT,
  priority TEXT DEFAULT 'medium',
  hasReminder INTEGER DEFAULT 0,
  reminderMinutes INTEGER DEFAULT 10,
  isHidden INTEGER DEFAULT 0
);
```

## Customization

### Theme Customization
The app supports dynamic theme switching with customizable colors:
- Primary color: Orange (#FF9800)
- Background: Dark theme with gradient support
- Accent colors: Configurable through Settings

### Notification Icons
Custom notification icons generated using [Android Asset Studio](https://romannurik.github.io/AndroidAssetStudio/icons-notification.html):
- **ic_stat_access_alarm.png**: Status bar alarm icon

## Features Implementation

### Core Requirements Met

1. **Task Management**
   - Create tasks with title, description, due date
   - Reminder time selection with plus/minus controls
   - Today's tasks display
   - Edit and delete functionality

2. **Calendar View**
   - Monthly calendar display
   - Task highlighting on dates
   - Date selection for task viewing

3. **Reminder System**
   - Local notifications with background support
   - Customizable reminder timing
   - Permission handling

4. **Local Storage**
   - SQLite database implementation
   - Data persistence across app restarts
   - Efficient query operations

5. **Navigation**
   - BottomNavigationBar with 3 screens
   - Today, Calendar, and Settings screens
   - Smooth navigation transitions

6. **Settings**
   - Reminder toggle functionality
   - Storage method indication (SQLite)

## Development

### Code Quality
- **Clean Architecture**: Separation of UI, business logic, and data layers
- **Modular Design**: Organized folder structure with clear separation of concerns
- **Documentation**: Comprehensive code comments and README
- **Best Practices**: Following Flutter and Dart coding conventions


## Assignment Compliance

This project fully meets all requirements for the Study Planner App assignment:

- **Task Management**: Complete CRUD operations with all required fields
- **Calendar Integration**: Monthly view with task highlighting
- **Reminder System**: Full notification support with custom timing
- **Local Storage**: SQLite implementation with data persistence
- **Navigation**: BottomNavigationBar with 3 required screens
- **Settings**: Reminder toggles and storage information
- **UI/UX**: Material Design compliance with clean, responsive interface
- **Code Quality**: Well-structured, documented, and modular codebase


## Author

**MUNEZERO Hubert**
- GitHub: [@Hubert2c](https://github.com/Hubert2c/Study-Planner-App_Hubert2c)
- Email: m.hubert@alustudent.com

## Acknowledgments

- Flutter team for the amazing framework
- [Android Asset Studio](https://romannurik.github.io/AndroidAssetStudio/icons-notification.html) for notification icons
- Material Design team for design guidelines
- Flutter community for excellent packages and resources
