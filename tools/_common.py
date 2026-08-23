"""Shared helper for building JAMB question JSON files.

Each subject generator imports `build` and passes a compact question list:
    {"t": question text, "o": [4 options], "a": correct_index (0-3),
     "e": explanation, "d": difficulty (1=easy, 2=medium, 3=hard)}
"""
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(ROOT, "assets", "questions")


def build(course_id, course_name, questions):
    out = []
    for i, q in enumerate(questions, 1):
        assert len(q["o"]) == 4, f"{course_id} #{i}: must have 4 options"
        assert 0 <= q["a"] <= 3, f"{course_id} #{i}: bad correct_index"
        # Rotate options deterministically so the correct answer is not always
        # in the same position in the source data.
        opts = list(q["o"])
        ci = q["a"]
        shift = i % 4
        if shift:
            opts = opts[shift:] + opts[:shift]
            ci = (ci - shift) % 4
        out.append({
            "id": f"{course_id}_{i:03d}",
            "text": q["t"],
            "options": opts,
            "correct_index": ci,
            "explanation": q.get("e", ""),
            "difficulty": q.get("d", 1),
        })
    data = {
        "course_id": course_id,
        "course_name": course_name,
        "version": "1.0.0",
        "questions": out,
    }
    os.makedirs(OUT_DIR, exist_ok=True)
    path = os.path.join(OUT_DIR, f"{course_id}.json")
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    print(f"{course_id} ({course_name}): {len(out)} questions -> {path}")


def tally():
    """Print a summary of all generated question files."""
    import glob
    for path in sorted(glob.glob(os.path.join(OUT_DIR, "*.json"))):
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        print(f"{os.path.basename(path):16s} {len(data['questions']):4d} questions")
