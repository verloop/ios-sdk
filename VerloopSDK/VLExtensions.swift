//
//  VLExtensions.swift
//  Verloop
//
//  Created by Sreedeep on 14/02/22.
//

import Foundation
import WebKit



extension String {
    
    func hasEmptyValue() -> Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || self == ""
    }
    
    static func getUserIdEvaluationJS(_ userId:String) -> String {
        return "\(Constants.JS_METHOD).setUserId('\(userId)')"
    }
    static func getRecipeEvaluationJS(_ recipe:String) -> String {
        return "\(Constants.JS_METHOD).setRecipe('\(recipe)')"
    }
    static func getCustomFieldEvaluationJS(_ field:VLConfig.CustomField) -> String {
           return "\(Constants.JS_METHOD).setCustomField(\"\(field.key)\",\"\(field.value)\",{scope:\"\(field.scope)\"})"
       }

       static func getUserParamEvaluationJS(key:String,value:String) -> String {
           return "\(Constants.JS_METHOD).setUserParams({'\(key)':'\(value)'})"

       }
    static func getDepartmentEvaluationJS(dept:String) -> String {
        return "\(Constants.JS_METHOD).setDepartment('\(dept)')"
    }
    static func getClearDepartmentEvaluationJS() -> String {
        return "\(Constants.JS_METHOD).clearDepartment()"
    }
    static func getCloseEvaluateJS() -> String {
        return "\(Constants.JS_METHOD).close()"
    }
    static func getLogoutEvaluationJS() -> String {
        let logout = "logout"
        return "\(Constants.JS_METHOD).close('\(logout)')"
    }
    static func getWidgetOpenedEvaluationJS() -> String {
        return "\(Constants.JS_METHOD).widgetOpened()"
    }
    static func getWidgetClosedEvaluationJS() -> String {
        return "\(Constants.JS_METHOD).widgetClosed()"
    }
    static func getWidgetColorEvaluationJS() -> String {
        return "\(Constants.JS_METHOD).widgetClosed()"
    }
    
    static func getShowDownloadButtonJS(_ allowFileDownload: Bool) -> String {
        return "\(Constants.JS_METHOD).showDownloadButton('\(allowFileDownload)')"
    }
}
