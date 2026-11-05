import json
import os

def kf(t, s, e=None):
    obj = {"t": t, "s": s}
    if e is not None:
        obj["e"] = e
    return obj

def val(v):
    return {"a": 0, "k": v}

def anim(keys):
    return {"a": 1, "k": keys}

def color(r, g, b, a=1.0):
    return [round(r/255.0, 3), round(g/255.0, 3), round(b/255.0, 3), a]

# High-contrast colors suitable for light background
RED_MAIN = color(225, 29, 46)     # #E11D2E
RED_LIGHT = color(255, 77, 95)    # #FF4D5F
RED_DARK = color(153, 13, 27)     # #990D1B
SLATE_DARK = color(15, 23, 42)   # #0F172A
SLATE_MID = color(71, 85, 105)    # #475569
SLATE_LIGHT = color(226, 232, 240)# #E2E8F0
WHITE = color(255, 255, 255)
GREEN_OK = color(16, 185, 129)   # #10B981

def base_lottie(name, w=500, h=500, fr=60, total_frames=180):
    return {
        "v": "5.7.4",
        "fr": fr,
        "ip": 0,
        "op": total_frames,
        "w": w,
        "h": h,
        "nm": name,
        "ddd": 0,
        "assets": [],
        "layers": []
    }

def make_shape_layer(ind, name, shapes, transforms=None, ip=0, op=180):
    tr = {
        "p": val([250, 250, 0]),
        "a": val([0, 0, 0]),
        "s": val([100, 100, 100]),
        "r": val(0),
        "o": val(100),
        "sk": val(0),
        "sa": val(0)
    }
    if transforms:
        tr.update(transforms)
    return {
        "ddd": 0,
        "ind": ind,
        "ty": 4,
        "nm": name,
        "sr": 1,
        "ks": tr,
        "ao": 0,
        "shapes": shapes,
        "ip": ip,
        "op": op,
        "st": 0,
        "bm": 0
    }

def group(name, items):
    return {
        "ty": "gr",
        "nm": name,
        "it": items + [{
            "ty": "tr",
            "p": val([0, 0]),
            "a": val([0, 0]),
            "s": val([100, 100]),
            "r": val(0),
            "o": val(100),
            "sk": val(0),
            "sa": val(0)
        }]
    }

def ellipse(name, w, h, x=0, y=0):
    return {"ty": "el", "nm": name, "p": val([x, y]), "s": val([w, h])}

def rect(name, w, h, r=0, x=0, y=0):
    return {"ty": "rc", "nm": name, "p": val([x, y]), "s": val([w, h]), "r": val(r)}

def stroke(c, width, opacity=100, dashes=None):
    res = {
        "ty": "st",
        "c": val(c),
        "o": val(opacity) if isinstance(opacity, (int, float)) else opacity,
        "w": val(width) if isinstance(width, (int, float)) else width,
        "lc": 2,
        "lj": 2
    }
    if dashes:
        d_items = []
        for i, d in enumerate(dashes):
            d_items.append({"n": f"d{i}", "v": val(d)})
        res["d"] = d_items
    return res

def fill(c, opacity=100):
    return {
        "ty": "fl",
        "c": val(c),
        "o": val(opacity) if isinstance(opacity, (int, float)) else opacity
    }

