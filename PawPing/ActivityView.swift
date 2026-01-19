//
//  ActivityView.swift
//  PawPing
//
//  Created by Atul on 19/01/26.
//

import SwiftUI

// MARK: - Main View
struct ActivityView: View {
    // Custom Color roughly matching the image
    let appRed = Color(red: 220/255, green: 50/255, blue: 60/255)
    let bgGray = Color(red: 245/255, green: 246/255, blue: 250/255)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            bgGray.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // 1. Header
                    HeaderView()
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    // 2. Main Activity Card
                    ActivityCard(appRed: appRed)
                        .padding(.horizontal)
                    
                    // 3. Grid Row (Upcoming & Meals)
                    HStack(alignment: .top, spacing: 15) {
                        UpcomingCard(appRed: appRed)
                        MealsCard(appRed: appRed)
                    }
                    .padding(.horizontal)
                    
                    // 4. Allergies
                    AllergiesCard(appRed: appRed)
                        .padding(.horizontal)
                    
                    // 5. Time Walked Graph
                    WalkGraphCard(appRed: appRed)
                        .padding(.horizontal)
                    
                    // Spacer for TabBar
                    Spacer().frame(height: 100)
                }
            }
            
            // 6. Custom Tab Bar
        }
    }
}

// MARK: - 1. Header View
struct HeaderView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Hello, Buddy")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "CE363F")) // Dark red text
                Text("Labrador • M • 2 Years")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
            }
            Spacer()
            // Placeholder for the dog image
            Image(systemName: "photo.circle.fill") // Replace with actual image
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 3)
        }
    }
}

// MARK: - 2. Activity Card
struct ActivityCard: View {
    let appRed: Color
    
    var body: some View {
        HStack(spacing: 20) {
            // Circular Progress
            ZStack {
                Circle()
                    .stroke(appRed.opacity(0.2), lineWidth: 25)
                
                Circle()
                    .trim(from: 0, to: 0.38) // 23/60 roughly
                    .stroke(appRed, style: StrokeStyle(lineWidth: 25, lineCap: .round))
                    .rotationEffect(.degrees(90)) // Start point adjustment
            }
            .frame(width: 140, height: 140)
            .padding(.leading, 10)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Walked")
                    .font(.headline)
                    .foregroundColor(appRed)
                
                HStack(alignment: .bottom, spacing: 2) {
                    Text("23")
                        .font(.system(size: 34, weight: .bold))
                    Text("/60min")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 4)
                }
                
                Button(action: {}) {
                    Text("START")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(appRed)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(appRed, lineWidth: 1)
                        )
                }
            }
            Spacer()
        }
        .padding(25)
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - 3. Upcoming & Meals Cards
struct UpcomingCard: View {
    let appRed: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Upcoming")
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right.circle.fill")
                    .foregroundColor(Color.gray.opacity(0.3))
            }
            
            Image(systemName: "syringe.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundColor(appRed)
                .rotationEffect(.degrees(-45))
                .padding(.vertical, 10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Rabies Booster")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text("3 Days Left")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct MealsCard: View {
    let appRed: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Meals")
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right.circle.fill")
                    .foregroundColor(Color.gray.opacity(0.3))
            }
            
            HStack(spacing: 12) {
                MealItem(icon: "sun.max.fill", time: "8:00AM", isSelected: true, appRed: appRed)
                MealItem(icon: "sun.haze.fill", time: "12:30PM", isSelected: false, appRed: appRed)
                MealItem(icon: "moon.fill", time: "8:00PM", isSelected: false, appRed: appRed)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct MealItem: View {
    let icon: String
    let time: String
    let isSelected: Bool
    let appRed: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isSelected ? appRed : appRed.opacity(0.8))
                    .frame(width: 35, height: 35)
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }
            
            Text(time)
                .font(.system(size: 8))
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Image(systemName: isSelected ? "checkmark.circle" : "circle")
                .foregroundColor(isSelected ? .black : .black)
                .font(.system(size: 16))
        }
    }
}

