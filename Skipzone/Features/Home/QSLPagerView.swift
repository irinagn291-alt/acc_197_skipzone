import SwiftUI

struct QSLPagerView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Environment(\.skipSwatch) private var swatch
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var selectedIndex = 0
    @State private var dragOffset: CGFloat = 0
    @State private var showContactEditor = false
    @State private var showStats = false
    @State private var showAntennas = false
    @State private var showPropNotes = false
    @State private var showStation = false
    @State private var editingContact: AirContact?
    @State private var activeToolbar: ToolbarTab?

    private enum ToolbarTab: CaseIterable {
        case log, rigs, bands, prop, qth

        var label: String {
            switch self {
            case .log: "LOG"
            case .rigs: "RIGS"
            case .bands: "BANDS"
            case .prop: "PROP"
            case .qth: "QTH"
            }
        }
    }

    private var contacts: [AirContact] { environment.contacts }
    private var selectedContact: AirContact? {
        guard !contacts.isEmpty, selectedIndex < contacts.count else { return nil }
        return contacts[selectedIndex]
    }

    private var homeCoordinate: GeoCoordinate {
        if let profile = environment.operatorProfile {
            return GeoCoordinate(latitude: profile.homeLatitude, longitude: profile.homeLongitude)
        }
        return GeoCoordinate(latitude: 0, longitude: 0)
    }

    private var homeGrid: String {
        MaidenheadLocator.encode(
            latitude: homeCoordinate.latitude,
            longitude: homeCoordinate.longitude,
            precision: .subsquare
        )
    }

    var body: some View {
        ZStack {
            SkipChrome.logBackground(swatch)
            VStack(spacing: 0) {
                headerBar
                mapSection
                    .frame(maxHeight: .infinity)
                pagerSection
                pagerBar
                toolbarStrip
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .sheet(isPresented: $showContactEditor, onDismiss: { activeToolbar = nil }) {
                ContactEditorView(contact: editingContact) {
                    Task { await environment.reloadContacts() }
                }
                .environmentObject(environment)
            }
            .sheet(isPresented: $showStats, onDismiss: { activeToolbar = nil }) {
                NavigationStack {
                    BandHeatmapView()
                        .environmentObject(environment)
                }
            }
            .sheet(isPresented: $showAntennas, onDismiss: { activeToolbar = nil }) {
                NavigationStack {
                    AntennaListView()
                        .environmentObject(environment)
                }
            }
            .sheet(isPresented: $showPropNotes, onDismiss: { activeToolbar = nil }) {
                NavigationStack {
                    PropNotesView()
                        .environmentObject(environment)
                }
            }
            .sheet(isPresented: $showStation, onDismiss: { activeToolbar = nil }) {
                NavigationStack {
                    StationProfileView()
                        .environmentObject(environment)
                }
            }
    }

    private var headerBar: some View {
        HStack {
            Text("LOGBOOK")
                .font(.system(size: 15, design: .monospaced).weight(.regular))
                .tracking(4.2)
                .foregroundStyle(swatch.ink)
            Spacer()
            Text(homeGrid)
                .font(.system(size: 10.5, design: .monospaced))
                .foregroundStyle(swatch.olive)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: SkipTokens.cornerS)
                        .fill(swatch.gridPillBG)
                        .overlay(
                            RoundedRectangle(cornerRadius: SkipTokens.cornerS)
                                .stroke(swatch.rule, lineWidth: SkipTokens.ruleStroke)
                        )
                )
                .accessibilityLabel("Home grid \(homeGrid)")
        }
        .padding(.horizontal, 22)
        .padding(.top, SkipTokens.screenTop)
    }

    private var mapSection: some View {
        Group {
            if let contact = selectedContact {
                let dest = GeoCoordinate(latitude: contact.theirLatitude, longitude: contact.theirLongitude)
                let route = GreatCircleSolver.route(from: homeCoordinate, to: dest)
                AzimuthalMapView(
                    home: homeCoordinate,
                    contact: dest,
                    qsoDate: contact.qsoAt,
                    route: route
                )
                .padding(.horizontal, SkipTokens.padL)
                .padding(.top, 12)
            } else {
                SkipEmptyPlate(
                    image: .emptyContacts,
                    title: "No contacts yet",
                    message: "Log your first QSO to see the map and QSL cards.",
                    actionTitle: "Log contact"
                ) {
                    editingContact = nil
                    showContactEditor = true
                }
                .frame(height: 260)
            }
        }
    }

    private var pagerSection: some View {
        Group {
            if !contacts.isEmpty {
                GeometryReader { geometry in
                    let cardWidth = SkipTokens.qslCardWidth
                    let spacing: CGFloat = SkipTokens.padM
                    HStack(spacing: spacing) {
                        ForEach(Array(contacts.enumerated()), id: \.element.id) { index, contact in
                            let dest = GeoCoordinate(latitude: contact.theirLatitude, longitude: contact.theirLongitude)
                            let route = GreatCircleSolver.route(from: homeCoordinate, to: dest)
                            ZStack {
                                if index == selectedIndex {
                                    QSLCardStackShadow()
                                }
                                QSLCardView(contact: contact, route: route)
                            }
                            .scaleEffect(index == selectedIndex ? 1.0 : 0.92)
                            .opacity(index == selectedIndex ? 1.0 : 0.55)
                            .onTapGesture {
                                selectCard(index)
                            }
                        }
                    }
                    .offset(x: -CGFloat(selectedIndex) * (cardWidth + spacing) + (geometry.size.width - cardWidth) / 2 + dragOffset)
                    .mask(
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .black, location: 0.06),
                                .init(color: .black, location: 0.94),
                                .init(color: .clear, location: 1)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in dragOffset = value.translation.width }
                            .onEnded { value in
                                let threshold = cardWidth / 3
                                if reduceMotion {
                                    if value.translation.width < -threshold, selectedIndex < contacts.count - 1 {
                                        selectedIndex += 1
                                    } else if value.translation.width > threshold, selectedIndex > 0 {
                                        selectedIndex -= 1
                                    }
                                    dragOffset = 0
                                } else {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        if value.translation.width < -threshold, selectedIndex < contacts.count - 1 {
                                            selectedIndex += 1
                                        } else if value.translation.width > threshold, selectedIndex > 0 {
                                            selectedIndex -= 1
                                        }
                                        dragOffset = 0
                                    }
                                }
                            }
                    )
                }
                .frame(height: SkipTokens.qslCardHeight + 24)
                .padding(.top, 10)
            }
        }
    }

    private var pagerBar: some View {
        Group {
            if !contacts.isEmpty {
                VStack(spacing: 8) {
                    PageDots(count: contacts.count, selected: selectedIndex)
                    Text("Card \(selectedIndex + 1) of \(contacts.count) · swipe")
                        .font(.system(size: 8.5, weight: .medium))
                        .tracking(2.7)
                        .textCase(.uppercase)
                        .foregroundStyle(swatch.muted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    swatch.pagerBar
                        .overlay(alignment: .top) {
                            Rectangle()
                                .fill(swatch.pagerBarBorder)
                                .frame(height: SkipTokens.ruleStroke)
                        }
                )
            }
        }
    }

    private var toolbarStrip: some View {
        HStack(spacing: 0) {
            ForEach(ToolbarTab.allCases, id: \.self) { tab in
                toolbarLabel(tab)
            }
        }
        .padding(.vertical, 10)
        .padding(.bottom, 2)
        .background(
            swatch.pagerBar
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(SkipChrome.rule(swatch), alignment: .top)
    }

    private func toolbarLabel(_ tab: ToolbarTab) -> some View {
        let isActive = activeToolbar == tab
        return Button {
            activeToolbar = tab
            switch tab {
            case .log:
                editingContact = selectedContact
                showContactEditor = true
            case .rigs:
                showAntennas = true
            case .bands:
                showStats = true
            case .prop:
                showPropNotes = true
            case .qth:
                showStation = true
            }
        } label: {
            Text(tab.label)
                .font(.system(size: 10, design: .monospaced).weight(.medium))
                .tracking(1.5)
                .foregroundStyle(isActive ? swatch.stamp : swatch.ink.opacity(0.75))
                .frame(maxWidth: .infinity)
                .frame(minHeight: SkipTokens.minHitTarget)
        }
        .accessibilityLabel(tab.label)
        .accessibilityAddTraits(.isButton)
    }

    private func selectCard(_ index: Int) {
        if reduceMotion {
            selectedIndex = index
        } else {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selectedIndex = index
            }
        }
    }
}
