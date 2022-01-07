import os
from pathlib import Path

instance_type = "nowalls"
files = os.listdir(instance_type)
nb_rd_exec = 5
files.sort()

c = "julia --project=. src/run_find_layout.jl"
for f in files:
    for d in [1.5, 2.0]:
        for p in ["nobackback", "backback"]:
            for m in ["exact", "placeclosecorner", "placerandomly"]:
                instance = Path("instances", instance_type, f)    
                cr = c + " --instance " + str(instance)
                cr += " --verbose"
                cr += " --mindist " + str(d)
                if p == "backback":
                    cr += " --backback"
                cr += " --method " + m
                if m == "placerandomly":
                    for s in range(1,nb_rd_exec+1):
                        print(cr + " --seed " + str(s))
                else:
                    print(cr)