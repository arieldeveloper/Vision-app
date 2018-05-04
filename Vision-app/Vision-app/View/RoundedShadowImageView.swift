//
//  RoundedShadowImageView.swift
//  Vision-app
//
//  Created by Ariel Chouminov on 2018-05-02.
//  Copyright © 2018 Ariel Chouminov. All rights reserved.
//

import UIKit

class RoundedShadowImageView: UIImageView {

    override func awakeFromNib() {
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.75
        self.layer.cornerRadius = 15

}

}
