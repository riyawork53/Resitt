import SwiftUI

struct DeckView: View {
    @EnvironmentObject private var library: Library
    @Environment(\.dismiss) private var dismiss
    let deckID: UUID
    @State private var adding = false
    @State private var editing: Flashcard?
    @State private var studying = false
    @State private var deleting = false

    private var deck: Deck? { library.decks.first { $0.id == deckID } }

    var body: some View {
        Group {
            if let deck {
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Tend to what you know.").font(.system(.title, design: .serif))
                            Text("\(deck.dueCards.count) ready now · \(deck.cards.count) in your deck")
                                .font(.subheadline).foregroundStyle(.secondary)
                            Button { studying = true } label: {
                                Label("Begin a quiet session", systemImage: "play.fill").frame(maxWidth: .infinity).padding(8)
                            }.buttonStyle(.borderedProminent)
                                .disabled(deck.dueCards.isEmpty || !library.canEdit)
                            if deck.dueCards.isEmpty && !deck.cards.isEmpty {
                                Text("All tended to. Come back when your cards are due.").font(.caption)
                            }
                        }.padding(.vertical, 12)
                    }.listRowBackground(Theme.moss)
                    Section("Your cards") {
                        if deck.cards.isEmpty { Text("Add your first question with the + button.") }
                        ForEach(deck.cards) { card in
                            Button { editing = card } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(card.prompt).font(.headline)
                                    Text(card.answer).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
                                }.padding(.vertical, 6)
                            }.disabled(!library.canEdit)
                                .swipeActions {
                                    Button("Delete", role: .destructive) { library.deleteCard(card.id, in: deckID) }
                                        .disabled(!library.canEdit)
                                }
                        }
                    }
                }.scrollContentBackground(.hidden).gardenStyle()
                    .navigationTitle(deck.name)
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button { adding = true } label: { Image(systemName: "plus") }.accessibilityLabel("Add card").disabled(!library.canEdit)
                        }
                        ToolbarItem(placement: .secondaryAction) {
                            Button("Delete deck", role: .destructive) { deleting = true }.disabled(!library.canEdit)
                        }
                    }
                    .confirmationDialog("Delete this deck and all its cards?", isPresented: $deleting, titleVisibility: .visible) {
                        Button("Delete deck", role: .destructive) { library.deleteDeck(deckID); dismiss() }
                    }
                    .sheet(isPresented: $adding) { CardEditor(deckID: deckID, card: nil) }
                    .sheet(item: $editing) { CardEditor(deckID: deckID, card: $0) }
                    .fullScreenCover(isPresented: $studying) { StudyView(deckID: deckID, cards: deck.dueCards) }
            } else { ContentUnavailableView("Deck unavailable", systemImage: "leaf") }
        }
    }
}

struct CardEditor: View {
    @EnvironmentObject private var library: Library
    @Environment(\.dismiss) private var dismiss
    let deckID: UUID
    let card: Flashcard?
    @State private var prompt: String
    @State private var answer: String

    init(deckID: UUID, card: Flashcard?) {
        self.deckID = deckID
        self.card = card
        _prompt = State(initialValue: card?.prompt ?? "")
        _answer = State(initialValue: card?.answer ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("The question") { TextField("What do you want to remember?", text: $prompt, axis: .vertical).lineLimit(3...8) }
                Section("The answer") { TextField("Keep it clear and memorable.", text: $answer, axis: .vertical).lineLimit(4...12) }
                Section { Text("One idea per card makes recall easier.").font(.caption) }
            }.navigationTitle(card == nil ? "Plant an idea" : "Refine your card")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            var updated = card ?? Flashcard(prompt: "", answer: "")
                            updated.prompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
                            updated.answer = answer.trimmingCharacters(in: .whitespacesAndNewlines)
                            library.saveCard(updated, in: deckID)
                            dismiss()
                        }.disabled(prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !library.canEdit)
                    }
                }
        }.tint(Theme.ink)
    }
}
