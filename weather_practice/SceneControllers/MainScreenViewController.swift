
import UIKit

class MainScreenViewController: UIViewController {
    
    // VARIABLES
    var greeting: String = Date.getGreetingbyTime()
    var weatherData: WeatherModel?
    
    private let backgroundImageView = UIImageView()
    
    var cityName: String = "Limassol"
   
    var weatherCondition: Int?
    
    var currentDateTime = Date.dateFormatter()
    
    lazy var locationNameLabel = UILabel.createLabel(font: UIFont.Light(size: 20),textAlingment: .left,text: cityName)
    
    lazy var greetingMessageLabel = UILabel.createLabel(font: UIFont.regular(size: 25),textAlingment: .left, text: greeting)
    
    lazy var currentTemperatureLabel = UILabel.createLabel(font: UIFont.Black(size: 50),textAlingment: .center,  text: "21°C")
    
    lazy var weatherDescriptionLabel = UILabel.createLabel(font: UIFont.Light(size: 20),textAlingment: .center, text: "SUNNY")
    
    lazy var currentDateTimeLabel = UILabel.createLabel(font: UIFont.regular(size: 15),textAlingment: .center, text: currentDateTime)
    
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
    
    //FUNCTIONS
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
    
    @objc private func UPDbgImage(){
        let hour = Calendar.current.component(.hour, from: Date())
        if hour>=6 && hour<19{
            setupDayBackground()
            return
        }else{
            setupNightBackground()}
    }
    
    @objc private func backFunc(){
        navigationController?.popViewController(animated: true)
    }
    
    // NETWORK
    func getWeather() {
            let weatherService = WeatherService()
            
            weatherService.fetchCurrentWeather(cityName: cityName) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let currentWeather):
                        // Этот блок теперь будет вызываться, только если данные не были переданы с первого экрана
                        let celcius = Int(currentWeather.main.temp - 273.15) // ИСПРАВЛЕНО: Более точное вычисление
                        let feelsLikeTemp = currentWeather.main.feelsLike ?? currentWeather.main.temp
                        let feelsLikeCelcius = Int(feelsLikeTemp - 273.15)
                        let humidityValue = currentWeather.main.humidity ?? 0
                        
                        if let weathercode = currentWeather.weather.first?.id {
                            self.weatherCondition = weathercode
                        }
                        
                        self.currentTemperatureLabel.text = "\(celcius)°C"
                        self.weatherDescriptionLabel.text = currentWeather.weather.first?.description.uppercased()
                        self.feelLike.updateBottomTitle("\(feelsLikeCelcius)°C")
                        self.humidity.updateBottomTitle("\(humidityValue)%")
                        
                        let sunriseTime = self.formateDateTime(from: currentWeather.sys.sunrise)
                        self.sunriseBlock.updateBottomTitle(sunriseTime)
                        
                        let sunsetTime = self.formateDateTime(from: currentWeather.sys.sunset)
                        self.sunsetBlock.updateBottomTitle(sunsetTime)
                        
                    case .failure(let error):
                        print("Ошибка при загрузке текущей погоды: \(error.localizedDescription)")
                    }
                }
            }
        }
    //CPP
    
    override func viewDidLoad() {
           super.viewDidLoad()
           navigationItem.hidesBackButton = true
           
           // ИЗМЕНЕНО: Главная логика для обработки переданных данных
           
           // Сначала обновляем название города, так как оно приходит в любом случае
           locationNameLabel.text = cityName
           
           if let data = weatherData {
               // 1. Если данные были переданы, сразу обновляем UI, без сетевого запроса
               print("Данные о погоде переданы. Обновляем UI...")
               
               let celcius = Int(data.main.temp - 273.15)
               let feelsLikeTemp = data.main.feelsLike ?? data.main.temp
               let feelsLikeCelcius = Int(feelsLikeTemp - 273.15)
               let humidityValue = data.main.humidity ?? 0
               
               if let weathercode = data.weather.first?.id {
                   self.weatherCondition = weathercode
               }
               
               self.currentTemperatureLabel.text = "\(celcius)°C"
               self.weatherDescriptionLabel.text = data.weather.first?.description.uppercased()
               self.feelLike.updateBottomTitle("\(feelsLikeCelcius)°C")
               self.humidity.updateBottomTitle("\(humidityValue)%")
               
               let sunriseTime = self.formateDateTime(from: data.sys.sunrise)
               self.sunriseBlock.updateBottomTitle(sunriseTime)
               
               let sunsetTime = self.formateDateTime(from: data.sys.sunset)
               self.sunsetBlock.updateBottomTitle(sunsetTime)
               
           } else {
               // 2. Иначе (если данные не были переданы), запускаем сетевой запрос как раньше
               print("Данные о погоде не были переданы. Запускаем сетевой запрос...")
               getWeather()
           }
           
           UPDbgImage()
            
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
}

