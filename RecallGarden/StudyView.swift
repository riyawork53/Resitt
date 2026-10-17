import SwiftUI

struct StudyView: View {
    @EnvironmentObject private var library: Library
    @Environment(\.dismiss) private var dismiss
    let deckID: UUID
    let cards: [Flashcard]
    @State private var index = 0
    @State private var revealed = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    if index < cards.count {
                        ProgressView(value: Double(index), total: Double(max(cards.count, 1))).tint(Theme.ink)
                        Text("CARD \(index + 1) OF \(cards.count)").font(.caption.weight(.bold)).tracking(2)
                        VStack(spacing: 24) {
                            Image(systemName: revealed ? "leaf.fill" : "leaf.circle").font(.title).accessibilityHidden(true)
                            Text(cards[index].prompt)
                                .font(.system(.title, design: .serif)).multilineTextAlignment(.center)
                                .textSelection(.enabled)
                            if revealed {
                                Divider()
                                Text(cards[index].answer).font(.title3).multilineTextAlignment(.center).textSelection(.enabled)
                            }
                        }.padding(30).frame(maxWidth: .infinity, minHeight: 300)
                            .background(revealed ? Theme.moss : .white, in: RoundedRectangle(cornerRadius: 32))
                        if revealed {
                            Text("How did that feel?").font(.subheadline)
                            HStack(spacing: 10) {
                                ForEach(Rating.allCases, id: \.self) { rating in
                                    Button {
                                        library.review(cards[index].id, in: deckID, rating: rating)
                                        revealed = false
                                        index += 1
                                    } label: {
                                        VStack(spacing: 5) {
                                            Text(rating.rawValue).font(.headline)
                                            Text(rating.hint).font(.caption2)
                                        }.frame(maxWidth: .infinity).padding(.vertical, 15)
                                            .background(rating == .again ? Theme.peach : Theme.moss, in: RoundedRectangle(cornerRadius: 18))
                                    }.buttonStyle(.plain).disabled(!library.canEdit)
                                }
                            }
                        } else {
                            Text("Pause. Try to recall it before you peek.").font(.subheadline).foregroundStyle(.secondary)
                            Button { revealed = true } label: {
                                Text("Reveal answer").frame(maxWidth: .infinity).padding(10)
                            }.buttonStyle(.borderedProminent)
                        }
                        if let error = library.storageError { Text(error).font(.callout).foregroundStyle(.red) }
                    } else {
                        Image(systemName: "tree.fill").font(.system(size: 72)).padding(.top, 60)
                        Text("A little more rooted.").font(.system(.largeTitle, design: .serif)).multilineTextAlignment(.center)
                        Text("You tended to \(cards.count) cards. Let them settle in.").multilineTextAlignment(.center)
                        Text("Cards marked Again return in one minute. Other cards rest until their next scheduled day.")
                            .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                        Button("Back to your garden") { dismiss() }.buttonStyle(.borderedProminent)
                    }
                }.padding(24)
            }.gardenStyle().navigationTitle("Quiet practice").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
        }
    }
}
