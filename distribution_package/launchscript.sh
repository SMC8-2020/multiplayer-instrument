#!/bin/bash
path="$(pwd)/applications"
dependency="instrument_simulation_v2"
javart="$(pwd)/javaruntime/jre/bin/java"
sudo "${javart}" -jar ./launcher/applauncher.jar "${path}" "${dependency}"
