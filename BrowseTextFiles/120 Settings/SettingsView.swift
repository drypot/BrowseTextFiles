//
//  SettingsView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/17/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState

    let fontFamilies = NSFontManager.shared.availableFontFamilies.sorted()
    let sliderWidth: CGFloat = 320

    var body: some View {
        @Bindable var appState = appState
        VStack(alignment: .leading, spacing: 24) {
            SettingsSection(title: "Font") {
                SettingsRow {
                    Text("Font")
                    Spacer()
                    Picker("", selection: $appState.fontName) {
                        ForEach(fontFamilies, id: \.self) { family in
                            Text(family)
                                .font(.custom(family, size: 13))
                        }
                    }
                    .frame(width: sliderWidth)
                }
                Divider()

                SettingsRow {
                    Text("Font Size: \(appState.fontSize.formatted()) pt")
                    Spacer()
                    Slider(value: $appState.fontSize, in: 8...36, step: 1)
                        .frame(width: sliderWidth)
                }
                Divider()

                SettingsRow {
                    Text("Line Height: \(appState.lineHeight.formatted())x")
                    Spacer()
                    Slider(value: $appState.lineHeight, in: 1.0...3.0, step: 0.1)
                        .frame(maxWidth: sliderWidth)
                }
            }

            SettingsSection(title: "Auto Save") {
                SettingsRow {
                    Text("Auto Save Enabled")
                    Spacer()
                    Toggle("", isOn: $appState.autoSaveEnabled)
                        .labelsHidden()
                        .controlSize(.mini)
                        .toggleStyle(.switch)
                }
                Divider()

                let binding = Binding<Double>(
                    get: { Double(appState.autoSaveAfterSeconds) },
                    set: { appState.autoSaveAfterSeconds = Int($0) }
                )
                SettingsRow {
                    Text("Auto Save After \(appState.autoSaveAfterSeconds.formatted()) Seconds")
                    Spacer()
                    Slider(value: binding, in: 2.0...60.0, step: 2)
                        .disabled(!appState.autoSaveEnabled)
                        .frame(maxWidth: sliderWidth)
                }
            }
        }
        .navigationTitle("Settings")
        .padding()
        .frame(width: 600)
    }
}

fileprivate struct SettingsSection<Content: View>: View {
    let title: String

    @ViewBuilder
    var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal, 12)

            VStack(spacing: 0) {
                content
            }
            .background(Color(nsColor: .tertiarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

fileprivate struct SettingsRow<Content: View>: View {
    @ViewBuilder
    let content: Content

    var body: some View {
        HStack {
            content
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
    }
}

#Preview {
    let appState = AppState()
    SettingsView()
        .environment(appState)
}
