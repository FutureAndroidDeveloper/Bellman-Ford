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
    private let annotationFrame = CGRect(x: 0, y: 0, width: 40, height: 40)
    private let label: UILabel

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        self.label = UILabel(frame: annotationFrame.offsetBy(dx: 0, dy: -6))
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.frame = annotationFrame
        self.label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        self.label.textColor = .white
        self.label.textAlignment = .center
        self.backgroundColor = .clear
        self.addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented!")
    }

    public var number: Int = 0 {
        didSet {
            self.label.text = String(number)
        }
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.beginPath()
        context.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        context.closePath()

        UIColor.blue.set()
        context.fillPath()
    }

}
