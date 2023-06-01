//
//  EmojiArtie.Background.swift
//  EmojiArt
//
//  Created by Rafael Melo on 29/05/23.
//

import Foundation

extension EmojiArtie {
    enum Background: Equatable {
        case blank
        case url(URL)
        case imageData(Data)
        
        var url: URL? {
            switch self {
            case .url(let url): return url
            default: return nil
            }
        }
        
        var imageData: Data? {
            switch self {
            case .imageData(let data): return data
            default: return nil
            }
        }
    }
}
