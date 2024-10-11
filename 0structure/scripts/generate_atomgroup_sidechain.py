#! /usr/bin/env python3
# from kota ohta

import argparse
import os


def gen_data(file_name):
    f = open(file_name, "r")
    for line in f:
        if "#" in line:
            continue
        l = line.split()
        atom_num, atom = int(l[0]), l[1]
        res_num, resid = int(l[2]), l[3]
        yield (res_num, resid, atom_num, atom)
    f.close()
    ##Atom Name  #Res Name  #Mol Type   Charge     Mass GBradius El
    # 1 HH31     1 ACE      1 HC     0.1123   1.0080   1.3000  H


def resid_group(file_name):
    prev_resid = (-1, None)
    resid_atoms = []
    for atom_data in gen_data(file_name):
        res_number, res_name, atom_number, atom_name = atom_data
        if prev_resid[0] < 0:
            prev_resid = (res_number, res_name)
            resid_atoms.append((atom_number, atom_name))
        else:
            if res_number == prev_resid[0]:
                resid_atoms.append((atom_number, atom_name))
            else:
                yield prev_resid, resid_atoms
                resid_atoms.clear()
                resid_atoms.append((atom_number, atom_name))
                prev_resid = (res_number, res_name)
    if len(resid_atoms) != 0:
        yield prev_resid, resid_atoms


main_chain_atoms = ["N", "H", "CA", "HA", "C", "O"]


def separate_group(atoms):
    main, side = [], []
    for atom_number, atom_name in atoms:
        if atom_name in main_chain_atoms:
            main.append(atom_number)
        else:
            side.append(atom_number)
    return main, side


def output_range(first_number, last_number):
    if first_number == last_number:
        atom_range = "{0}".format(first_number)
    else:
        atom_range = "{0}-{1}".format(first_number, last_number)
    return atom_range


def list_range(atomlist):
    first, last = -1, -1
    for number in atomlist:
        if first < 0:
            first, last = number, number
        else:
            if number - last == 1:
                last = number
            else:
                atom_range = output_range(first, last)
                first, last = number, number
                yield atom_range
    atom_range = output_range(first, last)
    yield atom_range


def output_group(groupname, atomlist, filename):
    group_line = f"[{groupname}]\n"
    atoms_line = " ".join(list_range(atomlist)) + "\n"
    with open(file=filename, mode="a") as f:
        f.writelines([group_line, atoms_line])


usage = """USAGE : ./gen_atomgroup.py [cpptraj atominfo file] [No separate residue number]

Residue number in [No separate residue number] are not separated in side chian and main chain.
This option is useful if your system has ligand like "ACE" or "NME".

If the residue numbers of your ligand residue are 1, 104, and 105, Type

$ ./atomgroup.py atominfo 1 104 105

Then you can get what you want.
"""


def main():
    parser = argparse.ArgumentParser(description=usage)
    parser.add_argument(
        "--sidechain-filename", dest="sidechain_filename", required=True
    )
    parser.add_argument("--residue-filename", dest="residue_filename", required=True)
    parser.add_argument("--atominfo-filename", dest="atominfo_filename", required=True)
    parser.add_argument(
        "--no-separated-residues",
        dest="no_separated_residue_ids",
        required=False,
        nargs="+",
        type=int,
        default=[],
    )

    args = parser.parse_args()

    # Remove exist residue and sidechain files
    for file in [args.residue_filename, args.sidechain_filename]:
        if os.path.exists(file): os.remove(file)

    for resid_atom_data in resid_group(args.atominfo_filename):
        resinfo, atoms = resid_atom_data
        group_name = "{0:0>5}_{1}".format(resinfo[0], resinfo[1])
        atom_numbers = [num for num, _ in atoms]

        # Residue
        output_group(group_name, atom_numbers, args.residue_filename)

        # Side and main chain
        if resinfo[0] in args.no_separated_residue_ids:
            output_group(group_name, atom_numbers, args.sidechain_filename)
        else:
            main_chain, side_chain = separate_group(atoms)
            output_group(group_name + "-main", main_chain, args.sidechain_filename)
            output_group(group_name + "-side", side_chain, args.sidechain_filename)


if __name__ == "__main__":
    main()