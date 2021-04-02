//
//  PlaceAPIService.swift
//  MyPlaces
//
//  Created by Paul Bonneville on 4/1/21.
//

import Foundation

class PlaceAPIService: NSObject {
    
    // MARK: Variables
    
    enum PlaceType: Int, CaseIterable {
        case supermarket, restaurant, gym
        
        func description() -> String {
            switch self {
            case .supermarket:
                return "supermarket"
            case .restaurant:
                return "restaurant"
            case .gym:
                return "gym"
            }
        }
    }
    
    let BASE_API_URL = "https://maps.googleapis.com/maps/api/place/textsearch/json"
    let API_KEY = "AIzaSyA5hMKU7bjm5GJeEH9_3wLmgVs6OB7aGl0"
    
    var dataTask: URLSessionDataTask?
    let defaultSession = URLSession(configuration: .default)

    // MARK: Public methods
    
    public func search(searchText: String, placeType: PlaceType, completion: @escaping ( PlaceResults? ) -> ()) {
        print("searching")
        dataTask?.cancel()
        
        if var urlComponents = URLComponents(string: BASE_API_URL) {
            urlComponents.query = "key=\(API_KEY)&type=\(placeType.description())&query=\(searchText)"
            
            guard let url = urlComponents.url else {
                return
            }
            
            dataTask = defaultSession.dataTask(with: url) { [weak self] data, response, error in
                defer {
                    self?.dataTask = nil
                }
                
                if let error = error {
                    print(error.localizedDescription)
                } else if let data = data,
                          let response = response as? HTTPURLResponse,
                          response.statusCode == 200 {
                    do {
                        let places = try JSONDecoder().decode(PlaceResults.self, from: data)
                        completion(places)
                        return
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
                completion(nil)
            }

            dataTask?.resume()
        }
    }
    
    public static func placeTypes() -> [String] {
        var allTypes = [String]()
        
        for placeType in PlaceType.allCases {
            allTypes.append(placeType.description().capitalized)
        }
        
        return allTypes
    }
    
    // MARK: Private methods
    
    private func confirmJSON(data: Data) {
        if let json = String(data: data, encoding: String.Encoding.utf8) {
            print(json)
        }
    }
}
