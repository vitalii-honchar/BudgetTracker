# Budget Tracker iOS - UI Design

## 1. Design Philosophy

**Principles**:
- **Clarity First**: Financial data must be immediately legible and trustworthy
- **Minimal Friction**: Common tasks (add transaction) in ≤3 taps
- **Visual Hierarchy**: Glass-morphism effects guide attention without overwhelming
- **Native Feel**: Embraces iOS platform conventions and gestures
- **Accessibility**: VoiceOver, Dynamic Type, and high contrast support built-in

**Visual Language**:
- Modern iOS design with depth through glass-morphism and blur effects
- System colors with semantic meaning (destructive red, success green)
- Generous whitespace for breathing room
- Smooth animations for state transitions (spring curves)

---

## 2. Navigation Structure

```
┌──────────────────────────────────────────────────────────────┐
│                    App Navigation Flow                        │
│                                                               │
│                  ┌─────────────────────┐                      │
│                  │   Expense Periods   │                      │
│                  │   (Root/Home)       │                      │
│                  └──────────┬──────────┘                      │
│                             │                                 │
│           ┌─────────────────┼─────────────────┐               │
│           │                 │                 │               │
│           ▼                 ▼                 ▼               │
│  ┌────────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ Create Period  │  │   Period    │  │   Reports   │        │
│  │    (Sheet)     │  │   Detail    │  │   (Tab)     │        │
│  └────────────────┘  └──────┬──────┘  └─────────────┘        │
│                             │                                 │
│                    ┌────────┼────────┐                        │
│                    │        │        │                        │
│                    ▼        ▼        ▼                        │
│           ┌────────────┐ ┌──────────────┐ ┌──────────┐       │
│           │   Create   │ │     Edit     │ │  Delete  │       │
│           │Transaction │ │ Transaction  │ │Transaction│       │
│           │  (Sheet)   │ │   (Sheet)    │ │  (Alert) │       │
│           └────────────┘ └──────────────┘ └──────────┘       │
│                                                               │
└──────────────────────────────────────────────────────────────┘

Tab Bar (Bottom):
┌───────────────┬────────────────┬───────────────────┐
│   Periods     │  Transactions  │      Reports      │
│   (Primary)   │   (Current)    │   (Analytics)     │
└───────────────┴────────────────┴───────────────────┘
```

**Navigation Patterns**:
- **Tab Bar**: Three primary sections (Periods, Transactions, Reports)
- **Sheets**: Modal forms for creation/editing (dismissible with swipe)
- **Navigation Stack**: Drill-down for period details
- **Alerts**: Confirmations for destructive actions

---

## 3. Screen Designs

### 3.1 Expense Periods List (Home)

**Purpose**: Top-level view showing all expense periods with quick actions.

```
┌──────────────────────────────────────────────────┐
│  ☰  Expense Periods                       [+]   │ ← Nav Bar
├──────────────────────────────────────────────────┤
│                                                  │
│  ┌────────────────────────────────────────────┐ │
│  │  March 2024                                │ │ ← Period Card
│  │  ───────────────────────────────────────   │ │   (Glassmorphic)
│  │  $2,847.50                                 │ │
│  │  Mar 1 - Mar 31  •  47 transactions        │ │
│  │                                            │ │
│  │  [View Details →]                          │ │
│  └────────────────────────────────────────────┘ │
│                                                  │
│  ┌────────────────────────────────────────────┐ │
│  │  February 2024                             │ │
│  │  ───────────────────────────────────────   │ │
│  │  $3,124.18                                 │ │
│  │  Feb 1 - Feb 29  •  52 transactions        │ │
│  │                                            │ │
│  │  [View Details →]                          │ │
│  └────────────────────────────────────────────┘ │
│                                                  │
│  ┌────────────────────────────────────────────┐ │
│  │  Vacation 2024                             │ │
│  │  ───────────────────────────────────────   │ │
│  │  $1,458.92                                 │ │
│  │  Jan 15 - Jan 22  •  28 transactions       │ │
│  │                                            │ │
│  │  [View Details →]                          │ │
│  └────────────────────────────────────────────┘ │
│                                                  │
└──────────────────────────────────────────────────┘
│   Periods  │  Transactions  │  Reports          │ ← Tab Bar
└──────────────────────────────────────────────────┘
```

