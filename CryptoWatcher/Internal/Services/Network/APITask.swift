import Foundation

class APITask <T:Codable> {
    let completion: ((RequestResult<T>) ->())
    let urlRequest: URLRequest

    init(urlRequest: URLRequest, completion: @escaping (RequestResult<T>) ->()) {
        self.urlRequest = urlRequest
        self.completion = completion
    }
}

