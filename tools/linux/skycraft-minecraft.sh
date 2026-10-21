#!/usr/bin/env bash
# Starts the native Linux Minecraft for SkyCraft, then quits it when Skyrim closes.
# Use as a Steam launch option for Skyrim:   /path/to/skycraft-minecraft.sh %command%
# (or run it by hand in a terminal before/after starting Skyrim).
#
# Needs a Prism Launcher instance with Minecraft 26.3, Fabric, Fabric API and the SkyCraft jar
# (fabric/build/libs/skycraft-fabric-*.jar), Java 25, and your own Microsoft login in Prism.
#
# Settings (environment variables):
#   SKYCRAFT_INSTANCE  Prism instance name       (default: SkyCraft)
#   SKYCRAFT_PRISM     Prism command             (default: prismlauncher)
#   SKYCRAFT_LINK      link file Skyrim creates  (default: /dev/shm/skycraft_v1)
set -u

instance="${SKYCRAFT_INSTANCE:-SkyCraft}"
prism="${SKYCRAFT_PRISM:-prismlauncher}"
link="${SKYCRAFT_LINK:-/dev/shm/skycraft_v1}"

# Hidden window; point the mod at the link file if it isn't the default.
export JAVA_TOOL_OPTIONS="${JAVA_TOOL_OPTIONS:-} -Dskycraft.startHidden=true -Dskycraft.linkFile=${link}"

watch_skyrim() {
	# Wait for Skyrim to appear, then for it to go away, then close Minecraft.
	until pgrep -f SkyrimSE.exe >/dev/null; do sleep 2; done
	while pgrep -f SkyrimSE.exe >/dev/null; do sleep 5; done
	pkill -f "dev.skycraft" 2>/dev/null || pkill -f "skycraft-fabric" 2>/dev/null
}

"$prism" --launch "$instance" &
watch_skyrim &

# As a Steam launch option, %command% follows: run Skyrim itself.
if [ "$#" -gt 0 ]; then
	exec "$@"
fi
wait
