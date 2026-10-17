# Recall Garden

A native SwiftUI flashcard foundation for iPhone and iPad (iOS 17+). A warm paper palette, botanical emblems, and a calm “tend your memories” voice give it its own direction. All visuals use SwiftUI shapes and Apple SF Symbols; there are no bundled third-party assets or dependencies.

## Run

Open `RecallGarden.xcodeproj` in Xcode 15 or newer on a Mac. Select the RecallGarden target and an iPhone simulator, then Run. For a physical device, select your signing team and replace `com.example.RecallGarden` with your own bundle identifier.

Each cloud task already has an isolated checkout; use the existing repository rather than creating a worktree. This Linux cloud machine has no Swift compiler, Apple SDK, or Xcode, so compilation and simulator behavior have not been verified here.

## Included

- Create decks with botanical and celestial emblems; delete decks with confirmation.
- Create, edit, and delete question-and-answer cards.
- Reveal answers and rate recall: Again returns in one minute; Got it schedules 1 day initially and doubles the interval; Easy schedules 3 days initially and triples it. Intervals cap at 365 days. This is a simple scheduling heuristic, not a validated learning algorithm.
- Study a snapshot of due cards once per session. Cards rated Again appear in a later session after their due time.
- Local, atomic JSON storage under Application Support. No accounts, analytics, advertising, or network calls. Corrupt files are preserved and editing is blocked rather than overwriting them.
- A small, removable starter deck.

## Validate on a Mac

```sh
xcodebuild -project RecallGarden.xcodeproj -scheme RecallGarden -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build
```

In the simulator: create a deck and two cards, edit one, study and reveal both answers, rate one Again and one Got it, and confirm only Again becomes due after a minute. Force-quit and reopen to verify persistence. Delete a card, cancel deck deletion, then confirm deletion. Check large accessibility text, VoiceOver, landscape, and iPad layouts. These checks are pending; no passing iOS build is claimed.

## Before an App Store submission

This is a starting point, not a submission-ready app. Add an original app icon and launch branding, choose and clear your final name, set signing and bundle ID, and validate on real devices. Prepare screenshots, support and privacy-policy URLs, accurate App Privacy disclosures, age rating, accessibility review, and any required privacy manifest declarations. Consider export/import and recovery of saved decks before public release. There is no paid content or purchase flow yet.

The interface and source were created for this project, but originality does not guarantee exclusive rights or that a similar name or concept does not already exist. Search App Store listings and trademark registers in your markets before investing in the brand. Copyright protects qualifying original expression; it does not prevent others from making flashcard apps. Do not publish under a claim of guaranteed exclusivity.
