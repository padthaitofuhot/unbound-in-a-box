#!/usr/bin/env bash
# REQUIRES: bash >= 4
set -o pipefail

bashversion="$(bash --version)"

if [ "${bashversion#*version 4}" == "${bashversion}" ]; then
    printf "%s requires GNU bash version 4+.\n" "${0}"
    exit 1
fi

if ! [ -f shipit/shipit.lib ]; then
    printf "%s requires shipit.lib.\n" "${0}"
    exit 1
fi

source shipit/shipit.lib
yay box/box.yml box
import_vars box
if [ -f conf.yml ]; then
    yay conf.yml
    import_vars conf
fi
if [ -f run.yml ]; then
    yay run.yml
    import_vars run
fi

# Verbosity: add a 'q' on the command line somewhere after $0 if you want it quiet.
if [ "${*#*q}" != "${*}" ]; then
    VERBOSE=false
else
    VERBOSE=true
fi

if [ "$(id -u)" -ne 0 ]; then
    die "A thousand pardons, but you must be root for this script to work."
    exit 1
fi

verbose "Ensuring directory tree for box is planted"
umask 077; if ! [ -d "${box_home}" ]; then
    mkdir -p "${box_home}"
    for dir in ${box_subdirs}; do
        mkdir -p "${box_home}/${dir}"
    done
fi; umask 022

# Render templates
verbose "Rendering templates"
umask 077; templater "box/${box_conf}" > "${box_home}/${box_conf}"; umask 022
templater box/Dockerfile > Dockerfile

# Do stuff on host
if [ -f box/hostconfig.sh ]; then
    verbose "Running host config"
    source box/hostconfig.sh
fi

# Buzzwordize
verbose "Building box image"
if ! docker build --force-rm -t ${box_name}:latest . 2>&1 | log; then
    die "An error occurred when building the image. Check shipit.log for info."
fi

verbose "Generating container run script in:"
o "${box_home}/run.sh"
umask 077; echo "docker run ${run_console} ${run_persist} -v ${box_home}:/opt ${run_volumes} ${run_capabilities} ${run_net} ${run_ports} ${run_logging} ${run_restart} --name ${box_name} ${box_name}" >${box_home}/run.sh
chmod +x ${box_home}/run.sh; umask 022

if [ -f box/boxconfig.sh ]; then
    verbose "Running box configuration"
    cp box/boxconfig.sh ${box_home}/boxconfig.sh
    chmod +x ${box_home}/boxconfig.sh

    docker run -it -v ${box_home}:/opt ${run_volumes} ${run_capabilities} ${run_net} ${run_ports} ${run_logging} --name ${box_name}_tmp --entrypoint /bin/ash ${box_name} -c /opt/boxconfig.sh 2>&1 | log
    err=$?
    if (( $err > 0 )); then
        die "$err An error occurred when running the boxconfig.sh. There may be additional info in shipit.log."
    fi

    # Have to reset ENTRYPOINT and CMD because Docker ¯\_(ツ)_/¯
    docker commit --change="'$(render_build_entrypoint)'" --change="'$(render_build_cmd)'" ${box_name}_tmp ${box_name}:latest 2>&1 | log
    err=$?
    if (( $err > 0 )); then
        die "$err An error occurred when committing ${box_name}_tmp back to ${box_name}:latest image. There may be additional info in shipit.log."
    fi

    docker rm ${box_name}_tmp 2>&1 | log
fi

verbose "Running container"
${box_home}/run.sh 2>&1 | log
err=$?
if (( $err > 0 )); then
    die "$err An error occurred when running the container."
fi

verbose "Great success! You have a new box."
