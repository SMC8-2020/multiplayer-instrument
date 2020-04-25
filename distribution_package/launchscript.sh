#!/bin/bash
path="$(pwd)/applications"
dependency="examplePd"
java -jar ./launcher/applauncher.jar "${path}" "${dependency}"
