
import UIKit

class MainScreenViewController: UIViewController {
    
    // VARIABLES
    var greeting = GreetingsMessage(greeting:.day)
    
    lazy var locationNameLabel = createLabel(textAlingment: .left, fintSize: 15, fontWeight: .light, text: "Melburne")
    
    lazy var greetingMessageLabel = createLabel(textAlingment: .left,fintSize: 25, fontWeight: .bold, text: greeting.text)
    
    lazy var currentTemperatureLabel = createLabel(textAlingment: .center, fintSize: 50, fontWeight: .black, text: "21°C")
    
    lazy var weatherDescriptionLabel = createLabel(textAlingment: .center, fintSize: 30, fontWeight: .light, text: "SUNNY")
    
    lazy var currentDateTimeLabel = createLabel(textAlingment: .center, fintSize: 20, fontWeight: .light, text: "Sunday 13 - 15:00")
    
    lazy var sunriseBlock = UIStackView.createBlock(imageName: "sunrise", topTitle: "Sunrise", bottomTitle: "9:21")
    
    lazy var sunsetBlock = UIStackView.createBlock(imageName: "sunset", topTitle: "Sunset", bottomTitle: "20:11")
    
    
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
    
    lazy var nextDaysButton: UIButton = {
        var config = UIButton.Configuration.plain()
         config.title = "Next Days"
         config.image = UIImage(systemName: "chevron.right")
         config.imagePlacement = .trailing   // иконка после текста
         config.imagePadding = 8 // отступ между текстом и иконкой
         config.baseForegroundColor = .white
         let button = UIButton(configuration: config, primaryAction: nil)
        
         button.addTarget(self, action: #selector(goToWeeklyScreen), for: .touchUpInside)
         button.translatesAutoresizingMaskIntoConstraints = false
         return button
    }()
    
    //FUNCTIONS
    private func createLabel(textAlingment: NSTextAlignment,fintSize: CGFloat, fontWeight: UIFont.Weight,text: String) -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.text = text
        label.textAlignment = .left
        label.font = .systemFont(ofSize: fintSize, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    @objc func goToWeeklyScreen () {
        let weeklyScreen = WeeklyScreenController()
        navigationController?.pushViewController(weeklyScreen, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

