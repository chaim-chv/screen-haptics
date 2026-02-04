import Cocoa
import ServiceManagement

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = AppDelegate()
app.delegate = delegate
app.run()

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var lastScreen: NSScreen?
    let strengthKey = "hapticStrength"
    var aboutWindow: NSWindow?
    var strengthMenu: NSMenu?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        createStatusItem()
        lastScreen = getCurrentScreen()
        NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] _ in self?.checkCursorPosition() }
        NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDragged) { [weak self] _ in self?.checkCursorPosition() }
        NSEvent.addGlobalMonitorForEvents(matching: .rightMouseDragged) { [weak self] _ in self?.checkCursorPosition() }
        NSEvent.addGlobalMonitorForEvents(matching: .otherMouseDragged) { [weak self] _ in self?.checkCursorPosition() }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        statusItem?.isVisible = true
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.statusItem?.button?.performClick(nil)
            }
        }
        return true
    }

    func createStatusItem() {
        if statusItem != nil { return }
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.behavior = .removalAllowed
        statusItem?.button?.image = NSImage(systemSymbolName: "cursorarrow.and.square.on.square.dashed", accessibilityDescription: nil)

        let menu = NSMenu()

        let appName = NSLocalizedString("app_name", comment: "")
        menu.addItem(NSMenuItem(title: String(format: NSLocalizedString("about_app", comment: ""), appName), action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())

        strengthMenu = NSMenu()
        strengthMenu?.delegate = self
        let strengths: [(String, Int)] = [
            (NSLocalizedString("strength_light", comment: ""), 0),
            (NSLocalizedString("strength_medium", comment: ""), 1),
            (NSLocalizedString("strength_strong", comment: ""), 2)
        ]
        let currentStrength = UserDefaults.standard.integer(forKey: strengthKey)

        for (label, value) in strengths {
            let item = NSMenuItem(title: label, action: #selector(setStrength(_:)), keyEquivalent: "")
            item.tag = value
            item.state = (currentStrength == value) ? .on : .off
            strengthMenu?.addItem(item)
        }

        let strengthParent = NSMenuItem(title: NSLocalizedString("haptic_strength", comment: ""), action: nil, keyEquivalent: "")
        strengthParent.submenu = strengthMenu
        menu.addItem(strengthParent)

        menu.addItem(NSMenuItem.separator())

        let login = NSMenuItem(title: NSLocalizedString("start_at_login", comment: ""), action: #selector(toggleLogin), keyEquivalent: "")
        login.state = SMAppService.mainApp.status == .enabled ? .on : .off
        menu.addItem(login)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: NSLocalizedString("quit", comment: ""), action: #selector(quitApp), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    @objc func showAbout() {
        if aboutWindow == nil {
            let style: NSWindow.StyleMask = [.titled, .closable]
            let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 280, height: 240), styleMask: style, backing: .buffered, defer: false)
            window.center()
            window.title = NSLocalizedString("about", comment: "")
            window.isReleasedWhenClosed = false
            window.level = .floating

            let view = NSView(frame: window.contentView!.frame)

            let title = NSTextField(labelWithString: NSLocalizedString("app_name", comment: ""))
            title.font = .systemFont(ofSize: 14, weight: .bold)
            title.frame = NSRect(x: 10, y: 195, width: 260, height: 20)
            title.alignment = .center

            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
            let versionLabel = NSTextField(labelWithString: String(format: NSLocalizedString("version", comment: ""), version))
            versionLabel.font = .systemFont(ofSize: 11)
            versionLabel.textColor = .secondaryLabelColor
            versionLabel.frame = NSRect(x: 10, y: 170, width: 260, height: 16)
            versionLabel.alignment = .center

            let desc = NSTextField(wrappingLabelWithString: NSLocalizedString("app_description", comment: ""))
            desc.font = .systemFont(ofSize: 12)
            desc.frame = NSRect(x: 20, y: 85, width: 240, height: 80)
            desc.alignment = .center

            let link = NSButton(title: NSLocalizedString("github_repository", comment: ""), target: self, action: #selector(openGitHub))
            link.bezelStyle = .inline
            link.font = .systemFont(ofSize: 11)
            link.frame = NSRect(x: 60, y: 55, width: 160, height: 25)

            let copy = NSTextField(labelWithString: NSLocalizedString("copyright", comment: ""))
            copy.font = .systemFont(ofSize: 10)
            copy.textColor = .secondaryLabelColor
            copy.frame = NSRect(x: 10, y: 20, width: 260, height: 20)
            copy.alignment = .center

            view.addSubview(title)
            view.addSubview(versionLabel)
            view.addSubview(desc)
            view.addSubview(link)
            view.addSubview(copy)

            window.contentView = view
            aboutWindow = window
        }

        NSApp.activate(ignoringOtherApps: true)
        aboutWindow?.makeKeyAndOrderFront(nil)
        aboutWindow?.orderFrontRegardless()
    }

    @objc func openGitHub() {
        if let url = URL(string: "https://github.com/chaim-chv/screen-haptics") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc func setStrength(_ sender: NSMenuItem) {
        UserDefaults.standard.set(sender.tag, forKey: strengthKey)
        guard let submenu = statusItem?.menu?.items.first(where: { $0.submenu == strengthMenu })?.submenu else { return }
        for item in submenu.items {
            item.state = (item == sender) ? .on : .off
        }
        triggerHaptic()
    }

    func getCurrentScreen() -> NSScreen? {
        let loc = NSEvent.mouseLocation
        return NSScreen.screens.first { NSMouseInRect(loc, $0.frame, false) }
    }

    func checkCursorPosition() {
        guard let current = getCurrentScreen() else { return }
        if let last = lastScreen, last != current {
            triggerHaptic()
        }
        lastScreen = current
    }

    func triggerHaptic(strength: Int? = nil) {
        let actualStrength = strength ?? UserDefaults.standard.integer(forKey: strengthKey)
        let performer = NSHapticFeedbackManager.defaultPerformer
        let pattern: NSHapticFeedbackManager.FeedbackPattern = switch actualStrength {
            case 1: .levelChange
            case 2: .generic
            default: .alignment
        }
        performer.perform(pattern, performanceTime: .now)

        if actualStrength == 2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                performer.perform(pattern, performanceTime: .now)
            }
        }
    }

    @objc func toggleLogin(_ sender: NSMenuItem) {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
                sender.state = .off
            } else {
                try SMAppService.mainApp.register()
                sender.state = .on
            }
        } catch {
            NSLog("Failed to toggle login item: \(error.localizedDescription)")
        }
    }

    @objc func quitApp() { NSApp.terminate(nil) }
}

extension AppDelegate: NSMenuDelegate {
    func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
        guard menu == strengthMenu, let item = item, item.action == #selector(setStrength(_:)) else { return }
        triggerHaptic(strength: item.tag)
    }
}
