import Foundation
import Combine

struct Flashcard: Identifiable, Codable {
    var id = UUID()
    var prompt: String
    var answer: String
    var photoData: Data?
    var due = Date.distantPast
    var interval = 0
    var reviews = 0
}

struct Deck: Identifiable, Codable {
    var id = UUID()
    var name: String
    var symbol: String = "rectangle.stack.fill"
    var cards: [Flashcard] = []
    var dueCards: [Flashcard] { cards.filter { $0.due <= Date() } }
}

@MainActor
final class Library: ObservableObject {
    @Published private(set) var decks: [Deck] = []
    @Published private(set) var storageError: String?
    private let url: URL

    init() {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        // Keep the original location so updates preserve existing study data.
        url = directory.appendingPathComponent("RecallGarden/library.json")
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                decks = try JSONDecoder().decode([Deck].self, from: Data(contentsOf: url))
            } else {
                decks = []
                save()
            }
        } catch {
            storageError = "Your saved library could not be opened. Your file has been preserved. Restart the app or recover it before making changes."
        }
    }

    var canEdit: Bool { storageError == nil }

    func addDeck(name: String, symbol: String) {
        guard canEdit else { return }
        decks.append(Deck(name: name, symbol: symbol))
        save()
    }

    func deleteDeck(_ id: UUID) {
        guard canEdit else { return }
        decks.removeAll { $0.id == id }
        save()
    }

    func saveCard(_ card: Flashcard, in deckID: UUID) {
        guard canEdit, let d = decks.firstIndex(where: { $0.id == deckID }) else { return }
        if let c = decks[d].cards.firstIndex(where: { $0.id == card.id }) {
            decks[d].cards[c] = card
        } else { decks[d].cards.append(card) }
        save()
    }

    func deleteCard(_ id: UUID, in deckID: UUID) {
        guard canEdit, let d = decks.firstIndex(where: { $0.id == deckID }) else { return }
        decks[d].cards.removeAll { $0.id == id }
        save()
    }

    func review(_ id: UUID, in deckID: UUID, rating: Rating) {
        guard canEdit,
              let d = decks.firstIndex(where: { $0.id == deckID }),
              let c = decks[d].cards.firstIndex(where: { $0.id == id }) else { return }
        var card = decks[d].cards[c]
        card.reviews += 1
        switch rating {
        case .again:
            card.interval = 0
            card.due = Date().addingTimeInterval(60)
        case .good:
            card.interval = card.interval == 0 ? 1 : min(card.interval * 2, 365)
            card.due = Calendar.current.date(byAdding: .day, value: card.interval, to: Date())!
        case .easy:
            card.interval = card.interval == 0 ? 3 : min(card.interval * 3, 365)
            card.due = Calendar.current.date(byAdding: .day, value: card.interval, to: Date())!
        }
        decks[d].cards[c] = card
        save()
    }

    private func save() {
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try JSONEncoder().encode(decks).write(to: url, options: .atomic)
        } catch {
            storageError = "Your latest changes could not be saved. Keep the app open and free up storage before restarting."
        }
    }
}

enum Rating: String, CaseIterable {
    case again = "Again", good = "Got it", easy = "Easy"
    var hint: String {
        switch self {
        case .again: return "1 minute"
        case .good: return "Standard interval"
        case .easy: return "Longer interval"
        }
    }
}
