//
//  VLConfiguration.swift
//  Verloop
//
//  Created by Sreedeep, Paul on 29/01/22.
//

import Foundation
import UIKit

struct VLConfiguration:VLOptionalConfiguration {
    
    enum VLConfigEvent {
        case vlOpenWidget
        case vlCloseWidget
        case vlLogout
        case vlWidgetColor(_ colorCode:UIColor)
    }
    
    var muserId:String
    private var mRecepie:String?
    private var mDepartment:String?
    private var mUserParameters:ConfigUserParams?
    private var mCustomFields:ConfigCustomFields?
    var didUpdateConfiguration:((_ configuration:VLConfiguration) -> Void)?
    var didRequestForNewEvent:((_ event:VLConfigEvent) -> Void)?
    
    init(userId uid:String) {
        self.muserId = uid
    }
    
    mutating func setUserParams(_ params: ConfigUserParams) {
        self.mUserParameters = params
        didUpdateConfiguration?(self)
    }
    
    mutating func setCustomField(_ fields: ConfigCustomFields) {
        self.mCustomFields = fields
        didUpdateConfiguration?(self)
    }
    
    mutating func setDepartment(_ dept: String) {
        self.mDepartment = dept
        didUpdateConfiguration?(self)
    }
    
    mutating func clearDepartment(_ dept: String) {
        if self.mDepartment == dept {
            self.mDepartment = nil
            didUpdateConfiguration?(self)
        }
    }
    
    mutating func setRecipe(_ recepie: String) {
        self.mRecepie = recepie
        didUpdateConfiguration?(self)
    }
    
    func openWidget() {
        didRequestForNewEvent?(.vlOpenWidget)
    }
    func closeWidget() {
        didRequestForNewEvent?(.vlCloseWidget)
    }
    func logout() {
        didRequestForNewEvent?(.vlLogout)
    }
    func setWidgetColor(_ color:UIColor) {
        didRequestForNewEvent?(.vlWidgetColor(color))
    }
}
