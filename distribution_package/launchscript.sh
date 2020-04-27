#!/bin/bash
path="$(pwd)/applications"
dependency="examplePd"
javart="$(pwd)/javaruntime/jre/bin/java"
"${javart}" -jar ./launcher/applauncher.jar "\"${path}"\" "${dependency}"
