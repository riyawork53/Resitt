import SwiftUI
import UIKit

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
                        ProgressView(value: Double(index), total: Double(max(cards.count, 1))).tint(Theme.accent)
                        Text("CARD \(index + 1) OF \(cards.count)").font(.caption.weight(.bold)).tracking(2)
                        VStack(spacing: 24) {
                            Image(systemName: revealed ? "checkmark.circle" : "rectangle.on.rectangle").font(.title).accessibilityHidden(true)
                            Text(cards[index].prompt)
                                .font(.system(.title, design: .default)).multilineTextAlignment(.center)
                                .textSelection(.enabled)
                            if let data = cards[index].photoData, let image = UIImage(data: data) {
                                Image(uiImage: image).resizable().scaledToFit()
                                    .accessibilityLabel("Photo attached to this question")
                            }
                            if revealed {
                                Divider()
                                Text(cards[index].answer).font(.title3).multilineTextAlignment(.center).textSelection(.enabled)
                            }
                        }.padding(30).frame(maxWidth: .infinity, minHeight: 300)
                            .background(revealed ? Theme.blush : Theme.surface, in: RoundedRectangle(cornerRadius: 24))
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
                                            .background(rating == .again ? Theme.blush : Theme.surface, in: RoundedRectangle(cornerRadius: 18))
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
                        Image(systemName: "checkmark.circle.fill").font(.system(size: 72)).padding(.top, 60)
                        Text("Session complete.").font(.system(.largeTitle, design: .default)).multilineTextAlignment(.center)
                        Text("You reviewed \(cards.count) cards. Keep the momentum going.").multilineTextAlignment(.center)
                        Text("Cards marked Again return in one minute. Other cards rest until their next scheduled day.")
                            .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                        Button("Back to decks") { dismiss() }.buttonStyle(.borderedProminent)
                    }
                }.padding(24)
            }.resittStyle().navigationTitle("Study session").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
        }
    }
}
