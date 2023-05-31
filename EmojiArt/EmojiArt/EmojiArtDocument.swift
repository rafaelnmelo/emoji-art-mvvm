//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Rafael Melo on 29/05/23.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    
    @Published private(set) var emojiArtie: EmojiArtie
    
    init() {
        emojiArtie = EmojiArtie()
        emojiArtie.addEmoji("🍌", at: (x: -100, y: -100), size: 80)
        emojiArtie.addEmoji("🍆", at: (x: 50, y: 100), size: 40)
    }
    
    var emojis: [EmojiArtie.Emoji] { emojiArtie.emojis }
    var background: EmojiArtie.Background { emojiArtie.background }
    
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
