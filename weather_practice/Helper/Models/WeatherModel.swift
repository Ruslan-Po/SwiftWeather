import Foundation


class WeatherModel : Codable{
    var coord: GeoModel?
    var name: String?
    var main: MainWeather?
    var weather: [Weather]?
    var sys: SysInfo?
}


struct MainWeather: Codable{
    var temp: Double
    var feelsLike: Double
    var tempMin: Double
    var tempMax:  Double
    var pressure : Int
    var humidity: Int
}

struct Weather: Codable{
    var description: String
}

struct GeoModel: Codable {
    var lat: Double
    var lon: Double
}

struct SysInfo: Codable {
    let sunrise: Int
    let sunset: Int
}


