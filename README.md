# Join Next Meeting

A minimal macOS command-line tool that finds the nearest meeting within ±1 hour in any of your calendars and offers to join it.

## What it does

- Searches all your macOS Calendars for events within 1 hour before or after now
- Picks the event closest to now that has a URL (checked in order: structured URL field → notes → location)
- Pops up a native dialog showing the event title, calendar name, and date/time
- "Join Meeting" opens the URL; "Cancel" dismisses

If no matching event is found, a dialog says so.

## Requirements

- macOS 13+
- [just](https://github.com/casey/just) (for the install recipe)
- Swift toolchain

## Install

```bash
just install
```

This builds a release binary, copies it to `~/.local/bin/join-next-meeting`, and installs the LaunchBar action.

Make sure `~/.local/bin` is on your `PATH`.

## Usage

### Command line

```bash
join-next-meeting
```

On first run macOS will prompt for calendar access. After granting it, the dialog appears immediately.

To suppress harmless system log noise from EventKit:

```bash
join-next-meeting 2>/dev/null
```

### LaunchBar

A LaunchBar action is included in `LaunchBar Action/`. `just install` installs it automatically to `~/Library/Application Support/LaunchBar/Actions/`.

Search for "Join Next Meeting" in LaunchBar to run it — no terminal window opens.

## Reset calendar permission

```bash
tccutil reset Calendar com.local.JoinNextMeeting
```