# 1. HERO CRYPTO RADAR SCANNER
def generate_hero():
    lt = base_lottie("Hero Hi-Tech Verification Console", 500, 500, 60, 180)
    layers = []
    
    # Outer Rotating Radar Ring (Clockwise)
    layers.append(make_shape_layer(1, "Outer Radar Ring", [
        group("Ring", [
            ellipse("El", 420, 420),
            stroke(SLATE_LIGHT, 2)
        ]),
        group("DashedRadar", [
            ellipse("ElDash", 390, 390),
            stroke(RED_MAIN, 2, 75, dashes=[24, 16])
        ]),
        group("CornerTick1", [
            rect("Tick", 24, 4, 0, 195, 0),
            fill(RED_MAIN, 90)
        ]),
        group("CornerTick2", [
            rect("Tick", 24, 4, 0, -195, 0),
            fill(RED_MAIN, 90)
        ]),
        group("CornerTick3", [
            rect("Tick", 4, 24, 0, 0, 195),
            fill(RED_MAIN, 90)
        ]),
        group("CornerTick4", [
            rect("Tick", 4, 24, 0, 0, -195),
            fill(RED_MAIN, 90)
        ])
    ], transforms={
        "r": anim([kf(0, [0], [360]), kf(180, [360])])
    }))

    # Inner Segmented Cryptographic Ring (Counter-Clockwise)
    layers.append(make_shape_layer(2, "Inner Crypto Ring", [
        group("InnerDashed", [
            ellipse("ElInner", 300, 300),
            stroke(RED_LIGHT, 2.5, 85, dashes=[14, 16, 28, 16])
        ]),
        group("InnerSubRing", [
            ellipse("Sub", 260, 260),
            stroke(RED_DARK, 1.5, 60)
        ])
    ], transforms={
        "r": anim([kf(0, [360], [0]), kf(180, [0])])
    }))

    # Laser Crosshairs
    layers.append(make_shape_layer(3, "Crosshairs", [
        group("HorizLine", [
            rect("HL", 440, 1.5, 0, 0, 0),
            fill(RED_MAIN, anim([kf(0, [30], [80]), kf(90, [80], [30]), kf(180, [30])]))
        ]),
        group("VertLine", [
            rect("VL", 1.5, 440, 0, 0, 0),
            fill(RED_MAIN, anim([kf(0, [30], [80]), kf(90, [80], [30]), kf(180, [30])]))
        ])
    ]))

    # Concentric Ripple Shockwaves
    for i, delay in enumerate([0, 45, 90, 135]):
        layers.append(make_shape_layer(4 + i, f"Ripple Wave {i+1}", [
            group("Ripple", [
                ellipse("RipEl", 200, 200),
                stroke(RED_MAIN, 2, anim([
                    kf(0, [0]),
                    kf(delay, [75]),
                    kf(min(180, delay + 70), [0]),
                    kf(180, [0])
                ]))
            ])
        ], transforms={
            "s": anim([
                kf(0, [30, 30, 100]),
                kf(delay, [40, 40, 100]),
                kf(min(180, delay + 70), [160, 160, 100]),
                kf(180, [160, 160, 100])
            ])
        }))

    # Center Cryptographic Shield Core
    layers.append(make_shape_layer(8, "Crypto Core Shield", [
        group("CoreBackdrop", [
            rect("CoreBox", 140, 140, 28, 0, 0),
            fill(WHITE, 95),
            stroke(RED_MAIN, 3, 95)
        ]),
        group("CoreInnerAccent", [
            rect("InnerBox", 100, 100, 20, 0, 0),
            stroke(RED_LIGHT, 1.5, 80)
        ]),
        group("CenterDiamond", [
            rect("Diamond", 40, 40, 8, 0, 0),
            fill(RED_MAIN, 95)
        ]),
        group("CenterEye", [
            ellipse("Pupil", 14, 14, 0, 0),
            fill(WHITE, 100)
        ])
    ], transforms={
        "s": anim([
            kf(0, [95, 95, 100], [105, 105, 100]),
            kf(90, [105, 105, 100], [95, 95, 100]),
            kf(180, [95, 95, 100])
        ]),
        "r": anim([
            kf(0, [0], [90]),
            kf(90, [90], [180]),
            kf(180, [180])
        ])
    }))

    # Orbital Data Nodes
    layers.append(make_shape_layer(9, "Orbital Nodes", [
        group("Node1", [
            ellipse("N1", 16, 16, 140, 0),
            fill(WHITE, 100),
            stroke(RED_MAIN, 3)
        ]),
        group("Node2", [
            ellipse("N2", 16, 16, -140, 0),
            fill(WHITE, 100),
            stroke(RED_MAIN, 3)
        ]),
        group("Node3", [
            ellipse("N3", 14, 14, 0, 140),
            fill(RED_MAIN, 100)
        ]),
        group("Node4", [
            ellipse("N4", 14, 14, 0, -140),
            fill(RED_MAIN, 100)
        ])
    ], transforms={
        "r": anim([kf(0, [0], [360]), kf(180, [360])])
    }))

    lt["layers"] = layers
    return lt

