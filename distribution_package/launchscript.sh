#!/bin/bash
path="$(pwd)/applications"
dependency="examplePd"
javajdk="$(pwd)/javaruntime/adoptopenjdk-8.jdk/Contents/Home"
javart="${javajdk}/jre/bin/java"
"${javart}" -jar ./launcher/applauncher.jar "${path}" "${dependency}"
