import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var library: Library
    @State private var adding = false
    @State private var premium = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    HStack {
                        Label("Resitt", systemImage: "rectangle.stack")
                            .font(.title2.weight(.bold)).foregroundStyle(Theme.accent)
                        Spacer()
                        Text(Date(), format: .dateTime.month(.abbreviated).day()).font(.caption)
                    }
                    Text("Study smarter.\nRemember more.")
                        .font(.system(.largeTitle, design: .default, weight: .bold)).foregroundStyle(Theme.accent)
                    HStack(spacing: 18) {
                        Image(systemName: "rectangle.stack.badge.play.fill").font(.largeTitle)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("\(library.decks.reduce(0) { $0 + $1.dueCards.count }) cards ready to review")
                                .font(.headline)
                            Text("Build confidence, one review at a time.").font(.subheadline)
                        }
                    }
                    .padding(22).frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.blush, in: RoundedRectangle(cornerRadius: 24))

                    if let error = library.storageError {
                        Label(error, systemImage: "exclamationmark.triangle").font(.callout)
                            .padding().background(Theme.blush, in: RoundedRectangle(cornerRadius: 16))
                    }
                    HStack {
                        Text("Your decks").font(.title3.weight(.semibold))
                        Spacer()
                        Button { adding = true } label: { Image(systemName: "plus.circle.fill").font(.title2) }
                            .accessibilityLabel("Create deck").disabled(!library.canEdit)
                    }
                    if library.decks.isEmpty {
                        ContentUnavailableView("Your next result starts here", systemImage: "rectangle.stack", description: Text("Create a deck, then add something you want to remember."))
                    }
                    ForEach(library.decks) { deck in
                        NavigationLink { DeckView(deckID: deck.id) } label: {
                            HStack(spacing: 16) {
                                Image(systemName: deck.symbol).font(.title2)
                                    .frame(width: 54, height: 60).background(Theme.paper, in: RoundedRectangle(cornerRadius: 16))
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(deck.name).font(.system(.title3, design: .default, weight: .semibold))
                                    Text("\(deck.cards.count) cards · \(deck.dueCards.count) ready").font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "arrow.up.right")
                            }.padding(18).background(Theme.surface, in: RoundedRectangle(cornerRadius: 24))
                        }.buttonStyle(.plain)
                    }
                    Button { premium = true } label: {
                        HStack {
                            Image(systemName: "sparkles")
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Resitt Premium").font(.headline)
                                Text("Your study style, upgraded. Coming soon.").font(.caption)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                        }.padding(20).background(Theme.blush, in: RoundedRectangle(cornerRadius: 20))
                    }.buttonStyle(.plain)
                    Text("Your notes. Your mistakes. Your progress.")
                        .font(.footnote).foregroundStyle(.secondary).frame(maxWidth: .infinity).padding(.vertical)
                }.padding(24)
            }.resittStyle()
                .sheet(isPresented: $adding) { DeckEditor() }
                .sheet(isPresented: $premium) { PremiumView() }
        }
    }
}

struct DeckEditor: View {
    @EnvironmentObject private var library: Library
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var symbol = "rectangle.stack.fill"
    private let symbols = ["rectangle.stack.fill", "pencil", "function", "book.fill", "globe.americas.fill"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Give your deck a name") { TextField("e.g. Everyday Spanish", text: $name) }
                Section("Choose an icon") {
                    Picker("Emblem", selection: $symbol) {
                        ForEach(symbols, id: \.self) { Image(systemName: $0).tag($0) }
                    }.pickerStyle(.segmented)
                }
            }.navigationTitle("New deck")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Create") {
                            library.addDeck(name: name.trimmingCharacters(in: .whitespacesAndNewlines), symbol: symbol)
                            dismiss()
                        }.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !library.canEdit)
                    }
                }
        }.tint(Theme.accent)
    }
}

struct PremiumView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "sparkles").font(.system(size: 48)).foregroundStyle(Theme.accent)
                Text("Resitt Premium").font(.largeTitle.bold())
                Text("Make every card feel like you.").font(.title3)
                Text("Optional flashcard designs are coming in a future update. Studying, photo cards and notes stay free.")
                    .multilineTextAlignment(.center).foregroundStyle(.secondary)
                Label("Card designs · Coming soon", systemImage: "rectangle.on.rectangle")
                    .padding().background(Theme.blush, in: RoundedRectangle(cornerRadius: 16))
                Text("Purchases are not available yet. No payment will be taken.")
                    .font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
            }.padding(28).frame(maxWidth: .infinity, maxHeight: .infinity).resittStyle()
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }.tint(Theme.accent)
    }
}
