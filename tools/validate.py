import json
import glob
import os
from collections import Counter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
QDIR = os.path.join(ROOT, "assets", "questions")

total = 0
for path in sorted(glob.glob(os.path.join(QDIR, "*.json"))):
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
    qs = data["questions"]
    cid = data.get("course_id", os.path.basename(path))
    n = len(qs)
    total += n
    problems = []
    ids = set()
    for q in qs:
        if len(q.get("options", [])) != 4:
            problems.append(f"{q.get('id')}: options != 4")
        if not (0 <= q.get("correct_index", -1) <= 3):
            problems.append(f"{q.get('id')}: bad correct_index")
        if not q.get("text"):
            problems.append(f"{q.get('id')}: empty text")
        if q["id"] in ids:
            problems.append(f"{q.get('id')}: duplicate id")
        ids.add(q["id"])
        for o in q.get("options", []):
            if not o.strip():
                problems.append(f"{q.get('id')}: empty option")
    dist = Counter(q["correct_index"] for q in qs)
    status = "OK" if (n == 200 and not problems) else "PROBLEM"
    print(f"{cid:8s} {n:4d} questions  dist={dict(sorted(dist.items()))}  {status}")
    for p in problems[:5]:
        print("    !!", p)

print(f"\nTOTAL questions: {total}")
