# Branch Manager Home Page

This implementation provides a fully functional Branch Manager Home page for managing tickets in a maintenance/ticketing system.

## Features Implemented

### 1. **Report Issue Card (Blue Card)**
   - Prominent gradient blue card at the top
   - Three-dot menu icon (not close icon)
   - "Report Issue" button for creating new tickets
   - Fixed position at top of scrollable content

### 2. **Interactive Filter Tabs**
   - Three filter options: New, In Progress, Completed
   - Located below the blue report issue card
   - Click to switch between ticket views
   - Real-time filtering of tickets based on status
   - Visual feedback for selected filter

### 3. **Dynamic Ticket Views**
   - **New Tickets**: Special UI design with:
     - Blue border highlight
     - "NEW TICKET" badge
     - Time ago indicator
     - Location information
     - Action buttons: "View Details" and "Assign"
   
   - **In Progress/Completed Tickets**: Standard card design with:
     - Title and description
     - Status badge
     - Branch location
     - Ticket number
     - Assignee avatar

### 4. **Mobile Bottom Navigation**
   - 5 navigation items: Home, Tickets, Add (center), Team, Profile
   - Active state indicators
   - Gradient center button for creating new tickets
   - Labels under each icon
   - SafeArea for notch support

### 4. **Components**

#### Files Created:
```
lib/
├── features/
│   ├── home/
│   │   └── view/
│   │       └── branch_manager_home_page.dart    # Main page with 3 sections
│   └── tickets/
│       ├── model/
│       │   └── ticket_model.dart                # Ticket data model
│       └── controller/
│           └── ticket_controller.dart           # State management
└── core/
    └── routing/
        └── app_router.dart                      # Updated with new route
```

## Data Model

### TicketModel
```dart
class TicketModel {
  String id;
  String title;
  String description;
  String branch;
  String ticketNumber;
  TicketStatus status;
  String? assignedTo;
  DateTime createdAt;
  DateTime? updatedAt;
}
```

### TicketStatus Enum
- `newTicket` - Newly created tickets
- `inProgress` - Tickets being worked on
- `completed` - Finished tickets
- `cancelled` - Cancelled tickets

## Usage

### Navigate to Branch Manager Home:
```dart
Navigator.pushNamed(context, RouteNames.branchManagerHome);
```

### To test with different data:
The `TicketController` contains sample data. You can modify `_loadSampleData()` method to add more test tickets.

## UI Features

### Design Elements:
- **Color Scheme**: Light blue accent (#4FC3F7)
- **Card Shadows**: Subtle elevation for depth
- **Rounded Corners**: 12-16px border radius
- **Responsive Layout**: Adapts to different screen sizes

### Interactive Elements:
1. **Filter Chips**: Tap to filter tickets by status
2. **Page Swipe**: Swipe left/right to navigate sections
3. **Bottom Navigation**: Placeholder for app navigation
4. **Report Issue Button**: Trigger for creating new tickets

## Next Steps

To complete the implementation, you'll need to:

1. **Connect to Backend API**
   - Replace sample data in `TicketController` with API calls
   - Implement proper error handling
   - Add loading states

2. **Create Report Issue Page**
   - Form for creating new tickets
   - Image upload functionality
   - Location picker

3. **Add Ticket Detail Page**
   - Tap on ticket cards to view full details
   - Update ticket status
   - Add comments/updates

4. **Implement Bottom Navigation**
   - Link to other sections of the app
   - Home, Tickets, Team, Profile tabs

5. **Add Pull-to-Refresh**
   - Refresh ticket list
   - Update status indicators

## Testing

To test the page:

1. Run the app:
   ```bash
   flutter run -d chrome
   ```
   or
   ```bash
   flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
   ```

2. Navigate to the Branch Manager Home page
3. Test swiping between sections
4. Test filter functionality
5. Verify responsive design

## Notes

- The page uses `PageView` for swipeable sections
- `AnimatedBuilder` ensures UI updates when filter changes
- Controller uses `ChangeNotifier` for state management
- Sample data is pre-loaded for demonstration
