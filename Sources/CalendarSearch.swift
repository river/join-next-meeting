import EventKit
import Foundation

struct MeetingEvent {
    let title: String
    let startDate: Date
    let endDate: Date
    let url: URL?
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

    guard !events.isEmpty else { return nil }

    func nearestByStart(_ candidates: [EKEvent]) -> EKEvent? {
        candidates.min(by: {
            abs($0.startDate.timeIntervalSinceNow) < abs($1.startDate.timeIntervalSinceNow)
        })
    }

    // Prefer the nearest event that has a meeting URL; fall back to nearest overall
    let withURLs = events.filter { firstURL(in: $0) != nil }
    let nearest = nearestByStart(withURLs) ?? nearestByStart(events)!

    return MeetingEvent(
        title:     nearest.title ?? "Untitled",
        startDate: nearest.startDate,
        endDate:   nearest.endDate,
        url:       firstURL(in: nearest)
    )
}

// Only accept http/https URLs — rejects mailto: and other schemes
private func validMeetingURL(_ url: URL?) -> URL? {
    guard let url, url.scheme == "http" || url.scheme == "https" else { return nil }
    return url
}

// Extract the first valid meeting URL from event.url, then location, then notes
private func firstURL(in event: EKEvent) -> URL? {
    if let url = validMeetingURL(event.url) { return url }
    if let location = event.location, let url = extractMeetingURL(from: location) { return url }
    if let notes = event.notes, let url = extractMeetingURL(from: notes) { return url }
    return nil
}

private let linkDetector = try? NSDataDetector(
    types: NSTextCheckingResult.CheckingType.link.rawValue
)

/// Finds the first http/https URL in free text (skipping mailto: etc.)
private func extractMeetingURL(from text: String) -> URL? {
    let range = NSRange(text.startIndex..., in: text)
    let matches = linkDetector?.matches(in: text, options: [], range: range) ?? []
    return matches.compactMap(\.url).first(where: { $0.scheme == "http" || $0.scheme == "https" })
}
