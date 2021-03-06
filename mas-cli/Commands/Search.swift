//
//  Search.swift
//  mas-cli
//
//  Created by Michael Schneider on 4/14/16.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

struct ResultKeys {
    static let ResultCount = "resultCount"
    static let Results = "results"
    static let TrackName = "trackName"
    static let TrackId = "trackId"
}

struct SearchCommand: CommandType {
    typealias Options = SearchOptions
    let verb = "search"
    let function = "Search for apps from the Mac App Store"
    
    func run(_ options: Options) -> Result<(), MASError> {
        
        guard let searchURLString = searchURLString(options.appName),
              let searchJson = URLSession.requestSynchronousJSONWithURLString(searchURLString) as? [String: AnyObject] else {
            return .failure(MASError(code:.searchError))
        }
        
        guard let resultCount = searchJson[ResultKeys.ResultCount] as? Int , resultCount > 0,
              let results = searchJson[ResultKeys.Results] as? [[String: AnyObject]] else {
            print("No results found")
            return .failure(MASError(code:.noSearchResultsFound))
        }
        
        for result in results {
            if let appName = result[ResultKeys.TrackName] as? String,
                   let appId = result[ResultKeys.TrackId] as? Int {
                print("\(String(appId)) \(appName)")
            }
        }
        
        return .success(())
    }
    
    func searchURLString(_ appName: String) -> String? {
        if let urlEncodedAppName = appName.URLEncodedString() {
            return "https://itunes.apple.com/search?entity=macSoftware&term=\(urlEncodedAppName)&attribute=allTrackTerm"
        }
        return nil
    }
}

struct SearchOptions: OptionsType {
    let appName: String
    
    static func create(_ appName: String) -> SearchOptions {
        return SearchOptions(appName: appName)
    }
    
    static func evaluate(_ m: CommandMode) -> Result<SearchOptions, CommandantError<MASError>> {
        return create
            <*> m <| Argument(usage: "the app name to search")
    }
}
