import SwiftUI
import UIKit
import PhotosUI
import AVFoundation

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
                            Text("Ready for your next review?").font(.title.bold()).foregroundStyle(Theme.accent)
                            Text("\(deck.dueCards.count) ready now · \(deck.cards.count) in your deck")
                                .font(.subheadline).foregroundStyle(.secondary)
                            Button { studying = true } label: {
                                Label("Start studying", systemImage: "play.fill").frame(maxWidth: .infinity).padding(8)
                            }.buttonStyle(.borderedProminent)
                                .disabled(deck.dueCards.isEmpty || !library.canEdit)
                            if deck.dueCards.isEmpty && !deck.cards.isEmpty {
                                Text("You’re up to date. Come back when your cards are due.").font(.caption)
                            }
                        }.padding(.vertical, 12)
                    }.listRowBackground(Theme.blush)
                    Section("Your cards") {
                        if deck.cards.isEmpty { Text("Add your first question with the + button.") }
                        ForEach(deck.cards) { card in
                            Button { editing = card } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        if card.photoData != nil { Image(systemName: "photo").foregroundStyle(Theme.accent) }
                                        Text(card.prompt).font(.headline)
                                    }
                                    Text(card.answer).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
                                }.padding(.vertical, 6)
                            }.disabled(!library.canEdit)
                                .swipeActions {
                                    Button("Delete", role: .destructive) { library.deleteCard(card.id, in: deckID) }
                                        .disabled(!library.canEdit)
                                }
                        }
                    }
                }.scrollContentBackground(.hidden).resittStyle()
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
            } else { ContentUnavailableView("Deck unavailable", systemImage: "rectangle.stack") }
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
    @State private var photoData: Data?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showingCamera = false
    @State private var photoError: String?
    @State private var loadingPhoto = false

    init(deckID: UUID, card: Flashcard?) {
        self.deckID = deckID
        self.card = card
        _prompt = State(initialValue: card?.prompt ?? "")
        _answer = State(initialValue: card?.answer ?? "")
        _photoData = State(initialValue: card?.photoData)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if let photoData, let image = UIImage(data: photoData) {
                        Image(uiImage: image).resizable().scaledToFit().frame(maxHeight: 280)
                            .accessibilityLabel("Photo of your study mistake")
                        Button("Remove photo", role: .destructive) { self.photoData = nil }
                    }
                    Button { requestCamera() } label: { Label("Take a photo", systemImage: "camera") }
                        .disabled(loadingPhoto)
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("Choose from photos", systemImage: "photo")
                    }.disabled(loadingPhoto)
                    if loadingPhoto { ProgressView("Loading photo…") }
                } header: { Text("Capture a mistake") }
                  footer: { Text("Save a question or worked example, then explain the correction in your notes. Photos stay on this device.") }
                Section("Question or topic") { TextField("What do you want to remember?", text: $prompt, axis: .vertical).lineLimit(3...8) }
                Section("Answer / correction notes") { TextField("What went wrong, and how would you solve it?", text: $answer, axis: .vertical).lineLimit(4...12) }
                Section { Text("One idea per card makes recall easier.").font(.caption) }
            }.navigationTitle(card == nil ? "New flashcard" : "Edit flashcard")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            var updated = card ?? Flashcard(prompt: "", answer: "")
                            updated.prompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
                            updated.answer = answer.trimmingCharacters(in: .whitespacesAndNewlines)
                            updated.photoData = photoData
                            library.saveCard(updated, in: deckID)
                            dismiss()
                        }.disabled(prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !library.canEdit || loadingPhoto)
                    }
                }
        }.tint(Theme.accent)
            .sheet(isPresented: $showingCamera) {
                CameraCapture { image in
                    if let image { storePhoto(image) }
                    showingCamera = false
                }.ignoresSafeArea()
            }
            .onChange(of: selectedPhoto) { _, item in
                guard let item else { return }
                loadingPhoto = true
                Task { @MainActor in
                    defer { loadingPhoto = false; selectedPhoto = nil }
                    do {
                        guard let data = try await item.loadTransferable(type: Data.self),
                              let image = UIImage(data: data) else {
                            photoError = "This image could not be opened. Try a different photo."
                            return
                        }
                        storePhoto(image)
                    } catch { photoError = "The photo could not be loaded. Please try again." }
                }
            }
            .alert("Photo unavailable", isPresented: Binding(get: { photoError != nil }, set: { if !$0 { photoError = nil } })) {
                Button("OK") { photoError = nil }
            } message: { Text(photoError ?? "") }
    }

    private func storePhoto(_ image: UIImage) {
        // Normalize orientation and bound storage size before persisting locally.
        let scale = min(1, 1800 / max(image.size.width, image.size.height))
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let resized = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        guard let data = resized.jpegData(compressionQuality: 0.8) else {
            photoError = "The photo could not be saved. Try another image."
            return
        }
        photoData = data
    }

    private func requestCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            photoError = "A camera is not available here. Choose a photo instead, or use Resitt on your iPhone."
            return
        }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: showingCamera = true
        case .notDetermined:
            Task { @MainActor in
                if await AVCaptureDevice.requestAccess(for: .video) { showingCamera = true }
                else { photoError = "Camera access was declined. You can allow it in Settings, or choose a photo instead." }
            }
        default: photoError = "Allow camera access for Resitt in Settings, or choose a photo instead."
        }
    }
}

private struct CameraCapture: UIViewControllerRepresentable {
    var completion: (UIImage?) -> Void
    func makeCoordinator() -> Coordinator { Coordinator(completion: completion) }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ controller: UIImagePickerController, context: Context) {}
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let completion: (UIImage?) -> Void
        init(completion: @escaping (UIImage?) -> Void) { self.completion = completion }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { completion(nil) }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            completion(info[.originalImage] as? UIImage)
        }
    }
}
