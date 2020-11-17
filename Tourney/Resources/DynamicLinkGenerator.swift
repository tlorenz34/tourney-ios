//
//  DynamicLinkGenerator.swift
//  Tourney
//
//  Created by German Espitia on 11/16/20.
//  Copyright © 2020 Will Cohen. All rights reserved.
//

import Foundation
import FirebaseDynamicLinks

/**
 Generates `DynamicLinks`.
 */
struct DynamicLinkGenerator {
    
    private let scheme = "https"
    private let host = "www.tourneyevents.com"
    private let queryItemKey = "tournament_id"
    private let bundleId = "com.tourney.Tourney"
    private let appStoreId = "1477223676"
    
    /// Generates dynamic link to share a tournaments page.
    public func generateLinkForTournament(_ tournament: Tournament, completion: @escaping ((URL?) -> Void)) {
        
        // generate base url
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.tourneyevents.com"
        
        let tournamentIdItem = URLQueryItem(name: "tournament_id", value: tournament.id)
        components.queryItems = [tournamentIdItem]
        
        guard let linkParameter = components.url else {
            completion(nil)
            return
        }
        
        // create dynamic link
        guard let shareLink = DynamicLinkComponents(link: linkParameter, domainURIPrefix: "https://tourney.page.link") else {
            print("could create FDL components")
            completion(nil)
            return
        }
        
        // set params
        guard let bundleId = Bundle.main.bundleIdentifier else { return }
        
        shareLink.iOSParameters = DynamicLinkIOSParameters(bundleID: bundleId)
        shareLink.iOSParameters?.appStoreID = appStoreId
        
        shareLink.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        shareLink.socialMetaTagParameters?.title = "\(tournament.name)"
        shareLink.socialMetaTagParameters?.imageURL = tournament.featuredImageURL
        
        shareLink.shorten { (url, warnings, error) in
            if let error = error {
                print("Error shortening FDL: \(error)")
                completion(nil)
                return
            }
            if let warnings = warnings {
                for warning in warnings {
                    print("FDL Warning: \(warning)")
                }
            }
            guard let url = url else {
                completion(nil)
                return
            }
            
            print("shortened url: \(url)")
            completion(url)
        }
    }
    
}
