//
//  CustomAnnotationView.swift
//  MapViewTest
//
//  Created by Klimenkov, Kirill on 16.11.2020.
//  Copyright © 2020 Kirill Klimenkov. All rights reserved.
//

import UIKit
import MapKit

class CustomAnnotationView: MKAnnotationView {
    private let annotationFrame = CGRect(x: 0, y: 0, width: 30, height: 30)
    private let label: UILabel
    
    public var color: UIColor = .blue {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var number: Int = 0 {
        didSet {
            self.label.text = String(number)
        }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        self.label = UILabel(frame: annotationFrame)
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.frame = annotationFrame
        let fontSize = annotationFrame.width / 2
        self.label.font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        self.label.textColor = .white
        self.label.textAlignment = .center
        self.backgroundColor = .clear
        self.addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented!")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.addEllipse(in: rect)
        context.drawPath(using: .fill)
    }
}
