
import UIKit

class MainScreenViewController: UIViewController {
    

    var cityName: String = "Limassol"
    
    var currentDateTime = Date.dateFormatter()
    // VARIABLES
    var greeting = GreetingsMessage(greeting:.day)
    
    lazy var locationNameLabel = UILabel.createLabel(textAlingment: .left, fintSize: 15, fontWeight: .light, text: cityName)
    
    lazy var greetingMessageLabel = UILabel.createLabel(textAlingment: .left,fintSize: 25, fontWeight: .bold, text: greeting.text)
    
    lazy var currentTemperatureLabel = UILabel.createLabel(textAlingment: .center, fintSize: 50, fontWeight: .black, text: "21°C")
    
    lazy var weatherDescriptionLabel = UILabel.createLabel(textAlingment: .center, fintSize: 30, fontWeight: .light, text: "SUNNY")
    
    lazy var currentDateTimeLabel = UILabel.createLabel(textAlingment: .center, fintSize: 20, fontWeight: .light, text: currentDateTime)
    
    lazy var sunriseBlock = UIStackView.createBlock(imageName: "sunrise", topTitle: "Sunrise", bottomTitle: "9:21")
    
    lazy var sunsetBlock = UIStackView.createBlock(imageName: "sunset", topTitle: "Sunset", bottomTitle: "20:11")
    
    lazy var nextDaysButton = UIButton.createNextButton(selector: #selector (goToWeeklyScreen))
    
    
    lazy var sunriseSunsetStackView: UIStackView = {
        let ssSV = UIStackView(arrangedSubviews: [sunriseBlock, sunsetBlock])
        ssSV.axis = .horizontal
        ssSV.spacing = 50
        ssSV.translatesAutoresizingMaskIntoConstraints = false
        return ssSV
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
        print("WeeklyScreenController")
        let weeklyScreen = WeeklyScreenController()
        navigationController?.pushViewController(weeklyScreen, animated: true)
    }
    
    func getWeather(){
        print("StartGetWeather")
        let weatherService = WeatherService()
        weatherService.fetscWeather (cityName: cityName){ (weather) in
            guard let unwrappedWeather = weather else { return }
            
            DispatchQueue.main.async {
                let celcius = Int(unwrappedWeather.main?.temp ?? 0.0) - 273
                self.currentTemperatureLabel.text = "\(celcius) °C"
                self.weatherDescriptionLabel.text = unwrappedWeather.weather?.first?.description.uppercased()
                print("CatchNew")
                let sunriseTime = self.formateDateTime(from: unwrappedWeather.sys?.sunrise ?? 0)
                self.sunriseBlock.updateBottomTitle(sunriseTime)
                let sunsetTime = self.formateDateTime(from: unwrappedWeather.sys?.sunset ?? 0)
                self.sunsetBlock.updateBottomTitle(sunsetTime)
               
            }
        }
      
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getWeather()
        //navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemBlue
        view.addSubview(locationNameLabel)
        view.addSubview(greetingMessageLabel)
        view.addSubview(currentWeatherImageView)
        view.addSubview(currentWeatherStackView)
        view.addSubview(sunriseSunsetStackView)
        view.addSubview(nextDaysButton)
    
        
        
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
    
            
        ])
        
    }
}

