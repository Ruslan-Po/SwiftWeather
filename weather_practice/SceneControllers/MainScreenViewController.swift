import UIKit
import CoreLocation

class MainScreenViewController: UIViewController {
    
    
    var greeting: String = Date.getGreetingbyTime()
    
    var weatherData: WeatherModel?
    var latitude: Double?
    var longitude: Double?
    
    private let backgroundImageView = UIImageView()
    
    var cityName: String = "Limassol"
    
    var weatherCondition: Int?
    var currentDateTime = Date.dateFormatter()
    
    lazy var locationNameLabel = UILabel.createLabel(font: .systemFont(ofSize: 20, weight: .light), textAlingment: .left, text: cityName)
    lazy var greetingMessageLabel = UILabel.createLabel(font: .systemFont(ofSize: 25, weight: .regular), textAlingment: .left, text: greeting)
    lazy var currentTemperatureLabel = UILabel.createLabel(font: .systemFont(ofSize: 50, weight: .black), textAlingment: .center,  text: "21°C")
    lazy var weatherDescriptionLabel = UILabel.createLabel(font: .systemFont(ofSize: 20, weight: .light), textAlingment: .center, text: "SUNNY")
    lazy var currentDateTimeLabel = UILabel.createLabel(font: .systemFont(ofSize: 15, weight: .regular), textAlingment: .center, text: currentDateTime)
    lazy var sunriseBlock = UIStackView.createBlock(imageName: "sunrise", topTitle: "Sunrise", bottomTitle: "9:21")
    lazy var sunsetBlock = UIStackView.createBlock(imageName: "sunset", topTitle: "Sunset", bottomTitle: "20:11")
    lazy var humidity = UIStackView.additionBlock(topTitle: "Humidity", bottomAdditionTitle: "21")
    lazy var feelLike = UIStackView.additionBlock(topTitle: "Feels Like", bottomAdditionTitle: "21")
    lazy var nextDaysButton = UIButton.createNextButton(selector: #selector (goToWeeklyScreen))
    lazy var backButton = UIButton.createPreviousButton(selector: #selector(backFunc))
    
    lazy var sunriseSunsetStackView: UIStackView = {
        let ssSV = UIStackView(arrangedSubviews: [sunriseBlock, sunsetBlock])
        ssSV.axis = .horizontal
        ssSV.spacing = 50
        ssSV.translatesAutoresizingMaskIntoConstraints = false
        return ssSV
    }()
    
    lazy var feelsLikeHumidityStackView: UIStackView = {
        let fshSV = UIStackView(arrangedSubviews: [humidity, feelLike])
        fshSV.axis = .horizontal
        fshSV.spacing = 50
        fshSV.translatesAutoresizingMaskIntoConstraints = false
        return fshSV
    }()
    
    lazy var currentWeatherStackView: UIStackView = {
        let cwSV = UIStackView(arrangedSubviews: [currentTemperatureLabel, weatherDescriptionLabel,currentDateTimeLabel])
        cwSV.axis = .vertical
        cwSV.alignment = .center
        cwSV.spacing = 5
        cwSV.distribution = .fillProportionally
        cwSV.translatesAutoresizingMaskIntoConstraints = false
        return cwSV
    }()
    
    lazy var currentWeatherImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "testImage"))
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    enum WeatherIconPath: String {
          case thunderstorm = "Thunderstorm"
          case drizzle = "Drizzle"
          case rain = "Rain"
          case snow = "Snow"
          case fog = "Fog"
          case clear = "ClearSky"
          case clouds = "Clouds"
          case unknown = "PartlyClouds"
      }

      func getWeatherIconByCode(from weatherDescription: Int) -> WeatherIconPath {
          switch weatherDescription {
          case 200...232:
              return .thunderstorm
          case 300...321:
              return .drizzle
          case 500...531:
              return .rain
          case 600...622:
              return .snow
          case 701...781:
              return .fog
          case 800:
              return .clear
          case 801...804:
              return .clouds
          default:
              return .unknown
          }
      }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        if let data = weatherData {
            locationNameLabel.text = cityName
            updateUI(with: data)
        } else if let lat = latitude, let lon = longitude {
            print("Переданы координаты. Загружаем погоду...")
            getWeatherByCoords(latitude: lat, longitude: lon)
        } else {
            print("Данные не переданы. Загружаем погоду по названию города по умолчанию...")
            getWeatherByName()
        }
        
