import UIKit

class WeeklyScreenController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    var cityNameForecast: String?
    var latitude: Double?
    var longitude: Double?
    
    private var dailyForecasts: [ForecastItem] = []
    
    
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.Black(size: 28)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let forecastTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(ForecastCell.self, forCellReuseIdentifier: ForecastCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateBackground()
        
        cityLabel.text = cityNameForecast
        forecastTableView.dataSource = self
        forecastTableView.delegate = self
        
        fetchForecast()
    }
    
    private func fetchForecast() {
        guard let lat = latitude, let lon = longitude else {
            return
        }
        
        WeatherService().fetchForecast(latitude: lat, longitude: lon) { [weak self] result in
            switch result {
            case .success(let forecastResponse):
                self?.dailyForecasts = self?.processForecast(list: forecastResponse.list) ?? []
                self?.forecastTableView.reloadData()
            case .failure(let error):
                print("Errror \(error)")
            }
        }
    }
    
    private func processForecast(list: [ForecastItem]) -> [ForecastItem] {
        var dailyData: [ForecastItem] = []
        var uniqueDays: Set<Int> = []
        let calendar = Calendar.current
        
        for item in list {
            let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
            let day = calendar.component(.day, from: date)
            
            if !uniqueDays.contains(day) {
                dailyData.append(item)
                uniqueDays.insert(day)
            }
        }
        return dailyData
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyForecasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ForecastCell.identifier, for: indexPath) as? ForecastCell else {
            return UITableViewCell()
        }
        let forecastItem = dailyForecasts[indexPath.row]
        cell.configure(with: forecastItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    private func setupUI() {
        view.addSubview(cityLabel)
        view.addSubview(forecastTableView)
        
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        forecastTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cityLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cityLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cityLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            forecastTableView.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 20),
            forecastTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            forecastTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            forecastTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func updateBackground() {
        let hour = Calendar.current.component(.hour, from: Date())
        let isDay = (6..<19).contains(hour)
        let topColor = isDay ? UIColor(red: 102/255.0, green: 178/255.0, blue: 255/255.0, alpha: 1.0).cgColor : UIColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 1.0).cgColor
        let bottomColor = isDay ? UIColor(red: 178/255.0, green: 216/255.0, blue: 255/255.0, alpha: 1.0).cgColor : UIColor(red: 0.3, green: 0.5, blue: 0.7, alpha: 1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
}


class ForecastCell: UITableViewCell {
    static let identifier = "ForecastCell"
    
    private let dayLabel = UILabel()
    private let tempLabel = UILabel()
    private let weatherIcon = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .clear
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        contentView.layer.cornerRadius = 10
        
        dayLabel.font = UIFont.regular(size: 30)
        dayLabel.textColor = .white
        
        tempLabel.font = UIFont.Black(size: 30)
        tempLabel.textColor = .white
        tempLabel.textAlignment = .right
        
        weatherIcon.contentMode = .scaleAspectFit
        
        let stackView = UIStackView(arrangedSubviews: [dayLabel, weatherIcon, tempLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: 60),
            
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            weatherIcon.widthAnchor.constraint(equalToConstant: 40),
            weatherIcon.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configure(with item: ForecastItem) {
        tempLabel.text = "\(Int(item.main.temp - 273.15))°C"
        dayLabel.text = formatDate(from: item.dt)
        if let weatherCode = item.weather.first?.id {
             weatherIcon.image = UIImage(named: getWeatherIconName(from: weatherCode))
        }
    }
    
    private func formatDate(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            return "Today"
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date).capitalized
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
}
