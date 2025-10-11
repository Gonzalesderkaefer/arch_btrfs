#!/usr/bin/python3

import subprocess
import json
import os


def get_drives() -> [str]:
    # Capture the json output from lsblk
    layout_json = subprocess.check_output(["lsblk", "-p", "--json"])
    layout = json.loads(layout_json)

    # Store the drives in here
    drives = []

    # Get all the drives
    for drive in layout['blockdevices']:
        drives.append(drive['name'])

    return drives


def get_choice(choices):
    # Print choices
    choice_index = 1
    for choice in choices:
        print(f"[{choice_index}] {choice}")
        choice_index = choice_index + 1

    # Ask user for choice
    user_choice = input("What drive would you like to use? : ")

    # Validate choice
    while not user_choice.isnumeric() or int(user_choice) - 1 < 0 or int(user_choice) - 1 >= choices.__len__():
        user_choice = input("Invalid please try again: ")

    return choices[int(user_choice) - 1]


def new_gpt(drive):
    subprocess.run(["sgdisk", "-o", f"{drive}"])

def new_part(drive, size):
    return


# drives = []
# dr_i = 1
# for drive in layout['blockdevices']:
#     drives.append(drive['name'])
#     print(f"[{dr_i}] {drive['name']}")
#     dr_i = dr_i + 1
# 
# drive_choice = input("What drive would you like to use? : ")
# 
# while not drive_choice.isnumeric() or int(drive_choice) - 1 < 0 or int(drive_choice) - 1 >= drives.__len__():
#     drive_choice = input("Invalid please try again: ")
# 
# print(f"Your drive is: {drives[int(drive_choice) - 1]}")
# 
# # Store the root drive
# root_drive = drives[int(drive_choice) - 1]
# 
# # Format the drive
# 
# # New GPT
# #subprocess.run(["sgdisk", "-o", f"{root_drive}"])
# 
# # Boot partition
# #subprocess.run(["sgdisk", "-n1::+4096MiB", f"{root_drive}"]);
# #subprocess.run(["sgdisk", "-t1:EF00", f"{root_drive}"]);
# 
# # LUKS partition
# #subprocess.run(["sgdisk", "-n2::", f"{root_drive}"]);
# #subprocess.run(["sgdisk", "-t2:8300", f"{root_drive}]);
# 
# # Get layout of the root drive
# drive_layout_json = subprocess.check_output(["lsblk", "-p", "--json"])
# drive_layout = json.loads(drive_layout_json)
# 
# 
# # Variables for the partitions
# boot_part = ""
# luks_part = ""
# 
# for blk_device in drive_layout["blockdevices"]:
#     if blk_device["name"] == root_drive:
#         boot_part = blk_device["children"][0]["name"]
#         luks_part = blk_device["children"][1]["name"]
# 
# 
# subprocess.run([ "cryptsetup", "luksFormat" f"{root_part}"; ]);
