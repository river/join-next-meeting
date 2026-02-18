import AppKit

@MainActor
func showMeetingAlert(meeting: MeetingEvent?) {
    NSApp.activate(ignoringOtherApps: true)

    let alert = NSAlert()

    // Use Calendar.app's own icon
    if let calendarURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.iCal") {
        alert.icon = NSWorkspace.shared.icon(forFile: calendarURL.path)
    }

    if let meeting {
        alert.messageText     = meeting.title
        alert.informativeText = [
            meeting.calendarName,
            formatDateRange(start: meeting.startDate, end: meeting.endDate),
            meeting.url.absoluteString
        ].joined(separator: "\n")

        alert.addButton(withTitle: "Join Meeting")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            NSWorkspace.shared.open(meeting.url)
        }
    } else {
        alert.messageText     = "No Meetings"
        alert.informativeText = "There are no meetings within 1 hour of now."
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

private func formatDateRange(start: Date, end: Date) -> String {
    let dayFormatter = DateFormatter()
    dayFormatter.dateFormat = "EEE MMM d"

    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "HH:mm"

    let day       = dayFormatter.string(from: start)
    let startTime = timeFormatter.string(from: start)
    let endTime   = timeFormatter.string(from: end)

    return "\(day) • \(startTime)–\(endTime)"
}
