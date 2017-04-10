//
//  Emoji.swift
//  EmojiKit
//
//  Created by Dasmer Singh on 12/20/15.
//  Copyright © 2015 Dastronics Inc. All rights reserved.
//

public struct Emoji: Equatable {

    public let character: String
    public let description: String
    public let category: String
    internal let aliases: [String]
    internal let tags: [String]

    public var ID: String {
        // There will never be more that 1 emoji struct for a given character,
        // so we can use the character itself to represent the unique ID
        return character
    }

    public init(emojiCharracter: String?,emojiAliases: [String]?,emojiDescription: String?, emojiCategory:String?, emojiTags: [String]? = []) {

        self.character = emojiCharracter!
        self.description = emojiDescription!
        self.category = emojiCategory!
        self.aliases = emojiAliases!
        self.tags = emojiTags != nil ? emojiTags! : []
    }
}


extension Emoji: Hashable {

    public var hashValue: Int {
        return ID.hashValue
    }
}


public func ==(lhs: Emoji, rhs: Emoji) -> Bool {
    return lhs.ID == rhs.ID
}
