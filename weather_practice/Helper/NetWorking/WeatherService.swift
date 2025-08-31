
import Foundation

class WeatherService{
    func fetscWeather(cityName: String ,complition: @escaping (WeatherModel?) -> Void ){
        
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=7cdd70a88a12f2058c790ed2952ac54a"
        guard let url = URL(string: urlString) else {
            complition(nil)
            return
        }
        let task = URLSession.shared.dataTask(with: url){
            (data, request,error) in
            guard let data = data else {
                return complition(nil)
            }
            do
            {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let WeatherData = try decoder.decode(WeatherModel.self, from: data)
                
                complition(WeatherData)
            }
            catch{
                print("Error decoding: \(error)")
                complition(nil)
            }
            
        }
        task.resume()
    }
}
