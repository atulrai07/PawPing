//
//  WalkTrackingView.swift
//  PawPing
//
//  Created by Atul on 21/03/26.
//

import SwiftUI
import WebKit

struct WalkTrackingView: View {
    @Environment(\.colorScheme) private var colorScheme
    var store: ActivityStore
    var onDismiss: () -> Void

    private var distanceText: String {
        let d = store.locationManager.totalDistance
        return String(format: "%.2f", d / 1000.0)
    }

    private var timerText: String {
        let total = store.elapsedSeconds
        let hours = Int(total) / 3600
        let mins = (Int(total) % 3600) / 60
        let secs = Int(total) % 60
        return String(format: "%02d:%02d:%02d", hours, mins, secs)
    }

    /// Calories burned using canine locomotion research:
    /// ~1.1 kcal per kg body weight per km at brisk walking pace
    /// Reference: Bryce et al. (2017), Journal of Experimental Biology
    /// "Comparative locomotor costs of domestic dogs reveal energetic economy of wolf-like breeds"
    private var caloriesText: String {
        let km = store.locationManager.totalDistance / 1000.0
        guard km > 0 else { return "0" }
        let weightKg = store.activePet?.weightKg ?? 15.0   // fallback: avg dog weight
        let kcal = 1.1 * weightKg * km
        return String(format: "%.0f", kcal)
    }

    private var progressPercent: Int {
        guard store.walkActivity.goalMinutes > 0 else { return 0 }
        let pct = Double(store.liveWalkedMinutes) / Double(store.walkActivity.goalMinutes) * 100.0
        return min(Int(pct), 100)
    }

