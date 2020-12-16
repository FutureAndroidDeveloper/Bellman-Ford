//
//  ViewDelegate.swift
//  MapViewTest
//
//  Created by Кирилл Клименков on 12/7/20.
//  Copyright © 2020 Kirill Klimenkov. All rights reserved.
//

import UIKit

protocol ViewDelegate: class {
    func didGetNewVertix(_ vertix: MapVertix)
    func didGetNewEdge(_ edge: MapEdge)
    func didChangeEdgeColor(_ color: UIColor)
}
