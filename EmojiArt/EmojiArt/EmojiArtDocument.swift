//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Rafael Melo on 29/05/23.
//

import SwiftUI
import Combine

class EmojiArtDocument: ObservableObject {
    
    @Published private(set) var emojiArtie: EmojiArtie {
        didSet {
            scheduleAutosave()
            if emojiArtie.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    
    private var autosaveTimer: Timer?
    
    private func scheduleAutosave() {
        autosaveTimer?.invalidate()
        autosaveTimer = Timer.scheduledTimer(withTimeInterval: Autosave.coalescingInterval,
                                             repeats: false, block: { _ in
            self.autosave()
        })
    }
    
    private struct Autosave {
        static let filename = "Autosave.emojiartie"
        static var url: URL? {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            return documentDirectory?.appendingPathComponent(filename)
        }
        static let coalescingInterval = 5.0
    }
    
    private func autosave() {
        if let url = Autosave.url {
            save(to: url)
        }
    }
    
    private func save(to url: URL) {
        let thisFunction = "\(String(describing: self)).\(#function)"
        do {
            let data: Data = try emojiArtie.json()
            print("\(thisFunction) json = \(String(data: data, encoding: .utf8) ?? "nil")")
            try data.write(to: url)
            print("\(thisFunction) success!")
        } catch let encodingError where encodingError is EncodingError {
            print("\(thisFunction) couldn't encode because = \(encodingError.localizedDescription)")
        } catch {
            print("\(thisFunction) error \(error)")
        }
    }
    
    init() {
        if let url = Autosave.url, let autosavedEmojiArtie = try? EmojiArtie(url: url) {
            emojiArtie = autosavedEmojiArtie
            fetchBackgroundImageDataIfNecessary()
        } else {
            emojiArtie = EmojiArtie()
        }
    }
    
    var emojis: [EmojiArtie.Emoji] { emojiArtie.emojis }
    var background: EmojiArtie.Background { emojiArtie.background }
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    enum BackgroundImageFetchStatus: Equatable {
        case idle
        case fetching
        case failed(URL)
    }
    
    private var backgroundImageFetchCancellable: AnyCancellable?
    
    private func fetchBackgroundImageDataIfNecessary() {
        backgroundImage = nil
        switch emojiArtie.background {
        case .url(let url):
            backgroundImageFetchStatus = .fetching
            let session = URLSession.shared
            let publisher = session.dataTaskPublisher(for: url)
                .map {(data, urlResponse) in UIImage(data: data)}
                .replaceError(with: nil)
                .receive(on: DispatchQueue.main)
            
            backgroundImageFetchCancellable = publisher
                .sink { [weak self] image in
                    self?.backgroundImage = image
                    self?.backgroundImageFetchStatus = (image != nil) ? .idle : .failed(url)
                }
        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        case .blank: break
        }
    }
    
    // MARK: - Intent(s)
    
    func setBackground(_ background: EmojiArtie.Background) {
        emojiArtie.background = background
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat) {
        emojiArtie.addEmoji(emoji, at: location, size: Int(size))
    }
    
    func removeEmoji(_ emoji: EmojiArtie.Emoji, by offset: CGSize) {
        if let index = emojiArtie.emojis.index(matching: emoji) {
            emojiArtie.emojis[index].x += Int(offset.width)
            emojiArtie.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArtie.Emoji, by scale: CGFloat) {
        if let index = emojiArtie.emojis.index(matching: emoji) {
            emojiArtie.emojis[index].size = Int((CGFloat(emojiArtie.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
        }
    }
}