# 2. NFC CHIP & TAMPER SEAL ANIMATION
def generate_nfc():
    lt = base_lottie("NTAG 424 DNA NFC Verification", 400, 400, 60, 180)
    layers = []

    for idx, d in enumerate([0, 40, 80, 120]):
        layers.append(make_shape_layer(idx+1, f"Signal Arc {idx+1}", [
            group("Arc", [
                ellipse("SignalWave", 120 + idx*40, 120 + idx*40, 70, 0),
                stroke(RED_MAIN, 3, anim([
                    kf(0, [20]),
                    kf(d, [90]),
                    kf(min(180, d+50), [10]),
                    kf(180, [20])
                ]))
            ])
        ], transforms={"p": val([200, 200, 0])}))

    layers.append(make_shape_layer(6, "NTAG 424 Chip Module", [
        group("SiliconeBase", [
            rect("ChipCard", 180, 180, 24, -40, 0),
            fill(WHITE, 95),
            stroke(SLATE_MID, 2)
        ]),
        group("TamperAntennaLoop", [
            rect("Loop1", 150, 150, 16, -40, 0),
            stroke(RED_MAIN, 2.5, 85, dashes=[18, 6])
        ]),
        group("TamperSubstrateCore", [
            rect("SiliconCore", 90, 90, 12, -40, 0),
            fill(RED_MAIN, 90),
            stroke(RED_LIGHT, 2)
        ]),
        group("SunTokenIcon", [
            ellipse("SunEye", 36, 36, -40, 0),
            fill(WHITE, 100)
        ]),
        group("SecurePinDots", [
            rect("Pin1", 16, 6, 2, -135, -30),
            rect("Pin2", 16, 6, 2, -135, 0),
            rect("Pin3", 16, 6, 2, -135, 30),
            fill(RED_MAIN, 90)
        ])
    ], transforms={
        "p": val([200, 200, 0]),
        "s": anim([
            kf(0, [98, 98, 100], [102, 102, 100]),
            kf(90, [102, 102, 100], [98, 98, 100]),
            kf(180, [98, 98, 100])
        ])
    }))

    lt["layers"] = layers
    return lt

# 3. AI MICRO-SCAN ANIMATION
def generate_ai_scan():
    lt = base_lottie("AI Micro-Canvas Feature Extractor", 400, 400, 60, 180)
    layers = []

    # Canvas weave grid background
    layers.append(make_shape_layer(1, "Canvas Texture Grid", [
        group("GridLineH1", [rect("H1", 320, 1, 0, 0, -80), fill(SLATE_LIGHT, 80)]),
        group("GridLineH2", [rect("H2", 320, 1, 0, 0, -40), fill(SLATE_LIGHT, 80)]),
        group("GridLineH3", [rect("H3", 320, 1, 0, 0, 0), fill(SLATE_LIGHT, 80)]),
        group("GridLineH4", [rect("H4", 320, 1, 0, 0, 40), fill(SLATE_LIGHT, 80)]),
        group("GridLineH5", [rect("H5", 320, 1, 0, 0, 80), fill(SLATE_LIGHT, 80)]),
        group("GridLineV1", [rect("V1", 1, 320, 0, -80, 0), fill(SLATE_LIGHT, 80)]),
        group("GridLineV2", [rect("V2", 1, 320, 0, -40, 0), fill(SLATE_LIGHT, 80)]),
        group("GridLineV3", [rect("V3", 1, 320, 0, 0, 0), fill(SLATE_LIGHT, 80)]),
        group("GridLineV4", [rect("V4", 1, 320, 0, 40, 0), fill(SLATE_LIGHT, 80)]),
        group("GridLineV5", [rect("V5", 1, 320, 0, 80, 0), fill(SLATE_LIGHT, 80)]),
        group("Frame", [rect("Fr", 320, 320, 20, 0, 0), stroke(RED_MAIN, 2)])
    ], transforms={"p": val([200, 200, 0])}))

    pts = [(-70, -60), (60, -50), (-30, 40), (80, 70), (0, -10)]
    for i, (px, py) in enumerate(pts):
        layers.append(make_shape_layer(2 + i, f"Micro Target Dot {i+1}", [
            group("TargetDot", [
                ellipse("Circ", 14, 14, px, py),
                fill(RED_MAIN, 100),
                stroke(WHITE, 2)
            ]),
            group("TargetRing", [
                ellipse("Ring", 28, 28, px, py),
                stroke(RED_LIGHT, 1.5, anim([
                    kf(0, [20]),
                    kf(30 * (i+1) % 180, [100]),
                    kf(180, [20])
                ]))
            ])
        ], transforms={"p": val([200, 200, 0])}))

    layers.append(make_shape_layer(8, "Laser Scan Beam", [
        group("LaserLine", [
            rect("LBeam", 320, 3, 0, 0, 0),
            fill(RED_MAIN, 100)
        ]),
        group("LaserGlow", [
            rect("LGlow", 320, 16, 0, 0, 0),
            fill(RED_MAIN, 30)
        ])
    ], transforms={
        "p": anim([
            kf(0, [200, 70, 0], [200, 330, 0]),
            kf(90, [200, 330, 0], [200, 70, 0]),
            kf(180, [200, 70, 0])
        ])
    }))

    lt["layers"] = layers
    return lt

