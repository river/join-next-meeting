import EventKit
import Foundation

struct MeetingEvent {
    let title: String
    let calendarName: String
    let startDate: Date
    let endDate: Date
    let url: URL
}

func findNextMeeting() async -> MeetingEvent? {
    let store = EKEventStore()

    // Request calendar access (handles macOS 14+ and earlier)
    let granted: Bool
    do {
        if #available(macOS 14.0, *) {
            granted = try await store.requestFullAccessToEvents()
        } else {
            granted = try await withCheckedThrowingContinuation { continuation in
                store.requestAccess(to: .event) { granted, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: granted)
                    }
                }
            }
        }
    } catch {
        return nil
    }

    guard granted else { return nil }

    let now = Date()
    let start = now.addingTimeInterval(-3600)
    let end   = now.addingTimeInterval( 3600)

    let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
    let events = store.events(matching: predicate)

    // Find all events with a URL, then pick the one whose start is nearest to now
    let candidates = events.compactMap { event -> (EKEvent, URL)? in
        if let url = firstURL(in: event) {
            return (event, url)
        }
        return nil
    }

    guard !candidates.isEmpty else { return nil }

    let (nearest, url) = candidates.min(by: {
        abs($0.0.startDate.timeIntervalSinceNow) < abs($1.0.startDate.timeIntervalSinceNow)
    })!

    return MeetingEvent(
        title:        nearest.title ?? "Untitled",
        calendarName: nearest.calendar?.title ?? "",
        startDate:    nearest.startDate,
        endDate:      nearest.endDate,
        url:          url
    )
}

// Extract the first URL from event.url, then event.notes, then event.location
private func firstURL(in event: EKEvent) -> URL? {
    if let url = event.url {
        return url
    }
    if let notes = event.notes, let url = extractURL(from: notes) {
        return url
    }
    if let location = event.location, let url = extractURL(from: location) {
        return url
    }
    return nil
}

private func extractURL(from text: String) -> URL? {
    let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    let range = NSRange(text.startIndex..., in: text)
    let match = detector?.firstMatch(in: text, options: [], range: range)
    guard let match, let url = match.url else { return nil }
    return url
}
