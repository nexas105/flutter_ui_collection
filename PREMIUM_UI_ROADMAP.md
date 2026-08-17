# Flutter UI Collection — Premium UI Roadmap

Stand: 17. August 2026

## Ziel

Die Collection wird von einer umfangreichen, Material-unabhängigen Widget-Sammlung zu einem eigenständigen Premium-Design-System weiterentwickelt. Themes sollen nicht nur Farben austauschen, sondern Typografie, Geometrie, Oberflächen, Interaktion, Bewegung und Informationshierarchie glaubwürdig verändern.

## Leitlinien

- Keine unkontrollierten Flutter- oder Material-Defaults.
- Bestehende öffentliche APIs bleiben nach Möglichkeit kompatibel.
- Designentscheidungen werden als semantische Tokens zentralisiert.
- Jede interaktive Komponente unterstützt Touch, Maus, Tastatur und Semantik.
- Themes unterscheiden sich strukturell, nicht nur über Farben.
- Neue visuelle Arbeit wird über die Demo und automatisierte Tests überprüfbar.

## Phase 1 — Premium Foundation

Status: **Abgeschlossen**

### 1.1 Component Tokens

- [x] Bestehendes Theme-System analysieren
- [x] Semantische Tokens für Control-Höhen, Radien und Abstände einführen
- [x] Tokens für Hover, Pressed, Disabled und Focus ergänzen
- [x] Tokens für Oberflächen und Elevation ergänzen
- [x] `UiThemeData.copyWith` vollständig erweitern
- [x] Öffentlichen Export ergänzen

Akzeptanzkriterien:

- Keine Breaking Changes für bestehende Themes.
- Komponenten können gemeinsame Maße verwenden, ohne feste Werte zu duplizieren.
- Neue Tokens lassen sich pro Preset überschreiben.

### 1.2 Erste Referenzkomponenten

- [x] `UiButton` migrieren
- [x] `UiCard` migrieren
- [x] `UiAppBar` migrieren
- [x] Token-Verhalten mit Widget-Tests absichern

Akzeptanzkriterien:

- Konsistente Höhen und Radien.
- Ruhigere, glaubwürdige Tiefenwirkung.
- Klar unterscheidbare Hover-, Pressed- und Disabled-Zustände.
- Keine gleichzeitige Standard-Kontur und Standardschatten auf Karten.

## Phase 2 — Typography and Icon Identity

Status: **Abgeschlossen**

- [x] Typografie-Skala und Zeilenhöhen überarbeiten
- [x] Display-, UI- und Datentextrollen trennen
- [x] Font-Fallbacks pro Plattform definieren
- [x] Eigene Icon-Familie oder austauschbaren Icon-Provider einführen
- [x] Direkte Material-Codepoints aus Core-Komponenten entfernen
- [x] Direkte Material-Codepoints aus App-Modulen entfernen
- [x] Icon-Größen semantisch tokenisieren
- [x] Icon-Strichstärken über eine eigene Icon-Familie steuerbar machen

Akzeptanzkriterien:

- Kein Preset hängt ausschließlich an `sans-serif` als Identität.
- Komponenten enthalten keine privaten Material-Codepoints mehr.
- Text bleibt bei Skalierung bis 200 Prozent verwendbar.

## Phase 3 — Core Controls

Status: **Abgeschlossen**

- [x] `UiTextField` und Suchfelder
- [x] Checkbox, Radio und Toggle
- [x] Slider und Segmented Control
- [x] Dropdown, Select und Autocomplete
- [x] Focus-Ring und Tastaturnavigation vereinheitlichen
- [x] Loading-, Error-, Empty- und Disabled-Zustände harmonisieren

Akzeptanzkriterien:

- Alle Controls besitzen dieselbe Zustandslogik.
- Touch-Ziele sind mindestens 44 × 44 logische Pixel groß.
- Fokus ist auf hellen und dunklen Themes eindeutig sichtbar.

## Phase 4 — Navigation and Surfaces

Status: **Abgeschlossen**

