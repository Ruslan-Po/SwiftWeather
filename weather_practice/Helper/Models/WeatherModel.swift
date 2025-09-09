struct WeatherModel: Codable {
    let coord: GeoModel
    let name: String
    let main: MainWeather
    let weather: [Weather]
    let sys: SysInfo
}

struct ForecastResponse: Codable {
    let list: [ForecastItem]
}


struct ForecastItem: Codable {
    let dt: Int
    let main: MainWeather
    let weather: [Weather]
}


struct MainWeather: Codable {
    let temp: Double
    let feelsLike: Double?
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int?
}

struct Weather: Codable {
    let id: Int 
    let description: String
}

struct GeoModel: Codable {
    let lat: Double
    let lon: Double
}

struct SysInfo: Codable {
    let sunrise: Int
    let sunset: Int
}
