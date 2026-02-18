import AppKit

@MainActor
func showMeetingAlert(meeting: MeetingEvent?) {
    NSApp.activate(ignoringOtherApps: true)

    let alert = NSAlert()

    // Use Calendar.app's own icon
    if let calendarURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.iCal") {
        alert.icon = NSWorkspace.shared.icon(forFile: calendarURL.path(percentEncoded: false))
    }

    if let meeting {
        alert.messageText = meeting.title

        if let url = meeting.url {
            alert.informativeText = [
                formatDateRange(start: meeting.startDate, end: meeting.endDate),
                url.absoluteString
            ].joined(separator: "\n")

            alert.addButton(withTitle: "Join Meeting")
            alert.addButton(withTitle: "Cancel")

            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                NSWorkspace.shared.open(url)
            }
        } else {
            alert.informativeText = [
                formatDateRange(start: meeting.startDate, end: meeting.endDate),
                "No meeting link found."
            ].joined(separator: "\n")
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            alert.runModal()
        }
    } else {
        alert.messageText     = "No Meetings"
        alert.informativeText = "There are no meetings within 1 hour of now."
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.runModal()
    }
}

private func formatDateRange(start: Date, end: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none

    let timeFormatter = DateFormatter()
    timeFormatter.dateStyle = .none
    timeFormatter.timeStyle = .short

    let day       = dateFormatter.string(from: start)
    let startTime = timeFormatter.string(from: start)
    let endTime   = timeFormatter.string(from: end)

    return "\(day) at \(startTime)–\(endTime)"
}
