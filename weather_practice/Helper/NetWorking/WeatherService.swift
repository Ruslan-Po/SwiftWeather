import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case noData
    case decodingFailed(Error, Data?)
}

class WeatherService {
    private let apiKey = "7cdd70a88a12f2058c790ed2952ac54a"
    private let baseUrl = "https://api.openweathermap.org/data/2.5/"

    func fetchCurrentWeather(cityName: String, completion: @escaping (Result<WeatherModel, NetworkError>) -> Void) {
        performRequest(endpoint: "weather", parameters: ["q": cityName], completion: completion)
    }

    func fetchCurrentWeather(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherModel, NetworkError>) -> Void) {
        performRequest(endpoint: "weather", parameters: [
            "lat": String(latitude),
            "lon": String(longitude)
        ], completion: completion)
    }

    func fetchForecast(cityName: String, completion: @escaping (Result<ForecastResponse, NetworkError>) -> Void) {
        performRequest(endpoint: "forecast", parameters: ["q": cityName], completion: completion)
    }

    private func performRequest<T: Decodable>(endpoint: String, parameters: [String: String], completion: @escaping (Result<T, NetworkError>) -> Void) {
        var components = URLComponents(string: baseUrl + endpoint)
        components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        components?.queryItems?.append(URLQueryItem(name: "appid", value: apiKey))

        guard let url = components?.url else {
            DispatchQueue.main.async { completion(.failure(.invalidURL)) }
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.requestFailed(error)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decodedData = try decoder.decode(T.self, from: data)
                    completion(.success(decodedData))
                } catch let decodingError {
                    completion(.failure(.decodingFailed(decodingError, data)))
                }
            }
        }
        task.resume()
    }
}
