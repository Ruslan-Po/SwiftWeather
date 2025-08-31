import UIKit

extension UIStackView{
    static func createBlock(imageName: String, topTitle:String, bottomTitle: String) -> UIStackView{
        
        let ImageView = UIImageView(image:  UIImage(named: imageName))
        ImageView.contentMode = .scaleAspectFit
        ImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        ImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let topLabel = UILabel()
        topLabel.text = topTitle
        topLabel.font = .systemFont(ofSize: 16, weight: .bold)
        topLabel.textColor = .white
        
        let bottomLabel = UILabel()
        bottomLabel.text = bottomTitle
        bottomLabel.font = .systemFont(ofSize: 14)
        bottomLabel.textColor = .white
        bottomLabel.tag = 101 
            
        let titleStack = UIStackView(arrangedSubviews: [topLabel, bottomLabel])
        titleStack.axis = .vertical
        titleStack.spacing = 2
        titleStack.alignment = .leading
        
        let blockStack = UIStackView(arrangedSubviews: [ImageView, titleStack])
        blockStack.axis = .horizontal
        blockStack.spacing = 8
        blockStack.alignment = .center
        return blockStack
        }
    func updateBottomTitle(_ newText: String) {
           // Ищем внутри stack view метку с тегом 101
           if let bottomLabel = self.viewWithTag(101) as? UILabel {
               // Если нашли, обновляем её текст
               bottomLabel.text = newText
           }
       }
}

extension UILabel{
    static func createLabel(textAlingment: NSTextAlignment,fintSize: CGFloat, fontWeight: UIFont.Weight,text: String) -> UILabel {
       let label = UILabel()
       label.textColor = .white
       label.text = text
       label.textAlignment = .left
       label.font = .systemFont(ofSize: fintSize, weight: .bold)
       label.translatesAutoresizingMaskIntoConstraints = false
       return label
   }
}


extension UIButton{
    static func createNextButton (selector: Selector) -> UIButton {
        var config = UIButton.Configuration.plain()
         config.title = "Next Days"
         config.image = UIImage(systemName: "chevron.right")
         config.imagePlacement = .trailing
         config.imagePadding = 8 
         config.baseForegroundColor = .white
         let button = UIButton(configuration: config, primaryAction: nil)
        
         button.addTarget(target, action: selector, for: .touchUpInside)
         button.translatesAutoresizingMaskIntoConstraints = false
         return button
    }
}

extension Date{
    static func dateFormatter() -> String {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        let localDateString = formatter.string(from: currentDateTime)
        return localDateString
    }
}
