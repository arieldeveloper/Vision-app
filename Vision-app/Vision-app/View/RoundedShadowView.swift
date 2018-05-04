//
//  RoundedShadowView.swift
//  Vision-app
//
//  Created by Ariel Chouminov on 2018-05-02.
//  Copyright © 2018 Ariel Chouminov. All rights reserved.
//

import UIKit

class RoundedShadowView: UIView {

    override func awakeFromNib() {
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.75
        self.layer.cornerRadius = self.frame.height / 2
    }

}
