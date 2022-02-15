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
}