**Interactions**:
- **[+]**: Opens "Create Period" sheet
- **Card Tap**: Navigates to Period Detail
- **Swipe Actions**: Edit, Delete (confirmation)

**Visual Elements**:
- Cards: Glassmorphic background with subtle blur
- Typography: Bold period name, regular metadata
- Spacing: 16pt between cards, 20pt edge padding

---

### 3.2 Period Detail (Transaction List)

**Purpose**: Shows all transactions within a specific expense period.

```
┌──────────────────────────────────────────────────┐
│  ← March 2024                            [+]    │ ← Nav Bar
├──────────────────────────────────────────────────┤
│  Total Spending                                  │
│  $2,847.50                                       │ ← Summary Header
│  47 transactions  •  Mar 1 - Mar 31              │
├──────────────────────────────────────────────────┤
│  🔍 Search or filter...          [⚙ Filter]     │ ← Search Bar
├──────────────────────────────────────────────────┤
│                                                  │
│  Today                                           │ ← Date Section
│  ┌───────────────────────────────────────────┐  │
│  │ 🍔  Lunch at Cafe          -$18.50        │  │ ← Transaction Row
│  │     Restaurants  •  12:34 PM              │  │
│  └───────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────┐  │
│  │ 🚕  Uber to Office         -$12.00        │  │
│  │     Transport  •  9:15 AM                 │  │
│  └───────────────────────────────────────────┘  │
│                                                  │
│  Yesterday                                       │
│  ┌───────────────────────────────────────────┐  │
│  │ 🛒  Grocery Shopping       -$84.32        │  │
│  │     Food  •  6:22 PM                      │  │
│  └───────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────┐  │
│  │ ⚽  Gym Membership          -$45.00        │  │
│  │     Sport  •  10:00 AM                    │  │
│  └───────────────────────────────────────────┘  │
│                                                  │
│  Mar 7                                           │
│  ┌───────────────────────────────────────────┐  │
│  │ 🎬  Movie Tickets          -$28.00        │  │
│  │     Entertainment  •  8:15 PM             │  │
│  └───────────────────────────────────────────┘  │
│                                                  │
└──────────────────────────────────────────────────┘
```

**Interactions**:
- **[+]**: Opens "Create Transaction" sheet
- **Row Tap**: Opens "Edit Transaction" sheet
- **Swipe Left**: Delete (with confirmation)
- **Pull to Refresh**: Sync with iCloud

**Visual Elements**:
- Rows: White/dark background with subtle shadow
- Icons: Category emoji (large, 28pt)
- Amount: Bold, right-aligned, color-coded (red for expenses)
- Metadata: Gray, smaller font (category + time)

---

### 3.3 Create/Edit Transaction (Sheet)

**Purpose**: Form for entering transaction details.

```
┌──────────────────────────────────────────────────┐
│  Cancel          Add Transaction          Save   │ ← Sheet Header
├──────────────────────────────────────────────────┤
│                                                  │
│  Amount                                          │
│  ┌────────────────────────────────────────────┐ │ ← Currency Input
│  │  $  [      147.50      ]       USD  ▼     │ │   (Large, Bold)
│  └────────────────────────────────────────────┘ │
│                                                  │
│  Transaction Name                                │
│  ┌────────────────────────────────────────────┐ │
│  │  Grocery Shopping                          │ │
│  └────────────────────────────────────────────┘ │
│                                                  │
│  Category                                        │
│  ┌─────┬─────┬─────┬─────┬─────┬─────┬─────┐  │
│  │ 🍔  │ 🍕  │ ⚽  │ 🚕  │ 🎬  │ 🛒  │ 💊  │  │ ← Icon Grid
│  │Food │Rest.│Sport│Trans│Ent. │Shop │Hlth │  │   (Selected=Bold)
│  └─────┴─────┴─────┴─────┴─────┴─────┴─────┘  │
│  ┌─────┬─────────────────────────────────────┐ │
│  │ 📝  │ [+ Create Custom Category]          │ │
│  │Bills│                                      │ │
│  └─────┴─────────────────────────────────────┘ │
│                                                  │
│  Date & Time                                     │
│  ┌────────────────────────────────────────────┐ │
│  │  Mar 8, 2024  •  2:45 PM          [Edit]  │ │ ← Auto-filled
│  └────────────────────────────────────────────┘ │
│                                                  │
│  Description (Optional)                          │
│  ┌────────────────────────────────────────────┐ │
│  │  Weekly grocery run at Whole Foods...     │ │ ← Text Editor
│  │                                            │ │
│  └────────────────────────────────────────────┘ │
│                                                  │
│            ┌──────────────────┐                 │
│            │   Save & Close   │                 │ ← Primary Button
│            └──────────────────┘                 │   (Glassmorphic)
│                                                  │
└──────────────────────────────────────────────────┘
```

