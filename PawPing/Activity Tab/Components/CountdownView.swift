//
//  CountdownView.swift
//  PawPing
//
//  Created by Atul on 21/03/26.
//

import SwiftUI
import WebKit
import Combine

// MARK: - Lottie Preloader (Singleton)
//
// Creates and loads the WKWebView once — as early as possible — so that by
// the time CountdownView appears, the WebKit process is already running,
// lottie_light.min.js is already parsed, and the first animation frame is
// already rendered. The view is then handed directly to LottieWebView with
// zero additional startup cost.

final class LottiePreloader: NSObject, WKNavigationDelegate {

    static let shared = LottiePreloader()

    private(set) var webView: WKWebView
    private var isLoaded = false

    private override init() {
        let cfg = WKWebViewConfiguration()
        cfg.allowsInlineMediaPlayback = true
        cfg.mediaTypesRequiringUserActionForPlayback = []

        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 300, height: 300), configuration: cfg)
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false

        super.init()
        webView.navigationDelegate = self
        loadHTML()
    }

    /// Call this from ActivityView.onAppear — no-op if already warmed up.
    func warmUp() { /* Singleton init() handles everything. */ }

    private func loadHTML() {
        guard
            let lottieURL = Bundle.main.url(forResource: "lottie_light.min", withExtension: "js"),
            let jsonURL   = Bundle.main.url(forResource: "Purple dog walking",  withExtension: "json"),
            let lottieJS  = try? String(contentsOf: lottieURL, encoding: .utf8),
            let jsonStr   = try? String(contentsOf: jsonURL,   encoding: .utf8)
        else {
            print("⚠️  LottiePreloader: missing bundle files.")
            return
        }

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
            lottie.loadAnimation({
              container: document.getElementById('c'),
              renderer: 'svg',
              loop: true,
              autoplay: true,
              animationData: \(jsonStr)
            });
          </script>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
        isLoaded = true
    }
}

// MARK: - LottieWebView
//
// Wraps the pre-loaded singleton WKWebView. Because the WebView is already
// warm and the animation is already playing in memory, it appears instantly
// — no startup lag at all.

struct LottieWebView: UIViewRepresentable {

    func makeUIView(context: Context) -> WKWebView {
        // Return the already-loaded singleton — instantaneous display.
        LottiePreloader.shared.webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    // Remove from its superview when SwiftUI tears down this representable
    // so it can be reused the next time CountdownView opens.
    static func dismantleUIView(_ webView: WKWebView, coordinator: ()) {
        webView.removeFromSuperview()
    }
}

// MARK: - Countdown View

struct CountdownView: View {
    @Environment(\.colorScheme) private var colorScheme
    var onComplete: () -> Void
    var onCancel: () -> Void

    @State private var count          = 3
    @State private var ringProgress: CGFloat = 0
    @State private var numberScale:  CGFloat = 0.5
    @State private var numberOpacity: Double  = 0

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        let isDark = colorScheme == .dark

        ZStack {
            (isDark ? Color.black : Color(white: 0.98))
                .ignoresSafeArea()

            // ZStack centres this VStack in the full screen by default
            VStack(spacing: 24) {
                // Pre-warmed — renders immediately with no lag
                LottieWebView()
                    .frame(width: 220, height: 220)
                    .background(Color.clear)

                ZStack {
                    Circle()
                        .stroke(Color.homePurple.opacity(isDark ? 0.15 : 0.10), lineWidth: 14)

                    Circle()
                        .trim(from: 0, to: ringProgress)
                        .stroke(Color.homePurple,
                                style: StrokeStyle(lineWidth: 14, lineCap: .round))
                        .rotationEffect(.degrees(-90))

                    Text("\(count)")
                        .font(.system(size: 100, weight: .bold, design: .rounded))
                        .foregroundColor(.homePurple)
                        .scaleEffect(numberScale)
                        .opacity(numberOpacity)
                }
                .frame(width: 220, height: 220)

                Text("Starting Walk")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.textPrimary)
            }
            .frame(maxWidth: .infinity)

            VStack {
                HStack {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.textPrimary)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(isDark ? Color(white: 0.16) : .white)
                                .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
                        )
                        .contentShape(Circle())
                        .onTapGesture { onCancel() }
                        .padding(.leading, 20)
                        .padding(.top, 10)
                    Spacer()
                }
                Spacer()
            }
        }
        .onAppear {
            animateNumber()
            animateRing(for: count)
        }
        .onReceive(timer) { _ in
            if count > 1 {
                count -= 1
                animateNumber()
                animateRing(for: count)
            } else {
                onComplete()
            }
        }
    }

    private func animateNumber() {
        numberScale   = 0.5
        numberOpacity = 0
        withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
            numberScale   = 1.0
            numberOpacity = 1.0
        }
    }

    private func animateRing(for remaining: Int) {
        withAnimation(.easeInOut(duration: 0.9)) {
            ringProgress = CGFloat(4 - remaining) / 3.0
        }
    }
}

#Preview {
    CountdownView(onComplete: {}, onCancel: {})
}
