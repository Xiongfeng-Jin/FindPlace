//
//  IconPinAnnotationView.swift
//  FindPlace
//
//  Created by Jin on 9/1/17.
//  Copyright © 2017 Jin. All rights reserved.
//

import UIKit
import MapKit

class IconPinAnnotationView: MKAnnotationView {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if image != nil {
            image?.draw(in: rect)
            backgroundColor = UIColor.clear
        }
        
    }
}