**Validation**:
- Amount: Required, > 0, max 2 decimal places
- Name: Required, max 50 characters
- Category: Required (one selection)
- Date: Optional override, defaults to now

**Visual Elements**:
- Amount Input: Extra-large font (36pt), centered
- Category Grid: 7 columns, glassmorphic selection highlight
- Form Fields: Rounded rectangles with subtle borders
- Save Button: Prominent, glassmorphic effect

---

### 3.4 Reports Screen

**Purpose**: Visual analytics of spending patterns.

```
┌──────────────────────────────────────────────────┐
│  Reports                                         │ ← Nav Bar
├──────────────────────────────────────────────────┤
│  Date Range                                      │
│  ┌────────────────────────────────────────────┐ │
│  │  This Month ▼  │  Mar 1 - Mar 31, 2024    │ │ ← Range Picker
│  └────────────────────────────────────────────┘ │
├──────────────────────────────────────────────────┤
│                                                  │
│  Total Spending                                  │
│  ┌────────────────────────────────────────────┐ │
│  │                                            │ │
│  │         $2,847.50                          │ │ ← Total Card
│  │         ─────────                          │ │   (Glassmorphic)
│  │         47 transactions                    │ │
│  │                                            │ │
│  └────────────────────────────────────────────┘ │
│                                                  │
│  Spending by Category                            │
│  ┌────────────────────────────────────────────┐ │
│  │                                            │ │
│  │     ┌───────────────────────────────┐     │ │
│  │     │▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░│     │ │ ← Horizontal Bar
│  │     └───────────────────────────────┘     │ │   Chart
│  │  🍔 Restaurants  $847.20  (29.8%)         │ │
│  │                                            │ │
│  │     ┌─────────────────────────┐           │ │
│  │     │▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░│           │ │
│  │     └─────────────────────────┘           │ │
│  │  🛒 Shopping     $612.40  (21.5%)         │ │
│  │                                            │ │
│  │     ┌─────────────────────┐               │ │
│  │     │▓▓▓▓▓▓▓▓▓▓░░░░░░░░░│               │ │
│  │     └─────────────────────┘               │ │
│  │  🍕 Food         $458.90  (16.1%)         │ │
│  │                                            │ │
│  │     [View All Categories →]               │ │
│  │                                            │ │
│  └────────────────────────────────────────────┘ │
│                                                  │
│  Spending Trend                                  │
│  ┌────────────────────────────────────────────┐ │
│  │   $1000 │                        ╱╲        │ │ ← Line Chart
│  │         │                    ╱──╯  ╲       │ │
│  │    $500 │        ╱─╲    ╱──╯       ╲──    │ │
│  │         │    ╱──╯   ╲──╯                   │ │
│  │       0 └──────────────────────────────────│ │
│  │         Week1 Week2 Week3 Week4            │ │
│  └────────────────────────────────────────────┘ │
│                                                  │
└──────────────────────────────────────────────────┘
│   Periods  │  Transactions  │  Reports          │
└──────────────────────────────────────────────────┘
```

**Interactions**:
- **Date Range Picker**: Quick presets (This Month, Last Month, Custom)
- **Bar Chart Tap**: Drill into category details
- **View All**: Expands to show all categories

**Visual Elements**:
- Charts: Custom SwiftUI shapes with gradient fills
- Percentages: Color-coded by magnitude (high=red, low=green)
- Cards: Glassmorphic background with subtle borders

