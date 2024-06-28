//
//  File.swift
//  PaginationWithThread
//
//  Created by Arpit iOS Dev. on 28/06/24.
//

import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    func fetchQuotes(page: Int, completion: @escaping (Result<Welcome, Error>) -> Void) {
        let url = "https://api.quotable.io/quotes?page=\(page)"
        AF.request(url).responseDecodable(of: Welcome.self) { response in

            switch response.result {
            case .success(let welcome):
                completion(.success(welcome))
            case .failure(let error):
                print("Error: \(error)")
                completion(.failure(error))
            }
        }
    }
}
