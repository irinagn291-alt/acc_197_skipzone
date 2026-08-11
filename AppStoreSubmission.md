# Skipzone — App Store Submission Package

## App Review Notes

Skipzone is an offline logbook for shortwave and amateur ("ham") radio operators. Its main purpose is recording contacts (QSOs): band, mode, signal report, and time, together with the other station's grid locator. For each contact, Skipzone draws the great-circle path between the operator's home station and the contact on an azimuthal map, and keeps a separate notebook for propagation observations such as K-index and solar flux.

The app is intended for licensed amateur radio operators — a specific, technically minded hobbyist audience that already keeps a paper or spreadsheet log and wants something purpose-built for it.

Responding to the ad and login concerns from review:

- Skipzone contains no advertising and no ad SDK — nothing in the app is sponsored or ad-served.
- There is no analytics, attribution, or crash-reporting SDK included; the app does not transmit usage data anywhere.
- The app has no login, sign-up, or account system whatsoever. A callsign and home grid entered during setup are the operator's own station details, stored locally — not credentials, and not required to explore the app.
- Every part of the app — the contact log, the azimuthal map, antenna records, the station profile, propagation notes, and statistics — is available immediately, with nothing gated behind a login.
- The app requests no camera, microphone, or location permission; the only stored files are the local database and an optional manual backup export.

Suggested review steps:
1. Launch the app — it opens on the Logbook with a sample contact already logged, including its map and QSL-style card.
2. Swipe through the card pager to see additional sample contacts.
3. Open the Propagation or Stats tab to see the band-by-hour heatmap and condition notes.

Happy to provide any additional detail the review team needs.

## Guideline 4.3 — Originality

Skipzone is a dedicated tool for a specific hobby with its own technical content, not a generic list-based logging app wearing a radio theme. Its centerpiece — a live azimuthal (great-circle) map with a gray-line terminator — is computed from the operator's and contact's coordinates, not a static image.

Concrete differentiators:
- Maidenhead grid-locator encoding and decoding, converting the locators hams actually use into coordinates the map can plot.
- A great-circle solver that computes bearing, distance, and long-path distance between two points on Earth for every logged contact.
- A swipeable, QSL-card-styled contact pager as the app's home screen, in place of a conventional table or list view.
- A band-by-hour contact heatmap for spotting propagation patterns across a user's own log.

Amateur radio logging has requirements — grid locators, band/mode tracking, propagation notes — that a general-purpose notes or CRM-style app does not address. Skipzone is built specifically around that workflow for an audience that already understands these concepts.

---

## App Store Metadata

### Description

**Skipzone — a logbook for the airwaves.**

Skipzone is an offline logbook built for shortwave and amateur radio operators who want more than a spreadsheet.

**Log every contact**
Record band, mode, signal report, and time for each QSO, along with the other station's grid locator.

**See the path, not just the distance**
Every contact is plotted on a great-circle map from your station, with distance, bearing, and the current gray-line terminator.

**Keep propagation notes**
Jot down K-index, solar flux, and band conditions as you notice them, tied to your log.

**Track your setup**
Log your antennas and station profile, and browse your activity as a band-by-hour heatmap.

**Runs entirely offline**
Everything lives on your device. Export a backup whenever you like — no account, no cloud, no ads.

### Promotional Text (170 char max)

Log contacts, watch the great-circle path and gray line update live, and keep propagation notes — a logbook for the airwaves.

### Subtitle (30 char max)

Shortwave QSO logbook

### Keywords (100 char max)

ham radio,shortwave,QSO log,propagation,grid locator,great circle,DX,QSL,band conditions
