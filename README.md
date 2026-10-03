#  macOS-Inspired Hyprland Desktop

A clean, elegant, and modern Hyprland rice designed to bring the refined aesthetic and fluid experience of **macOS Sonoma** to Arch Linux.

Featuring frosted glassmorphism, native-style window traffic lights, a centered top menu bar, a floating bottom dock, and a Spotlight-styled app launcher.

---

## ✨ Features & Aesthetic Highlights

- ** Menu Bar (Waybar)**: Modeled after the macOS menu bar with an Apple menu trigger, active application class display, centered date/time, and streamlined status indicators.
- **🚥 Traffic Light Window Controls**: Integrated window titlebars using `hyprbars` with macOS-style close, minimize, and fullscreen buttons.
- **🔍 Spotlight Launcher (Wofi)**: Centered, clean quick-launcher styled with frosted translucent acrylic backgrounds and Cupertino blue highlights.
- **🖥️ Floating Dock (nwg-dock-hyprland)**: Autohiding bottom dock with rounded corners and subtle border translucency.
- **🔒 Sonoma Lock Screen (Hyprlock)**: Minimalist lock screen featuring live desktop blur, bold typography, and a pill-shaped password entry.
- **🧊 Liquid Glass Effects (Hyprglass & Blurring)**: Layered dual-pass gaussian blur, subtle specular highlights, and soft window drop shadows.
- **⚡ Fluid Curves**: Custom smooth cubic bezier window animations (`0.25, 0.8, 0.25, 1`).

---

## 🛠️ Components