# 4. BLOCKCHAIN BASE L2 SYNC ANIMATION
def generate_blockchain():
    lt = base_lottie("Base L2 ERC-721 Immutable Ledger", 400, 400, 60, 180)
    layers = []

    layers.append(make_shape_layer(1, "Chain Connector Lines", [
        group("Line1", [rect("CLine1", 70, 4, 2, -60, 0), fill(RED_MAIN, 80)]),
        group("Line2", [rect("CLine2", 70, 4, 2, 60, 0), fill(RED_MAIN, 80)])
    ], transforms={"p": val([200, 200, 0])}))

    layers.append(make_shape_layer(2, "Genesis Block", [
        group("BlockBox1", [
            rect("B1", 80, 80, 16, -110, 0),
            fill(WHITE, 95),
            stroke(RED_MAIN, 2)
        ]),
        group("HashText1", [
            rect("T1", 44, 6, 2, -110, -18),
            rect("T2", 52, 6, 2, -110, 0),
            rect("T3", 36, 6, 2, -110, 18),
            fill(RED_LIGHT, 85)
        ])
    ], transforms={
        "p": val([200, 200, 0]),
        "s": anim([
            kf(0, [100, 100, 100], [105, 105, 100]),
            kf(90, [105, 105, 100], [100, 100, 100]),
            kf(180, [100, 100, 100])
        ])
    }))

    layers.append(make_shape_layer(3, "Current L2 State Block", [
        group("BlockBox2", [
            rect("B2", 96, 96, 20, 0, 0),
            fill(WHITE, 100),
            stroke(RED_MAIN, 3)
        ]),
        group("BaseLogoCube", [
            rect("CoreCube", 36, 36, 8, 0, 0),
            fill(RED_MAIN, 100)
        ]),
        group("WhiteDot", [
            ellipse("Dot", 12, 12, 0, 0),
            fill(WHITE, 100)
        ])
    ], transforms={
        "p": val([200, 200, 0]),
        "r": anim([
            kf(0, [0], [4]),
            kf(90, [4], [-4]),
            kf(180, [-4], [0])
        ])
    }))

    layers.append(make_shape_layer(4, "Provenance Block", [
        group("BlockBox3", [
            rect("B3", 80, 80, 16, 110, 0),
            fill(WHITE, 95),
            stroke(SLATE_MID, 2)
        ]),
        group("HashText3", [
            rect("T4", 40, 6, 2, 110, -18),
            rect("T5", 48, 6, 2, 110, 0),
            rect("T6", 32, 6, 2, 110, 18),
            fill(SLATE_MID, 80)
        ])
    ], transforms={
        "p": val([200, 200, 0]),
        "s": anim([
            kf(0, [100, 100, 100], [96, 96, 100]),
            kf(90, [96, 96, 100], [100, 100, 100]),
            kf(180, [100, 100, 100])
        ])
    }))

    layers.append(make_shape_layer(5, "Ethereum L1 Anchor Ray", [
        group("Beam", [
            rect("AnchorBeam", 4, 90, 2, 0, -95),
            fill(RED_MAIN, anim([
                kf(0, [30]),
                kf(90, [95]),
                kf(180, [30])
            ]))
        ]),
        group("L1Pill", [
            rect("Pill", 90, 26, 999, 0, -150),
            fill(WHITE, 100),
            stroke(RED_MAIN, 1.5)
        ]),
        group("L1Dot", [
            ellipse("EthDot", 8, 8, -25, -150),
            fill(RED_MAIN, 100)
        ]),
        group("L1Bar", [
            rect("EthBar", 35, 6, 2, 5, -150),
            fill(RED_LIGHT, 90)
        ])
    ], transforms={"p": val([200, 200, 0])}))

    lt["layers"] = layers
    return lt

