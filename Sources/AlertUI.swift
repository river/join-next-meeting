import AppKit

@MainActor
func showMeetingAlert(result: MeetingResult) {
    NSApp.activate(ignoringOtherApps: true)

    let alert = NSAlert()

    // Use Calendar.app's own icon
    if let calendarURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.iCal") {
        alert.icon = NSWorkspace.shared.icon(forFile: calendarURL.path(percentEncoded: false))
    }

    switch result {
    case .found(let meeting):
        alert.messageText = meeting.title

        let dateRange = formatDateRange(start: meeting.startDate, end: meeting.endDate)
        let relative = relativeTime(to: meeting.startDate)

        if let url = meeting.url {
            alert.informativeText = [
                "\(dateRange) \(relative)",
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
                "\(dateRange) \(relative)",
                "No meeting link found."
            ].joined(separator: "\n")
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            alert.runModal()
        }

    case .noMeetings:
        alert.messageText     = "No Meetings"
        alert.informativeText = "There are no meetings within 1 hour of now."
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.runModal()

    case .accessDenied:
        alert.messageText     = "Calendar Access Required"
        alert.informativeText = "Grant calendar access in System Settings > Privacy & Security > Calendars."
        alert.addButton(withTitle: "Open Settings")
        alert.addButton(withTitle: "Cancel")
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars") {
                NSWorkspace.shared.open(url)
            }
        }
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

private func relativeTime(to date: Date) -> String {
    let interval = date.timeIntervalSinceNow
    let minutes = Int(abs(interval) / 60)

    if minutes < 1 {
        return "(now)"
    } else if interval > 0 {
        if minutes >= 60 {
            return "(in \(minutes / 60)h \(minutes % 60)m)"
        }
        return "(in \(minutes)m)"
    } else {
        if minutes >= 60 {
            return "(\(minutes / 60)h \(minutes % 60)m ago)"
        }
        return "(\(minutes)m ago)"
    }
}