| Component | Role | Description |
|-----------|------|-------------|
| **[Hyprland](https://hyprland.org/)** | Compositor | Dynamic tiling Wayland compositor with fluid animations & blur |
| **[Waybar](https://github.com/Alexays/Waybar)** | Menu Bar | macOS-style top status bar with Apple menu and app titles |
| **[nwg-dock-hyprland](https://github.com/nwg-piotr/nwg-dock-hyprland)** | Dock | Smooth bottom application dock |
| **[Wofi](https://hg.sr.ht/~scoopta/wofi)** | Launcher | Spotlight-inspired search and application launcher |
| **[Hyprlock](https://github.com/hyprwm/hyprlock)** | Lock Screen | Fast, hardware-accelerated lock screen with desktop blur |
| **[Hypridle](https://github.com/hyprwm/hypridle)** | Idle Daemon | Automatic screen dimming, lock, and DPMS sleep handling |
| **[Hyprpaper](https://github.com/hyprwm/hyprpaper)** | Wallpaper | Wallpaper utility configured for macOS Sonoma wallpaper |
| **[Wlogout](https://github.com/ArtsyMacaw/wlogout)** | Power Menu | Minimalist session menu (Lock, Log Out, Sleep, Restart, Shut Down) |
| **[Hyprland Plugins](https://github.com/hyprwm/hyprland-plugins)** | Plugins | `hyprbars` (traffic lights) & `hyprglass` |

---

## 🎨 Color Palette & Typography

Designed around macOS dark mode materials and system accent colors:

| Token | Hex / Value | Purpose |
|-------|-------------|---------|
| **System Accent Blue** | `#0A84FF` | Active selection, spotlight focus, interactive highlights |
| **Traffic Light Close** | `#FF5F57` | Titlebar close button, critical battery, disconnected status |
| **Traffic Light Minimize**| `#FEBC2E` | Titlebar minimize button, battery warnings |
| **Traffic Light Fullscreen**| `#28C840` | Titlebar fullscreen button, battery charging |
| **Dark Glass Background** | `rgba(30, 30, 30, 0.55)` | Top bar, dock, dialogs, floating panels |
| **Border Highlight** | `rgba(255, 255, 255, 0.15)` | Subtle translucent window & element borders |
| **Typography** | **Inter** + **Symbols Nerd Font** | Primary UI font & status icons |
| **Cursor Theme** | **WhiteSur-cursors** | macOS cursor theme |

---

## ⌨️ Keybindings

### Applications & Controls

| Shortcut | Action |
|----------|--------|
| `Super + Return` | Open Terminal ([kitty](https://sw.kovidgoyal.net/kitty/)) |
| `Super + D` | Open Spotlight launcher (`wofi`) |
| `Super + F` | Launch Firefox |
| `Super + Q` | Close active window |
| `Super + Shift + F` | Toggle fullscreen |
| `Super + M` | Toggle minimized windows (special workspace) |
| `Super + Space` | Cycle keyboard layout (CZ / US) |
| `Super + L` | Open power menu (`wlogout`) |
| `Super + Shift + A` | Toggle laptop display / lid mode |

### Screenshots

| Shortcut | Action |
|----------|--------|
| `Print` | Capture full screen to `~/Pictures/Screenshots/` |
| `Super + Shift + S` | Interactive area screenshot copied to clipboard (`slurp` + `grim`) |

### Workspaces

| Shortcut | Action |
|----------|--------|
| `Super + 1..0` | Switch to workspace 1–10 |
| `Super + Shift + 1..0` | Move active window to workspace 1–10 |

---

## 📦 Dependencies

Ensure you have the following packages installed (Arch Linux / AUR):

```bash
# Core Compositor & Wayland Utilities
sudo pacman -S hyprland waybar hyprpaper hyprlock hypridle wofi wlogout kitty \
               grim slurp wl-clipboard pavucontrol networkmanager brightnessctl

# Dock & Theming
paru -S nwg-dock-hyprland nwg-look-bin whitesur-cursor-theme-git ttf-inter ttf-nerd-fonts-symbols
```

### Hyprland Plugins

This setup utilizes official plugins (`hyprbars` for window titlebars and traffic light buttons):

```bash
# Initialize and install plugins via hyprpm
hyprpm update
hyprpm add https://github.com/hyprwm/hyprland-plugins
hyprpm enable hyprbars
hyprpm reload
```

---

## 🚀 Quick Installation (Automated)

The easiest way to install everything (dependencies, AUR packages, plugins, fonts, scripts, and dotfiles) is with the automated install script:

```bash
git clone https://github.com/Olinkkt/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

The script will:
- Back up any existing `~/.config` configurations safely.
- Install official packages (`pacman`) and AUR packages (`yay`/`paru`).
- Set up and build `hyprpm` plugins (`hyprbars` traffic lights, `dynamic-cursors`, `hyprglass`).
- Deploy the Sonoma wallpaper and helper scripts (`lid-toggle`, `weather`).
- Stow dotfiles directly to `~/.config/`.

---

### 🛠️ Manual Installation

If you prefer to install manually:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Olinkkt/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Deploy dotfiles using GNU Stow:**
   ```bash
   stow hypr waybar wofi wlogout kitty nwg-dock-hyprland nwg-look bin
   ```
   *Or symlink manually to `~/.config/`:*
   ```bash
   mkdir -p ~/.config/{hypr,waybar,wofi,wlogout,kitty,nwg-dock-hyprland,nwg-look} ~/.local/bin
   ln -sf ~/dotfiles/hypr/.config/hypr/* ~/.config/hypr/
   ln -sf ~/dotfiles/waybar/.config/waybar/* ~/.config/waybar/
   ln -sf ~/dotfiles/wofi/.config/wofi/* ~/.config/wofi/
   ln -sf ~/dotfiles/wlogout/.config/wlogout/* ~/.config/wlogout/
   ln -sf ~/dotfiles/kitty/.config/kitty/* ~/.config/kitty/
   ln -sf ~/dotfiles/nwg-dock-hyprland/.config/nwg-dock-hyprland/* ~/.config/nwg-dock-hyprland/
   ln -sf ~/dotfiles/nwg-look/.config/nwg-look/* ~/.config/nwg-look/
   ln -sf ~/dotfiles/bin/.local/bin/* ~/.local/bin/
   ```

3. **Install the wallpaper:**
   ```bash
   mkdir -p ~/Pictures/wallpapers
   cp ~/dotfiles/wallpapers/sonoma.jpg ~/Pictures/wallpapers/sonoma.jpg
   ```

---

## ⚙️ Customization

- **Menu Bar**: Edit [waybar/config](file:///home/oliver/dotfiles/waybar/.config/waybar/config) and [waybar/style.css](file:///home/oliver/dotfiles/waybar/.config/waybar/style.css)
- **Dock Appearance**: Adjust [nwg-dock-hyprland/style.css](file:///home/oliver/dotfiles/nwg-dock-hyprland/.config/nwg-dock-hyprland/style.css)
- **Spotlight Search**: Modify [wofi/style.css](file:///home/oliver/dotfiles/wofi/.config/wofi/style.css)
- **Window Decorations & Gaps**: Tweak borders, shadows, and animations in [hyprland.conf](file:///home/oliver/dotfiles/hypr/.config/hypr/hyprland.conf)
- **Lock Screen**: Customize clock format and blur intensity in [hyprlock.conf](file:///home/oliver/dotfiles/hypr/.config/hypr/hyprlock.conf)

---

## 📄 License

This configuration is open source and available under the [MIT License](LICENSE).