---

## 4. Component Library

### 4.1 Glassmorphic Button

```
Visual Representation:
┌──────────────────────────────────────┐
│                                      │ ← Blur Background
│         [ Button Label ]             │   (UIBlurEffect)
│                                      │
└──────────────────────────────────────┘
    ↑                                ↑
    │                                │
  Border (1pt)              Shadow (subtle)
```

**Properties**:
- Background: `.ultraThinMaterial` blur effect
- Border: 1pt white/black with 0.2 opacity
- Corner Radius: 12pt
- Shadow: 2pt offset, 4pt blur, 0.1 opacity
- Padding: 16pt vertical, 24pt horizontal

**States**:
- Default: Normal appearance
- Pressed: Scale down 0.95, opacity 0.8
- Disabled: Opacity 0.5, no interaction

---

### 4.2 Category Icon

```
┌──────────┐
│          │
│    🍔    │ ← Emoji (28pt)
│          │
│   Food   │ ← Label (12pt)
│          │
└──────────┘

Size: 64x64pt
Selected: Bold border + shadow
Unselected: Subtle border only
```

**Usage**:
- Transaction rows: Icon only (28pt)
- Category picker: Icon + label
- Reports: Icon + label + amount

---

### 4.3 Money Text Field

**Features**:
- Currency symbol prefix (dynamic based on locale)
- Decimal number formatting (max 2 places)
- Large, bold font (36pt for input)
- Currency picker (dropdown, top-right)

**Validation**:
- Only numeric input allowed
- Auto-format with thousand separators
- Prevent negative values (handled at use case level)

---

### 4.4 Transaction Row

```
┌──────────────────────────────────────────────┐
│  [Icon]  Transaction Name          -$XX.XX   │ ← Main Content
│          Category • Time                     │ ← Metadata
└──────────────────────────────────────────────┘
```

**Layout**:
- Icon: Leading, 28pt square
- Name: Bold, 16pt, truncate if needed
- Amount: Bold, 18pt, right-aligned
- Metadata: Gray, 14pt, below name

**States**:
- Normal: White/dark background
- Pressed: Slight gray tint
- Swipe Left: Red delete action revealed

---

## 5. Design System

### 5.1 Color Palette

**Semantic Colors** (System Dynamic Colors):

```
Primary Actions:
┌────────┐
│ .blue  │ ← Primary buttons, accents
└────────┘

Destructive:
┌────────┐
│  .red  │ ← Delete actions, warnings
└────────┘

Success:
┌────────┐
│ .green │ ← Confirmations, positive trends
└────────┘

Neutral:
┌────────┐
│ .gray  │ ← Metadata, secondary text
└────────┘

Backgrounds:
┌─────────────────┐
│ .systemBackground      │ ← Main background
│ .secondarySystemBackground │ ← Cards, rows
│ .tertiarySystemBackground  │ ← Nested elements
└─────────────────┘

Text:
┌─────────────┐
│ .label      │ ← Primary text
│ .secondaryLabel │ ← Metadata
│ .tertiaryLabel  │ ← Disabled text
└─────────────┘
```

**Category Colors**:
- Food: Orange
- Restaurants: Red
- Sport: Green
- Transport: Blue
- Entertainment: Purple
- Shopping: Pink
- Health: Teal
- Bills: Gray

---

### 5.2 Typography

**Type Scale**:

```
┌────────────────────────────────────────┐
│  Large Title   │ 34pt  │ Bold         │ ← Screen titles
│  Title 1       │ 28pt  │ Bold         │ ← Section headers
│  Title 2       │ 22pt  │ Bold         │ ← Card headers
│  Headline      │ 17pt  │ Semibold     │ ← Emphasis
│  Body          │ 17pt  │ Regular      │ ← Main content
│  Callout       │ 16pt  │ Regular      │ ← Secondary
│  Subheadline   │ 15pt  │ Regular      │ ← Metadata
│  Footnote      │ 13pt  │ Regular      │ ← Fine print
│  Caption       │ 12pt  │ Regular      │ ← Labels
└────────────────────────────────────────┘

Font: SF Pro (System)
Dynamic Type: Enabled (supports all sizes)
Weight: Regular, Semibold, Bold
```

