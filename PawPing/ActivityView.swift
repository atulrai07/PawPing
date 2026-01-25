//
//  ActivityView.swift
//  PawPing
//
//  Created by Atul on 19/01/26.
//

import SwiftUI

// MARK: - Main View
struct ActivityView: View {
    var body: some View {
        ZStack {
            // Background Color
            Color(hex: "F2F2F7")
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // 1. Header Section
                    HeaderView()
                    
                    // 2. Activity/Walk Card
                    WalkActivityCard()
                    
                    // 3. Middle Row (Upcoming & Meals)
                    HStack(spacing: 15) {
                        UpcomingCard()
                        MealsCard()
                    }
                    
                    // 4. Allergies Card
                    AllergiesCard()
                    
                    // 5. Time Walked Graph
                    TimeWalkedGraphCard()
                    
                    // Bottom spacing since we ignored the tab bar
                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
    }
}

// MARK: - 1. Header View
struct HeaderView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello, Buddy")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "D93838")) // Theme Red
                
                Text("Labrador • M • 2 Years")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Profile Image Placeholder
            Image(systemName: "dog.fill") // Using SF Symbol as placeholder
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .padding(12)
                .background(Color(hex: "D6C0B0"))
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 2)
                )
                .shadow(radius: 3)
        }
    }
}

// MARK: - 2. Walk Activity Card
struct WalkActivityCard: View {
    var body: some View {
        HStack(spacing: 20) {
            // Circular Progress
            ZStack {
                Circle()
                    .stroke(Color(hex: "E0E0E0"), lineWidth: 20)
                
                Circle()
                    .stroke(Color(hex: "EF9A9A").opacity(0.3), lineWidth: 20)
                
                Circle()
                    .trim(from: 0, to: 0.38) // 23/60 approx
                    .stroke(
                        Color(hex: "D93838"),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 120, height: 120)
            
            // Text Content
            VStack(alignment: .leading, spacing: 8) {
                Text("Walked")
                    .font(.headline)
                    .foregroundColor(Color(hex: "D93838"))
                
                Text("23/60min")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                
                Button(action: {}) {
                    Text("START")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "D93838"))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(hex: "D93838"), lineWidth: 1)
                        )
                }
            }
            Spacer()
        }
        .padding(25)
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - 3. Upcoming Card
struct UpcomingCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Upcoming")
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Color(hex: "D93838"))
                    .padding(6)
                    .background(Color(hex: "FCE4E4"))
                    .clipShape(Circle())
            }
            
            Image(systemName: "syringe.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(Color(hex: "D93838"))
                .rotationEffect(.degrees(-45))
                .padding(.vertical, 10)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Rabies Booster")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text("3 Days Left")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - 4. Meals Card
struct MealsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Meals")
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Color(hex: "D93838"))
                    .padding(6)
                    .background(Color(hex: "FCE4E4"))
                    .clipShape(Circle())
            }
            
            HStack(spacing: 12) {
                // Morning (Active)
                MealItem(icon: "sun.max.fill", time: "8:00 AM", status: "checkmark", isActive: true)
                // Afternoon
                MealItem(icon: "sun.haze.fill", time: "12:30 PM", status: "circle", isActive: false)
                // Evening
                MealItem(icon: "moon.fill", time: "8:00 PM", status: "circle", isActive: false)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct MealItem: View {
    let icon: String
    let time: String
    let status: String
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isActive ? Color(hex: "D93838") : Color(hex: "F2F2F7"))
                    .frame(width: 35, height: 35)
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(isActive ? .white : .gray)
            }
            
            Text(time)
                .font(.system(size: 8))
                .foregroundColor(.gray)
            
            Image(systemName: status)
                .font(.caption)
                .foregroundColor(isActive ? .black : .gray)
        }
    }
}

// MARK: - 5. Allergies Card
struct AllergiesCard: View {
    var body: some View {
        HStack {
            // Icon Box
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(hex: "FCE4E4"))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "cross.case.fill") // Approximating the medical cross
                    .font(.title2)
                    .foregroundColor(Color(hex: "D93838"))
                
                Image(systemName: "pawprint.fill")
                    .font(.caption2)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Allergies")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(Color(hex: "D93838"))
                        .padding(6)
                        .background(Color(hex: "FCE4E4"))
                        .clipShape(Circle())
                }
                
                HStack {
                    TagView(text: "Gluten")
                    TagView(text: "Lactose")
                    TagView(text: "Wheat")
                }
            }
            .padding(.leading, 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct TagView: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - 6. Graph Card (Custom Shape)
struct TimeWalkedGraphCard: View {
    let days = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Time Walked")
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Color(hex: "D93838"))
                    .padding(6)
                    .background(Color(hex: "FCE4E4"))
                    .clipShape(Circle())
            }
            .padding(.bottom, 10)
            
            ZStack {
                // The Graph Drawing
                GraphShape()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "D93838").opacity(0.4), Color(hex: "D93838").opacity(0.0)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 100)
                
                // The Line on top
                GraphShape()
                    .stroke(Color(hex: "D93838"), lineWidth: 2)
                    .frame(height: 100)
                
                // Dotted Target Line
                VStack {
                    Divider()
                        .frame(height: 1)
                        .overlay(Color.gray.opacity(0.5))
                    Spacer()
                }
                .padding(.top, 30) // Position roughly where 60min is
                
                // Graph Points (Simulated positions)
                HStack(spacing: 0) {
                    ForEach(0..<7) { i in
                        VStack {
                            Spacer()
                            // This creates the day labels at bottom
                            Text(days[i])
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(i == 4 ? .white : .gray) // FRI highlighted
                                .padding(.vertical, 2)
                                .padding(.horizontal, 4)
                                .background(i == 4 ? Color(hex: "D93838") : Color.clear)
                                .cornerRadius(4)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(height: 120)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// Simple Bezier curve shape to mimic the image
struct GraphShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Starting point (bottom left)
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: 0, y: height))
        
        // Example points to mimic the curve in image
        // (Normalized coordinates 0..1 mapped to width/height)
        let points: [CGPoint] = [
            CGPoint(x: 0, y: height * 0.9),
            CGPoint(x: width * 0.16, y: height * 0.9),
            CGPoint(x: width * 0.33, y: height * 0.5), // Peak 1
            CGPoint(x: width * 0.5, y: height * 0.8),  // Dip
            CGPoint(x: width * 0.66, y: height * 0.3), // Peak 2 (Highest)
            CGPoint(x: width * 0.83, y: height * 0.4),
            CGPoint(x: width, y: height * 0.4)
        ]
        
        // Draw lines/curves
        path.addLine(to: points[0])
        
        // Simple curve approximation
        for i in 1..<points.count {
            path.addQuadCurve(to: points[i], control: CGPoint(x: (points[i-1].x + points[i].x)/2, y: points[i-1].y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Helper for Hex Colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Preview Provider
struct PetDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView()
    }
}
