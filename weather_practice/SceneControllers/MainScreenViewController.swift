import UIKit
import CoreLocation

class MainScreenViewController: UIViewController {
    
    var weatherData: WeatherModel?
    var latitude: Double?
    var longitude: Double?
    var cityName: String?

    
    private let greetingMessageLabel = UILabel.createLabel(font: .systemFont(ofSize: 25, weight: .regular), textAlingment: .left, text: Date.getGreetingbyTime())
    private let locationNameLabel = UILabel.createLabel(font: .systemFont(ofSize: 20, weight: .light), textAlingment: .left, text: "Loading...")
    private let currentTemperatureLabel = UILabel.createLabel(font: .systemFont(ofSize: 50, weight: .black), textAlingment: .center, text: "--°C")
    private let weatherDescriptionLabel = UILabel.createLabel(font: .systemFont(ofSize: 20, weight: .light), textAlingment: .center, text: "...")
    private let currentDateTimeLabel = UILabel.createLabel(font: .systemFont(ofSize: 15, weight: .regular), textAlingment: .center, text: Date.dateFormatter())
    
    private let sunriseBlock = UIStackView.createBlock(imageName: "sunrise", topTitle: "Sunrise", bottomTitle: "--:--")
    private let sunsetBlock = UIStackView.createBlock(imageName: "sunset", topTitle: "Sunset", bottomTitle: "--:--")
    private let humidity = UIStackView.additionBlock(topTitle: "Humidity", bottomAdditionTitle: "--")
    private let feelLike = UIStackView.additionBlock(topTitle: "Feels Like", bottomAdditionTitle: "--")
    
    private lazy var nextDaysButton = UIButton.createNextButton(selector: #selector (goToWeeklyScreen))
    private lazy var backButton = UIButton.createPreviousButton(selector: #selector(backFunc))
    
    private lazy var sunriseSunsetStackView = UIStackView(arrangedSubviews: [sunriseBlock, sunsetBlock])
    private lazy var feelsLikeHumidityStackView = UIStackView(arrangedSubviews: [humidity, feelLike])
    private lazy var currentWeatherStackView = UIStackView(arrangedSubviews: [currentTemperatureLabel, weatherDescriptionLabel, currentDateTimeLabel])
    
    private let currentWeatherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
        setupUI()
        fetchWeatherData()
    }
    
    private func fetchWeatherData() {
        if let data = weatherData {
            updateUI(with: data)
            saveCoordinates(from: data)
        } else if let lat = latitude, let lon = longitude {
            getWeatherByCoords(latitude: lat, longitude: lon)
        } else if let name = cityName {
            getWeatherByName(name: name)
        } else {
            locationNameLabel.text = "Error"
            print("View controller has been opened without coordinates")
        }
    }
    
    private func getWeatherByName(name: String) {
        WeatherService().fetchCurrentWeather(cityName: name) { [weak self] result in
            self?.handleWeatherResult(result)
        }
    }
    
    private func getWeatherByCoords(latitude: Double, longitude: Double) {
        WeatherService().fetchCurrentWeather(latitude: latitude, longitude: longitude) { [weak self] result in
            self?.handleWeatherResult(result)
        }
    }

    private func handleWeatherResult(_ result: Result<WeatherModel, NetworkError>) {
        DispatchQueue.main.async {
            switch result {
            case .success(let currentWeather):
                self.updateUI(with: currentWeather)
                self.saveCoordinates(from: currentWeather)
            case .failure(let error):
                print("Loading Error \(error)")
                self.locationNameLabel.text = "Failed to load"
            }
        }
    }
    
    private func saveCoordinates(from data: WeatherModel) {
        let lat = data.coord.lat
        let lon = data.coord.lon
        
        UserDefaults.standard.set(lat, forKey: "lastLatitude")
        UserDefaults.standard.set(lon, forKey: "lastLongitude")
    }

    private func updateUI(with data: WeatherModel) {
        self.weatherData = data
        self.cityName = data.name
        self.latitude = data.coord.lat
        self.longitude = data.coord.lon
        
        updateBackground()
        
        locationNameLabel.text = data.name
        currentTemperatureLabel.text = "\(Int(data.main.temp - 273.15))°C"
        weatherDescriptionLabel.text = data.weather.first?.description.uppercased()
        
        let feelsLikeTemp = data.main.feelsLike ?? data.main.temp
        feelLike.updateBottomTitle("\(Int(feelsLikeTemp - 273.15))°C")
        humidity.updateBottomTitle("\(data.main.humidity ?? 0)%")
        
        sunriseBlock.updateBottomTitle(formatDateTime(from: data.sys.sunrise))
        sunsetBlock.updateBottomTitle(formatDateTime(from: data.sys.sunset))
        
        if let weatherCode = data.weather.first?.id {
            currentWeatherImageView.image = UIImage(named: getWeatherIconName(from: weatherCode))
        }
    }
    
    @objc private func goToWeeklyScreen() {
        guard let cityName = self.cityName else { return }
        let weeklyScreen = WeeklyScreenController()
        weeklyScreen.cityNameForecast = cityName
        weeklyScreen.latitude = self.latitude
        weeklyScreen.longitude = self.longitude
        navigationController?.pushViewController(weeklyScreen, animated: true)
    }
    
    @objc private func backFunc() {
        UserDefaults.standard.removeObject(forKey: "lastLatitude")
        UserDefaults.standard.removeObject(forKey: "lastLongitude")
        
        guard let window = view.window else { return }
        let firstScreenVC = FirstScreenViewController()
        let rootNC = UINavigationController(rootViewController: firstScreenVC)
        
        window.rootViewController = rootNC
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }
    
    private func formatDateTime(from unix: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unix))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func getWeatherIconName(from code: Int) -> String {
        switch code {
        case 200...232: return "Thunderstorm"
        case 300...321: return "Drizzle"
        case 500...531: return "Rain"
        case 600...622: return "Snow"
        case 701...781: return "Fog"
        case 800:       return "ClearSky"
        case 801...804: return "Clouds"
        default:        return "PartlyClouds"
        }
    }
    
    private func updateBackground() {
        let hour = Calendar.current.component(.hour, from: Date())
        let isDay = (6..<19).contains(hour)
        
        let topColor = isDay ? UIColor(red: 102/255.0, green: 178/255.0, blue: 255/255.0, alpha: 1.0).cgColor : UIColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 1.0).cgColor
        let bottomColor = isDay ? UIColor(red: 178/255.0, green: 216/255.0, blue: 255/255.0, alpha: 1.0).cgColor : UIColor(red: 0.3, green: 0.5, blue: 0.7, alpha: 1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        
        self.view.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupController() {
        navigationItem.hidesBackButton = true
        view.backgroundColor = .darkGray
    }

    private func setupUI() {
        sunriseSunsetStackView.axis = .horizontal
        sunriseSunsetStackView.spacing = 50
        feelsLikeHumidityStackView.axis = .horizontal
        feelsLikeHumidityStackView.spacing = 50
        currentWeatherStackView.axis = .vertical
        currentWeatherStackView.alignment = .center
        currentWeatherStackView.spacing = 5
        
        let allSubviews = [locationNameLabel, backButton, greetingMessageLabel, currentWeatherImageView, currentWeatherStackView, sunriseSunsetStackView, feelsLikeHumidityStackView, nextDaysButton]
        allSubviews.forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            locationNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            locationNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            backButton.leadingAnchor.constraint(equalTo: locationNameLabel.trailingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: locationNameLabel.centerYAnchor),
            
            greetingMessageLabel.topAnchor.constraint(equalTo: locationNameLabel.bottomAnchor, constant: 5),
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
}