**Usage Examples**:
- Screen Titles: Large Title, Bold
- Transaction Name: Body, Regular
- Transaction Amount: Body, Bold
- Category Label: Caption, Regular
- Metadata (time/date): Subheadline, Gray

---

### 5.3 Spacing & Layout

**Spacing Scale** (8pt grid):

```
┌────────┬─────────┬──────────────────┐
│  4pt   │  xs     │ Tight spacing    │
│  8pt   │  sm     │ Compact items    │
│  12pt  │  md     │ Related items    │
│  16pt  │  lg     │ Standard gap     │
│  24pt  │  xl     │ Section spacing  │
│  32pt  │  2xl    │ Major sections   │
│  48pt  │  3xl    │ Screen padding   │
└────────┴─────────┴──────────────────┘

Component Padding:
• Buttons: 16pt vertical, 24pt horizontal
• Cards: 16pt all sides
• Screen Edges: 20pt horizontal
• List Rows: 12pt vertical, 16pt horizontal
```

**Corner Radius**:
- Buttons: 12pt
- Cards: 16pt
- Input Fields: 8pt
- Sheets: 20pt (top corners only)

**Shadows**:
- Elevation 1: 2pt offset, 4pt blur, 0.1 opacity (buttons)
- Elevation 2: 4pt offset, 8pt blur, 0.15 opacity (cards)
- Elevation 3: 8pt offset, 16pt blur, 0.2 opacity (sheets)

---

### 5.4 Animation & Motion

**Timing Curves**:

```
Spring (Default):
┌────────────────────────────────────┐
│  Response: 0.3s                    │ ← Most UI transitions
│  Damping: 0.7                      │
└────────────────────────────────────┘

Ease In-Out:
┌────────────────────────────────────┐
│  Duration: 0.25s                   │ ← Fade transitions
│  Curve: .easeInOut                 │
└────────────────────────────────────┘

Quick:
┌────────────────────────────────────┐
│  Duration: 0.15s                   │ ← Button presses
│  Curve: .easeOut                   │
└────────────────────────────────────┘
```

**Animation Use Cases**:
- Sheet Present/Dismiss: Spring (0.3s)
- Button Press: Quick (0.15s) + scale 0.95
- List Item Tap: Quick (0.15s) + opacity 0.8
- Screen Transitions: Spring (0.3s) + slide
- Delete Action: Ease In-Out (0.25s) + fade + slide

---

## 6. Accessibility

### 6.1 VoiceOver Support

**Labels**:
- All interactive elements have descriptive labels
- Images/Icons: Hidden or descriptive alt text
- Amounts: Read as currency ("twenty-three dollars and fifty cents")
- Dates: Read in full ("March eighth, twenty twenty-four")

**Hints**:
- Buttons: "Double-tap to [action]"
- Swipe Actions: "Swipe right for options"

**Groupings**:
- Transaction rows: Group icon + name + amount + metadata
- Forms: Logical field groupings

---

### 6.2 Dynamic Type

**Support**:
- All text uses system text styles (scales automatically)
- Minimum touch targets: 44x44pt (iOS standard)
- Layout adapts to larger text (vertical stacking if needed)

**Testing Sizes**:
- xSmall → xxxLarge (7 sizes)
- Accessibility sizes: AX1 → AX5 (5 sizes)

---

### 6.3 Color Contrast

**WCAG AA Compliance**:
- Text on Background: Minimum 4.5:1 ratio
- Large Text: Minimum 3:1 ratio
- Interactive Elements: Minimum 3:1 ratio

**High Contrast Mode**:
- Stronger borders on buttons/cards
- Increased color saturation
- Thicker dividers/separators

---

## 7. Responsive Design

### 7.1 Device Sizes

**iPhone (Portrait)**:
- Transaction List: Single column, full-width cards
- Category Picker: 7 columns (if space) or 5 columns
- Charts: Full-width with vertical scroll

**iPhone (Landscape)**:
- Transaction List: Optional two-column layout (larger devices)
- Forms: Wider with side padding (max 600pt)

