import netCDF4 as nc
import inspect
import numpy as np


def load_nc_file(filepath: str) -> nc.Dataset:
    return nc.Dataset(filepath, "r")


def check_nc_file_structure(nc_file: nc.Dataset) -> bool:
    # for info in inspect.getmembers(nc_file):
    #     print(info)

    time_data = nc_file.variables["time"]
    print(time_data[0], time_data[1], time_data[-2], time_data[-1])
    frame_data = nc_file.dimensions["frame"]
    velocities = nc_file.variables["velocities"]
    print(velocities[0], velocities[1], velocities[-2], velocities[-1])
    # print(velocities)
    return "velocity" in nc_file.variables and "time" in nc_file.variables


def inspect_nc_file(nc_file: nc.Dataset) -> None:
    for info in inspect.getmembers(nc_file):
        print(info)


def compare_nc_files(nc_file1: nc.Dataset, nc_file2: nc.Dataset) -> bool:
    velocities1 = nc_file1.variables["velocities"]
    velocities2 = nc_file2.variables["velocities"]
    mean_abs_diff = compute_mean_abs_diff_velocities(velocities1, velocities2)
    print("mean abs diff of velocities:", mean_abs_diff)
    time_data1 = nc_file1.variables["time"]
    time_data2 = nc_file2.variables["time"]
    compare_time_data(time_data1, time_data2)
    # print("mean abs diff of time data:", mean_abs_diff_time)


def compute_mean_abs_diff_velocities(
    velocities1: nc._netCDF4.Variable, velocities2: nc._netCDF4.Variable
) -> float:
    diff = (velocities1[:] - velocities2[:]) / velocities1[:]
    print(velocities1[0][0], velocities2[0][0], diff[0][0])
    print(velocities1[1][0], velocities2[1][0], diff[1][0])
    print(velocities1[2][0], velocities2[2][0], diff[2][0])
    print(velocities1[-1][0], velocities2[-1][0], diff[-1][0])
    return np.mean(np.abs(diff))


def compare_time_data(
    time_data1: nc._netCDF4.Variable, time_data2: nc._netCDF4.Variable
) -> float:
    print(
        time_data1[0],
        time_data1[1],
        time_data1[2],
        time_data1[-1],
        time_data2[0],
        time_data2[1],
        time_data2[2],
        time_data2[-1],
    )


if __name__ == "__main__":
    import sys
    from argparse import ArgumentParser

    arg_parser = ArgumentParser()
    arg_parser.add_argument(
        "input_file", type=str, help="Path to the netCDF file to check"
    )
    arg_parser.add_argument(
        "-o",
        "--output",
        type=str,
        help="Path to the output file to save the results",
    )

    arg_parser.add_argument(
        "-m", "--mode", type=str, help="Mode to run the script in"
    )

    arg_parser.add_argument(
        "-c",
        "--compare",
        type=str,
        help="Path to the netCDF file to compare the input file with",
    )

    args = arg_parser.parse_args()
    filepath = args.input_file
    mode = args.mode
    filepath2 = args.compare
    nc_file = load_nc_file(filepath)
    if mode == "compare":
        nc_file2 = load_nc_file(filepath2)
        compare_nc_files(nc_file, nc_file2)
    elif mode == "inspect":
        inspect_nc_file(nc_file)
    else:
        print(check_nc_file_structure(nc_file))
