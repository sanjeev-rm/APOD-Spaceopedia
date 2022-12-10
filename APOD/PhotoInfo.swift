//
//  PhotoInfo.swift
//  APOD
//
//  Created by Sanjeev RM on 10/12/22.
//

import Foundation

/// Model Object to represent an photo info.
struct PhotoInfo : Codable
{
    var title : String
    var description : String
    var url : URL
    var mediaType : String
    var copyright : String?
    
    enum CodingKeys : String, CodingKey
    {
        case title
        case description = "explanation"
        case url
        case mediaType = "media_type"
        case copyright
    }
}
