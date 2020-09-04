#!/bin/bash
set -e

# setup ros2 environment
. "${ROS2_WS}/install/local_setup.bash"

exec "$@"
