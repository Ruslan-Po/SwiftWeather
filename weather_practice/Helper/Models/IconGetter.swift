import Foundation


enum WeatherIconPath: String {
    case thunderstorm = "Thunderstorm";
    case drizzle = "Drizzle";
    case rain = "Rain";
    case snow = "Snow";
    case fog = "Fog";
    case partlyCloudy = "PartlyClouds";
    case clear = "ClearSky";
    case clouds = "testImage"
}

func getWeatherIconByCode(from weatherDescription: Int) -> WeatherIconPath? {
    switch weatherDescription {
    case 200...232:
        return .thunderstorm
    case 300...321:
        return .drizzle
    case 500...531:
        return .rain
    case 600...622:
        return .snow
    case 800:
        return .clear
    case 801...804:
        return .clouds
    case 701...741:
        return .fog
    default:
        return nil
    }
}
