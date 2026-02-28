import EventKit
import Foundation

enum MeetingResult {
    case found(MeetingEvent)
    case noMeetings
    case accessDenied
}

struct MeetingEvent {
    let title: String
    let startDate: Date
    let endDate: Date
    let url: URL?
}

func findNextMeeting() async -> MeetingResult {
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
        return .accessDenied
    }

    guard granted else { return .accessDenied }

    let now = Date()
    let start = now.addingTimeInterval(-3600)
    let end   = now.addingTimeInterval( 3600)

    let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
    let events = store.events(matching: predicate)
        .filter { !$0.isAllDay && $0.status != .canceled }

    func nearestByStart(_ candidates: [EKEvent]) -> EKEvent? {
        let future = candidates.filter { $0.startDate >= Date() }
        if let best = future.min(by: { $0.startDate < $1.startDate }) {
            return best
        }
        return candidates.max(by: { $0.startDate < $1.startDate })
    }

    // Pre-compute URLs once per event
    let urlCache = Dictionary(uniqueKeysWithValues: events.compactMap { event -> (ObjectIdentifier, URL)? in
        guard let url = firstURL(in: event) else { return nil }
        return (ObjectIdentifier(event), url)
    })

    // Prefer the nearest event that has a meeting URL; fall back to nearest overall
    let withURLs = events.filter { urlCache[ObjectIdentifier($0)] != nil }
    guard let best = nearestByStart(withURLs) ?? nearestByStart(events) else { return .noMeetings }

    return .found(MeetingEvent(
        title:     best.title ?? "Untitled",
        startDate: best.startDate,
        endDate:   best.endDate,
        url:       urlCache[ObjectIdentifier(best)]
    ))
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

private let linkDetector: NSDataDetector? = {
    do {
        return try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    } catch {
        assertionFailure("Failed to create NSDataDetector: \(error)")
        return nil
    }
}()

/// Finds the first http/https URL in free text (skipping mailto: etc.)
private func extractMeetingURL(from text: String) -> URL? {
    let range = NSRange(text.startIndex..., in: text)
    let matches = linkDetector?.matches(in: text, options: [], range: range) ?? []
    return matches.compactMap(\.url).first(where: { $0.scheme == "http" || $0.scheme == "https" })
}
