# Join Next Meeting

A [LaunchBar](https://www.obdev.at/products/launchbar/) action for macOS that finds your next calendar meeting and lets you join it in one keystroke.

Trigger it from LaunchBar and a dialog pops up showing the meeting — hit **Join Meeting** to open the link, or **Cancel** to dismiss. If nothing is coming up in the next hour it'll tell you that too.

## Install

1. Download `Join Next Meeting.lbaction.zip` from [Releases](https://github.com/river/join-next-meeting/releases)
2. Unzip it
3. Double-click `Join Next Meeting.lbaction` — LaunchBar will install it automatically

On first run, macOS will ask for permission to access your calendars. Grant it and you're good to go.

## Usage

Open LaunchBar, type **"Join"**, select **Join Next Meeting**, press Return.

---

## Building from source

If you'd prefer to build the binary yourself:

```bash
git clone https://github.com/river/join-next-meeting
cd join-next-meeting
just install
```

This requires Xcode's Swift toolchain and [just](https://github.com/casey/just). It builds the binary, bundles it into the action, and installs it to LaunchBar.

To reset the calendar permission:

```bash
tccutil reset Calendar com.riverjiang.JoinNextMeeting
```
