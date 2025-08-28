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
}

