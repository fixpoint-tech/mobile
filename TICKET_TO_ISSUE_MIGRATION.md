# Complete Rename: Ticket → Issue

## ✅ Completed Files

### New Files Created:
1. ✅ `lib/features/tickets/model/issue_model.dart` - IssueModel, IssueStatus
2. ✅ `lib/features/tickets/service/issue_api_service.dart` - IssueApiService
3. ✅ `lib/features/tickets/controller/issue_controller.dart` - IssueController
4. ✅ `lib/shared/widgets/issue_card.dart` - IssueCard widget

## 📋 Remaining Files to Update

### High Priority - Core Files:
These files import and use the ticket classes directly:

1. ⏳ `lib/features/home/view/branch_manager_home_page.dart`
   - Import: ticket_controller → issue_controller
   - Import: ticket_model → issue_model
   - Import: ticket_card → issue_card
   - Class: TicketController → IssueController
   - Variables: _ticketController → _issueController
   - Methods: refreshTickets() → refreshIssues()
   - Text: "Recent Tickets" → "Recent Issues"
   - Enum: TicketStatus → IssueStatus

2. ⏳ `lib/features/home/view/maintenance_executive_home_page.dart`
   - Same changes as branch_manager_home_page

3. ⏳ `lib/features/home/view/technician_home_page.dart`
   - Same changes as branch_manager_home_page

4. ⏳ `lib/features/tickets/view/report_new_issue_page.dart`
   - Import: ticket_controller → issue_controller
   - Import: ticket_model → issue_model
   - Class: TicketController → IssueController, TicketModel → IssueModel
   - Variables: _ticketController → _issueController, newTicket → newIssue
   - Methods: createTicket() → createIssue()

5. ⏳ `lib/features/tickets/view/reported_issues_page.dart`
   - Import: ticket_model → issue_model
   - Class: TicketModel → IssueModel, TicketStatus → IssueStatus
   - Variables: ticket → issue

### Medium Priority - Routing & Config:
6. ⏳ `lib/core/routing/app_router.dart`
   - Update imports if any

### Low Priority - Documentation:
7. ⏳ `API_INTEGRATION.md` - Already updated
8. ⏳ `ARCHITECTURE.md` - Update references
9. ⏳ `BRANCH_MANAGER_HOME.md` - Update references

## 🗑️ Files to Delete (After Migration):
- `lib/features/tickets/model/ticket_model.dart`
- `lib/features/tickets/service/ticket_api_service.dart`
- `lib/features/tickets/controller/ticket_controller.dart`
- `lib/shared/widgets/ticket_card.dart`
- `lib/core/services/ticket_api_service.dart` (if exists)

## 📝 Complete Terminology Changes:

| Old | New |
|-----|-----|
| Ticket | Issue |
| ticket | issue |
| tickets | issues |
| TicketModel | IssueModel |
| TicketController | IssueController |
| TicketApiService | IssueApiService |
| TicketStatus | IssueStatus |
| TicketCard | IssueCard |
| ticketNumber | issueNumber |
| newTicket | newIssue |
| createTicket() | createIssue() |
| fetchTickets() | fetchIssues() |
| refreshTickets() | refreshIssues() |
| updateTicketStatus() | updateIssueStatus() |
| filteredTickets | filteredIssues |
| _ticketController | _issueController |
| "Recent Tickets" | "Recent Issues" |
| "No tickets found" | "No issues found" |

## 🔧 Migration Steps:

### Option 1: Complete Now (Recommended)
I can continue and update all remaining files systematically. This will take several operations but will be complete.

### Option 2: Manual Migration
You can manually update the files using find-and-replace in VS Code:
1. Find: `TicketModel` → Replace: `IssueModel`
2. Find: `TicketController` → Replace: `IssueController`
3. Find: `TicketStatus` → Replace: `IssueStatus`
4. Find: `ticket_controller` → Replace: `issue_controller`
5. Find: `ticket_model` → Replace: `issue_model`
6. etc.

### Option 3: Gradual Migration
Keep both old and new files, gradually migrate page by page, then delete old files when done.

## ⚠️ Important Notes:

1. **Folder Name**: The folder is still `lib/features/tickets/` - Do you want to rename to `lib/features/issues/`?

2. **Breaking Changes**: This is a breaking change. All existing references must be updated.

3. **Testing**: After migration, thoroughly test:
   - Creating new issues
   - Viewing issue lists
   - Filtering issues
   - API calls

## 🚀 Next Steps:

Would you like me to:
1. ✅ **Continue automated refactoring** - I'll update all remaining files
2. ⏸️ **Pause here** - You can review and test current changes
3. 📁 **Also rename folder** - Rename `tickets/` to `issues/`

Let me know and I'll proceed!
