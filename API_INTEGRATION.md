# API Integration Guide

This Flutter app is now configured to use API calls for issue management. Here's what you need to know:

## 📁 Files Created

### 1. API Service Layer
- **`lib/core/services/api_service.dart`** - Base HTTP service with GET, POST, PUT, DELETE methods
- **`lib/core/services/ticket_api_service.dart`** - Issue-specific API methods
- **`lib/core/config/api_config.dart`** - API configuration (base URL, endpoints)

### 2. Updated Files
- **`lib/features/tickets/controller/ticket_controller.dart`** - Now uses API calls instead of mock data
- **`pubspec.yaml`** - Added `http: ^1.2.2` package

## ⚙️ Configuration

### Update API Base URL

Open `lib/core/config/api_config.dart` and update the base URL:

```dart
class ApiConfig {
  // Update this with your backend URL
  static const String baseUrl = 'http://your-backend-url.com/api';
}
```

**Examples:**
- Local development: `'http://localhost:3000/api'`
- Production: `'https://api.yourdomain.com/api'`

## 🔌 API Endpoints Expected

Your backend should provide these endpoints:

### 1. **Fetch All Issues**
```
GET /issues
```
**Response:**
```json
{
  "issues": [
    {
      "id": "1",
      "title": "Pizza Oven Malfunction",
      "description": "Main oven not heating properly",
      "branch": "Kollupitiya Branch",
      "ticketNumber": "21",
      "status": "In Progress",
      "assignedTo": "John Doe",
      "createdAt": "2025-10-23T10:30:00Z",
      "updatedAt": "2025-10-23T11:00:00Z"
    }
  ]
}
```

### 2. **Create New Issue**
```
POST /issues
```
**Request Body:**
```json
{
  "id": "123456789",
  "title": "New Issue Title",
  "description": "Issue description",
  "branch": "Kollupitiya Branch",
  "ticketNumber": "789",
  "status": "New",
  "assignedTo": "Executive Name",
  "createdAt": "2025-10-23T10:30:00Z"
}
```
**Response:**
```json
{
  "issue": {
    "id": "123456789",
    "title": "New Issue Title",
    // ... full issue object
  }
}
```

### 3. **Update Issue Status**
```
PUT /issues/{issueId}
```
**Request Body:**
```json
{
  "status": "inProgress"
}
```
**Response:**
```json
{
  "issue": {
    "id": "1",
    "status": "inProgress",
    // ... full updated issue
  }
}
```

### 4. **Delete Issue**
```
DELETE /issues/{issueId}
```

## 🎯 How It Works

### When Creating a New Issue:

1. User fills out the form in `ReportNewIssuePage`
2. On submit, `createTicket()` is called
3. The issue is sent to your backend via `POST /issues`
4. Backend saves it to the database
5. Backend returns the created issue
6. The issue is added to the local list
7. User is redirected to home page

### When Viewing Home Page:

1. Page loads and calls `refreshTickets()` in `initState()`
2. `fetchTickets()` makes a `GET /issues` request
3. Backend fetches issues from database
4. Issues are displayed in the UI
5. User can filter by status (New, In Progress, Completed)

## 🔄 API Flow Diagram

```
Create Issue Flow:
User → ReportNewIssuePage → createTicket() → API Service → Backend → Database
                                                                      ↓
Database → Backend → API Response → TicketController → Update UI ← User

View Issues Flow:
User → HomePage → initState() → refreshTickets() → API Service → Backend → Database
                                                                            ↓
Database → Backend → API Response → TicketController → Display List ← User
```

## 🛠️ Testing Without Backend

The app includes fallback behavior:
- If API calls fail, it loads sample data automatically
- This allows you to test the UI while the backend is being developed

To test with sample data:
1. Keep the default URL in `api_config.dart`
2. The API will fail (no server running)
3. Sample data will be loaded as fallback

## 📝 Response Format Options

The API service supports multiple response formats:

```json
// Option 1: Wrapped in 'issues' key
{ "issues": [...] }

// Option 2: Wrapped in 'data' key
{ "data": [...] }

// Option 3: Direct array
[...]
```

The same applies for single issue responses:
```json
{ "issue": {...} }  // or
{ "data": {...} }    // or
{...}                // direct object
```

## 🔒 Adding Authentication

To add authentication headers, update `lib/core/services/api_service.dart`:

```dart
Map<String, String> get _headers => {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'Bearer YOUR_TOKEN_HERE', // Add this
};
```

You can store the token in SharedPreferences or a state management solution.

## ⚡ Performance Notes

- The controller is a **singleton** - it's shared across all pages
- API calls are made only when needed (on page load, on create, etc.)
- Local state is updated immediately for responsive UI
- The `refreshTickets()` method can be called to force refresh

## 🐛 Error Handling

All API errors are caught and:
1. Logged to console
2. Shown to user via SnackBar
3. Sample data loaded as fallback (for fetch operations)

Error types:
- Network errors
- 400 Bad Request
- 401 Unauthorized
- 404 Not Found
- 500 Server Error

## 📦 Dependencies

- `http: ^1.2.2` - For making HTTP requests
- `intl: ^0.19.0` - For date formatting
- `google_fonts: ^6.2.1` - For Outfit font

## 🚀 Next Steps

1. **Update API base URL** in `lib/core/config/api_config.dart`
2. **Ensure your backend endpoints match** the expected format above
3. **Test the create flow**: Create a new issue and verify it appears in the database
4. **Test the fetch flow**: Reload the home page and verify issues are fetched from the database
5. **Add authentication** if needed

## 💡 Tips

- Check browser console (F12) for network requests when testing
- Use a tool like Postman to test your backend endpoints first
- Ensure CORS is enabled on your backend for web testing
- The app will automatically retry failed requests on pull-to-refresh

---

**Need help?** Check the code comments in the service files for more details!