// MARK: - 4. Allergies Card
struct AllergiesCard: View {
    let appRed: Color
    let items = ["Gluten", "Lactose", "Wheat"]
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                Image(systemName: "cross.case.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(appRed)
                    .overlay(
                        Image(systemName: "pawprint.fill")
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundColor(.white)
                            .offset(x: 4, y: 4)
                    )
            }
            .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Allergies")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right.circle.fill")
                        .foregroundColor(Color.gray.opacity(0.3))
                }
                
                HStack {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.leading, 10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - 5. Graph Card
struct WalkGraphCard: View {
    let appRed: Color
    let days = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Time Walked")
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right.circle.fill")
                    .foregroundColor(Color.gray.opacity(0.3))
            }
            .padding(.bottom, 20)
            
            ZStack {
                // Graph content
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(0..<days.count, id: \.self) { index in
                        VStack {
                            Spacer()
                            // Just a clear placeholder to align the labels at bottom
                            Text(days[index])
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                                .padding(.top, 10)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 120)
                
                // The Line Shape
                LineGraphShape()
                    .fill(
                        LinearGradient(gradient: Gradient(colors: [appRed.opacity(0.4), appRed.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
                    )
                    .frame(height: 80)
                    .offset(y: 5)
                    .overlay(
                        LineGraphShape()
                            .stroke(appRed, lineWidth: 3)
                            .frame(height: 80)
                            .offset(y: 5)
                    )
                
                // Dotted Line
                VStack {
                    Spacer()
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: 350, y: 0))
                    }
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [2]))
                    .foregroundColor(.gray)
                    .frame(height: 1)
                    .offset(y: -40) // Adjust height to match visual
                }
                .frame(height: 120)

                // White Circles on points
                GeometryReader { geo in
                    let width = geo.size.width
                    let step = width / 7
                    let halfStep = step / 2
                    
                    // Manually placing points to match the curve shape
                    CirclePoint(x: halfStep, y: 110)
                    CirclePoint(x: halfStep + step, y: 80, stroke: true)
                    CirclePoint(x: halfStep + (step*2), y: 85)
                    CirclePoint(x: halfStep + (step*3), y: 40)
                    CirclePoint(x: halfStep + (step*4), y: 50, stroke: true) // Current day
                }
                .frame(height: 120)
                
                // "60 min" Label
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Text("60 min")
                            .font(.system(size: 9))
                            .offset(y: -38)
                    }
                }
                .frame(height: 120)

            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    @ViewBuilder
    func CirclePoint(x: CGFloat, y: CGFloat, stroke: Bool = false) -> some View {
        Circle()
            .fill(Color.white)
            .frame(width: 8, height: 8)
            .overlay(Circle().stroke(Color.black, lineWidth: 1))
            .position(x: x, y: y)
    }
}

// Simple hardcoded Bezier curve to match the image
struct LineGraphShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let step = width / 7
        let halfStep = step / 2
        
        // Coordinates normalized to frame
        let p1 = CGPoint(x: halfStep, y: height)
        let p2 = CGPoint(x: halfStep + step, y: height * 0.4)
        let p3 = CGPoint(x: halfStep + (step * 2), y: height * 0.6)
        let p4 = CGPoint(x: halfStep + (step * 3), y: 0)
        let p5 = CGPoint(x: halfStep + (step * 4), y: height * 0.2)
        let p6 = CGPoint(x: halfStep + (step * 5), y: height * 0.2) // Extension
        
        path.move(to: p1)
        path.addCurve(to: p2, control1: CGPoint(x: p1.x + 20, y: p1.y), control2: CGPoint(x: p2.x - 20, y: p2.y))
        path.addCurve(to: p3, control1: CGPoint(x: p2.x + 20, y: p2.y), control2: CGPoint(x: p3.x - 20, y: p3.y))
        path.addCurve(to: p4, control1: CGPoint(x: p3.x + 20, y: p3.y), control2: CGPoint(x: p4.x - 20, y: p4.y))
        path.addCurve(to: p5, control1: CGPoint(x: p4.x + 20, y: p4.y), control2: CGPoint(x: p5.x - 20, y: p5.y))
        
        // Line extend to bottom for fill
        path.addLine(to: CGPoint(x: p5.x, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        
        return path
    }
}

// MARK: - 6. Custom Tab Bar

// Helper for hex colors if needed
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

struct PetHealthDashboard_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView()
    }
}
#Preview {
    ActivityView()
}
