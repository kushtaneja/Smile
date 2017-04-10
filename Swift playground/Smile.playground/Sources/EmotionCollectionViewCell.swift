//
//  EmotionCollectionViewCell.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit

class EmotionCollectionViewCell: UICollectionViewCell {
    
    let emotionView = EmotionView(frame: CGRect.zero)
    
    var emotion = Emotion() {
        didSet {
            emotionView.emotion = emotion
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(emotionView)
        emotionView.translatesAutoresizingMaskIntoConstraints = false
        emotionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        emotionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        emotionView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        emotionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented.")
    }
}