- [x] Scaffold und Responsive Body
- [x] App Bar, Sidebar und Drawer
- [x] Bottom Navigation und Tabs
- [x] Dialog, Sheet, Popover und Command Palette
- [x] Surface-Level für Hintergrund, Canvas, Raised und Overlay anwenden

Akzeptanzkriterien:

- Navigation besitzt eine klare Hierarchie auf Mobile, Tablet und Desktop.
- Overlays haben konsistente Platzierung, Fokusführung und Rückkehrlogik.

## Phase 5 — Premium Settings Reference

Status: **Abgeschlossen**

- [x] Settings-Screen als Referenzoberfläche neu komponieren
- [x] Responsive Split-View für breite Viewports
- [x] Settings-Zeilen entkarten und visuell beruhigen
- [x] Theme-Selector als echte Miniaturvorschau gestalten
- [x] About-Screen mit klarer Produktidentität aufwerten

Akzeptanzkriterien:

- Kein erkennbarer Standard-iOS-/Android-Settings-Klon.
- Mobile und Desktop haben jeweils passende Informationsarchitektur.
- Der Screen demonstriert die neue visuelle Qualität ohne Dekorationsoverkill.

## Phase 6 — Preset Redesign

Status: **Abgeschlossen**

Jedes Preset erhält eine eigene Designgrammatik:

- [x] Minimal
- [x] Neon
- [x] Glass
- [x] Cyberpunk
- [x] Retro
- [x] Aurora
- [x] Terminal
- [x] Pastel

Pro Preset zu definieren:

- Typografische Stimme
- Control-Geometrie
- Surface- und Elevation-System
- Icon-Behandlung
- Bewegungscharakter
- Light-/Dark-Kontrast

Akzeptanzkriterien:

- Ein Preset ist auch in Graustufen anhand seiner Formensprache erkennbar.
- Effekte wie Glow, Blur und Gradient werden nur dort eingesetzt, wo sie zur jeweiligen Grammatik gehören.

## Phase 7 — Module Migration

Status: **Abgeschlossen**

- [x] Auth
- [x] Chat
- [x] Dashboard
- [x] E-Commerce
- [x] Social
- [x] Settings

Akzeptanzkriterien:

- Module verwenden ausschließlich zentrale Tokens und Kernkomponenten.
- Keine duplizierten Schatten-, Radius- oder Opacity-Konstanten.
- Reale Zustände und lange Inhalte sind abgedeckt.

## Phase 8 — Showcase App

Status: **Geplant**

- [ ] Katalogstruktur durch kuratierte Produkt-Szenarien ersetzen
- [ ] Preset-Wechsel mit aussagekräftigen Vorschauen
- [ ] Mobile, Tablet und Desktop gezielt demonstrieren
- [ ] Accessibility- und State-Lab integrieren
- [ ] Screenshots für README und Releases erzeugen

Akzeptanzkriterien:

- Die Demo wirkt wie ein fertiges Premium-Produkt.
- Alle Kernzustände sind ohne Codeänderung prüfbar.

## Phase 9 — Quality Gate

Status: **Geplant**

- [ ] Golden Tests für Kernkomponenten und Presets
- [ ] Semantics-Tests
- [ ] Keyboard- und Focus-Tests
- [ ] Kontrastprüfung
- [ ] Responsive Screenshot-Tests
- [ ] Performance-Prüfung für Blur, Glow und Animation
- [x] Analyzer-Warnungen auf null reduzieren

Akzeptanzkriterien:

- `flutter analyze` ohne Findings.
- Vollständige Test-Suite erfolgreich.
- Visuelle Änderungen werden durch Golden Tests sichtbar.

## Aktueller Arbeitsblock

1. Showcase-Struktur und bestehende Demo-Screens inventarisieren.
2. Katalog durch kuratierte Produkt-Szenarien ersetzen.
3. Preset-Vorschau sowie Mobile-, Tablet- und Desktop-Komposition ergänzen.
4. Accessibility- und State-Lab integrieren.
5. Screenshots und README-Material erzeugen.