    var body: some View {
        let isDark = colorScheme == .dark
        ZStack(alignment: .top) {
            // Background
            (isDark ? Color.black : Color(white: 0.98))
                .ignoresSafeArea()

            // 1. Scrollable Content (Underlapping Top Header)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    // Safe area header spacer - keeps Map Card below navigation icons initially
                    Color.clear.frame(height: 120)
                    
                    // MARK: - Map Card
                    WalkMapView(routeLocations: store.locationManager.routeLocations)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .frame(height: 180)
                        .padding(.horizontal, 20)

                    // MARK: - Active Walk Information Banner Card
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 6) {
                                Text(store.activePet?.name ?? "Tommy")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.textPrimary)
                                Image(systemName: "heart")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.homePurple)
                            }
                            
                            Text(timerText)
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                                .foregroundColor(.homePurple)
                                .monospacedDigit()
                        }
                        
                        Spacer()
                        
                        // Dedicated WalkLottieWebView that does not conflict with CountdownView's preloader
                        WalkLottieWebView(isPaused: store.isPaused)
                            .frame(width: 100, height: 100)
                            .background(Color.clear)
                            .offset(y: 6)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(LinearGradient(
                                colors: [
                                    Color.homePurple.opacity(isDark ? 0.12 : 0.06),
                                    Color.homePurple.opacity(isDark ? 0.04 : 0.02)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                    )
                    .padding(.horizontal, 20)

                    // MARK: - Unified Goal & Distance Stat Card
                    HStack(spacing: 0) {
                        // Distance Section
                        VStack(alignment: .leading, spacing: 4) {
                            Text("DISTANCE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.textSecondary)
                                .tracking(0.5)
                            
                            HStack(alignment: .lastTextBaseline, spacing: 4) {
                                Text(distanceText)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.textPrimary)
                                Text("km")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Vertical Divider
                        Rectangle()
                            .fill(Color.gray.opacity(0.12))
                            .frame(width: 1, height: 36)
                            .padding(.horizontal, 16)
                        
                        // Goal Section
                        VStack(alignment: .leading, spacing: 4) {
                            Text("GOAL PROGRESS")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.textSecondary)
                                .tracking(0.5)
                            
                            HStack(alignment: .lastTextBaseline, spacing: 4) {
                                Text("\(progressPercent)%")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.homePurple)
                                Text("/ \(store.walkActivity.goalMinutes) min")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(20)
                    .background(Color.cardIvory)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)

                    // MARK: - Time Remaining Card (Without Chevron)
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.homePurple.opacity(0.12))
                                .frame(width: 36, height: 36)
                            Image(systemName: "shoeprints.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.homePurple)
                        }
                        
                        let remainingMins = max(0, store.walkActivity.goalMinutes - store.liveWalkedMinutes)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(remainingMins) min remaining")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.textPrimary)
                            Text("You're on track to reach your goal!")
                                .font(.system(size: 11))
                                .foregroundColor(.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isDark ? Color(white: 0.15) : Color.homePurple.opacity(0.04))
                    )
                    .padding(.horizontal, 20)
                    
                    // Bottom Controls space - prevents scrolling items from staying covered
                    Color.clear.frame(height: 140)
                }
                .padding(.vertical, 8)
            }
            .layoutPriority(1)
            .clipped()
            .ignoresSafeArea(edges: .top)

            // 2. Fixed Header Toolbar (Transparent Backdrop overlay)
            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(isDark ? Color(white: 0.16) : .white)
                            .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
                    )
                    .contentShape(Circle())
                    .onTapGesture {
                        onDismiss()
                    }
                
                Spacer()
                
                Text("Walk")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Color.clear
                    .frame(width: 36, height: 36)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .background(
                LinearGradient(
                    colors: [
                        (isDark ? Color.black : Color(white: 0.98)),
                        (isDark ? Color.black : Color(white: 0.98)).opacity(0.8),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea(edges: .top)
            )

            // 3. Fixed Controls Panel (Aligned Bottom Card overlay)
            VStack {
                Spacer()
                HStack(spacing: 0) {
                    // Lock Control
                    VStack(spacing: 6) {
                        Button {
                            // Lock action trigger
                        } label: {
                            Circle()
                                .fill(isDark ? Color(white: 0.18) : .white)
                                .frame(width: 54, height: 54)
                                .shadow(color: .black.opacity(0.06), radius: 4)
                                .overlay(
                                    Image(systemName: "lock")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.homePurple)
                                )
                        }
                        .buttonStyle(.plain)
                        
                        Text("Lock")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Play / Pause Control
                    VStack(spacing: 6) {
                        Button {
                            store.togglePause()
                        } label: {
                            Circle()
                                .fill(LinearGradient(colors: [Color.homePurple, Color.homePurple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 80, height: 80)
                                .shadow(color: Color.homePurple.opacity(0.3), radius: 8, x: 0, y: 4)
                                .overlay(
                                    Image(systemName: store.isPaused ? "play.fill" : "pause.fill")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                        .buttonStyle(.plain)
                        
                        Text(store.isPaused ? "Resume" : "Pause")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Stop Control
                    VStack(spacing: 6) {
                        Button {
                            store.stopWalk()
                            onDismiss()
                        } label: {
                            Circle()
                                .fill(isDark ? Color(white: 0.18) : .white)
                                .frame(width: 54, height: 54)
                                .shadow(color: .black.opacity(0.06), radius: 4)
                                .overlay(
                                    Image(systemName: "stop.fill")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color.red.opacity(0.8))
                                )
                        }
                        .buttonStyle(.plain)
                        
                        Text("Stop")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(isDark ? Color(white: 0.12) : Color.homePurple.opacity(0.04))
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

// MARK: - Subviews

struct TrackingStatCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let iconName: String
    let iconColor: Color
    let title: String
    let value: String
    let unit: String
    var customProgressView: AnyView? = nil
    
    var body: some View {
        let isDark = colorScheme == .dark
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: iconName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.textSecondary)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.textPrimary)
            
            if let customProgressView = customProgressView {
                customProgressView
            } else {
                Text(unit)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isDark ? Color(white: 0.13) : Color.cardIvory)
                .shadow(color: .black.opacity(isDark ? 0.15 : 0.03), radius: 6, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isDark ? Color(white: 0.2) : Color.textPrimary.opacity(0.05), lineWidth: 1)
        )
    }
}

#Preview {
    WalkTrackingView(store: ActivityStore(), onDismiss: {})
}

// MARK: - WalkLottieWebView
//
// A dedicated WKWebView wrapper that loads the "Purple dog walking" animation
// and controls play/pause state based on whether the walk activity is paused.
// This prevents sharing instance conflicts with CountdownView's preloader.
struct WalkLottieWebView: UIViewRepresentable {
    var isPaused: Bool

    func makeUIView(context: Context) -> WKWebView {
        let cfg = WKWebViewConfiguration()
        cfg.allowsInlineMediaPlayback = true
        cfg.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: cfg)
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false

        if let lottieURL = Bundle.main.url(forResource: "lottie_light.min", withExtension: "js"),
           let jsonURL   = Bundle.main.url(forResource: "Purple dog walking",  withExtension: "json"),
           let lottieJS  = try? String(contentsOf: lottieURL, encoding: .utf8),
           let jsonStr   = try? String(contentsOf: jsonURL,   encoding: .utf8) {
            
            let html = """
            <!DOCTYPE html>
            <html>
            <head>
            <meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1">
            <style>
              *{margin:0;padding:0;box-sizing:border-box}
              html,body{width:100%;height:100%;background:transparent;overflow:hidden}
              #c{width:100%;height:100%}
            </style>
            </head>
            <body>
              <div id="c"></div>
              <script>\(lottieJS)</script>
              <script>
                var anim = lottie.loadAnimation({
                  container: document.getElementById('c'),
                  renderer: 'svg',
                  loop: true,
                  autoplay: \(isPaused ? "false" : "true"),
                  animationData: \(jsonStr)
                });
              </script>
            </body>
            </html>
            """
            webView.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
        }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let js = isPaused ? "if(typeof anim !== 'undefined') { anim.pause(); }" : "if(typeof anim !== 'undefined') { anim.play(); }"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
}