        UPDbgImage()
        setupUI()
    }

    
    private func setupUI() {
        view.backgroundColor = .darkGray
        view.addSubview(locationNameLabel)
        view.addSubview(backButton)
        view.addSubview(greetingMessageLabel)
        view.addSubview(currentWeatherImageView)
        view.addSubview(currentWeatherStackView)
        view.addSubview(sunriseSunsetStackView)
        view.addSubview(feelsLikeHumidityStackView)
        view.addSubview(nextDaysButton)
        
        NSLayoutConstraint.activate([
            locationNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            locationNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            backButton.leadingAnchor.constraint(equalTo: locationNameLabel.trailingAnchor, constant: 20),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0.5),
            
            greetingMessageLabel.topAnchor.constraint(equalTo: locationNameLabel.bottomAnchor, constant:5),
            greetingMessageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            currentWeatherImageView.topAnchor.constraint(equalTo: greetingMessageLabel.bottomAnchor, constant: 10),
            currentWeatherImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            currentWeatherImageView.heightAnchor.constraint(equalTo: currentWeatherImageView.widthAnchor),
            currentWeatherImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            currentWeatherStackView.topAnchor.constraint(equalTo: currentWeatherImageView.bottomAnchor, constant: 10),
            currentWeatherStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nextDaysButton.topAnchor.constraint(equalTo: currentWeatherStackView.bottomAnchor, constant: 20),
            nextDaysButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            sunriseSunsetStackView.topAnchor.constraint(equalTo: nextDaysButton.bottomAnchor, constant: 20),
            sunriseSunsetStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            feelsLikeHumidityStackView.topAnchor.constraint(equalTo: sunriseSunsetStackView.bottomAnchor, constant: 15),
            feelsLikeHumidityStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    
    private func getWeatherByName() {
        let weatherService = WeatherService()
        weatherService.fetchCurrentWeather(cityName: cityName) { [weak self] result in
            self?.handleWeatherResult(result)
        }
    }
    
    private func getWeatherByCoords(latitude: Double, longitude: Double) {
        let weatherService = WeatherService()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, preferredLocale: nil) { (placemarks, error) in
            if let placemark = placemarks?.first {
                self.cityName = placemark.locality ?? placemark.administrativeArea ?? "Saved Location"
                self.locationNameLabel.text = self.cityName
            }
        }
        weatherService.fetchCurrentWeather(latitude: latitude, longitude: longitude) { [weak self] result in
            self?.handleWeatherResult(result)
        }
    }
    
    private func updateConditionIcon(with code: Int) {
        let iconEnum = getWeatherIconByCode(from: code)
        let iconName = iconEnum.rawValue
        currentWeatherImageView.image = UIImage(named: iconName)
        print("Иконка погоды обновлена на: \(iconName)")
    }
    
    private func handleWeatherResult(_ result: Result<WeatherModel, NetworkError>) {
        switch result {
        case .success(let currentWeather):
            updateUI(with: currentWeather)
        case .failure(let error):
            print("Ошибка при загрузке текущей погоды: \(error)")
            // Здесь можно показать пользователю алерт
        }
    }

    private func updateUI(with data: WeatherModel) {
        let celcius = Int(data.main.temp - 273.15)
        let feelsLikeTemp = data.main.feelsLike ?? data.main.temp
        let feelsLikeCelcius = Int(feelsLikeTemp - 273.15)
        let humidityValue = data.main.humidity ?? 0
        
        if let weathercode = data.weather.first?.id {
            self.weatherCondition = weathercode
            self.updateConditionIcon(with: weathercode)
        }
        
        self.locationNameLabel.text = self.cityName // Обновляем имя города, если оно пришло из координат
        self.currentTemperatureLabel.text = "\(celcius)°C"
        self.weatherDescriptionLabel.text = data.weather.first?.description.uppercased()
        self.feelLike.updateBottomTitle("\(feelsLikeCelcius)°C")
        self.humidity.updateBottomTitle("\(humidityValue)%")
        
        let sunriseTime = self.formateDateTime(from: data.sys.sunrise)
        self.sunriseBlock.updateBottomTitle(sunriseTime)
        
        let sunsetTime = self.formateDateTime(from: data.sys.sunset)
        self.sunsetBlock.updateBottomTitle(sunsetTime)
    }
    
    func formateDateTime(from unix: Int )->String{
        let date = Date(timeIntervalSince1970:  TimeInterval(unix))
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "HH:mm"
        return dateFormater.string(from: date)
    }

    @objc func goToWeeklyScreen () {
        let weeklyScreen = WeeklyScreenController()
        navigationController?.pushViewController(weeklyScreen, animated: true)
    }
    
    @objc private func backFunc(){
        UserDefaults.standard.removeObject(forKey: "lastLatitude")
          UserDefaults.standard.removeObject(forKey: "lastLongitude")
          print("Сохраненные координаты удалены.")
          
          guard let window = view.window else { return }

          let firstScreenVC = FirstScreenViewController()
          let rootNC = UINavigationController(rootViewController: firstScreenVC)

          window.rootViewController = rootNC
          UIView.transition(with: window,
                            duration: 0.3,
                            options: .transitionCrossDissolve,
                            animations: nil,
                            completion: nil)
    }
    
    @objc private func UPDbgImage(){
        let hour = Calendar.current.component(.hour, from: Date())
        if (6..<19).contains(hour){
            setupDayBackground()
        } else {
            setupNightBackground()
        }
    }
    
    private func setupNightBackground() {
        let gradientLayer = CAGradientLayer()
        let topColor = UIColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 0.3, green: 0.5, blue: 0.7, alpha: 1.0).cgColor
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupDayBackground() {
        let gradientLayer = CAGradientLayer()
        let topColor = UIColor(red: 102/255.0, green: 178/255.0, blue: 255/255.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 178/255.0, green: 216/255.0, blue: 255/255.0, alpha: 1.0).cgColor
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
}
