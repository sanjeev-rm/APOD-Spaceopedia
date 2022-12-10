//
//  PhotoInfoController.swift
//  APOD
//
//  Created by Sanjeev RM on 10/12/22.
//

import Foundation

import UIKit

class PhotoInfoController
{
    /// Created an error for the PhotoInfo.
    enum PhotoInfoError : Error, LocalizedError
    {
        case itemNotFound
        case imageNotFound
    }
    
    /// This function fetches information from the internet.
    func fetchPhotoInfo(query: [String:String]) async throws -> PhotoInfo
    {
        var urlComponents = URLComponents(string: "https://api.nasa.gov/planetary/apod")!
        urlComponents.queryItems = query.map({ (key: String, value: String) in
            URLQueryItem(name: key, value: value)
        })
        
        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
        
        guard let httpUrlResponse = response as? HTTPURLResponse, httpUrlResponse.statusCode == 200 else
        {
            throw PhotoInfoError.itemNotFound
        }
        
        let jsonDecoder = JSONDecoder()
        let jsonDecodedPhotoInfo = try jsonDecoder.decode(PhotoInfo.self, from: data)
        return jsonDecodedPhotoInfo
    }
    
    /// This function gets the image / video (media) from the internet.
    func fetchPhotoImage(imageUrl url: URL) async throws -> UIImage
    {
        // Here sometimes what happens is the image url does not have the secure protocol https instead it's http which sometimes might throw an error. And it's not secure. So we're changing it to https. By creating URLComponents.
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        urlComponents?.scheme = "https"
        
        let (data, response) = try await URLSession.shared.data(from: urlComponents!.url!)
        
        guard let httpUrlResponse = response as? HTTPURLResponse, httpUrlResponse.statusCode == 200,
        let image = UIImage(data: data) else
        {
            throw PhotoInfoError.imageNotFound
        }
        
        return image
    }
}
