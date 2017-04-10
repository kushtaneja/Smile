//
//  EmojiFactory.swift
//  Smile
//
//  Created by Kush Taneja on 23/03/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit


public class EmojiFactory{
    private var AllEmojiArray = [Emoji]()

    private var emojis = [String]()
    
    public init() {
        parseEmojis()
    }
    
    public func get(emojisOf number:Int)->[String]{
        
        var customEmojis = [String]()
        
        customEmojis = select(from: emojis, count
            : 5)
        
        return expand(from: customEmojis, count: number)
    }
    
    //MARK: Private Methods
    
    private func parseEmojis(){
   
        let path: NSString = Bundle.main.path(forResource: "emoji", ofType: ".json")! as NSString
        let emojiData : Data = try! NSData(contentsOfFile: path as String, options: Data.ReadingOptions.dataReadingMapped) as Data
        
        let jsonarray: NSArray!=(try! JSONSerialization.jsonObject(with: emojiData, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSArray
        
        let emojisMutableArray = jsonarray as! NSMutableArray

        for emoji in emojisMutableArray{
            
            let emoji = emoji as! NSDictionary
            
            let charracterString: String? = emoji.value(forKey: "emoji") != nil ? emoji.value(forKey: "emoji") as? String : "😄"
            let category: String? = emoji.value(forKey: "category") != nil ? emoji.value(forKey: "category") as? String : ""
            let description = emoji.value(forKey: "description") != nil ? emoji.value(forKey: "description") as? String : ""
            let aliases = emoji.value(forKey: "aliases") as? [String]
            let tags = emoji.value(forKey: "tags") as? [String]
            
            let currentEmoji = Emoji(emojiCharracter: charracterString,emojiAliases: aliases,emojiDescription: description, emojiCategory:category, emojiTags: tags)
            
            emojis.append(charracterString!)
            AllEmojiArray.append(currentEmoji)
        }
        
}

public func query(_ searchString: String, completion: @escaping (([Emoji]) -> Void)) {
    var results: [Emoji] = []
    let emojiResults = AllEmojiArray.filter {
        $0.character == searchString }
    results = emojiResults
    completion(results)
}
}


public func repeated<T>(from a:[T], count k:Int) -> [T]{
    var b = [T]()
    for i in 0..<k {
        let r = random(min: i, max: a.count - 1)
        b.append(a[r])
    }
    return b
}
/*
 Expand an array of size n to k by repeating it's elements at random postions. Performance: O(k).
*/

public func expand<T>(from a:[T], count k:Int) -> [T]{
    
    var b = [T]()
    
    for i in 0..<k {
        let r = random(min: 0, max: a.count - 1)
        b.append(a[r])
    }
    return b
}

/*
 Selects k items at random from an array of size n. Does not keep the elements
 in the original order. Performance: O(k).
 */
public func select<T>(from a: [T], count k: Int) -> [T] {
    var a = a
    for i in 0..<k {
        let r = random(min: i, max: a.count - 1)
        if i != r {
            swap(&a[i], &a[r])
        }
    }
    return Array(a[0..<k])
}

/* Returns a random integer in the range min...max, inclusive. */
public func random(min: Int, max: Int) -> Int {
    assert(min < max)
    return min + Int(arc4random_uniform(UInt32(max - min + 1)))
}
