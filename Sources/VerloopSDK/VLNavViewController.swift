//
//  VLNavViewController.swift
//  VerloopSDK
//
//  Created by Shobhit Bakliwal on 04/01/19.
//  Copyright © 2019 Verloop. All rights reserved.
//

import Foundation
import UIKit

class VLNavViewController: UINavigationController {
    // forcing portrait orientation
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    
    override var shouldAutorotate : Bool {
        return false
    }
}
