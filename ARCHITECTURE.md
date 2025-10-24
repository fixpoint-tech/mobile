# Component-Wise Architecture

## 📁 Folder Structure

Your Flutter app follows a **component-wise (feature-based)** architecture:

```
lib/
├── core/                           # Core/Shared functionality across the app
│   ├── config/
│   │   └── api_config.dart        # API configuration (base URL, endpoints)
│   ├── constants/
│   │   ├── app_colors.dart        # Centralized color constants
│   │   └── app_text_styles.dart   # Centralized text styles
│   ├── routing/
│   │   └── app_router.dart        # App navigation/routing
│   ├── services/
│   │   └── api_service.dart       # Base HTTP service (GET, POST, PUT, DELETE)
│   └── utils/
│
├── features/                       # Feature-based modules
│   ├── auth/                      # Authentication feature
│   │   ├── controller/            # Auth state management
│   │   ├── model/                 # Auth data models
│   │   ├── service/               # Auth API services
│   │   └── view/                  # Auth UI screens
│   │
│   ├── home/                      # Home feature
│   │   ├── controller/            # Home state management
│   │   ├── model/                 # Home data models
│   │   ├── service/               # Home API services
│   │   └── view/                  # Home UI screens
│   │       ├── branch_manager_home_page.dart
│   │       ├── maintenance_executive_home_page.dart
│   │       └── technician_home_page.dart
│   │
│   └── tickets/                   # Issues/Tickets feature ✅
│       ├── controller/            # Issue state management
│       │   └── ticket_controller.dart
│       ├── model/                 # Issue data models
│       │   └── ticket_model.dart
│       ├── service/               # Issue API services ✅
│       │   └── ticket_api_service.dart
│       └── view/                  # Issue UI screens
│           ├── report_new_issue_page.dart
│           ├── ticket_create_page.dart
│           ├── ticket_detail_page.dart
│           ├── ticket_list_page.dart
│           └── widgets/
│               ├── ticket_card.dart
│               ├── ticket_form.dart
│               └── ...
│
├── shared/                         # Shared UI components
│   └── widgets/
│       ├── user_header.dart       # Reusable user header
│       ├── status_filter_chip.dart # Reusable filter chips
│       ├── ticket_card.dart       # Reusable issue card
│       └── custom_bottom_navigation.dart
│
├── app.dart                       # App widget
└── main.dart                      # App entry point
```

## 🎯 Component-Wise Benefits

### ✅ **What We've Done Correctly:**

1. **Tickets/Issues Feature** - Self-contained module:
   ```
   features/tickets/
   ├── controller/          # TicketController (state management)
   ├── model/              # TicketModel, TicketStatus (data models)
   ├── service/            # TicketApiService (API calls) ✅
   └── view/               # UI screens and widgets
   ```

2. **Core Services** - Shared across all features:
   ```
   core/
   ├── config/             # Configuration files
   ├── constants/          # App-wide constants
   ├── routing/            # Navigation
   └── services/           # Base API service (used by all features)
   ```

3. **Shared Widgets** - Reusable components:
   ```
   shared/widgets/
   ├── user_header.dart
   ├── status_filter_chip.dart
   ├── ticket_card.dart
   └── custom_bottom_navigation.dart
   ```

## 📦 How Each Component Works

### 1. **Tickets Feature** (Component)
```
features/tickets/
```
- **Self-contained**: Everything related to issues is in one place
- **Model**: Defines what an issue looks like (`TicketModel`, `TicketStatus`)
- **Service**: Handles API calls for issues (`TicketApiService`)
- **Controller**: Manages issue state and business logic (`TicketController`)
- **View**: UI screens for creating/viewing issues

### 2. **Core Layer**
```
core/
```
- **Shared by all features**: Common functionality
- **api_service.dart**: Base HTTP client (GET, POST, PUT, DELETE)
- **api_config.dart**: API configuration
- **app_colors.dart**: Color constants
- **app_text_styles.dart**: Text styles

### 3. **Shared Layer**
```
shared/widgets/
```
- **Reusable UI components**: Used across multiple features
- **Stateless widgets**: No business logic, just presentation

## 🔄 Data Flow (Component-Wise)

```
UI (View)
   ↓
Controller (State Management)
   ↓
Service (API Layer - Component Specific)
   ↓
Core API Service (HTTP Client)
   ↓
Backend API
```

### Example: Creating an Issue

1. **View** (`report_new_issue_page.dart`) - User fills form
2. **Controller** (`ticket_controller.dart`) - `createTicket()` called
3. **Service** (`ticket_api_service.dart`) - Makes POST request
4. **Core Service** (`api_service.dart`) - Executes HTTP POST
5. **Backend** - Saves to database
6. **Response flows back** through the same chain
7. **UI updates** automatically (via `notifyListeners()`)

## 📋 File Organization Rules

### ✅ DO:
- Keep all feature-related code in the feature folder
- Use `core/` for shared functionality
- Use `shared/` for reusable UI components
- One feature = One folder

### ❌ DON'T:
- Mix feature logic in `core/`
- Put feature-specific services in `core/services/`
- Create circular dependencies between features

## 🎨 Current Structure Summary

Your app follows **component-wise architecture** correctly:

✅ **Features are self-contained**
- `tickets/` has its own controller, model, service, and view

✅ **Core is shared**
- `core/services/api_service.dart` is used by all features
- `core/config/` and `core/constants/` are app-wide

✅ **Shared widgets are reusable**
- `shared/widgets/` contains UI components used across features

✅ **Clean separation of concerns**
- Model (data)
- Service (API)
- Controller (state)
- View (UI)

## 🚀 Adding New Features

To add a new feature (e.g., "notifications"):

```
lib/features/notifications/
├── controller/
│   └── notification_controller.dart
├── model/
│   └── notification_model.dart
├── service/
│   └── notification_api_service.dart
└── view/
    ├── notification_list_page.dart
    └── widgets/
        └── notification_card.dart
```

Each feature is **independent** and **self-contained**! 🎯
