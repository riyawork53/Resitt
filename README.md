# Resitt

A SwiftUI study app for iPhone and iPad, iOS 17+. White surfaces, soft red accents and study-focused decks. No external dependencies, accounts, analytics or network calls.

## Open on a Mac

Open `RecallGarden.xcodeproj` in Xcode 15 or newer. The project filename and bundle identifier are retained for compatibility; the installed app and interface display **Resitt**. Select an iPhone simulator and press Command-R. For a physical iPhone, select your signing team. Camera capture requires a real device; the simulator can use the photo picker.

## Features

- Create and delete decks, and create, edit and delete cards.
- Attach a camera photo or library image to a card; enter a question/topic and answer/correction notes. Photos appear on the question side during study. Remove or replace photos in the editor. Images are normalized and resized to at most 1,800 pixels on their longest side, then saved as JPEG locally with the cards.
- Review due cards with answer reveals and Again / Got it / Easy scheduling. Again is due after a minute; Got it starts at one day and doubles; Easy starts at three days and triples. Intervals cap at 365 days. Cards appear once per session.
- Fresh libraries start empty. Earlier versions included a “Small wonders” example deck: existing data is deliberately preserved. Delete that deck through its menu if unwanted. Missing photo fields in older saves decode as nil.
- Resitt Premium has a clearly labeled coming-soon screen for future cosmetic card designs. **No designs, prices, transactions or premium entitlements are implemented.** Core study and photo features are free.

Storage is an atomic JSON file under the original Application Support location to preserve upgrades. There is no cloud sync or export yet; deleting the app can delete study data. Photos are embedded in that file, so a large collection will eventually need a separate image store. Camera access has a purpose string and denial/unavailable handling. The system photo picker does not require full photo-library access.

## Validation

This Linux environment has no Swift compiler, Xcode or Apple SDK. Source and project consistency checks are possible here, but an iOS compilation, simulator run and camera validation remain pending. On a Mac:

```sh
xcodebuild -project RecallGarden.xcodeproj -scheme RecallGarden -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build
```

Check a fresh install has no cards. Create a deck and a card with question and notes, choose a library image, save, reopen and edit it, and restart the app to check persistence. Study it and confirm the image precedes the revealed correction. Remove/replace its photo. Verify camera capture, cancellation, denied permission and permission recovery on a real iPhone; check simulator fallback. Verify existing text-only cards still load on upgrade. Check deletion confirmation, scheduling, large text, VoiceOver, landscape and iPad. Open Premium and verify it explicitly offers no purchase.

## Before release

Add an original app icon, clear the final name/branding, set your own signing configuration and bundle identifier for release, and test on devices. Prepare screenshots, support and privacy-policy URLs, accurate App Privacy disclosures and any required privacy declarations.

When designs are ready, configure real App Store Connect products and integrate StoreKit purchases, verified entitlements, restore purchases, pending/cancel/error handling and required purchase disclosures. Do not enable payment before the purchased content can be delivered. Premium pricing and whether it is a one-time purchase or subscription remain undecided.

Each cloud task is already isolated: use the existing checkout rather than creating a worktree. Original source/design does not guarantee exclusive rights to a name or the general flashcard concept; check branding conflicts before release.
