//
//  VLOptionalConfiguration.swift
//  Verloop
//
//  Created by Sreedeep, Paul on 29/01/22.
//

import Foundation

protocol VLOptionalConfiguration {
    func setUserParams(_ params:ConfigUserParams)
    func setCustomField(_ fields:ConfigCustomFields)
    func setDepartment(_ dept:String)
    func clearDepartment(_ dept:String)
    func setRecipe(_ recepie:String)
    func openWidget()
    func closeWidget()
    func logout()
    func setWidgetColor()
}

extension VLOptionalConfiguration {
    func setUserParams(_ params:ConfigUserParams) {    }
    func setCustomField(_ field:ConfigCustomFields) {    }
    func setDepartment(_ dept:String) {    }
    func clearDepartment(_ dept:String) {    }
    func setRecipe(_ recepie:String) {    }
    func openWidget() {    }
    func closeWidget() {    }
    func logout() {    }
    func setWidgetColor() {    }
}
