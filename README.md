# Vimba SDK ROS 2 vendor package

This repository contains a ROS 2 package which simplifies the inclusion of
the Vimba SDK in any ROS 2 project.

The package includes a CMake find script which can be used to import a binary
copy of the library and easily link it to existing targets.

## SDK Installation

By default, the script will look for a Vimba SDK installation under `/opt/Vimba_4.2`.

You can customize this location by setting variable `VIMBA_DIR` in your
shell environment, or by passing it directly to CMake, e.g.:

```sh
# Customize via shell variable, or...
export VIMBA_DIR=/path/to/Vimba_x.y

# Specify variable as a CMake argument
colcon build ... --cmake-args -DVIMBA_DIR=/path/to/Vimba_x.y
```
