//
//  VLExtensions.swift
//  Verloop
//
//  Created by Sreedeep on 14/02/22.
//

import Foundation
import WebKit

extension String {
    static func getUserIdEvaluationJS(_ userId:String,optionArgument:String?) -> String {
        if let _unwrapped = optionArgument {
            return "\(Constants.JS_METHOD).setUserId('\(userId)','\(_unwrapped)')"
        }
        return "VerloopLivechat.setUserId('\(userId)')"
    }
    static func getRecepieEvaluationJS(_ recepie:String) -> String {
        return "\(Constants.JS_METHOD).setRecipe('\(recepie)')"
    }
    static func getCustomFieldEvaluationJS(_ field:VLConfig.CustomField) -> String {
        return "\(Constants.JS_METHOD).setCustomField('\(field.key)','\(field.value)','\(field.scope)')"
    }
    static func getUserParamEvaluationJS(key:String,value:String) -> String {
        return "\(Constants.JS_METHOD).setUserParams('\(key)','\(value)')"
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
}
