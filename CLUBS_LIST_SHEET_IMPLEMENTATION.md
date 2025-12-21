# Clubs List Sheet Implementation - iOS Map Screen

## What Was Added

### 1. Menu Icon Button (Bottom Left)
- Positioned at bottom left of the map screen
- White background with orange menu icon
- Taps to open the clubs list sheet

### 2. Clubs List Bottom Sheet (`_showClubsListSheet()`)
A draggable, expandable bottom sheet that displays all clubs within the current search radius.

**Features:**
- **Header**: Shows "Clubs in Radius (X)" with close button (X)
- **Draggable**: Can be dragged up/down to expand/collapse
- **Size Range**: 
  - Min: 30% of screen
  - Initial: 50% of screen
  - Max: 90% of screen
- **Empty State**: Shows icon and message when no clubs in radius
- **Club Cards**: Each club displays:
  - Club name (bold, 16px)
  - Sport icon + sport name
  - People icon + member count
  - Orange distance badge (e.g., "2.5 km")
- **Tap Action**: Tapping a club navigates to its profile screen

### 3. Layout Changes
- Moved "My Location" button from `bottom: 100` to `bottom: 16` (same level as menu)
- Menu icon on left, My Location button on right
- Both buttons are white with colored icons (orange for menu, blue for location)

## How It Works

1. User taps the menu icon (hamburger) at bottom left
2. Bottom sheet slides up showing clubs in search radius
3. Sheet is draggable - user can drag to expand/collapse
4. Each club shows: name, sport, member count, distance
5. Tap any club to view its full profile
6. Close button (X) or drag down to dismiss

## Files Modified
- `lib/src/screens/map_screen.dart`

## Testing
1. Open map screen on iOS
2. Tap menu icon (hamburger) at bottom left
3. Sheet should slide up showing clubs in radius
4. Drag sheet up/down to expand/collapse
5. Tap a club to view its profile
6. Tap X or drag down to close sheet
