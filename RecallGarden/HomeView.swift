import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var library: Library
    @State private var adding = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    HStack {
                        Label("RECALL GARDEN", systemImage: "leaf")
                            .font(.caption.weight(.bold)).tracking(2)
                        Spacer()
                        Text(Date(), format: .dateTime.month(.abbreviated).day()).font(.caption)
                    }
                    Text("A little practice.\nA lasting memory.")
                        .font(.system(.largeTitle, design: .serif, weight: .medium))
                    HStack(spacing: 18) {
                        Image(systemName: "sun.max.fill").font(.largeTitle)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("\(library.decks.reduce(0) { $0 + $1.dueCards.count }) cards ready to grow")
                                .font(.headline)
                            Text("Take your time. Let knowledge take root.").font(.subheadline)
                        }
                    }
                    .padding(22).frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.moss, in: RoundedRectangle(cornerRadius: 24))

                    if let error = library.storageError {
                        Label(error, systemImage: "exclamationmark.triangle").font(.callout)
                            .padding().background(Theme.peach, in: RoundedRectangle(cornerRadius: 16))
                    }
                    HStack {
                        Text("Your growing collection").font(.title3.weight(.semibold))
                        Spacer()
                        Button { adding = true } label: { Image(systemName: "plus.circle.fill").font(.title2) }
                            .accessibilityLabel("Create deck").disabled(!library.canEdit)
                    }
                    if library.decks.isEmpty {
                        ContentUnavailableView("Plant your first idea", systemImage: "leaf", description: Text("Create a deck, then add something you want to remember."))
                    }
                    ForEach(library.decks) { deck in
                        NavigationLink { DeckView(deckID: deck.id) } label: {
                            HStack(spacing: 16) {
                                Image(systemName: deck.symbol).font(.title2)
                                    .frame(width: 54, height: 60).background(Theme.paper, in: RoundedRectangle(cornerRadius: 16))
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(deck.name).font(.system(.title3, design: .serif, weight: .semibold))
                                    Text("\(deck.cards.count) cards · \(deck.dueCards.count) ready").font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "arrow.up.right")
                            }.padding(18).background(.white.opacity(0.75), in: RoundedRectangle(cornerRadius: 24))
                        }.buttonStyle(.plain)
                    }
                    Text("Made for quiet progress, one card at a time.")
                        .font(.footnote).foregroundStyle(.secondary).frame(maxWidth: .infinity).padding(.vertical)
                }.padding(24)
            }.gardenStyle()
                .sheet(isPresented: $adding) { DeckEditor() }
        }
    }
}

struct DeckEditor: View {
    @EnvironmentObject private var library: Library
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var symbol = "leaf.fill"
    private let symbols = ["leaf.fill", "sparkles", "moon.fill", "book.fill", "globe.americas.fill"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Give your deck a name") { TextField("e.g. Everyday Spanish", text: $name) }
                Section("Pick a little emblem") {
                    Picker("Emblem", selection: $symbol) {
                        ForEach(symbols, id: \.self) { Image(systemName: $0).tag($0) }
                    }.pickerStyle(.segmented)
                }
            }.navigationTitle("New beginnings")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Create") {
                            library.addDeck(name: name.trimmingCharacters(in: .whitespacesAndNewlines), symbol: symbol)
                            dismiss()
                        }.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !library.canEdit)
                    }
                }
        }.tint(Theme.ink)
    }
}
