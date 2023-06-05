//
//  EmojiArtie.swift
//  EmojiArt
//
//  Created by Rafael Melo on 29/05/23.
//

import Foundation

struct EmojiArtie: Codable {
    private var uniqueEmojiID = 0
    
    var background = Background.blank
    var emojis = [Emoji]()
    
    struct Emoji: Identifiable, Hashable, Codable {
        let id: Int
        let text: String
        var x: Int
        var y: Int
        var size: Int
        
        //trancamos a criação de um emoji para apenas o arquivo
        //porem ainda podemos modificar o emoji em outros lugares
        fileprivate init(id: Int, text: String, x: Int, y: Int, size: Int) {
            self.id = id
            self.text = text
            self.x = x
            self.y = y
            self.size = size
        }
    }
    
    func json() throws -> Data {
        try JSONEncoder().encode(self)
    }
    
    init(json: Data) throws {
        self = try JSONDecoder().decode(EmojiArtie.self, from: json)
    }
    
    init(url: URL) throws {
        let data = try Data(contentsOf: url)
        self = try EmojiArtie(json: data)
    }
    
    //impossibilita a criação personalizada
    init() {}
    
    mutating func addEmoji(_ text: String,
                  at location: (x: Int, y: Int),
                  size: Int) {
        uniqueEmojiID += 1
        emojis.append(Emoji(id: uniqueEmojiID,
                            text: text,
                            x: location.x,
                            y: location.y,
                            size: size))
    }
}
