#!/usr/bin/env python3
"""Report real (testable) line coverage from coverage/lcov.info.

Excludes generated + bootstrap files that cannot be meaningfully unit-tested,
matching the team's 100% house-rule exception. Pass --list to print the worst
uncovered real files; pass a path substring to scope the rollup to one feature.
"""
import re, sys

EXCLUDE = re.compile(
    r'\.(g|gr|freezed|config|mocks)\.dart$'
    r'|app_localizations'
    r'|/generated/'
    r'|injectable\.dart$'
    r'|/main\.dart$'
    r'|firebase_options\.dart$'
)

def load(path='coverage/lcov.info'):
    files=[]; sf=None; lf=lh=0; miss=[]
    with open(path) as f:
        for line in f:
            line=line.rstrip('\n')
            if line.startswith('SF:'): sf=line[3:]; lf=lh=0; miss=[]
            elif line.startswith('DA:'):
                num,cnt=line[3:].split(',')[:2]
                if cnt=='0': miss.append(int(num))
            elif line.startswith('LF:'): lf=int(line[3:])
            elif line.startswith('LH:'): lh=int(line[3:])
            elif line=='end_of_record': files.append((sf,lf,lh,miss))
    return files

def main():
    scope=None; do_list=False
    for a in sys.argv[1:]:
        if a=='--list': do_list=True
        else: scope=a
    files=load()
    real=[f for f in files if not EXCLUDE.search(f[0])]
    if scope: real=[f for f in real if scope in f[0]]
    lf=sum(f[1] for f in real); lh=sum(f[2] for f in real)
    pct = (lh*100/lf) if lf else 100.0
    print(f"REAL coverage{' ['+scope+']' if scope else ''}: "
          f"{lh}/{lf} = {pct:.1f}%  ({lf-lh} missing, {len(real)} files)")
    if do_list:
        worst=sorted(real,key=lambda f:f[2]-f[1])
        print("\nWorst uncovered files:")
        for sf,l,h,_ in worst[:40]:
            if l-h>0:
                print(f"  {l-h:5d} miss  {h:4d}/{l:4d}  {sf}")
    zero=[f for f in real if f[2]==0 and f[1]>0]
    print(f"\n{len(zero)} real files at 0% ({sum(f[1] for f in zero)} lines)")

if __name__=='__main__': main()
