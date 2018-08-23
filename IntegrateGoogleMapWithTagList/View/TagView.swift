//
//  TagView.swift
//  IntegrateGoogleMapWithTagList
//
//  Created by Rahul Chopra on 21/08/18.
//  Copyright © 2018 AppSmall. All rights reserved.
//

import UIKit

protocol DeleteTagView: class {
    func deleteTagView(tagView: TagView)
}

class TagView: UIView {
    
    var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.textColor = UIColor.black
        return label
    }()
    
    var crossButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_cross"), for: .normal)
        button.addTarget(self, action: #selector(crossButtonPressed), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: DeleteTagView?
    var tagViewLeadingConstraint: NSLayoutConstraint?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTagView()
        self.addSubview(label)
        self.addSubview(crossButton)
        label.translatesAutoresizingMaskIntoConstraints = false
        crossButton.translatesAutoresizingMaskIntoConstraints = false
        updateConstraintsOnTagView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTagView() {
        layer.cornerRadius = 8.0
        layer.borderWidth = 1.0
        layer.backgroundColor = UIColor.lightGray.cgColor
        layer.borderColor = UIColor.darkGray.cgColor
        layer.masksToBounds = true
    }
    
    func updateConstraintsOnTagView() {
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        crossButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
        crossButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        crossButton.widthAnchor.constraint(equalTo: crossButton.heightAnchor).isActive = true
        crossButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    @objc func crossButtonPressed() {
        print("Cross Button Pressed")
        
        if let delegate = delegate {
            delegate.deleteTagView(tagView: self)
        }
    }
    
}
