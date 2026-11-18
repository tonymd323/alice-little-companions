"""Render original Wind over the Veranda Foley. Run with Python, NumPy and SciPy."""
from pathlib import Path
import wave

import numpy as np
from scipy.signal import butter, sosfilt

HERE = Path(__file__).resolve().parent
ASSETS = HERE.parents[3] / "apps/mobile/assets/wind/audio"
RATE = 32000
PEAKS = {
    "wind": .38, "scarf": .40, "basket": .54, "takeLeaf": .31,
    "seatLeaf": .46, "windowLight": .38, "footsteps": .53,
}


def time_axis(duration):
    return np.arange(round(duration * RATE)) / RATE


def noise(rng, t, low, high):
    band = butter(2, [low, high], fs=RATE, btype="bandpass", output="sos")
    sample = sosfilt(band, rng.normal(size=len(t)))
    return sample / max(.0001, np.sqrt(np.mean(sample ** 2)))


def envelope(t, points):
    at, levels = zip(*points)
    return np.interp(t, at, levels, left=0, right=0)


def attack(t, seconds=.004):
    return 1 - np.exp(-t / seconds)


def dab(track, sound, when):
    start = round(when * RATE)
    count = min(len(sound), len(track) - start)
    if count > 0:
        track[start:start + count] += sound[:count]


def resonances(t, modes, attack_time=.002):
    result = np.zeros(len(t))
    for frequency, gain, decay in modes:
        result += gain * np.sin(2 * np.pi * frequency * t) * np.exp(-t / decay)
    return result * attack(t, attack_time)


def brush(rng, duration, low, high, ridges):
    """A fingertip, cloth or plait crossing a row of irregular surfaces."""
    t = time_axis(duration)
    speed = ridges * (1 + .23 * np.sin(np.pi * t / duration))
    phase = np.cumsum(speed) / RATE
    grain = .26 + .74 * np.maximum(0, np.sin(2 * np.pi * phase)) ** 2.4
    shape = np.sin(np.pi * t / duration) ** 1.55
    return noise(rng, t, low, high) * grain * shape


def stereo(mono, pan=0):
    angle = (np.asarray(pan) + 1) * np.pi / 4
    return np.column_stack((mono * np.cos(angle), mono * np.sin(angle)))


def breeze(rng):
    t = time_axis(2.55)
    gust = envelope(t, [(0, 0), (.15, .11), (.48, .68), (.72, .96),
                         (1.08, .52), (1.43, .67), (1.75, .29), (2.51, 0)])
    body = noise(rng, t, 160, 1450)
    air = noise(rng, t, 1200, 5200)
    edge = np.sin(2 * np.pi * np.cumsum(695 + 67 * gust) / RATE)
    wind = gust * (.40 * body + (.12 + .11 * gust) * air + .023 * edge)
    for when, strength in [(.26, .09), (.52, .22), (.83, .15), (1.09, .1), (1.42, .18)]:
        dab(wind, strength * brush(rng, .15, 2300, 7600, 53), when)
    return stereo(wind, .33 - .56 * (t / t[-1]))


def cloth(rng):
    t = time_axis(.58)
    fabric = np.zeros(len(t))
    dab(fabric, .48 * brush(rng, .18, 420, 3350, 33), .015)
    dab(fabric, .28 * brush(rng, .22, 950, 4600, 22), .14)
    dab(fabric, .16 * brush(rng, .105, 800, 2300, 41), .375)
    cloth_press = resonances(t, [(185, .09, .042), (411, .032, .035)], .008)
    return stereo(fabric + cloth_press, -.13)


def bamboo_tap(rng, strength=1, tune=1):
    t = time_axis(.19)
    wood = resonances(t, [(324 * tune, .43, .039), (573 * tune, .22, .025),
                          (1227 * tune, .15, .014)])
    texture = .44 * noise(rng, t, 650, 4200) * np.exp(-t / .008) * attack(t, .0008)
    return strength * (wood + texture)


def basket(rng):
    t = time_axis(1.03)
    wicker = np.zeros(len(t))
    dab(wicker, .52 * brush(rng, .43, 150, 1850, 63), .035)
    dab(wicker, .30 * brush(rng, .32, 280, 2850, 51), .40)
    for when, volume, tone in [(0, .19, .89), (.17, .12, 1.12), (.32, .21, 1.04),
                                (.52, .15, .91), (.69, .56, .83), (.79, .15, 1.18)]:
        dab(wicker, bamboo_tap(rng, volume, tone), when)
    return stereo(wicker, -.20 + .34 * t / t[-1])


