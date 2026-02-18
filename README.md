# Join Next Meeting

A minimal macOS tool that finds the nearest meeting within ±1 hour in any of your calendars and offers to join it.

## What it does

- Searches all your macOS Calendars for events within 1 hour before or after now
- Picks the event closest to now that has a URL (checked in order: structured URL field → notes → location)
- Pops up a native dialog showing the event title, calendar name, and date/time
- "Join Meeting" opens the URL; "Cancel" dismisses

If no matching event is found, a dialog says so.

## Requirements

- macOS 13+
- [just](https://github.com/casey/just)
- Swift toolchain
- [LaunchBar](https://www.obdev.at/products/launchbar/)

## Install

```bash
just install
```

This installs the LaunchBar action to `~/Library/Application Support/LaunchBar/Actions/`.

On first run macOS will prompt for calendar access. After granting it, the dialog appears immediately.

## Usage

Search for "Join Next Meeting" in LaunchBar to run it — no terminal window opens.

## Build

```bash
swift build -c release
```

## Reset calendar permission

```bash
tccutil reset Calendar com.local.JoinNextMeeting
```
