import AppKit

// Must initialize NSApplication on the main thread before anything else
let app = NSApplication.shared
app.setActivationPolicy(.accessory)

// Fetch calendar data on a background task, then show UI on main thread
Task {
    let meeting = await findNextMeeting()
    await MainActor.run {
        showMeetingAlert(meeting: meeting)
        app.stop(nil)
    }
}

app.run()
