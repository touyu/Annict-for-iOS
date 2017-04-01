//
//  AnnictUsersResponse.swift
//  Annict-for-iOS
//
//  Created by Yuto Akiba on 2017/02/13.
//  Copyright © 2017年 Yuto Akiba. All rights reserved.
//

import Himotoki


// MARK: - AnnictUsersResponse

struct AnnictUsersResponse {
    var users: [AnnictUserResponse]
    
    init (_ e: Extractor) {
        users = try! e <|| "users"
    }
}

extension AnnictUsersResponse: Decodable {
    static func decode(_ e: Extractor) throws -> AnnictUsersResponse {
        return try castOrFail(AnnictUsersResponse(e))
    }
}

struct AnnictUserResponse {
    var id: Int
    var username: String?
    var name: String?
    var description: String?
    var avatarURL: String?
    var backgroundImageURL: String?
    
    init (_ e: Extractor) {
        id = try! e <| "id"
        username = try! e <|? "username"
        name = try! e <|? "name"
        description = try! e <|? "description"
        avatarURL = try! e <|? "avatar_url"
        backgroundImageURL = try! e <|? "background_image_url"
    }
    
    init (dictionary: [String: Any]) {
        id = dictionary["id"] as! Int
        username = dictionary["username"] as? String
        name = dictionary["name"] as? String
        description = dictionary["description"]  as? String
        avatarURL = dictionary["avatarURL"] as? String
        backgroundImageURL = dictionary["backgroundImageURL"]  as? String
    }
    
    func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        dictionary["id"] = id
        dictionary["username"] = username
        dictionary["name"] = name
        dictionary["description"] = description
        dictionary["avatarURL"] = avatarURL
        dictionary["backgroundImageURL"] = backgroundImageURL
        return dictionary
    }
}

extension AnnictUserResponse: Decodable {
    static func decode(_ e: Extractor) throws -> AnnictUserResponse {
        return try castOrFail(AnnictUserResponse(e))
    }
}
