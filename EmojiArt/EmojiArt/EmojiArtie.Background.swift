//
//  EmojiArtie.Background.swift
//  EmojiArt
//
//  Created by Rafael Melo on 29/05/23.
//

import Foundation

extension EmojiArtie {
    enum Background: Equatable, Codable {
        case blank
        case url(URL)
        case imageData(Data)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let url = try? container.decode(URL.self, forKey: .url) {
                self = .url(url)
            } else if let imageData = try? container.decode(Data.self, forKey: .imageData) {
                self = .imageData(imageData)
            } else {
                self = .blank
            }
        }
        //necessário tornar codable quando os tipos não são por default
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .blank: break
            case .url(let url): try container.encode(url, forKey: .url)
            case .imageData(let data): try container.encode(data, forKey: .imageData)
            }
        }
        
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
        
        enum CodingKeys: String, CodingKey {
            case url
            case imageData
        }
    }
}
