//
//  MovableEntity.swift
//  HelloAR
//
//  Created by Mohammad Azam on 5/8/22.
//

import UIKit
import RealityKit

enum Shape {
    case box
    case sphere
}

class MovableEntity: Entity, HasModel, HasPhysics, HasCollision {
    
    var size: Float!
    var color: UIColor!
    var shape: Shape = .box
    
    init(size: Float, color: UIColor, shape: Shape) {
        
        super.init()
        self.size = size
        self.color = color
        self.shape = shape
        
        let mesh = generateMeshResource()
        let materials = [generateMaterial()]
        model = ModelComponent(mesh: mesh, materials: materials)
        
        physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .dynamic)
        collision = CollisionComponent(shapes: [generateShapeResource()], mode: .trigger, filter: .sensor)
        generateCollisionShapes(recursive: true)
    }
    
    private func generateShapeResource() -> ShapeResource {
        switch shape {
            case .box:
                return ShapeResource.generateBox(size: [self.size, self.size, self.size])
            case .sphere:
                return ShapeResource.generateSphere(radius: self.size)
        }
    }
    
    private func generateMaterial() -> Material {
        SimpleMaterial(color: color, isMetallic: true)
    }
    
    private func generateMeshResource() -> MeshResource {
        switch shape {
            case .box:
                return MeshResource.generateBox(size: size)
            case .sphere:
                return MeshResource.generateSphere(radius: size)
        }
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
}