# 5. VERIFIED BADGE & CHECKMARK ANIMATION
def generate_verified_badge():
    lt = base_lottie("Verified Authentic Badge", 350, 350, 60, 180)
    layers = []

    layers.append(make_shape_layer(1, "Emerald Aura", [
        group("Halo", [
            ellipse("H", 240, 240),
            stroke(GREEN_OK, 2, anim([
                kf(0, [20]),
                kf(90, [75]),
                kf(180, [20])
            ]))
        ])
    ], transforms={
        "p": val([175, 175, 0]),
        "s": anim([
            kf(0, [92, 92, 100]),
            kf(90, [108, 108, 100]),
            kf(180, [92, 92, 100])
        ])
    }))

    layers.append(make_shape_layer(2, "Shield Container", [
        group("BasePill", [
            rect("MainCard", 180, 180, 40, 0, 0),
            fill(WHITE, 98),
            stroke(GREEN_OK, 3)
        ]),
        group("SubRing", [
            rect("SubCard", 150, 150, 32, 0, 0),
            stroke(GREEN_OK, 1.5, 60, dashes=[10, 10])
        ])
    ], transforms={
        "p": val([175, 175, 0]),
        "s": anim([
            kf(0, [100, 100, 100]),
            kf(90, [104, 104, 100]),
            kf(180, [100, 100, 100])
        ])
    }))

    layers.append(make_shape_layer(3, "Checkmark", [
        group("CheckLeftLeg", [
            rect("CLeg", 32, 10, 4, -20, 6),
            fill(GREEN_OK, 100)
        ]),
        group("CheckRightLeg", [
            rect("RLeg", 64, 10, 4, 16, -10),
            fill(GREEN_OK, 100)
        ])
    ], transforms={
        "p": val([175, 175, 0]),
        "r": val(-45),
        "s": anim([
            kf(0, [95, 95, 100]),
            kf(90, [105, 105, 100]),
            kf(180, [95, 95, 100])
        ])
    }))

    lt["layers"] = layers
    return lt

dest_dir = "/Applications/XAMPP/xamppfiles/htdocs/S2/Arthenthic/learn-arthentic/assets/lottie"
os.makedirs(dest_dir, exist_ok=True)

with open(os.path.join(dest_dir, "hero-security.json"), "w") as f:
    json.dump(generate_hero(), f, indent=2)

with open(os.path.join(dest_dir, "nfc-handshake.json"), "w") as f:
    json.dump(generate_nfc(), f, indent=2)

with open(os.path.join(dest_dir, "ai-microscan.json"), "w") as f:
    json.dump(generate_ai_scan(), f, indent=2)

with open(os.path.join(dest_dir, "blockchain-ledger.json"), "w") as f:
    json.dump(generate_blockchain(), f, indent=2)

with open(os.path.join(dest_dir, "verified-badge.json"), "w") as f:
    json.dump(generate_verified_badge(), f, indent=2)

print("Updated 5 Lottie animation files for rich light/dark compatibility!")