def paper(rng, duration, strength=1):
    t = time_axis(duration)
    material = .45 * brush(rng, duration, 1200, 6600, 34)
    for portion in [.10, .32, .61, .73]:
        ct = time_axis(.018)
        snap = noise(rng, ct, 1750, 7400) * np.exp(-ct / .0037) * attack(ct, .00065)
        dab(material, rng.uniform(.045, .14) * snap, portion * duration)
    return strength * material


def take_leaf(rng):
    return stereo(paper(rng, .26), -.07)


def seat_leaf(rng):
    t = time_axis(.335)
    sound = np.zeros(len(t))
    dab(sound, bamboo_tap(rng, .72, 1.84), .002)
    dab(sound, paper(rng, .14, .53), .018)
    dab(sound, bamboo_tap(rng, .15, 2.15), .079)
    return stereo(sound, .13)


def window_light(rng):
    t = time_axis(1.25)
    glass = resonances(t, [(869, .32, .21), (1302, .14, .27), (2150, .10, .14),
                           (3113, .044, .07)], .015)
    response = resonances(t, [(1159, .20, .30), (1733, .08, .22),
                              (2898, .045, .11)], .026)
    left = stereo(glass, .20)
    output = np.zeros_like(left)
    dab(output, left, .008)
    dab(output, stereo(response, .41), .116)
    dab(output, stereo(paper(rng, .21, .14), .14), .012)
    return output


def paw_step(rng, pitch, distance):
    t = time_axis(.27)
    pad = noise(rng, t, 110, 1150) * attack(t, .004) * np.exp(-t / .021)
    nail = noise(rng, t, 1200, 4100) * np.exp(-t / .007) * attack(t, .0013)
    wood = resonances(t, [(139 * pitch, .46, .082), (286 * pitch, .47, .063),
                          (518 * pitch, .29, .041), (872 * pitch, .13, .023)])
    return .48 * pad + (.085 + .115 * distance) * nail + wood


def approaching(rng):
    t = time_axis(2.19)
    crossing = np.zeros((len(t), 2))
    # Pairs of light paws compress as the fox approaches the wind-sheltered sill.
    for i, when in enumerate((.025, .185, .45, .614, .88, 1.035, 1.275, 1.41, 1.63, 1.754)):
        near = i / 9
        rail = 1.07 if i % 2 == 0 else .94
        step = paw_step(rng, rail * rng.uniform(.96, 1.04), near)
        volume = (.21 + .70 * near ** 1.32) * (1 if i % 2 == 0 else .86)
        dab(crossing, stereo(volume * step, .42 - .52 * near), when)
    return crossing


def write_wav(path, samples):
    with wave.open(str(path), "wb") as sound:
        sound.setparams((2, 2, RATE, 0, "NONE", "not compressed"))
        sound.writeframes(np.round(np.clip(samples, -1, 1) * 32767).astype("<i2").tobytes())


def render():
    ASSETS.mkdir(parents=True, exist_ok=True)
    generators = {
        "wind": breeze, "scarf": cloth, "basket": basket, "takeLeaf": take_leaf,
        "seatLeaf": seat_leaf, "windowLight": window_light, "footsteps": approaching,
    }
    sounds = {}
    for i, (name, generator) in enumerate(generators.items()):
        raw = generator(np.random.default_rng(251118 + i))
        t = np.arange(len(raw)) / RATE
        edge = np.minimum(1, np.minimum(t / .002, (t[-1] - t) / .022))
        raw *= edge[:, None]
        raw *= PEAKS[name] / np.max(np.abs(raw))
        write_wav(ASSETS / f"{name}.wav", raw)
        sounds[name] = raw

    cues = [(0, "wind"), (.86, "scarf"), (2.69, "basket"), (3.94, "takeLeaf"),
            (4.25, "seatLeaf"), (4.76, "takeLeaf"), (5.07, "seatLeaf"),
            (5.19, "windowLight"), (6.66, "footsteps")]
    mix = np.zeros((round(9.05 * RATE), 2))
    for when, name in cues:
        dab(mix, sounds[name], when)
    write_wav(HERE / "audition.wav", mix)


if __name__ == "__main__":
    render()
