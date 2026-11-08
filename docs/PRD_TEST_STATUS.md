# FixNoww: PRD Test Status

**Date:** 8 November 2026  
**Build:** debug, Flutter 3.38.4, uncommitted working copy  
**Device:** Samsung SM A065F, Android 14, 720 × 1600 screen

This records what has and hasn't been tested against the [MVP PRD](PRD.md).

## Result

**Of the 25 issues from the phone test, 22 are fixed in code, 1 is partly fixed (#11), and 2 remain open (#1 and #3).** `flutter analyze` reports no issues, and all 13 automated tests pass.

**The fixes have not been fully rechecked on the phone yet.** The fixed build is installed, but the phone had locked before any of its screens could be checked. Issues marked "Automated" or "Rendered" below should still get a final look on the device, and the dialler still needs trying on a real phone.

## How each result was checked

| Label | Meaning |
| --- | --- |
| **Phone** | Done on the real device and checked with a screenshot |
| **Automated** | Passes in the repo's tests, which run at the phone's screen size with the real Roboto font |
| **Rendered** | Screen drawn on the Mac with real fonts and checked by eye, but not on a device |
| **Code only** | Changed, but no test or check has run it directly |

## Issues from the phone test

### High

| # | Issue | Status | Checked by |
| --- | --- | --- | --- |
| 1 | Pressing Back to leave the app logs out and wipes all data | **Open:** needs the backend | Phone, before fixes |
| 2 | Negative prices are accepted | Fixed: price must be greater than 0, with an error message | Automated |
| 3 | A provider's price takes effect without customer approval | **Open:** needs the PRD's offer flow (C6, PR3) | Phone, before fixes |

### Medium

| # | Issue | Status | Checked by |
| --- | --- | --- | --- |
| 4 | Offline providers see requests | Fixed | Automated |
| 5 | Declined jobs stay listed | Fixed: hidden for that provider, open for others | Automated |
| 6 | Long addresses overflow on two cards | Fixed: wrap to two lines, then shorten with "…" | Automated |
| 7 | Cancelled bookings are deleted | Fixed: kept with a Cancelled status and message | Automated |
| 8 | Empty booking forms are accepted | Fixed: every field is required, including a future date and time | Automated |
| 9 | A hidden time could be booked | Fixed: a time can only be chosen after a date, and it's always shown | Code only |
| 10 | Cancelling the date still opens the time picker | Fixed | Automated |
| 11 | After acceptance, the customer can't cancel or contact the provider | **Partly open:** **Call Provider** added; cancelling needs PRD C8 | Automated (button present) |
| 12 | Cancel Booking has no confirmation | Fixed | Automated |
| 13 | The bell and support number do nothing | Fixed: bell shows "coming soon", **Call Now** opens the dialler | Code only |
| 14 | Request cards don't show the scheduled time | Fixed | Automated |
| 15 | Date and time pickers are hard to read | Fixed | Rendered |
| 16 | Pop-up messages are hard to read | Fixed: white text, with a darker green | Rendered (green message only) |
| 25 | Earnings don't change after a completed job | Fixed: price is added once on completion | Automated |

### Low

| # | Issue | Status | Checked by |
| --- | --- | --- | --- |
| 17 | Double border on the phone field | Fixed | Code only |
| 18 | "Code sent to +94 07…" wording | Fixed: "Enter the code for +94 7…" | Automated |
| 19 | Hard-to-see customer icon | Fixed | Code only |
| 20 | "You can always switch later", and the mention of cleaning | Fixed: both removed | Code only |
| 21 | Provider tab labels mixed up | Fixed: **Requests** and **My Jobs** | Code only |
| 22 | Banner shows only the first job, and seed jobs are dated April | Fixed: banner counts jobs, seed dates follow today | Rendered (dates only) |
| 23 | An empty price has no message, and `Rs.` is hidden until selected | Fixed | Automated (message) |
| 24 | Done adds a new line in the description, hiding Submit | Fixed: keyboard action set to Done | Code only |

### Other changes

- **Category tiles:** "Construction" barely fit its tile, and automated tests caught it overflowing with different font metrics. Tiles now have more room.
- **Repository layer:** screens now reach data through interfaces, ready for an API (see the [overview](PROJECT_OVERVIEW.md#data-flow)).
- **Safe claiming and status order:** the in-memory repository now refuses a second claim on a job and any out-of-order status change. Automated tests cover both, and the server must enforce the same rules.
- **Removed code:** the unreachable pending actions on the job detail screen.

## What the original phone round confirmed

These were checked on the real device before the fixes, and the fixes shouldn't have changed them. A final phone pass should confirm that.

- **Login:** install and launch, bypass with any number or blank fields, role select, all five demo accounts, **Change number**, the OTP back arrow, and logout.
- **Customer:** home, category grid, booking creation with temp data, booking list, details in every status, Call tab, and profile.
- **Provider:** home, request matching on trade and area, accept, start, complete, My Jobs, chat placeholder, and profile.
- **Navigation:** Android Back on detail pages, the app's back arrows, and data surviving the Home button and logout.
- **Log:** the only exceptions were the long-address overflows, now fixed.

## Phone recheck list

Do this on the fixed build:

- [ ] Phone field has a single border
- [ ] Empty form shows three errors
- [ ] Date and time pickers are readable, and cancelling the date stops there
- [ ] Long address fits on the provider's and customer's cards
- [ ] Negative and empty prices show an error
- [ ] Offline hides requests, and declining removes the job
- [ ] Earnings rise after a completed job
- [ ] All pop-up messages are readable, especially "Booking cancelled." and "Job marked as started!"
- [ ] **Call Now** and **Call Provider** open the dialler
- [ ] Provider tabs read **Requests** and **My Jobs**
- [ ] Done closes the keyboard in the description field

## What was not tested

### Existing features

- The Carpentry, Welding, Construction and Other forms. They share code with the tested ones, and no seeded provider covers those trades
- Very long descriptions and names, and very large prices. The code suggests 1,000,000 displays as `Rs. 1000,000`
- Rotating the phone, large text sizes, smaller screens and TalkBack
- Interruptions such as calls, or the phone killing the app in the background
- Opening detail pages directly by URL, and a customer reaching provider routes. These are known risks from reading the code, but neither has been run
- Release builds on Android and iOS, including confirming the bypass is absent
- Performance. Debug builds are slower, so nothing here says how fast a release build would be
- Running the app on iOS. The app targets Android and iOS only, and all phone testing so far has been on Android

### PRD requirements that can't be tested yet

These aren't built, so there's nothing to test:

| Area | PRD items |
| --- | --- |
| **Accounts** | OTP (A1), sign-up (A2), staying logged in (A3), server-side permissions (A4), and all P1 account items |
| **Customer** | Launch trades only (C2), offer details and approval (C5, C6), cancelling after acceptance (C8), reviews (C10) |
| **Provider** | Customer-approved offers (PR3), real earnings history (PR6), fixed service areas (PR7) |
| **Across the product** | Syncing between phones (X1), server enforcement (X2, X3), privacy controls (X4) |
| **Admin** | All, since the MVP uses database tools |
| **Non-functional** | Performance, reliability and security (section 9) |

## Suggested next steps

1. Run the phone recheck list.
2. Decide what to do with the four extra categories (PRD section 12).
3. Start the backend in its own workspace.
