
import UIKit

class MainScreenViewController: UIViewController {
    

    // VARIABLES
    var greeting: String = Date.getGreetingbyTime()
    
    private let backgroundImageView = UIImageView()
    
    var cityName: String = "Limassol"
    
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
        let imageView = UIImageView(image: UIImage(named: "test"))
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
    
    private func setupBackground(){
        backgroundImageView.frame = view.bounds
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
    }
    
    private func getBackgroundImageByTime()->String{
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour{
        case 6..<19:
            return "day"
        default:
            return "night"
        }
    }
    
    @objc private func UPDbgImage(){
        let imageName = getBackgroundImageByTime()
        backgroundImageView.image = UIImage(named: imageName)
    }
    
    
    // NETWORK
    func getWeather(){
        print("StartGetWeather")
        let weatherService = WeatherService()
        weatherService.fetscWeather (cityName: cityName){ (weather) in
            guard let unwrappedWeather = weather else { return }
            DispatchQueue.main.async {
                let celcius = Int(unwrappedWeather.main?.temp ?? 0.0) - 273
                let feelsLikeCelcius = Int(unwrappedWeather.main?.feelsLike ?? 0.0) - 273
                self.currentTemperatureLabel.text = "\(celcius) °C"
                self.weatherDescriptionLabel.text = unwrappedWeather.weather?.first?.description.uppercased()
                print("CatchNew")
                let sunriseTime = self.formateDateTime(from: unwrappedWeather.sys?.sunrise ?? 0)
                self.sunriseBlock.updateBottomTitle(sunriseTime)
                let sunsetTime = self.formateDateTime(from: unwrappedWeather.sys?.sunset ?? 0)
                self.sunsetBlock.updateBottomTitle(sunsetTime)
                self.humidity.updateBottomTitle("\(Int(unwrappedWeather.main?.humidity ?? 0))%")
                self.feelLike.updateBottomTitle("\(feelsLikeCelcius) °C")
            }
        }
    }
    
    //CPP
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getWeather()
        setupBackground()
        
        view.backgroundColor = .systemBlue
        view.addSubview(locationNameLabel)
        view.addSubview(greetingMessageLabel)
        view.addSubview(currentWeatherImageView)
        view.addSubview(currentWeatherStackView)
        view.addSubview(sunriseSunsetStackView)
        view.addSubview(feelsLikeHumidityStackView)
        view.addSubview(nextDaysButton)
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
        
    
        NotificationCenter.default.addObserver(
                  self,
                  selector: #selector(UPDbgImage),
                  name: UIApplication.didBecomeActiveNotification,
                  object: nil
              )

        NSLayoutConstraint.activate([
            locationNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            locationNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
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
    deinit {
         NotificationCenter.default.removeObserver(self)
     }
}

