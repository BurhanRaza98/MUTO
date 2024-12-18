//
//  SplashScreenView.swift
//  MUTO
//
//  Created by Burhan Raza on 16/12/24.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var logoOffset: CGFloat = UIScreen.main.bounds.height
    @State private var stars: [StarParticle] = []
    @State private var backgroundLogoOpacity: Double = 0.1
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                Color("BackgroundBlue").edgesIgnoringSafeArea(.all)
                
                // Background App Icon
                Image("AppIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .opacity(0.08)
                
                // Stars
                ForEach(stars) { star in
                    Circle()
                        .fill(Color("AccentBlue"))
                        .frame(width: star.size, height: star.size)
                        .position(star.position)
                        .opacity(star.opacity)
                }
                
                // Main Logo
                VStack {
                    Text("MUTO")
                        .font(.system(size: 80, weight: .black))
                        .foregroundColor(Color("PrimaryBlue"))
                        .tracking(5)
                        .shadow(color: Color("SecondaryBlue").opacity(0.5), radius: 4, x: 0, y: 2)
                }
                .scaleEffect(1.2)
                .offset(y: logoOffset)
            }
            .onAppear {
                // Animate logo from bottom
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    logoOffset = 0
                }
                
                // Create and animate stars
                createStars()
                
                // Transition to main view
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
    
    private func createStars() {
        // Create initial stars
        for _ in 0...30 { // Increased number of stars
            stars.append(StarParticle())
        }
        
        // Animate stars
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            for i in stars.indices {
                withAnimation {
                    stars[i].update()
                }
            }
            
            if isActive {
                timer.invalidate()
            }
        }
    }
}

struct StarParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGPoint
    var size: CGFloat
    var opacity: Double
    
    init() {
        // Start from center of screen
        let screenCenter = CGPoint(
            x: UIScreen.main.bounds.width / 2,
            y: UIScreen.main.bounds.height / 2
        )
        self.position = screenCenter
        
        // Direct stars towards corners
        let corners = [
            CGPoint(x: -1, y: -1),  // Top left
            CGPoint(x: 1, y: -1),   // Top right
            CGPoint(x: -1, y: 1),   // Bottom left
            CGPoint(x: 1, y: 1)     // Bottom right
        ]
        
        let selectedCorner = corners.randomElement()!
        let speed = Double.random(in: 5...10) // Increased speed
        self.velocity = CGPoint(
            x: selectedCorner.x * speed,
            y: selectedCorner.y * speed
        )
        
        self.size = CGFloat.random(in: 4...8) // Increased size
        self.opacity = 1.0
    }
    
    mutating func update() {
        // Update position
        position.x += velocity.x
        position.y += velocity.y
        
        // Fade out as star moves away
        let distance = hypot(
            position.x - UIScreen.main.bounds.width / 2,
            position.y - UIScreen.main.bounds.height / 2
        )
        opacity = max(0, 1 - distance / 400) // Increased visible distance
        
        // Reset star if it's completely faded
        if opacity <= 0 {
            position = CGPoint(
                x: UIScreen.main.bounds.width / 2,
                y: UIScreen.main.bounds.height / 2
            )
            opacity = 1.0
        }
    }
}
