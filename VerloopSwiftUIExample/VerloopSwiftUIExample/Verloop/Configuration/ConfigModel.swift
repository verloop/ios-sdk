//
//  ConfigModel.swift
//  Verloop
//
//  Created by Sreedeep, Paul on 29/01/22.
//

import Foundation

//can be added as many fields as needed
struct ConfigUserParams:Codable {
    let name:String?
}
//can be added as many fields as needed
struct ConfigCustomFields:Codable {
    let user_id:String?
}