**iPad**:
- Navigation: Sidebar + detail view
- Transaction List: Two-column layout
- Forms: Centered with max 600pt width
- Reports: Side-by-side charts

---

## 8. Interaction Patterns

### 8.1 Gestures

```
Swipe Right (on Transaction Row):
┌──────────────────────────────────────────┐
│  [Edit]  Transaction Name       -$XX.XX  │ ← Edit action
└──────────────────────────────────────────┘

Swipe Left (on Transaction Row):
┌──────────────────────────────────────────┐
│  Transaction Name       -$XX.XX  [Delete]│ ← Delete action
└──────────────────────────────────────────┘

Pull to Refresh (on Lists):
┌──────────────────────────────────────────┐
│              ↓ Pull to sync              │
└──────────────────────────────────────────┘

Swipe Down (on Sheets):
┌──────────────────────────────────────────┐
│  ─────── Swipe to dismiss ───────        │
└──────────────────────────────────────────┘
```

**Tap Targets**:
- Minimum: 44x44pt (iOS standard)
- Recommended: 48x48pt for primary actions
- Spacing: 8pt minimum between interactive elements

---

### 8.2 Loading States

**Skeleton Screens**:
```
┌──────────────────────────────────────────┐
│  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓             ▓▓▓▓▓▓▓     │ ← Shimmer effect
│  ▓▓▓▓▓▓▓▓   ▓▓▓▓▓                        │   (loading)
└──────────────────────────────────────────┘
```

**Empty States**:
```
┌──────────────────────────────────────────┐
│                                          │
│              💰                          │
│                                          │
│         No Transactions Yet              │
│                                          │
│  Add your first transaction to start     │
│         tracking your expenses           │
│                                          │
│       ┌──────────────────┐               │
│       │  Add Transaction │               │
│       └──────────────────┘               │
│                                          │
└──────────────────────────────────────────┘
```

---

### 8.3 Error States

**Inline Validation**:
```
┌──────────────────────────────────────────┐
│  Amount                                  │
│  ┌────────────────────────────────────┐ │
│  │  $  [      0.00      ]       USD   │ │ ← Red border
│  └────────────────────────────────────┘ │
│  ⚠️ Amount must be greater than zero    │ ← Error message
└──────────────────────────────────────────┘
```

**Alert Dialogs**:
```
┌──────────────────────────────────────────┐
│                                          │
│  ⚠️  Delete Transaction?                 │
│                                          │
│  This action cannot be undone.           │
│                                          │
│  ┌────────────┐    ┌─────────────────┐  │
│  │   Cancel   │    │  Delete (Red)   │  │
│  └────────────┘    └─────────────────┘  │
│                                          │
└──────────────────────────────────────────┘
```

---

## 9. Dark Mode

**Automatic Switching**:
- Respects system preference
- No manual toggle (follows iOS convention)

**Color Adjustments**:
```
Light Mode               Dark Mode
┌────────────┐          ┌────────────┐
│ White BG   │    ↔     │ Black BG   │
│ Black Text │          │ White Text │
└────────────┘          └────────────┘

Glassmorphism:
• Light: .ultraThinMaterial (white tint)
• Dark: .ultraThinMaterial (dark tint)

Shadows:
• Light: 0.1 opacity
• Dark: 0.3 opacity (stronger for depth)
```

---

## 10. Summary

**Design Highlights**:

✅ **Modern**: Glassmorphic effects with iOS design language
✅ **Accessible**: VoiceOver, Dynamic Type, high contrast support
✅ **Efficient**: 3-tap maximum for common tasks
✅ **Responsive**: Adapts to all iPhone/iPad sizes
✅ **Native**: Platform-standard gestures and patterns
✅ **Consistent**: Unified component library and spacing system

**Key Screens**: 5 primary views (Periods List, Period Detail, Transaction Form, Reports, Settings)
**Components**: 8 reusable components (Buttons, Cards, Icons, Inputs, Charts)
**Design System**: Complete with colors, typography, spacing, and animation guidelines

The UI design prioritizes **clarity** and **efficiency** while maintaining a **modern, polished** aesthetic that feels native to iOS.
