//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Rafael Melo on 29/05/23.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    
    @Published private(set) var emojiArtie: EmojiArtie {
        didSet {
            if emojiArtie.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    
    init() {
        emojiArtie = EmojiArtie()
        emojiArtie.addEmoji("🍌", at: (x: -100, y: -100), size: 80)
        emojiArtie.addEmoji("🍆", at: (x: 50, y: 100), size: 40)
    }
    
    var emojis: [EmojiArtie.Emoji] { emojiArtie.emojis }
    var background: EmojiArtie.Background { emojiArtie.background }
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    enum BackgroundImageFetchStatus {
        case idle
        case fetching
    }
    
    private func fetchBackgroundImageDataIfNecessary() {
        backgroundImage = nil
        switch emojiArtie.background {
        case .url(let url):
            backgroundImageFetchStatus = .fetching
            DispatchQueue.global(qos: .userInitiated).async {
                //voltar para a main thread para atualizar ui
                DispatchQueue.main.async { [weak self] in //weak para não manter a model na memoria
                    //checar se é a imagem mais recente arrastada
                    if self?.emojiArtie.background == EmojiArtie.Background.url(url) {
                        self?.backgroundImageFetchStatus = .idle
                        if let imageData = try? Data(contentsOf: url) {
                            self?.backgroundImage = UIImage(data: imageData)
                        }
                    }
                }
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
