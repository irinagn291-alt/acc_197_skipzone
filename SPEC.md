# Skipzone — Technical Specification

Offline shortwave and amateur radio logbook with propagation notes and azimuthal map.

## 1. Store metadata

- **Name:** Skipzone
- **Subtitle:** Shortwave log & propagation
- **Keywords:** ham,radio,shortwave,logbook,qsl,maidenhead,grid,propagation,amateur,offline
- **Primary category:** Utilities
- **Secondary category:** Reference
- **Age rating:** 4+
- **Bundle ID:** com.skipzone.logbook

## 2. Product goal

Map-first offline logbook. Log QSOs with Maidenhead grids, view great-circle paths and gray-line terminator on an azimuthal projection, track antennas and propagation notes, export JSON backup. No network, widgets, or notifications.

## 3. Platform and architecture

- iOS 16.4+, Swift 6.2, SwiftUI. iPhone + iPad.
- MVVM, `ObservableObject` + `VMHolder`.
- Persistence: Core Data programmatic `LogbookVault`.
- Navigation: custom QSL card horizontal pager with page dots; secondary sheets for settings, backup, stats.
- Light UI. Palette ink `#1E3A5F`, stamp `#A7382F`, olive `#5E6B4A`, rule `#C9C2AE`, paper `#F2EEE3`, card `#FBF8EE`.
- No SPM. No UserNotifications.

### 3.1 Database layer

```
LogbookVault — Core Data container, perform(block) serialising background work
LogbookModelBuilder — programmatic NSManagedObjectModel
Repositories — Contact, Station, Antenna, PropNote, Profile, BandSegment, Locator
```

## 4. Domain model

Entities: `RadioStation`, `AirContact`, `BandSegment`, `ModeSpec`, `GridLocator`, `AerialRig`, `PropNote`, `OperatorProfile`.

## 5. Core logic

### 5.1 MaidenheadLocator

Grid square encode/decode for 4, 6, and 8 character precision. Lat/lon ↔ Maidenhead offline.

### 5.2 GreatCircleSolver

Haversine distance, initial bearing, long-path complement, solar terminator from declination and hour angle. Great-circle path interpolation for map drawing.

### 5.3 BandHeatmapAggregator

Band × UTC hour contact count aggregation for statistics heatmap.

## 6. Screens

| Screen | Contents |
|--------|----------|
| SplashGate | Brand mark, bootstrap |
| Onboarding (4) | Radio intro → grids → QSL pager → station setup |
| QSLPagerView | **Home.** Azimuthal map + QSL card pager + toolbar |
| ContactEditorView | Log/edit QSO |
| StationProfileView | Operator callsign and home grid |
| BandHeatmapView | Band × hour heatmap |
| AntennaListView | Antenna rigs |
| PropNotesView | Propagation notes |
| BackupView | JSON export/import via ShareLink |
| SettingsView | Profile, backup, about |
| Empty states | Contacts, antennas, prop notes |

## 7. Design

`SkipTokens`, `SkipChrome`, `SkipImage`. Monospaced callsigns via `.fontDesign(.monospaced)` / Courier Prime when bundled.

## 8. Storage

- Core Data SQLite: Application Support / `skipzone.sqlite`.
- UserDefaults: `skipzone.onboardingCompleted`, `skipzone.seedVersion`.

## 9. Tests

Maidenhead roundtrip, GreatCircle known distances, LogbookVault CRUD, backup round-trip.

## 10. Privacy

`PrivacyInfo.xcprivacy`: CA92.1, C617.1. Documents folder usage for backup import/export.

## 11. Assets

Icon (light/dark/tinted), brand-mark, illustrations: onboarding-radio, onboarding-grid, onboarding-qsl, onboarding-log, empty-contacts, empty-antennas, empty-prop-notes, map-banner, stats-banner, backup-empty.
